// ファイル名: lib/word_list_screen.dart

import 'package:flutter/material.dart';
import 'word_data.dart';
import 'word_detail_screen.dart';
import 'study_session.dart';

class WordListScreen extends StatelessWidget {
  final List<Word> words;
  final Function(Word updatedWord) onWordUpdated;
  final Function(Word updatedWord) onWordSaved;

  const WordListScreen({
    super.key,
    required this.words,
    required this.onWordUpdated,
    required this.onWordSaved,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Center(
        child: Text(
          'No words. You should add or switch tabs.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: ListTile(
            leading: Icon(
              word.isLearned ? Icons.check_circle : Icons.book,
              color: word.isLearned ? Colors.green : Colors.blue,
            ),
            title: Text(
              word.word,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(word.translation),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final session = StudySession(
                currentList: words,
                currentIndex: index,
              );

              // 詳細画面を開き、結果が返ってくるのを待つ
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordDetailScreen(
                    session: session,
                    onWordSaved: onWordSaved,
                  ),
                ),
              );

              // 結果が Word 型の場合（Learned/Retry または Edit の結果）
              if (result != null && result is Word) {
                // 結果が返ってきたら、そのまま MainScreen に渡してリストを更新してもらう
                onWordUpdated(result);
              }
            },
          ),
        );
      },
    );
  }
}
