import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/character.dart';
import '../providers/app_provider.dart';
import 'consulting_screen.dart';
import 'history_screen.dart';

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  int? _hoveredIndex;
  bool _showStory = true;

  @override
  Widget build(BuildContext context) {
    final characters = Character.all;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Main content - 3 columns
          Row(
            children: List.generate(characters.length, (index) {
              final character = characters[index];
              final isHovered = _hoveredIndex == index;

              return Expanded(
                flex: isHovered ? 2 : 1,
                child: _CharacterColumn(
                  character: character,
                  isHovered: isHovered,
                  onHover: (hovering) {
                    setState(() {
                      _hoveredIndex = hovering ? index : null;
                    });
                  },
                  onTap: () => _selectCharacter(context, character),
                ),
              );
            }),
          ),

          // Header overlay
          _buildHeader(),

          // Footer overlay
          _buildFooter(),

          // Story overlay (적벽대전 서사)
          if (_showStory) _buildStoryOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: AppColors.goldAccent.withOpacity(0.8),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '삼책지계',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              // 히스토리 버튼
              IconButton(
                onPressed: () => _openHistory(context),
                icon: Icon(
                  Icons.history,
                  color: Colors.white.withOpacity(0.7),
                ),
                tooltip: '상담 기록',
              ),
              // 서사 보기 버튼
              IconButton(
                onPressed: () {
                  setState(() {
                    _showStory = true;
                  });
                },
                icon: Icon(
                  Icons.menu_book,
                  color: Colors.white.withOpacity(0.7),
                ),
                tooltip: '삼책의 유래',
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
    );
  }

  Widget _buildFooter() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '책사를 선택하세요',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.3),
                      letterSpacing: 2,
                    ),
              ),
              Text(
                '상책 · 중책 · 하책',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.3),
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
    );
  }

  Widget _buildStoryOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showStory = false;
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.9),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.goldAccent.withOpacity(0.4),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더 (아이콘 + 제목 한 줄)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_stories,
                        size: 24,
                        color: AppColors.goldAccent,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '삼책지계',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.goldAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '三策之計',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.4),
                              letterSpacing: 1,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 본문
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.goldAccent.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        // 서사 요약
                        Text(
                          '서기 208년 적벽대전,\n제갈량이 유비에게 세 가지 책략을 올렸다.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                height: 1.6,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // 상중하책 (간결하게)
                        _buildCompactStrategy('상책', '손권과 연합하여 격파', AppColors.bestStrategy),
                        const SizedBox(height: 6),
                        _buildCompactStrategy('중책', '형주를 빌려 세력 확보', AppColors.middleStrategy),
                        const SizedBox(height: 6),
                        _buildCompactStrategy('하책', '남쪽으로 피신 후 재기', AppColors.worstStrategy),

                        const SizedBox(height: 12),

                        // 결과
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                            children: [
                              const TextSpan(text: '유비는 '),
                              TextSpan(
                                text: '상책',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.bestStrategy,
                                ),
                              ),
                              const TextSpan(text: '을 택해 대승을 거두었다.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 500.ms, delay: 100.ms),

                  const SizedBox(height: 14),

                  // 마무리 문구
                  Text(
                    '이제 책사들이 당신에게\n세 가지 책략을 드립니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.goldAccent.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showStory = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '책사 선택하기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95)),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStrategy(String label, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 42,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),
        ),
      ],
    );
  }

  void _selectCharacter(BuildContext context, Character character) {
    context.read<AppProvider>().selectCharacter(character);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ConsultingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HistoryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class _CharacterColumn extends StatelessWidget {
  final Character character;
  final bool isHovered;
  final Function(bool) onHover;
  final VoidCallback onTap;

  const _CharacterColumn({
    required this.character,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isHovered
                ? character.accentColor.withOpacity(0.1)
                : AppColors.cardDark,
            border: Border(
              right: BorderSide(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: isHovered ? 1.0 : 0.3,
                child: Image.asset(
                  character.mainImage,
                  fit: BoxFit.cover,
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isHovered
                          ? character.accentColor.withOpacity(0.3)
                          : Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: isHovered
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: _buildCollapsedContent(context),
                  secondChild: _buildExpandedContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
              color: Colors.white.withOpacity(0.05),
            ),
            child: Icon(
              character.icon,
              size: 28,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            character.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 4,
                ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag(character.title),
              if (character.alias.isNotEmpty) _buildTag(character.alias),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            character.name,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            character.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  height: 1.6,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),

          // Button
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: character.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('상담하기'),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: character.accentColor.withOpacity(0.4)),
        color: character.accentColor.withOpacity(0.1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: character.accentColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
