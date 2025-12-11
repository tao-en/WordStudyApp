// 単語セットの「設計図」となるクラス
class Word {
  // 必須の要素
  final String word; // 英単語
  final String translation; // 日本語訳
  final String exampleSentence; // 例文（英文）
  final String exampleTranslation; // 例文の日本語訳

  // 任意（後で変更される可能性のある）の要素
  final String? imageUrl; // イメージ図のURL (画像がない場合はnull)
  final bool isLearned; // 学習済みリストに入っているか (初期値は false)

  // コンストラクタ：Wordクラスのインスタンスを作成するときに使う関数
  const Word({
    required this.word,
    required this.translation,
    required this.exampleSentence,
    required this.exampleTranslation,
    this.imageUrl, // imageUrlとisLearnedはrequiredではない
    this.isLearned = false, // 初期値として false を設定
  });

  // ========== 学習済みリストへの移動を可能にするための処理 ==========

  // isLearnedの状態を反転させた新しいWordインスタンスを返す関数
  Word toggleLearnedStatus() {
    return Word(
      word: word,
      translation: translation,
      exampleSentence: exampleSentence,
      exampleTranslation: exampleTranslation,
      imageUrl: imageUrl,
      isLearned: !isLearned, // 現在の状態を反転させる (trueならfalseに、falseならtrueに)
    );
  }
}

// ========== アプリで使うダミーデータ（テスト用） ==========

// 開発中に動作確認するための仮の単語リストです。
final List<Word> sampleWords = [
  const Word(
    word: 'develop',
    translation: '開発する',
    exampleSentence: 'I want to develop a useful application.',
    exampleTranslation: '私は役に立つアプリケーションを開発したい。',
    imageUrl: 'https://example.com/develop_img.jpg', // ダミーURL
  ),
  const Word(
    word: 'concept',
    translation: '概念',
    exampleSentence: 'The concept of this app is very simple.',
    exampleTranslation: 'このアプリの概念はとてもシンプルだ。',
    // imageUrlがnullの単語も作成してみます
  ),
  const Word(
    word: 'environment',
    translation: '環境',
    exampleSentence: 'We need to set up the development environment.',
    exampleTranslation: '私たちは開発環境をセットアップする必要がある。',
    isLearned: true, // 最初から学習済みにしておく単語
  ),
];
