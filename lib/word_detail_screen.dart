// ファイル名: lib/word_detail_screen.dart

import 'package:flutter/material.dart';
import 'word_data.dart';
import 'study_session.dart';
import 'word_edit_add_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WordDetailScreen extends StatefulWidget {
  final StudySession session;
  final Function(Word updatedWord) onWordSaved;

  const WordDetailScreen({
    super.key,
    required this.session,
    required this.onWordSaved,
  });

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late StudySession _currentSession;
  bool _isWordTranslationVisible = false;
  bool _isExampleTranslationVisible = false;

  final FlutterTts flutterTts = FlutterTts();

  void initializeTts() {
    flutterTts.setLanguage("en"); // 英語に設定
    flutterTts.setSpeechRate(0.5);
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
    initializeTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speak(_currentSession.currentWord.word);
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _toggleLearnedStatus() {
    final updatedWord = _currentSession.currentWord.toggleLearnedStatus();
    Navigator.pop(context, updatedWord);
  }

  void _goToNextWord() {
    if (_currentSession.currentList.length > 1) {
      setState(() {
        _currentSession = _currentSession.next();
        _isWordTranslationVisible = false;
        _isExampleTranslationVisible = false;
        speak(_currentSession.currentWord.word);
      });
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildContentCard({
    required String title,
    required String mainText,
    required String translationText,
    required bool isVisible,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const Divider(),
            Text(
              mainText,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),

            InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isVisible ? translationText : 'タップして訳を表示',
                  style: TextStyle(
                    fontSize: 20,
                    color: isVisible ? Colors.black87 : Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ★フリーズ回避のため setState を含まない最終形
  void _editWord() async {
    final currentWord = _currentSession.currentWord;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordEditAddScreen(
          wordToEdit: currentWord,
          onSaveWord: (updatedWord) {
            widget.onWordSaved(updatedWord); // 編集画面を閉じ、更新された単語を戻り値として返す
            Navigator.pop(context);
          },
        ),
      ),
    );
    //await Future.delayed(const Duration(milliseconds: 100));
    // データを親へ渡し、画面を閉じる。setStateは不要。
    //Navigator.pop(context);
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _currentSession.currentWord;
    final statusButtonLabel = currentWord.isLearned ? 'Retry' : 'Learned';
    final statusButtonColor = currentWord.isLearned
        ? Colors.orange
        : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentWord.word),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => speak(currentWord.word),
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: _editWord),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildContentCard(
              title: 'Word / Phrase',
              mainText: currentWord.word,
              translationText: currentWord.translation,
              isVisible: _isWordTranslationVisible,
              onTap: () {
                setState(() {
                  _isWordTranslationVisible = !_isWordTranslationVisible;
                });
                speak(currentWord.word);
              },
            ),

            _buildContentCard(
              title: 'Example Sentence',
              mainText: currentWord.exampleSentence,
              translationText: currentWord.exampleTranslation,
              isVisible: _isExampleTranslationVisible,
              onTap: () {
                setState(() {
                  _isExampleTranslationVisible = !_isExampleTranslationVisible;
                });
                speak(currentWord.exampleSentence);
              },
            ),

            if (currentWord.imageUrl != null)
              Image.network(
                currentWord.imageUrl!,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(child: Text('image load failed')),
                ),
              ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: _toggleLearnedStatus,
              icon: Icon(
                currentWord.isLearned ? Icons.rotate_left : Icons.check,
              ),
              label: Text(
                statusButtonLabel,
                style: const TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusButtonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: _goToNextWord,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
