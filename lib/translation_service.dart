// ★注意: このコードはGemini APIを前提としています。他のAPIを使う場合は内容が変わります。

import 'dart:convert';
import 'package:http/http.dart' as http;

// ★★★ 取得したご自身の API キーに置き換えてください ★★★
const String GEMINI_API_KEY = 'AIzaSyCEqUEBoPwp3Dq_VzwL0Dbmja620JgexfE';
// ★★★ 取得したご自身の API キーに置き換えてください ★★★

class TranslationService {
  final String apiUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY';

  Future<Map<String, String>?> getTranslationAndExample(String word) async {
    if (word.trim().isEmpty) return null;

    final prompt =
        '''
      You are a professional dictionary and English teacher.
      Analyze the word "$word" and provide the following information in strict JSON format:
      {
        "translation": "日本語訳 (Japanese Translation)",
        "exampleSentence": "簡潔な英語の例文",
        "exampleTranslation": "例文の日本語訳"
      }
      Do not include any pre-amble or explanation outside of the JSON block.
    ''';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // LLMの応答からJSON文字列を抽出
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        // JSONパース
        // LLMの出力は時にJSONの前後が汚れるため、JSONブロックだけを抽出する
        final jsonString = text.substring(
          text.indexOf('{'),
          text.lastIndexOf('}') + 1,
        );
        final jsonResult = json.decode(jsonString);

        if (jsonResult is Map<String, dynamic>) {
          return {
            'translation': jsonResult['translation']?.toString() ?? '',
            'exampleSentence': jsonResult['exampleSentence']?.toString() ?? '',
            'exampleTranslation':
                jsonResult['exampleTranslation']?.toString() ?? '',
          };
        }
      }
      print('API Error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Network Error or JSON Parsing Failed: $e');
      return null;
    }
  }
}
