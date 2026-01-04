import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/strategy.dart';
import '../services/gemini_service.dart';

enum AppState { idle, loading, success, error, notConcern, serverBusy, additionalQuestions }

// 상담 기록 클래스
class ConsultationRecord {
  final String characterName;
  final String characterImage;
  final Color characterColor;
  final String concern;
  final StrategyResult result;
  final DateTime timestamp;

  ConsultationRecord({
    required this.characterName,
    required this.characterImage,
    required this.characterColor,
    required this.concern,
    required this.result,
    required this.timestamp,
  });
}

class AppProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  // State
  AppState _state = AppState.idle;
  Character? _selectedCharacter;
  String _concern = '';
  StrategyResult? _strategyResult;
  String _errorMessage = '';
  String _notConcernMessage = ''; // 고민이 아닐 때 책사의 메시지

  // 추가 질문 관련 상태
  String _additionalInfoMessage = ''; // 추가 질문 전 메시지
  List<AdditionalQuestion> _additionalQuestions = []; // 추가 질문 목록
  Map<int, String> _additionalAnswers = {}; // 질문별 답변

  // 상담 기록 히스토리
  final List<ConsultationRecord> _consultationHistory = [];

  // Getters
  AppState get state => _state;
  Character? get selectedCharacter => _selectedCharacter;
  String get concern => _concern;
  StrategyResult? get strategyResult => _strategyResult;
  String get errorMessage => _errorMessage;
  String get notConcernMessage => _notConcernMessage;
  bool get isLoading => _state == AppState.loading;
  bool get hasResult => _strategyResult != null;
  bool get isNotConcern => _state == AppState.notConcern;
  List<ConsultationRecord> get consultationHistory => _consultationHistory;

  // 추가 질문 관련 Getters
  String get additionalInfoMessage => _additionalInfoMessage;
  List<AdditionalQuestion> get additionalQuestions => _additionalQuestions;
  Map<int, String> get additionalAnswers => _additionalAnswers;
  bool get hasAdditionalQuestions => _state == AppState.additionalQuestions;

  // Initialize Gemini service
  Future<void> initialize() async {
    try {
      await _geminiService.initialize();
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
      notifyListeners();
    }
  }

  // Select character
  void selectCharacter(Character character) {
    _selectedCharacter = character;
    notifyListeners();
  }

  // Set concern
  void setConcern(String concern) {
    _concern = concern;
    notifyListeners();
  }

  // Generate strategy
  Future<void> generateStrategy() async {
    if (_selectedCharacter == null || _concern.isEmpty) {
      _errorMessage = '인물과 고민을 모두 입력해주세요.';
      _state = AppState.error;
      notifyListeners();
      return;
    }

    _state = AppState.loading;
    _errorMessage = '';
    _notConcernMessage = '';
    notifyListeners();

    try {
      final response = await _geminiService.generateStrategy(
        character: _selectedCharacter!,
        concern: _concern,
      );

      if (response.isServerBusy) {
        // 서버 과부하 - 3번 재시도 후 실패
        _state = AppState.serverBusy;
      } else if (response.needAdditionalInfo && response.questions != null) {
        // 추가 정보 필요 - 질문 표시
        _additionalInfoMessage = response.additionalInfoMessage ?? '몇 가지 더 여쭤봐도 되겠소?';
        _additionalQuestions = response.questions!;
        _additionalAnswers = {};
        _state = AppState.additionalQuestions;
      } else if (response.isConcern && response.result != null) {
        // 고민인 경우 - 책략 결과 표시
        _strategyResult = response.result;
        _state = AppState.success;
        // 히스토리에 저장
        _addToHistory();
      } else {
        // 고민이 아닌 경우 - 책사의 메시지 표시
        _notConcernMessage = response.notConcernMessage ?? '고민이나 전략이 필요한 내용을 말씀해주세요.';
        _state = AppState.notConcern;
      }
    } catch (e) {
      _errorMessage = '전략 생성 중 오류가 발생했습니다: ${e.toString()}';
      _state = AppState.error;
    }

    notifyListeners();
  }

  // 히스토리에 상담 기록 추가
  void _addToHistory() {
    if (_selectedCharacter != null && _strategyResult != null) {
      _consultationHistory.add(ConsultationRecord(
        characterName: _selectedCharacter!.name,
        characterImage: _selectedCharacter!.mainImage,
        characterColor: _selectedCharacter!.accentColor,
        concern: _concern,
        result: _strategyResult!,
        timestamp: DateTime.now(),
      ));
    }
  }

  // 히스토리 전체 삭제
  void clearHistory() {
    _consultationHistory.clear();
    notifyListeners();
  }

  // 특정 기록 삭제
  void removeFromHistory(int index) {
    if (index >= 0 && index < _consultationHistory.length) {
      _consultationHistory.removeAt(index);
      notifyListeners();
    }
  }

  // Reset to start new session
  void reset() {
    _state = AppState.idle;
    _selectedCharacter = null;
    _concern = '';
    _strategyResult = null;
    _errorMessage = '';
    _notConcernMessage = '';
    _additionalInfoMessage = '';
    _additionalQuestions = [];
    _additionalAnswers = {};
    notifyListeners();
  }

  // Reset only result (keep character and concern)
  void resetResult() {
    _state = AppState.idle;
    _strategyResult = null;
    _errorMessage = '';
    _notConcernMessage = '';
    _additionalInfoMessage = '';
    _additionalQuestions = [];
    _additionalAnswers = {};
    notifyListeners();
  }

  // 추가 질문에 대한 답변 설정
  void setAdditionalAnswer(int questionIndex, String answer) {
    _additionalAnswers[questionIndex] = answer;
    notifyListeners();
  }

  // 모든 질문에 답변했는지 확인
  bool get allQuestionsAnswered {
    if (_additionalQuestions.isEmpty) return false;
    for (int i = 0; i < _additionalQuestions.length; i++) {
      if (!_additionalAnswers.containsKey(i) || _additionalAnswers[i]!.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  // 추가 정보와 함께 전략 재생성
  Future<void> generateStrategyWithAdditionalInfo() async {
    if (_selectedCharacter == null || _concern.isEmpty) {
      _errorMessage = '인물과 고민을 모두 입력해주세요.';
      _state = AppState.error;
      notifyListeners();
      return;
    }

    if (!allQuestionsAnswered) {
      _errorMessage = '모든 질문에 답변해주세요.';
      _state = AppState.error;
      notifyListeners();
      return;
    }

    _state = AppState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // 사용자 답변을 포함한 고민 내용 구성
      final additionalInfo = StringBuffer();
      additionalInfo.writeln(_concern);
      additionalInfo.writeln('\n--- 사용자의 답변 ---');
      for (int i = 0; i < _additionalQuestions.length; i++) {
        final question = _additionalQuestions[i];
        final answer = _additionalAnswers[i] ?? '';
        additionalInfo.writeln('질문: ${question.question}');
        additionalInfo.writeln('답변: $answer');
        additionalInfo.writeln();
      }

      final response = await _geminiService.generateStrategy(
        character: _selectedCharacter!,
        concern: additionalInfo.toString(),
      );

      if (response.isServerBusy) {
        _state = AppState.serverBusy;
      } else if (response.isConcern && response.result != null) {
        _strategyResult = response.result;
        _state = AppState.success;
        _addToHistory();
      } else {
        _notConcernMessage = response.notConcernMessage ?? '고민이나 전략이 필요한 내용을 말씀해주세요.';
        _state = AppState.notConcern;
      }
    } catch (e) {
      _errorMessage = '전략 생성 중 오류가 발생했습니다: ${e.toString()}';
      _state = AppState.error;
    }

    notifyListeners();
  }
}
