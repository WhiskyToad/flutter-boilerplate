import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:skelter/common/theme/text_style/app_text_styles.dart';
import 'package:skelter/i18n/localization.dart';
import 'package:skelter/presentation/ai_chat/bloc/ai_chat_bloc.dart';
import 'package:skelter/presentation/ai_chat/bloc/ai_chat_event.dart';
import 'package:skelter/presentation/ai_chat/bloc/ai_chat_state.dart';
import 'package:skelter/presentation/ai_chat/widgets/ai_chat_input_field.dart';
import 'package:skelter/presentation/ai_chat/widgets/ai_chat_message_bubble.dart';
import 'package:skelter/presentation/home/domain/entities/product.dart';
import 'package:skelter/utils/theme/extention/theme_extension.dart';
import 'package:skelter/widgets/styling/app_colors.dart';

void showAiChatBottomSheet(
  BuildContext context, {
  required AiChatBloc existingBloc,
  required VoidCallback onCartTap,
}) {
  final products = existingBloc.products;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final keyboardHeight = MediaQuery.viewInsetsOf(ctx).bottom;
      final screenHeight = MediaQuery.sizeOf(ctx).height;
      return Padding(
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight - keyboardHeight),
          child: BlocProvider<AiChatBloc>.value(
            value: existingBloc,
            child: _AiChatSheetContent(
              products: products,
              onCartTap: onCartTap,
            ),
          ),
        ),
      );
    },
  );
}

class _AiChatSheetContent extends StatelessWidget {
  const _AiChatSheetContent({required this.products, required this.onCartTap});

  final List<Product> products;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      decoration: BoxDecoration(
        color: context.currentTheme.bgSurfaceBase,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            _buildDragHandle(context),
            _buildHeader(context),
            Divider(
              height: 1,
              color: context.currentTheme.strokeNeutralLight100,
            ),
            Expanded(
              child: _AiChatMessageList(
                products: products,
                onCartTap: onCartTap,
              ),
            ),
            const SizedBox(height: 4),
            _buildSuggestionRow(context),
            const SizedBox(height: 4),
            _buildInputSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: context.currentTheme.strokeNeutralLight100,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 16, right: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.currentTheme.bgBrandLight100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              TablerIcons.robot,
              size: 20,
              color: context.currentTheme.iconBrandPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.localization.ai_assistant,
                  style: AppTextStyles.p2SemiBold.copyWith(
                    color: context.currentTheme.textNeutralPrimary,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<AiChatBloc, AiChatState>(
            buildWhen: (previous, current) =>
                previous.messages.length != current.messages.length,
            builder: (context, state) {
              if (state.messages.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () {
                  context.read<AiChatBloc>().add(const ClearChatEvent());
                },
                icon: Icon(
                  TablerIcons.trash,
                  size: 20,
                  color: context.currentTheme.iconNeutralDefault,
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              TablerIcons.x,
              size: 20,
              color: context.currentTheme.iconNeutralDefault,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionRow(BuildContext context) {
    final suggestions = [
      context.localization.ai_chat_suggestion_cart,
      context.localization.ai_chat_suggestion_deals,
      context.localization.ai_chat_suggestion_coupon,
    ];

    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen: (previous, current) =>
          previous.isGenerating != current.isGenerating,
      builder: (context, state) {
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: state.isGenerating
                    ? null
                    : () {
                        context.read<AiChatBloc>().add(
                          SendMessageEvent(message: suggestions[index]),
                        );
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: state.isGenerating
                        ? context.currentTheme.bgNeutralLight50
                        : context.currentTheme.bgBrandLight50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: state.isGenerating
                          ? context.currentTheme.strokeNeutralLight100
                          : context.currentTheme.strokeBrandDefault,
                    ),
                  ),
                  child: Text(
                    suggestions[index],
                    style: AppTextStyles.p4Medium.copyWith(
                      color: state.isGenerating
                          ? context.currentTheme.textNeutralSecondary
                          : context.currentTheme.textBrandPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen: (previous, current) =>
          previous.isGenerating != current.isGenerating,
      builder: (context, state) {
        return AiChatInputField(
          isEnabled: !state.isGenerating,
          onSend: (message) {
            context.read<AiChatBloc>().add(SendMessageEvent(message: message));
          },
          onStop: () {
            context.read<AiChatBloc>().add(const StopGenerationEvent());
          },
        );
      },
    );
  }
}

class _AiChatMessageList extends StatefulWidget {
  const _AiChatMessageList({required this.products, required this.onCartTap});

  final List<Product> products;
  final VoidCallback onCartTap;

  @override
  State<_AiChatMessageList> createState() => _AiChatMessageListState();
}

class _AiChatMessageListState extends State<_AiChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiChatBloc, AiChatState>(
      listener: (context, state) => _scrollToBottom(),
      builder: (context, state) {
        if (state.messages.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount:
              state.messages.length + (state.errorMessage != null ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < state.messages.length) {
              return AiChatMessageBubble(
                message: state.messages[index],
                products: widget.products,
                onCartTap: widget.onCartTap,
              );
            }
            return _buildErrorBanner(context, state.errorMessage!);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.message_chatbot,
              size: 48,
              color: context.currentTheme.iconNeutralDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              context.localization.ai_chat_how_can_i_help,
              style: AppTextStyles.p1SemiBold.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.localization.ai_chat_description,
              textAlign: TextAlign.center,
              style: AppTextStyles.p3Regular.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String errorMessage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.currentTheme.bgErrorLight50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            TablerIcons.alert_circle,
            size: 16,
            color: context.currentTheme.iconErrorDefault,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: AppTextStyles.p4Regular.copyWith(
                color: context.currentTheme.textErrorPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
