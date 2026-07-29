enum Category { all, video, image, web, code, writing }

extension CategoryExtension on Category {
  String get displayName {
    switch (this) {
      case Category.all:
        return 'All';
      case Category.video:
        return 'Video';
      case Category.image:
        return 'Image';
      case Category.web:
        return 'Web';
      case Category.code:
        return 'Code';
      case Category.writing:
        return 'Writing';
    }
  }
}

enum ModelType { gpt4, geminiPro, nano, claude35, midjourneyV6, flux1Pro }

extension ModelTypeExtension on ModelType {
  String get displayName {
    switch (this) {
      case ModelType.gpt4:
        return 'GPT-4';
      case ModelType.geminiPro:
        return 'Gemini Pro';
      case ModelType.nano:
        return 'Nano';
      case ModelType.claude35:
        return 'Claude 3.5';
      case ModelType.midjourneyV6:
        return 'Midjourney v6';
      case ModelType.flux1Pro:
        return 'Flux.1 Pro';
    }
  }
}

class Creator {
  final String name;
  final String avatar;
  final String? role;

  const Creator({
    required this.name,
    required this.avatar,
    this.role,
  });
}

class PromptParameters {
  final double temperature;
  final double topP;
  final String? systemPrompt;
  final String? negativePrompt;
  final String aspectRatio;
  final int samplingSteps;
  final double guidanceScale;
  final String seed;
  final bool safetyFilter;

  const PromptParameters({
    this.temperature = 0.7,
    this.topP = 0.9,
    this.systemPrompt,
    this.negativePrompt,
    this.aspectRatio = '16:9',
    this.samplingSteps = 50,
    this.guidanceScale = 3.5,
    this.seed = '842910385',
    this.safetyFilter = true,
  });
}

class PromptVariant {
  final String title;
  final String imageUrl;

  const PromptVariant({
    required this.title,
    required this.imageUrl,
  });
}

enum BentoSpan { large, medium, code, writing, visual, standard }

class PromptItem {
  final String id;
  final String title;
  final String description;
  final String fullPrompt;
  final Category category;
  final ModelType model;
  final int likes;
  final String? likesFormatted;
  final String viewsCount;
  final String runsCount;
  final String? usageCount;
  final String? matchScore;
  final bool isFeatured;
  final bool isTrendingNow;
  final List<String> tags;
  final String? imageUrl;
  final Creator creator;
  final PromptParameters parameters;
  final String? codeSnippet;
  final List<String>? avatars;
  final List<String> howToUse;
  final List<PromptVariant> variants;
  final BentoSpan bentoSpan;
  final String? price;
  final double rating;
  final int reviewCount;

  PromptItem({
    required this.id,
    required this.title,
    required this.description,
    required this.fullPrompt,
    required this.category,
    required this.model,
    required this.likes,
    this.likesFormatted,
    this.viewsCount = '12.4k',
    this.runsCount = '3.2k',
    this.usageCount,
    this.matchScore,
    this.isFeatured = false,
    this.isTrendingNow = false,
    required this.tags,
    this.imageUrl,
    required this.creator,
    this.parameters = const PromptParameters(),
    this.codeSnippet,
    this.avatars,
    this.howToUse = const [
      'Best used with higher step counts (40-60) for glass transparency depth.',
      'Modify environment keywords for varied atmospheres.',
      'Guidance scale above 4.0 may cause oversaturation in lighting glows.'
    ],
    this.variants = const [],
    this.bentoSpan = BentoSpan.standard,
    this.price,
    this.rating = 4.9,
    this.reviewCount = 120,
  });
}
