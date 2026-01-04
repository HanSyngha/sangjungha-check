// 추가 질문 항목
class AdditionalQuestion {
  final String question;
  final String type; // 'text' 또는 'choice'
  final List<String>? choices; // type이 'choice'일 때 선택지

  const AdditionalQuestion({
    required this.question,
    required this.type,
    this.choices,
  });

  factory AdditionalQuestion.fromJson(Map<String, dynamic> json) {
    return AdditionalQuestion(
      question: json['question'] ?? '',
      type: json['type'] ?? 'text',
      choices: json['choices'] != null
          ? List<String>.from(json['choices'])
          : null,
    );
  }
}

// Gemini 응답 래퍼 클래스
class GeminiResponse {
  final bool isConcern;
  final bool isServerBusy; // 서버 과부하로 실패
  final bool needAdditionalInfo; // 추가 정보 필요
  final String? notConcernMessage; // 고민이 아닐 때 표시할 메시지
  final String? additionalInfoMessage; // 추가 질문 전 메시지
  final List<AdditionalQuestion>? questions; // 추가 질문 목록
  final StrategyResult? result; // 고민일 때 책략 결과

  const GeminiResponse({
    required this.isConcern,
    this.isServerBusy = false,
    this.needAdditionalInfo = false,
    this.notConcernMessage,
    this.additionalInfoMessage,
    this.questions,
    this.result,
  });

  // 서버 과부하 응답 생성
  factory GeminiResponse.serverBusy() {
    return const GeminiResponse(
      isConcern: false,
      isServerBusy: true,
    );
  }

  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    final isConcern = json['is_concern'] ?? true;
    final needAdditionalInfo = json['need_additional_info'] ?? false;

    // 추가 정보 필요한 경우
    if (needAdditionalInfo) {
      final questionsList = json['questions'] as List<dynamic>?;
      return GeminiResponse(
        isConcern: true,
        needAdditionalInfo: true,
        additionalInfoMessage: json['message'] ?? '몇 가지 더 여쭤봐도 되겠소?',
        questions: questionsList
            ?.map((q) => AdditionalQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
      );
    }

    // 고민이 아닌 경우
    if (!isConcern) {
      return GeminiResponse(
        isConcern: false,
        notConcernMessage: json['message'] ?? '고민이나 전략이 필요한 내용을 말씀해주세요.',
      );
    }

    // 정상 응답
    return GeminiResponse(
      isConcern: true,
      result: StrategyResult.fromJson(json),
    );
  }
}

class StrategyItem {
  final String title;
  final String subtitle;
  final String description;
  final String quote;

  const StrategyItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.quote,
  });

  factory StrategyItem.fromJson(Map<String, dynamic> json) {
    return StrategyItem(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      quote: json['quote'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'quote': quote,
    };
  }
}

class StrategyResult {
  final StrategyItem best;
  final StrategyItem middle;
  final StrategyItem worst;

  const StrategyResult({
    required this.best,
    required this.middle,
    required this.worst,
  });

  factory StrategyResult.fromJson(Map<String, dynamic> json) {
    return StrategyResult(
      best: StrategyItem.fromJson(json['best'] ?? {}),
      middle: StrategyItem.fromJson(json['middle'] ?? {}),
      worst: StrategyItem.fromJson(json['worst'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'best': best.toJson(),
      'middle': middle.toJson(),
      'worst': worst.toJson(),
    };
  }
}

enum StrategyType { best, middle, worst }

extension StrategyTypeExtension on StrategyType {
  String get koreanName {
    switch (this) {
      case StrategyType.best:
        return '상책';
      case StrategyType.middle:
        return '중책';
      case StrategyType.worst:
        return '하책';
    }
  }

  String get englishName {
    switch (this) {
      case StrategyType.best:
        return '최선의 방책';
      case StrategyType.middle:
        return '차선의 방책';
      case StrategyType.worst:
        return '최후의 방책';
    }
  }

  String get label {
    switch (this) {
      case StrategyType.best:
        return '선견지명';
      case StrategyType.middle:
        return '실용주의';
      case StrategyType.worst:
        return '즉시대응';
    }
  }
}
