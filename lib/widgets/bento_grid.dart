import 'package:flutter/material.dart';
import '../models/prompt_model.dart';
import 'prompt_card.dart';

class BentoGrid extends StatelessWidget {
  final List<PromptItem> prompts;

  const BentoGrid({super.key, required this.prompts});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return _buildDesktopBento(context);
        } else {
          return _buildMobileList(context);
        }
      },
    );
  }

  Widget _buildDesktopBento(BuildContext context) {
    return Column(
      children: [
        // Row 1: Featured Large + Medium Cards
        if (prompts.length >= 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 7,
                  child: PromptCard(prompt: prompts[0]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: PromptCard(prompt: prompts[1]),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        // Row 2: Grid of remaining cards
        if (prompts.length > 2)
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: prompts.skip(2).map((prompt) {
              return SizedBox(
                width: 380,
                child: PromptCard(prompt: prompt),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildMobileList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: prompts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return PromptCard(prompt: prompts[index]);
      },
    );
  }
}
