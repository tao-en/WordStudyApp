import 'dart:convert';
import 'package:http/http.dart' as http;

const String PIXABAY_API_KEY = 'Enter Your API Key';

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
        final data = json.decode(response.body);

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
