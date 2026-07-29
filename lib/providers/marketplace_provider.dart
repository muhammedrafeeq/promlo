import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prompt_model.dart';
import '../models/collection_model.dart';

enum SortOrder { trending, mostLiked, mostViewed, newest }

extension SortOrderExtension on SortOrder {
  String get label {
    switch (this) {
      case SortOrder.trending:   return 'Trending';
      case SortOrder.mostLiked:  return 'Most Liked';
      case SortOrder.mostViewed: return 'Most Viewed';
      case SortOrder.newest:     return 'Newest';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOrder.trending:   return Icons.trending_up_rounded;
      case SortOrder.mostLiked:  return Icons.favorite_rounded;
      case SortOrder.mostViewed: return Icons.visibility_rounded;
      case SortOrder.newest:     return Icons.schedule_rounded;
    }
  }
}

class MarketplaceProvider extends ChangeNotifier {
  List<PromptItem> _prompts = [];
  int _activeTabIndex = 0;
  int _previousTabIndex = 0;
  Category _activeCategory = Category.all;
  ModelType? _activeModel;
  List<Collection> _collections = [Collection(id: 'default', name: 'Saved', emoji: '❤️')];
  bool _isDarkMode = false;
  PromptItem? _selectedPromptDetails;
  String _searchQuery = '';
  bool _isLoading = true;
  SortOrder _sortOrder = SortOrder.trending;
  final List<String> _recentSearches = [];
  bool _isOnline = true;
  String? _loadError;

  static const _keyCollections   = 'collections_v2';
  static const _keyDarkMode      = 'dark_mode';
  static const _keyRecentSearches = 'recent_searches';

  MarketplaceProvider() {
    _init();
  }

  // ── Getters ──────────────────────────────────────────────────

  List<PromptItem> get prompts            => List.unmodifiable(_prompts);
  int              get activeTabIndex     => _activeTabIndex;
  int              get previousTabIndex   => _previousTabIndex;
  bool             get isNavigatingRight  => _activeTabIndex >= _previousTabIndex;
  Category         get activeCategory     => _activeCategory;
  ModelType?       get activeModel        => _activeModel;
  bool             get isDarkMode         => _isDarkMode;
  PromptItem?      get selectedPromptDetails => _selectedPromptDetails;
  String           get searchQuery        => _searchQuery;
  bool             get isLoading          => _isLoading;
  SortOrder        get sortOrder          => _sortOrder;
  List<String>     get recentSearches     => List.unmodifiable(_recentSearches);
  bool             get isOnline           => _isOnline;
  String?          get loadError          => _loadError;
  List<Collection> get collections        => List.unmodifiable(_collections);

  // Backward-compat: all saved prompt IDs across every collection
  Set<String> get savedIds {
    final ids = <String>{};
    for (final c in _collections) {
      ids.addAll(c.promptIds);
    }
    return ids;
  }

  bool isInCollection(String promptId, String collectionId) =>
      _collections.any((c) => c.id == collectionId && c.promptIds.contains(promptId));

  List<Collection> collectionsContaining(String promptId) =>
      _collections.where((c) => c.promptIds.contains(promptId)).toList();

  // ── Init ─────────────────────────────────────────────────────

