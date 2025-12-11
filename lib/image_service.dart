import 'dart:convert';
import 'package:http/http.dart' as http;

// ★★★ 取得したご自身の API キーに置き換えてください ★★★
const String PIXABAY_API_KEY = '53654683-dd3eb7dbedf814decc127055b';
// ★★★ 取得したご自身の API キーに置き換えてください ★★★

class ImageService {
  // Pixabay APIを使って単語に関連する画像を検索し、URLを返す
  Future<String?> searchImageUrl(String query) async {
    // 検索クエリをURLエンコード（例: 'study hard' -> 'study+hard'）
    final encodedQuery = Uri.encodeComponent(query);

    // API呼び出しURLの構築
    final url = Uri.parse(
      'https://pixabay.com/api/?key=$PIXABAY_API_KEY&q=$encodedQuery&image_type=photo&per_page=3&safesearch=true&lang=en',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 成功した場合
        final data = json.decode(response.body);

        // ヒットした画像があるか確認
        if (data['hits'] != null && data['hits'].length > 0) {
          // 最初の画像のWebformatURL（中サイズ）を返す
          return data['hits'][0]['webformatURL'];
        } else {
          // 画像が見つからなかった
          print('No images found for: $query');
          return null;
        }
      } else {
        // API呼び出しが失敗した場合
        print('API request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // ネットワークエラーなど
      print('An error occurred during API request: $e');
      return null;
    }
  }
}
