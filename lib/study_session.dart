import 'word_data.dart';

// 単語詳細画面に渡すためのセッション情報
class StudySession {
  final List<Word> currentList; // 現在表示している単語リスト（未学習または学習済み）
  final int currentIndex; // 現在見ている単語のインデックス

  const StudySession({required this.currentList, required this.currentIndex});

  // 次の単語に進むための新しいセッション情報を作成
  StudySession next() {
    // リストの最後に来た場合、最初に戻る
    final nextIndex = (currentIndex + 1) % currentList.length;
    return StudySession(currentList: currentList, currentIndex: nextIndex);
  }

  // 現在の単語を取得
  Word get currentWord => currentList[currentIndex];
}
