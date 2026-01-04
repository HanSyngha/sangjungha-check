import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/strategy.dart';

class GeminiService {
  late GenerativeModel _geminiModel;
  String? _xaiApiKey;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Gemini 초기화
    final geminiKey = dotenv.env['GEMINI_API_KEY'];
    if (geminiKey != null && geminiKey.isNotEmpty) {
      _geminiModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: geminiKey,
        generationConfig: GenerationConfig(
          temperature: 0.8,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
      );
    }

    // xAI 키 저장
    _xaiApiKey = dotenv.env['XAI_API_KEY'];

    _isInitialized = true;
  }

  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<GeminiResponse> generateStrategy({
    required Character character,
    required String concern,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final prompt = '''${character.systemPrompt}

사용자의 메시지:
$concern

위 내용을 분석하여 JSON 형식으로 응답해주세요.''';

    // 3번까지 재시도 (1번: Gemini, 2-3번: Grok)
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        String? responseText;

        if (attempt == 1) {
          // 첫 번째 시도: Gemini
          print('=== Trying Gemini API (attempt $attempt) ===');
          responseText = await _callGemini(prompt);
        } else {
          // 2-3번째 시도: xAI Grok
          print('=== Trying xAI Grok API (attempt $attempt) ===');
          responseText = await _callGrok(prompt);
        }

        if (responseText == null || responseText.isEmpty) {
          throw Exception('Empty response');
        }

        // Extract JSON from response
        final jsonString = _extractJson(responseText);
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;

        return GeminiResponse.fromJson(jsonData);
      } catch (e) {
        print('=== API Error (attempt $attempt/$_maxRetries) ===');
        print('Error: $e');

        // JSON 파싱 에러는 fallback 반환
        if (e.toString().contains('FormatException')) {
          return GeminiResponse(
            isConcern: true,
            result: _getFallbackStrategy(character),
          );
        }

        // 마지막 시도가 아니면 대기 후 재시도
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay);
          continue;
        }

        // 3번 모두 실패
        return GeminiResponse.serverBusy();
      }
    }

    return GeminiResponse.serverBusy();
  }

  Future<String?> _callGemini(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await _geminiModel.generateContent(content);
    return response.text;
  }

  Future<String?> _callGrok(String prompt) async {
    if (_xaiApiKey == null || _xaiApiKey!.isEmpty) {
      throw Exception('xAI API key not found');
    }

    final response = await http.post(
      Uri.parse('https://api.x.ai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_xaiApiKey',
      },
      body: json.encode({
        'model': 'grok-3-fast',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.8,
        'max_tokens': 2048,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Grok API error: ${response.statusCode} - ${response.body}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('No choices in response');
    }

    final message = choices[0]['message'] as Map<String, dynamic>?;
    return message?['content'] as String?;
  }

  String _extractJson(String text) {
    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}');

    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      return text.substring(jsonStart, jsonEnd + 1);
    }

    throw const FormatException('No valid JSON found in response');
  }

  StrategyResult _getFallbackStrategy(Character character) {
    return StrategyResult(
      best: StrategyItem(
        title: '근본적 해결',
        subtitle: '문제의 원인을 직접 해결하는 방법',
        description:
            '${character.name}이 분석한 결과, 가장 이상적인 해결책은 문제의 근본 원인을 파악하고 직접 해결하는 것입니다.',
        quote: '천리 길도 한 걸음부터 시작됩니다.',
      ),
      middle: StrategyItem(
        title: '현실적 타협',
        subtitle: '상황에 맞는 균형 잡힌 접근',
        description: '현재 상황과 자원을 고려하여 실현 가능한 수준에서 최선의 결과를 도출하는 방법입니다.',
        quote: '물은 낮은 곳으로 흐르지만, 결국 바다에 이릅니다.',
      ),
      worst: StrategyItem(
        title: '임시방편',
        subtitle: '급할 때 사용하는 응급 처치',
        description: '당장의 위기를 넘기기 위한 방법입니다. 근본적 해결은 아니지만 시간을 벌 수 있습니다.',
        quote: '급할수록 돌아가라, 하지만 때로는 직진도 필요합니다.',
      ),
    );
  }
}
