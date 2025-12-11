import 'package:flutter/material.dart';
import 'word_data.dart';
import 'word_list_screen.dart';
import 'word_edit_add_screen.dart';
import 'study_session.dart';
import 'word_detail_screen.dart';

// ========== アプリ全体のメイン画面（タブ切り替えと状態管理） ==========

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 0: Unlearned, 1: Learned
  // 単語リスト全体をここで管理し、変更可能にします (var/List<Word>)
  List<Word> _allWords = sampleWords.toList(); // ダミーデータをコピーして使用

  // 単語の状態（isLearned）が更新されたときに呼ばれる関数
  void _handleWordSave(Word savedWord) {
    // デバッグ用: Wordが届いたか確認
    print('--- DEBUG: Saving Word ---');
    print('Received Word: ${savedWord.word}');
    print('Current List Size BEFORE: ${_allWords.length}');

    setState(() {
      // 既存のリスト内の単語を見つける（編集の場合）
      final index = _allWords.indexWhere((word) => word.word == savedWord.word);

      print('Index Found: $index');

      if (index != -1) {
        // 編集の場合: 既存の単語を置き換える
        _allWords[index] = savedWord;
        print('ACTION: EDITED existing word.');
      } else {
        // 追加の場合: 新しい単語をリストの先頭に追加
        _allWords = [savedWord, ..._allWords];
        print('ACTION: ADDED new word.');
      }

      _selectedIndex = 0; // 状態更新後は未学習タブに戻る
    });

    print('Current List Size AFTER: ${_allWords.length}');
    print('--- END DEBUG ---');
  }

  // シャッフルロジック
  void _shuffleWordsAndStart() async {
    //現在表示しているタブのリストを取得
    List<Word> targetList;
    if (_selectedIndex == 0) {
      targetList = _allWords.where((w) => !w.isLearned).toList();
    } else {
      targetList = _allWords.where((w) => w.isLearned).toList();
    }

    if (targetList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No words to shuffle in this tab.')),
      );
      return;
    }

    // Unlearned の全単語をシャッフル
    targetList.shuffle();

    // シャッフルしたリストからセッションを作成
    final session = StudySession(currentList: targetList, currentIndex: 0);

    // 詳細画面を開く (結果を受け取る)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WordDetailScreen(session: session, onWordSaved: _handleWordSave),
      ),
    );

    // 詳細画面から単語の状態が返ってきた場合 (Learned/Retry, Edit のトグル)
    if (result != null && result is Word) {
      _handleWordSave(result);
    }
  }

  // ポップアップメニューを表示する関数（Add/Shuffleボタン）
  Widget _buildPopupActions() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        if (result == 'add') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WordEditAddScreen(onSaveWord: _handleWordSave),
            ),
          );
        } else if (result == 'shuffle') {
          _shuffleWordsAndStart();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'add',
          child: ListTile(leading: Icon(Icons.add), title: Text('Add Word')),
        ),
        const PopupMenuItem<String>(
          value: 'shuffle',
          child: ListTile(
            leading: Icon(Icons.shuffle),
            title: Text('Shuffle Start'),
          ),
        ),
      ],
      icon: const Icon(Icons.menu),
    );
  }

  // 選択されたタブの画面を生成
  Widget _buildCurrentScreen() {
    final unlearnedWords = _allWords.where((w) => !w.isLearned).toList();
    final learnedWords = _allWords.where((w) => w.isLearned).toList();

    if (_selectedIndex == 0) {
      return WordListScreen(
        words: unlearnedWords,
        onWordUpdated: _handleWordSave,
        onWordSaved: _handleWordSave,
      );
    } else {
      return WordListScreen(
        words: learnedWords,
        onWordUpdated: _handleWordSave,
        onWordSaved: _handleWordSave,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Unlearned Words (${_allWords.where((w) => !w.isLearned).length})'
              : 'Learned Words (${_allWords.where((w) => w.isLearned).length})',
        ),
        actions: <Widget>[
          _buildPopupActions(), // ポップアップボタン
        ],
      ),
      body: _buildCurrentScreen(), // 選択された画面を表示

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Unlearned'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Learned',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

void main() {
  runApp(const WordStudyApp());
}

class WordStudyApp extends StatelessWidget {
  const WordStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '英単語学習アプリ',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {'/': (context) => const MainScreen()},
      // home: const MainScreen(),
    );
  }
}
