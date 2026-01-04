import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/character.dart';
import '../models/strategy.dart';
import '../providers/app_provider.dart';
import 'result_screen.dart';

class DeliberationScreen extends StatefulWidget {
  const DeliberationScreen({super.key});

  @override
  State<DeliberationScreen> createState() => _DeliberationScreenState();
}

class _DeliberationScreenState extends State<DeliberationScreen> {
  double _progress = 0.0;
  String _statusMessage = '책사에게 연결 중...';

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    final provider = context.read<AppProvider>();

    // Simulate progress updates
    _simulateProgress();

    // Actually generate strategy
    await provider.generateStrategy();

    // Navigate to result when done
    if (mounted && provider.state == AppState.success) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ResultScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else if (mounted && provider.state == AppState.additionalQuestions) {
      // 추가 질문이 필요한 경우
      _showAdditionalQuestionsDialog(provider);
    } else if (mounted && provider.state == AppState.notConcern) {
      // 고민이 아닌 경우 - 책사의 메시지 표시
      _showNotConcernDialog(provider);
    } else if (mounted && provider.state == AppState.serverBusy) {
      // 서버 과부하 - 3번 재시도 후 실패
      _showServerBusyDialog(provider);
    } else if (mounted && provider.state == AppState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: AppColors.worstStrategy,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showNotConcernDialog(AppProvider provider) {
    final character = provider.selectedCharacter;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: character?.accentColor.withOpacity(0.3) ?? AppColors.borderDark,
          ),
        ),
        title: Row(
          children: [
            if (character != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: character.accentColor),
                ),
                child: ClipOval(
                  child: Image.asset(
                    character.talkingImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              character?.name ?? '책사',
              style: TextStyle(
                color: character?.accentColor ?? AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          provider.notConcernMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 이전 화면(상담 화면)으로 돌아가기
            },
            child: Text(
              '다시 입력하기',
              style: TextStyle(color: character?.accentColor ?? AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showServerBusyDialog(AppProvider provider) {
    final character = provider.selectedCharacter;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: character?.accentColor.withOpacity(0.3) ?? AppColors.borderDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 책사 이미지 (큰 사이즈)
            if (character != null) ...[
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: character.accentColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: character.accentColor.withOpacity(0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    character.talkingImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                character.name,
                style: TextStyle(
                  color: character.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
            ],
            // 캐릭터별 에러 메시지
            Text(
              _getServerBusyMessage(character),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getServerBusySubMessage(character),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 이전 화면(상담 화면)으로 돌아가기
            },
            child: Text(
              '알겠습니다',
              style: TextStyle(color: character?.accentColor ?? AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _getServerBusyMessage(character) {
    switch (character?.name) {
      case '제갈량':
        return '지금은 지혜를 얻으려는 이들이\n너무 많아 잠시 쉬어가야 하오.';
      case '방통':
        return '허허, 도움이 필요한 이가\n너무 많아 잠시 쉬어야겠네.';
      case '초선':
        return '죄송해요, 저를 찾는 분들이\n너무 많아서 잠시 쉬어야 해요.';
      default:
        return '지금은 찾는 이가 많아 잠시 쉬어야 합니다.';
    }
  }

  String _getServerBusySubMessage(character) {
    switch (character?.name) {
      case '제갈량':
        return '조금 뒤에 다시 찾아주시오.';
      case '방통':
        return '잠시 후에 다시 오게나.';
      case '초선':
        return '조금 있다가 다시 와주세요.';
      default:
        return '잠시 후 다시 시도해주세요.';
    }
  }

  void _showAdditionalQuestionsDialog(AppProvider provider) {
    final character = provider.selectedCharacter;
    final questions = provider.additionalQuestions;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.cardDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: character?.accentColor.withOpacity(0.3) ?? AppColors.borderDark,
              ),
            ),
            title: Column(
              children: [
                // 책사 이미지
                if (character != null) ...[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: character.accentColor.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: character.accentColor.withOpacity(0.2),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        character.talkingImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    character.name,
                    style: TextStyle(
                      color: character.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                // 추가 질문 메시지
                Text(
                  provider.additionalInfoMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(questions.length, (index) {
                    final question = questions[index];
                    return _buildQuestionItem(
                      context,
                      provider,
                      question,
                      index,
                      character,
                      setDialogState,
                    );
                  }),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pop(context); // 이전 화면으로 돌아가기
                },
                child: Text(
                  '취소',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              ElevatedButton(
                onPressed: provider.allQuestionsAnswered
                    ? () async {
                        Navigator.pop(context); // 다이얼로그 닫기
                        // 로딩 상태로 다시 시작
                        setState(() {
                          _progress = 0.0;
                          _statusMessage = _getAnalyzingAnswerMessage(character);
                        });
                        _simulateProgressForAdditionalInfo();
                        await provider.generateStrategyWithAdditionalInfo();

                        // 결과 처리
                        if (mounted && provider.state == AppState.success) {
                          Navigator.pushReplacement(
                            this.context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const ResultScreen(),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 400),
                            ),
                          );
                        } else if (mounted && provider.state == AppState.serverBusy) {
                          _showServerBusyDialog(provider);
                        } else if (mounted && provider.state == AppState.error) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(provider.errorMessage),
                              backgroundColor: AppColors.worstStrategy,
                            ),
                          );
                          Navigator.pop(this.context);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: character?.accentColor ?? AppColors.primary,
                  disabledBackgroundColor: AppColors.borderDark,
                ),
                child: Text(
                  _getSubmitButtonText(character),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getSubmitButtonText(character) {
    switch (character?.name) {
      case '제갈량':
        return '답변 올리오';
      case '방통':
        return '답변하겠네';
      case '초선':
        return '답변할게요';
      default:
        return '답변 제출';
    }
  }

  Widget _buildQuestionItem(
    BuildContext context,
    AppProvider provider,
    AdditionalQuestion question,
    int index,
    character,
    void Function(void Function()) setDialogState,
  ) {
    final currentAnswer = provider.additionalAnswers[index] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surfaceDark,
        border: Border.all(
          color: character?.accentColor.withOpacity(0.2) ?? AppColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 질문 번호 및 내용
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: character?.accentColor.withOpacity(0.2) ?? AppColors.primary.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: character?.accentColor ?? AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.question,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 답변 입력 (주관식 또는 객관식)
          if (question.type == 'choice' && question.choices != null)
            // 객관식
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: question.choices!.map((choice) {
                final isSelected = currentAnswer == choice;
                return GestureDetector(
                  onTap: () {
                    provider.setAdditionalAnswer(index, choice);
                    setDialogState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected
                          ? character?.accentColor.withOpacity(0.3) ?? AppColors.primary.withOpacity(0.3)
                          : AppColors.cardDark,
                      border: Border.all(
                        color: isSelected
                            ? character?.accentColor ?? AppColors.primary
                            : AppColors.borderDark,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      choice,
                      style: TextStyle(
                        color: isSelected
                            ? character?.accentColor ?? AppColors.primary
                            : Colors.white.withOpacity(0.8),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            // 주관식
            TextField(
              onChanged: (value) {
                provider.setAdditionalAnswer(index, value);
                setDialogState(() {});
              },
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: _getTextFieldHint(character),
                hintStyle: TextStyle(
                  color: AppColors.textMuted.withOpacity(0.5),
                ),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: character?.accentColor ?? AppColors.primary,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
        ],
      ),
    );
  }

  String _getTextFieldHint(character) {
    switch (character?.name) {
      case '제갈량':
        return '답변을 적어주시오...';
      case '방통':
        return '답변을 적어보게...';
      case '초선':
        return '답변을 적어주세요...';
      default:
        return '답변을 입력하세요...';
    }
  }

  String _getAnalyzingAnswerMessage(character) {
    switch (character?.name) {
      case '제갈량':
        return '그대의 답변을 살피는 중이오...';
      case '방통':
        return '자네의 대답을 분석 중일세...';
      case '초선':
        return '당신의 이야기를 읽고 있어요...';
      default:
        return '답변을 분석하는 중...';
    }
  }

  void _simulateProgressForAdditionalInfo() async {
    final provider = context.read<AppProvider>();
    final character = provider.selectedCharacter;
    final name = character?.name ?? '전략가';

    List<String> messages;
    switch (name) {
      case '제갈량':
        messages = [
          '그대의 답변을 살피는 중이오...',
          '더 깊이 통찰하는 중이오...',
          '최선의 책략을 도출하는 중이오...',
        ];
        break;
      case '방통':
        messages = [
          '자네의 대답을 분석 중일세...',
          '더 기발한 묘책을 떠올리는 중이네...',
          '최고의 계책을 완성하는 중일세...',
        ];
        break;
      case '초선':
        messages = [
          '당신이 해주신 이야기를 읽고 있어요...',
          '더 좋은 방법을 찾고 있어요...',
          '최선의 답을 준비하고 있어요...',
        ];
        break;
      default:
        messages = [
          '답변 분석 중...',
          '전략 최적화 중...',
          '최종 전략 생성 중...',
        ];
    }

    for (int i = 0; i < messages.length; i++) {
      if (!mounted) return;

      setState(() {
        _statusMessage = messages[i];
        _progress = (i + 1) / messages.length;
      });

      await Future.delayed(Duration(milliseconds: 800 + (i * 200)));
    }
  }

  void _simulateProgress() async {
    final provider = context.read<AppProvider>();
    final character = provider.selectedCharacter;
    final name = character?.name ?? '전략가';

    // 캐릭터별 진행 메시지
    List<String> messages;
    switch (name) {
      case '제갈량':
        messages = [
          '와룡선생을 모셔오는 중...',
          '그대의 고민을 살피는 중이오...',
          '책략을 구상하는 중이오...',
        ];
        break;
      case '방통':
        messages = [
          '봉추선생을 모셔오는 중...',
          '자네의 고민을 파악하는 중일세...',
          '묘책을 떠올리는 중이네...',
        ];
        break;
      case '초선':
        messages = [
          '초선을 모셔오는 중...',
          '당신의 마음을 읽고 있어요...',
          '방법을 생각하고 있어요...',
        ];
        break;
      default:
        messages = [
          '책사를 모셔오는 중...',
          '고민을 파악하는 중...',
          '전략을 생성하는 중...',
        ];
    }

    for (int i = 0; i < messages.length; i++) {
      if (!mounted) return;

      setState(() {
        _statusMessage = messages[i];
        _progress = (i + 1) / messages.length;
      });

      await Future.delayed(Duration(milliseconds: 800 + (i * 200)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final selectedCharacter = provider.selectedCharacter;

    if (selectedCharacter == null) {
      return const Scaffold(
        body: Center(child: Text('캐릭터를 선택해주세요.')),
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),

                    // Headline
                    _buildHeadline(context, selectedCharacter),
                    const SizedBox(height: 48),

                    // Selected strategist visualization (only one)
                    _buildSelectedStrategist(context, selectedCharacter),
                    const SizedBox(height: 48),

                    // Progress section
                    _buildProgressSection(context, selectedCharacter),

                    const Spacer(),
                  ],
                ),
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
        color: AppColors.backgroundDark2,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.psychology,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '책략 도출 중',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _getRandomSubText(String characterName) {
    final random = Random();

    final zhugeLiangTexts = [
      '천하의 이치를 살피고 있소.',
      '바람의 흐름을 읽고 있소.',
      '별의 움직임을 관찰하는 중이오.',
      '깊은 사색에 잠겨있소.',
      '과거의 지혜를 되새기는 중이오.',
      '형세를 면밀히 분석하고 있소.',
      '만반의 준비를 갖추는 중이오.',
      '신중히 계책을 짜는 중이오.',
      '대의를 헤아리고 있소.',
      '천시와 지리를 살피는 중이오.',
    ];

    final pangTongTexts = [
      '기발한 묘책을 떠올리는 중일세.',
      '허허, 재미있는 생각이 떠오르는군.',
      '역발상으로 접근해보겠네.',
      '틀을 깨는 방법을 찾는 중일세.',
      '남들이 못 보는 것을 보고 있네.',
      '대담한 계략을 구상 중일세.',
      '허점을 찾아내는 중이네.',
      '뒤집어 생각해보는 중일세.',
      '파격적인 수를 떠올리고 있네.',
      '흥미로운 방법이 있을 것 같군.',
    ];

    final diaoChanTexts = [
      '마음의 길을 찾고 있어요.',
      '감정의 흐름을 읽고 있어요.',
      '사람의 마음을 헤아리는 중이에요.',
      '관계의 실타래를 풀어보고 있어요.',
      '부드러운 해결책을 찾고 있어요.',
      '상대의 입장에서 생각해보고 있어요.',
      '마음을 움직일 방법을 찾는 중이에요.',
      '섬세하게 살펴보고 있어요.',
      '진심을 담은 답을 찾고 있어요.',
      '따뜻한 조언을 준비하고 있어요.',
    ];

    switch (characterName) {
      case '제갈량':
        return zhugeLiangTexts[random.nextInt(zhugeLiangTexts.length)];
      case '방통':
        return pangTongTexts[random.nextInt(pangTongTexts.length)];
      case '초선':
        return diaoChanTexts[random.nextInt(diaoChanTexts.length)];
      default:
        return '깊이 생각하고 있습니다.';
    }
  }

  Widget _buildHeadline(BuildContext context, Character character) {
    // 캐릭터별 숙고 메시지
    String thinkingText;

    switch (character.name) {
      case '제갈량':
        thinkingText = '제갈공명이 숙고 중...';
        break;
      case '방통':
        thinkingText = '방통이 숙고 중...';
        break;
      case '초선':
        thinkingText = '초선이 생각 중...';
        break;
      default:
        thinkingText = '${character.name}이 숙고 중...';
    }

    final subText = _getRandomSubText(character.name);

    return Column(
      children: [
        Text(
          thinkingText,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildSelectedStrategist(BuildContext context, Character character) {
    return _StrategistCard(
      character: character,
      isActive: true,
      statusText: _statusMessage,
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }

  Widget _buildProgressSection(BuildContext context, Character character) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '책략 생성 중',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1,
                    ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: AppColors.borderDark,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Log terminal
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF0B0C15),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogItem(
                  icon: Icons.check_circle,
                  text: '책사에게 연결됨',
                  isActive: false,
                  isComplete: _progress > 0.2,
                ),
                const SizedBox(height: 12),
                _buildLogItem(
                  icon: Icons.sync,
                  text: _statusMessage,
                  isActive: true,
                  isComplete: false,
                ),
                const SizedBox(height: 12),
                _buildLogItem(
                  icon: Icons.pending,
                  text: '최종 전략 도출 대기 중...',
                  isActive: false,
                  isComplete: false,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }

  Widget _buildLogItem({
    required IconData icon,
    required String text,
    required bool isActive,
    required bool isComplete,
  }) {
    Color color;
    if (isComplete) {
      color = AppColors.textMuted;
    } else if (isActive) {
      color = AppColors.primary;
    } else {
      color = AppColors.textMuted.withOpacity(0.5);
    }

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        )
            .animate(
              onPlay: (controller) =>
                  isActive ? controller.repeat() : controller.stop(),
            )
            .rotate(duration: 1.seconds, begin: 0, end: isActive ? 1 : 0),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

class _StrategistCard extends StatelessWidget {
  final Character character;
  final bool isActive;
  final String statusText;

  const _StrategistCard({
    required this.character,
    required this.isActive,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isActive
            ? AppColors.surfaceDark
            : AppColors.surfaceDark.withOpacity(0.5),
        border: Border.all(
          color: isActive ? character.accentColor.withOpacity(0.5) : AppColors.borderDark,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: character.accentColor.withOpacity(0.2),
                  blurRadius: 20,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? character.accentColor
                    : AppColors.borderDark,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                character.thinkingImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            character.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 4),

          // Status
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive ? character.accentColor : AppColors.textMuted,
                ),
          ),

          const SizedBox(height: 8),

          // Activity indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isActive && index == 1)
                      ? character.accentColor
                      : character.accentColor.withOpacity(0.3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
