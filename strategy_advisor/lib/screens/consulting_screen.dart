import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import 'deliberation_screen.dart';

class ConsultingScreen extends StatefulWidget {
  const ConsultingScreen({super.key});

  @override
  State<ConsultingScreen> createState() => _ConsultingScreenState();
}

class _ConsultingScreenState extends State<ConsultingScreen> {
  final TextEditingController _concernController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _concernController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final character = provider.selectedCharacter;

    if (character == null) {
      return const Scaffold(
        body: Center(child: Text('인물을 선택해주세요')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark2,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Character selector
                    _buildCharacterSelector(context, character),
                    const SizedBox(height: 32),

                    // Headline
                    _buildHeadline(context, character),
                    const SizedBox(height: 32),

                    // Text input area
                    _buildTextInput(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // FAB - Send button
      floatingActionButton: _buildSendButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark2.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.history_edu,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '삼책지계',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildCharacterSelector(BuildContext context, character) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Selected character
        Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: character.accentColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: character.accentColor.withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  character.mainImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${character.name} (${character.alias.isNotEmpty ? character.alias : character.title})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: character.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);
  }

  Widget _buildHeadline(BuildContext context, character) {
    // 캐릭터별 말투
    String headline;
    String subtitle;

    switch (character.name) {
      case '제갈량':
        headline = '"그대의 고뇌를 경청하겠소."';
        subtitle = '세 가지 책략을 올리리다.';
        break;
      case '방통':
        headline = '"자네의 고민을 들어보겠네."';
        subtitle = '세 가지 묘책을 알려주지.';
        break;
      case '초선':
        headline = '"당신의 이야기를 들려주세요."';
        subtitle = '세 가지 방법을 알려드릴게요.';
        break;
      default:
        headline = '"고뇌를 경청합니다."';
        subtitle = '세 가지 책략을 드리겠습니다.';
    }

    return Column(
      children: [
        Text(
          headline,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildTextInput(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark.withOpacity(0.5)),
      ),
      child: Stack(
        children: [
          // Corner decorations
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderDark.withOpacity(0.5)),
                  left:
                      BorderSide(color: AppColors.borderDark.withOpacity(0.5)),
                ),
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(16)),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderDark.withOpacity(0.5)),
                  right:
                      BorderSide(color: AppColors.borderDark.withOpacity(0.5)),
                ),
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(16)),
              ),
            ),
          ),

          // Text field
          TextField(
            controller: _concernController,
            focusNode: _focusNode,
            maxLines: null,
            minLines: 10,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  height: 1.8,
                ),
            decoration: InputDecoration(
              hintText:
                  '이곳에 당신의 고민을 털어놓으세요.\n깊은 지혜가 답할 것입니다...',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted.withOpacity(0.5),
                    height: 1.8,
                  ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(24),
            ),
            onChanged: (value) {
              context.read<AppProvider>().setConcern(value);
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  Widget _buildSendButton(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _submitConcern(context),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send, size: 28),
            const SizedBox(height: 4),
            Text(
              '전송',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  void _submitConcern(BuildContext context) {
    final concern = _concernController.text.trim();
    if (concern.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('고민을 입력해주세요.'),
          backgroundColor: AppColors.worstStrategy,
        ),
      );
      return;
    }

    context.read<AppProvider>().setConcern(concern);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DeliberationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
