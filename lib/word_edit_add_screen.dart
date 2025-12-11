import 'package:flutter/material.dart';
import 'word_data.dart';
import 'image_service.dart';
import 'translation_service.dart'; // ★Gemini APIのサービスをインポート

class WordEditAddScreen extends StatefulWidget {
  final Word? wordToEdit;
  final void Function(Word updatedWord) onSaveWord;

  const WordEditAddScreen({
    super.key,
    this.wordToEdit,
    required this.onSaveWord,
  });

  @override
  State<WordEditAddScreen> createState() => _WordEditAddScreenState();
}

class _WordEditAddScreenState extends State<WordEditAddScreen> {
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _exampleSentenceController = TextEditingController();
  final _exampleTranslationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoadingImage = false;
  bool _isLoadingAutoFill = false;

  @override
  void initState() {
    super.initState();
    if (widget.wordToEdit != null) {
      final word = widget.wordToEdit!;
      _wordController.text = word.word;
      _translationController.text = word.translation;
      _exampleSentenceController.text = word.exampleSentence;
      _exampleTranslationController.text = word.exampleTranslation;
      _imageUrlController.text = word.imageUrl ?? '';
    }
  }

  // 翻訳・例文を自動入力するロジック（_saveWordから呼ばれる）
  Future<void> _fillMissingFields() async {
    final word = _wordController.text.trim();
    if (word.isEmpty) return;

    final TranslationService service = TranslationService();
    final Map<String, String>? results = await service.getTranslationAndExample(
      word,
    );

    if (results != null) {
      // 空のフィールドのみ埋める
      if (_translationController.text.trim().isEmpty) {
        _translationController.text = results['translation'] ?? '';
      }
      if (_exampleSentenceController.text.trim().isEmpty) {
        _exampleSentenceController.text = results['exampleSentence'] ?? '';
      }
      if (_exampleTranslationController.text.trim().isEmpty) {
        _exampleTranslationController.text =
            results['exampleTranslation'] ?? '';
      }
    }
  }

  // 単語セットを保存する処理 (自動埋め込みロジックを統合)
  void _saveWord() async {
    // 1. 英単語（キー）の検証のみ、手動で実行
    if (_wordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('英単語 (Word) は必須項目です。')));
      return;
    }

    // 2. 必須項目が埋まっていない場合、自動埋め込みを試行
    // (自動入力されるため、必須項目が空でも処理を進める)
    if (_translationController.text.trim().isEmpty ||
        _exampleSentenceController.text.trim().isEmpty ||
        _exampleTranslationController.text.trim().isEmpty) {
      setState(() {
        _isLoadingAutoFill = true;
      });
      await _fillMissingFields();
      setState(() {
        _isLoadingAutoFill = false;
      });

      // 自動埋め込み後も主要項目が空の場合（APIエラー）、保存を中断し警告
      if (_translationController.text.trim().isEmpty ||
          _exampleSentenceController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('自動埋め込みに失敗しました。手動で入力してください。')),
        );
        return;
      }
    }

    // 3. 画像URLが空の場合、画像を自動検索する
    if (_imageUrlController.text.trim().isEmpty) {
      setState(() {
        _isLoadingImage = true;
      });
      final query = _wordController.text.trim();
      final service = ImageService();
      final imageUrl = await service.searchImageUrl(query);

      if (imageUrl != null) {
        _imageUrlController.text = imageUrl;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('画像URLなしで保存しました。')));
      }
      setState(() {
        _isLoadingImage = false;
      });
    }

    // 4. Wordインスタンスを作成し、保存する
    final bool isLearnedStatus = widget.wordToEdit?.isLearned ?? false;

    final updatedWord = Word(
      word: _wordController.text.trim(),
      translation: _translationController.text.trim(),
      exampleSentence: _exampleSentenceController.text.trim(),
      exampleTranslation: _exampleTranslationController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      isLearned: isLearnedStatus,
    );

    widget.onSaveWord(updatedWord);
    Navigator.pop(context);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = true,
  }) {
    // 自動で埋まる項目（日本語訳、例文、例文訳）の場合、検証を無効化する

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: widget.wordToEdit != null && label.contains('英単語'),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          helperText: widget.wordToEdit != null && label.contains('英単語')
              ? '※キーとなる英単語は編集できません'
              : null,
        ),

        // 必須検証は、英単語欄（必須）のみ有効化
        validator: (label.contains('英単語') && isRequired)
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label は必須項目です。';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.wordToEdit != null;
    final isLoading = _isLoadingImage || _isLoadingAutoFill;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit word' : 'Add new word')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 1. 英単語 (必須)
              _buildTextField(controller: _wordController, label: '英単語 (Word)'),

              // 2. 日本語訳 (必須だが自動埋め込み対象)
              _buildTextField(
                controller: _translationController,
                label: '日本語訳 (Translation)',
              ),

              // 3. 例文（英文） (必須だが自動埋め込み対象)
              _buildTextField(
                controller: _exampleSentenceController,
                label: '例文（英文） (Example Sentence)',
              ),

              // 4. 例文の日本語訳 (必須だが自動埋め込み対象)
              _buildTextField(
                controller: _exampleTranslationController,
                label: '例文の日本語訳 (Example Translation)',
              ),

              // 5. イメージ図のURL (任意)
              _buildTextField(
                controller: _imageUrlController,
                label: '画像URL (Optional Image URL)',
                isRequired: false,
              ),
              const SizedBox(height: 30),

              // 6. 保存ボタン
              ElevatedButton.icon(
                onPressed: isLoading ? null : _saveWord,
                icon: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isEditing ? 'Save changes' : 'Save new word',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _exampleSentenceController.dispose();
    _exampleTranslationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
