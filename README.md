# 📕 Word Study App - 英単語学習アプリ

## 概要 (Overview)

このプロジェクトは、Flutter/Dart で開発された英単語学習アプリケーションです。

ユーザーは単語を追加し、学習済み・未学習リストで管理できます。最も特徴的な機能として、高度な外部API連携による単語セットの自動生成機能を備えています。

## 💡 主要機能 (Features)

1. **データ管理**: 未学習 / 学習済みタブでの単語のフィルタリングと管理。
2. **LLM連携による自動入力**:
    * 英単語のみを入力すると、**Gemini API** を利用して日本語訳、例文、例文の日本語訳を自動生成し、フォームに埋め込みます。
3. **画像自動取得**: Pixabay APIを利用し、英単語に関連する画像を自動で検索・表示します。
4. **学習機能**: TTS (Text-to-Speech) による英単語・例文の音声読み上げ機能。

## 🛠️ 実行環境 (Setup & Requirements)

このアプリを実行するには、以下の環境が必要です。

* **Flutter SDK**: 最新の安定版
* **Dart SDK**
* **API Key (必須)**:
    1. **Gemini API Key**: 自動翻訳機能のために必要です。（`lib/translation_service.dart` に設定）
    2. **Pixabay API Key**: 画像検索のために必要です。（`lib/image_service.dart` に設定）

### ローカルでの実行手順

1. リポジトリをクローンします。
   ```bash
   git clone [https://github.com/tao-en/WordStudyApp.git](https://github.com/tao-en/WordStudyApp.git)
   cd WordStudyApp

2. 必要なパッケージをインストールします。
    ```bash
    flutter pub get

3. 上記の記載の通り、各APIサービスファイルにキーを設定します。

4. アプリを実行します。
    ```bash
    flutter run