  Future<void> _init() async {
    await _loadPrefs();
    _listenConnectivity();
    await _loadPrompts();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyCollections);
      if (raw != null) {
        _collections = Collection.decodeList(raw);
      } else {
        // Seed one default collection
        _collections = [
          Collection(id: 'default', name: 'Saved', emoji: '❤️'),
        ];
      }
      _isDarkMode = prefs.getBool(_keyDarkMode) ?? false;
      final searches = prefs.getStringList(_keyRecentSearches) ?? [];
      _recentSearches.addAll(searches);
      notifyListeners();
    } catch (_) {
      _collections = [Collection(id: 'default', name: 'Saved', emoji: '❤️')];
      notifyListeners();
    }
  }

  Future<void> _savePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCollections, Collection.encodeList(_collections));
      await prefs.setBool(_keyDarkMode, _isDarkMode);
      await prefs.setStringList(_keyRecentSearches, _recentSearches);
    } catch (_) {}
  }

  void _listenConnectivity() {
    Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
      }
    });
    Connectivity().checkConnectivity().then((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      notifyListeners();
    });
  }

  // ── Prompts ──────────────────────────────────────────────────

  Future<void> _loadPrompts() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();
    try {
      final rows = await Supabase.instance.client
          .from('prompts')
          .select()
          .order('created_at', ascending: false);
      _prompts = rows
          .map((r) { try { return _rowToPrompt(r); } catch (_) { return null; } })
          .whereType<PromptItem>()
          .toList();
    } catch (e) {
      _loadError = e.toString();
      _prompts = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _loadPrompts();

  static PromptItem _rowToPrompt(dynamic row) {
    final map = row as Map<String, dynamic>;
    Category category;
    switch ((map['category'] ?? '').toString().toLowerCase()) {
      case 'video':   category = Category.video; break;
      case 'web':     category = Category.web; break;
      case 'code':    category = Category.code; break;
      case 'writing': category = Category.writing; break;
      default:        category = Category.image; break;
    }
    ModelType model;
    switch ((map['model'] ?? '').toString()) {
      case 'geminiPro':    model = ModelType.geminiPro; break;
      case 'nano':         model = ModelType.nano; break;
      case 'claude35':     model = ModelType.claude35; break;
      case 'midjourneyV6': model = ModelType.midjourneyV6; break;
      case 'flux1Pro':     model = ModelType.flux1Pro; break;
      default:             model = ModelType.gpt4; break;
    }
    final rawTags = map['tags'];
    final tags = rawTags is List ? rawTags.map((t) => t.toString()).toList() : <String>[];
    return PromptItem(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      fullPrompt: map['full_prompt']?.toString() ?? '',
      category: category,
      model: model,
      likes: (map['likes'] as num?)?.toInt() ?? 0,
      viewsCount: map['views_count']?.toString() ?? '0',
      runsCount: map['runs_count']?.toString() ?? '0',
      isTrendingNow: map['is_trending_now'] == true,
      isFeatured: map['is_featured'] == true,
      tags: tags,
      imageUrl: map['image_url']?.toString(),
      price: map['price']?.toString(),
      creator: Creator(
        name: map['creator_name']?.toString() ?? 'Unknown',
        avatar: map['creator_avatar']?.toString() ?? '',
      ),
    );
  }

  List<PromptItem> get sortedPrompts {
    final list = List<PromptItem>.from(_prompts);
    switch (_sortOrder) {
      case SortOrder.trending:
        list.sort((a, b) {
          if (a.isTrendingNow && !b.isTrendingNow) return -1;
          if (!a.isTrendingNow && b.isTrendingNow) return 1;
          return b.likes.compareTo(a.likes);
        });
      case SortOrder.mostLiked:
        list.sort((a, b) => b.likes.compareTo(a.likes));
      case SortOrder.mostViewed:
        list.sort((a, b) => _parseCount(b.viewsCount).compareTo(_parseCount(a.viewsCount)));
      case SortOrder.newest:
        return list.reversed.toList();
    }
    return list;
  }

  List<String> get allTags {
    final tags = <String>{};
    for (final p in _prompts) { tags.addAll(p.tags); }
    return tags.toList()..sort();
  }

  int _parseCount(String count) {
    final s = count.toLowerCase().replaceAll(',', '').trim();
    if (s.endsWith('k')) return ((double.tryParse(s.replaceAll('k', '')) ?? 0) * 1000).toInt();
    if (s.endsWith('m')) return ((double.tryParse(s.replaceAll('m', '')) ?? 0) * 1000000).toInt();
    return int.tryParse(s) ?? 0;
  }

  // ── Collections CRUD ─────────────────────────────────────────

  void createCollection(String name, String emoji) {
    final id = '${name.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
    _collections.add(Collection(id: id, name: name, emoji: emoji));
    notifyListeners();
    _savePrefs();
  }

  void deleteCollection(String collectionId) {
    _collections.removeWhere((c) => c.id == collectionId);
    notifyListeners();
    _savePrefs();
  }

  void renameCollection(String collectionId, String newName, String newEmoji) {
    final i = _collections.indexWhere((c) => c.id == collectionId);
    if (i == -1) return;
    _collections[i] = _collections[i].copyWith(name: newName, emoji: newEmoji);
    notifyListeners();
    _savePrefs();
  }

  void addToCollection(String promptId, String collectionId) {
    final i = _collections.indexWhere((c) => c.id == collectionId);
    if (i == -1) return;
    if (!_collections[i].promptIds.contains(promptId)) {
      final updated = List<String>.from(_collections[i].promptIds)..add(promptId);
      _collections[i] = _collections[i].copyWith(promptIds: updated);
      notifyListeners();
      _savePrefs();
      _adjustBookmarks(promptId, 1);
    }
  }

  void removeFromCollection(String promptId, String collectionId) {
    final i = _collections.indexWhere((c) => c.id == collectionId);
    if (i == -1) return;
    final updated = List<String>.from(_collections[i].promptIds)..remove(promptId);
    _collections[i] = _collections[i].copyWith(promptIds: updated);
    notifyListeners();
    _savePrefs();
    _adjustBookmarks(promptId, -1);
  }

  void toggleInCollection(String promptId, String collectionId) {
    if (isInCollection(promptId, collectionId)) {
      removeFromCollection(promptId, collectionId);
    } else {
      addToCollection(promptId, collectionId);
    }
  }

  Future<void> _adjustBookmarks(String promptId, int delta) async {
    try {
      final row = await Supabase.instance.client
          .from('prompts')
          .select('bookmarks_count')
          .eq('id', promptId)
          .single();
      final current = (row['bookmarks_count'] as num?)?.toInt() ?? 0;
      final next = (current + delta).clamp(0, 999999);
      await Supabase.instance.client
          .from('prompts')
          .update({'bookmarks_count': next})
          .eq('id', promptId);
    } catch (_) {}
  }

  // Keep toggleSave pointing to default collection for backward compat
  void toggleSave(String promptId) => toggleInCollection(promptId, 'default');

  void clearAllSaved() {
    _collections = _collections.map((c) => c.copyWith(promptIds: [])).toList();
    notifyListeners();
    _savePrefs();
  }

  // ── Navigation ───────────────────────────────────────────────

  void setActiveTab(int index) {
    _previousTabIndex = _activeTabIndex;
    _activeTabIndex = index;
    _selectedPromptDetails = null;
    notifyListeners();
  }

  void setActiveCategory(Category category) { _activeCategory = category; notifyListeners(); }
  void setActiveModel(ModelType? model)      { _activeModel = model; notifyListeners(); }
  void setSearchQuery(String query)          { _searchQuery = query; notifyListeners(); }
  void setSortOrder(SortOrder order)         { _sortOrder = order; notifyListeners(); }

  void addRecentSearch(String query) {
    if (query.trim().isEmpty) return;
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) _recentSearches.removeLast();
    notifyListeners();
    _savePrefs();
  }

  void removeRecentSearch(String query) { _recentSearches.remove(query); notifyListeners(); _savePrefs(); }
  void clearRecentSearches()            { _recentSearches.clear(); notifyListeners(); _savePrefs(); }

  void toggleTheme() { _isDarkMode = !_isDarkMode; notifyListeners(); _savePrefs(); }

  void addPrompt(PromptItem p)    { _prompts.insert(0, p); notifyListeners(); }
  void openPromptDetails(PromptItem p) { _selectedPromptDetails = p; notifyListeners(); }
  void closePromptDetails()            { _selectedPromptDetails = null; notifyListeners(); }

  void updatePromptCounts(String id, {int? likes, String? viewsCount, int? bookmarksCount}) {
    final i = _prompts.indexWhere((p) => p.id == id);
    if (i == -1) return;
    final p = _prompts[i];
    _prompts[i] = PromptItem(
      id: p.id,
      title: p.title,
      description: p.description,
      fullPrompt: p.fullPrompt,
      category: p.category,
      model: p.model,
      likes: likes ?? p.likes,
      likesFormatted: p.likesFormatted,
      viewsCount: viewsCount ?? p.viewsCount,
      runsCount: p.runsCount,
      usageCount: p.usageCount,
      matchScore: p.matchScore,
      isFeatured: p.isFeatured,
      isTrendingNow: p.isTrendingNow,
      tags: p.tags,
      imageUrl: p.imageUrl,
      creator: p.creator,
      parameters: p.parameters,
      codeSnippet: p.codeSnippet,
      avatars: p.avatars,
      howToUse: p.howToUse,
      variants: p.variants,
      bentoSpan: p.bentoSpan,
      price: p.price,
      rating: p.rating,
      reviewCount: p.reviewCount,
    );
    if (_selectedPromptDetails?.id == id) {
      _selectedPromptDetails = _prompts[i];
    }
    notifyListeners();
  }

}
