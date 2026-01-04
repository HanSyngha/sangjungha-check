import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/strategy.dart';
import '../providers/app_provider.dart';
import 'character_selection_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final Set<StrategyType> _revealedStrategies = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final character = provider.selectedCharacter;
    final result = provider.strategyResult;

    if (character == null || result == null) {
      return const Scaffold(
        body: Center(child: Text('결과를 불러올 수 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),

            // Main content - 3 columns
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use column layout for narrow screens
                  if (constraints.maxWidth < 800) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildStrategyCardNarrow(
                            context,
                            StrategyType.best,
                            result.best,
                            character,
                          ),
                          _buildStrategyCardNarrow(
                            context,
                            StrategyType.middle,
                            result.middle,
                            character,
                          ),
                          _buildStrategyCardNarrow(
                            context,
                            StrategyType.worst,
                            result.worst,
                            character,
                          ),
                        ],
                      ),
                    );
                  }

                  // Use row layout for wide screens
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStrategyCardWide(
                          context,
                          StrategyType.best,
                          result.best,
                          character,
                        ),
                      ),
                      Expanded(
                        child: _buildStrategyCardWide(
                          context,
                          StrategyType.middle,
                          result.middle,
                          character,
                        ),
                      ),
                      Expanded(
                        child: _buildStrategyCardWide(
                          context,
                          StrategyType.worst,
                          result.worst,
                          character,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121217),
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primary.withOpacity(0.2),
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
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              // Export functionality (placeholder)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('내보내기 기능은 준비 중입니다.')),
              );
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('저장'),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.borderDark,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _startNewSession(context),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('새 상담'),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 좁은 화면용 카드 (모바일) - Expanded 사용 안함
  Widget _buildStrategyCardNarrow(
    BuildContext context,
    StrategyType type,
    StrategyItem strategy,
    character,
  ) {
    final isRevealed = _revealedStrategies.contains(type);
    final color = _getStrategyColor(type);
    final icon = _getStrategyIcon(type);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121217),
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top color indicator
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),

          // Content (no Expanded, no scroll)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      type.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  type.koreanName,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  type.englishName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 16),

                // Strategy content - 두루마리 펼침 애니메이션
                if (isRevealed) ...[
                  // 두루마리 펼침 컨테이너
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withOpacity(0.2),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 두루마리 상단 장식
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            gradient: LinearGradient(
                              colors: [color.withOpacity(0.6), color.withOpacity(0.2)],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strategy.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                strategy.subtitle,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                              ),
                              const SizedBox(height: 16),

                              // Description card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.surfaceDark,
                                  border: Border.all(
                                    color: color.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  strategy.description,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.6,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Strategist quote
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          color.withOpacity(0.3),
                                          color.withOpacity(0.1),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: color.withOpacity(0.3),
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        character.talkingImage,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.person, color: color);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          character.name,
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '"${strategy.quote}"',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textMuted,
                                                fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 두루마리 하단 장식
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            gradient: LinearGradient(
                              colors: [color.withOpacity(0.2), color.withOpacity(0.6)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 400.ms)
                    .scaleY(begin: 0.0, end: 1.0, duration: 500.ms, curve: Curves.easeOutBack, alignment: Alignment.topCenter),
                ] else ...[
                  // Unrevealed state - 봉인된 두루마리
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.surfaceDark,
                      border: Border.all(
                        color: color.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 40,
                          color: color.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '봉인된 두루마리',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: color.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '아래 버튼을 눌러\n책략을 확인하세요',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .shimmer(duration: 2.seconds, color: color.withOpacity(0.1)),
                ],
              ],
            ),
          ),

          // Unseal button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ElevatedButton.icon(
              onPressed: isRevealed ? null : () => _revealStrategy(type),
              icon: Icon(
                isRevealed ? Icons.check : Icons.auto_stories,
              ),
              label: Text(
                isRevealed ? '열람 완료' : '두루마리 열기',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isRevealed ? AppColors.surfaceDark : color.withOpacity(0.2),
                foregroundColor: isRevealed ? AppColors.textMuted : color,
                disabledBackgroundColor: AppColors.surfaceDark,
                disabledForegroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: isRevealed
                      ? AppColors.borderDark
                      : color.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: 500.ms,
          delay: Duration(milliseconds: 200 * type.index),
        );
  }

  // 넓은 화면용 카드 (데스크톱/태블릿) - Expanded 사용
  Widget _buildStrategyCardWide(
    BuildContext context,
    StrategyType type,
    StrategyItem strategy,
    character,
  ) {
    final isRevealed = _revealedStrategies.contains(type);
    final color = _getStrategyColor(type);
    final icon = _getStrategyIcon(type);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121217),
        border: Border(
          right: BorderSide(color: AppColors.borderDark),
          bottom: BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top color indicator
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        type.label,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    type.koreanName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    type.englishName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Strategy title
                  if (isRevealed) ...[
                    Text(
                      strategy.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      strategy.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Description card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.surfaceDark,
                        border: Border.all(
                          color: color.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        strategy.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Strategist quote
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.3),
                                color.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: color.withOpacity(0.3),
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              character.talkingImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                character.name,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '"${strategy.quote}"',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textMuted,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ].animate().fadeIn(duration: 500.ms)
                  else ...[
                    // Unrevealed state
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.surfaceDark,
                        border: Border.all(
                          color: AppColors.borderDark,
                        ),
                      ),
                      child: Text(
                        '봉인된 두루마리입니다.\n아래 버튼을 눌러 열어보세요.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                              height: 1.6,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Unseal button
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: isRevealed ? null : () => _revealStrategy(type),
              icon: Icon(
                isRevealed ? Icons.check : Icons.auto_stories,
              ),
              label: Text(
                isRevealed ? '열람 완료' : '두루마리 열기',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isRevealed ? AppColors.surfaceDark : color.withOpacity(0.2),
                foregroundColor: isRevealed ? AppColors.textMuted : color,
                disabledBackgroundColor: AppColors.surfaceDark,
                disabledForegroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: isRevealed
                      ? AppColors.borderDark
                      : color.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: 500.ms,
          delay: Duration(milliseconds: 200 * type.index),
        );
  }

  Color _getStrategyColor(StrategyType type) {
    switch (type) {
      case StrategyType.best:
        return AppColors.bestStrategy;
      case StrategyType.middle:
        return AppColors.middleStrategy;
      case StrategyType.worst:
        return AppColors.worstStrategy;
    }
  }

  IconData _getStrategyIcon(StrategyType type) {
    switch (type) {
      case StrategyType.best:
        return Icons.light_mode;
      case StrategyType.middle:
        return Icons.balance;
      case StrategyType.worst:
        return Icons.warning;
    }
  }

  void _revealStrategy(StrategyType type) {
    setState(() {
      _revealedStrategies.add(type);
    });
  }

  void _startNewSession(BuildContext context) {
    context.read<AppProvider>().reset();
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CharacterSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }
}
