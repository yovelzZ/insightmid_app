// lib/features/insightmind/presentation/pages/summary_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/question.dart';
import '../providers/questionnaire_provider.dart';
import '../providers/score_provider.dart';
import 'result_page.dart';

// Import yang diperlukan
import '../../domain/entities/history_entry.dart';
import '../providers/history_provider.dart'; 
// Asumsi Anda juga telah mendefinisikan historyRepositoryProvider di tempat lain

class SummaryPage extends ConsumerWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);

    // Cek apakah semua pertanyaan sudah dijawab untuk validasi tombol
    final isAllAnswered = questions.every(
      (q) => qState.answers.containsKey(q.id) && qState.answers[q.id] != null,
    );
    
    // Tentukan warna accent untuk teks jawaban agar kontras di Dark Mode
    final Color accentColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.tealAccent.shade400 // Warna cerah di Dark Mode
        : Theme.of(context).primaryColor; // Primary Color di Light Mode

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Jawaban Anda'),
      ),
      // --- PERBAIKAN UTAMA DARK MODE DI SINI ---
      // Menghapus Container/BoxDecoration agar Scaffold yang mengatur latar belakang
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: questions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final q = questions[index];
          final selectedScore = qState.answers[q.id];

          final selectedLabel = q.options
              .firstWhere(
                (opt) => opt.score == selectedScore,
                orElse: () =>
                    const AnswerOption(label: 'Belum dijawab', score: -1),
              )
              .label;

          return Card(
            // Card color akan otomatis menyesuaikan dengan tema gelap
            color: Theme.of(context).cardColor, 
            elevation: 2.0,
            child: ListTile(
              title: Text(
                q.text,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                selectedLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor, // Menggunakan warna accent yang sudah disesuaikan
                ),
              ),
            ),
          );
        },
      ),
      // ------------------------------------------
      
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Konfirmasi & Lihat Hasil'),
            // --- PERBAIKAN VALIDASI TOMBOL DI SINI ---
            onPressed: isAllAnswered ? () async { 
              final answersOrdered = <int>[];
              for (final q in questions) {
                // Menggunakan ?? 0 untuk ketahanan, meskipun tombol sudah divalidasi
                answersOrdered.add(qState.answers[q.id] ?? 0); 
              }
              ref.read(answersProvider.notifier).state = answersOrdered;

              // 2. Ambil hasil akhir untuk disimpan
              final result = ref.read(resultProvider);

              // 3. Buat entri riwayat baru
              final newEntry = HistoryEntry(
                score: result.score,
                riskLevel: result.riskLevel,
                date: DateTime.now(),
              );

              // 4. Simpan ke database (Pastikan historyRepositoryProvider tersedia!)
              try {
                // ASUMSI: historyRepositoryProvider adalah Provider yang valid
                await ref.read(historyRepositoryProvider).addHistory(newEntry);
              } catch (e) {
                // Tampilkan error jika repository tidak ditemukan/gagal menyimpan
                print('Error saving history: $e');
                // Anda bisa tambahkan Snackbar di sini untuk feedback user
              }

              // 5. Reset provider riwayat agar UI update
              ref.invalidate(historyProvider);
              
              // 6. Reset form kuesioner
              ref.read(questionnaireProvider.notifier).reset();

              // 7. Navigasi ke ResultPage
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ResultPage()),
                );
              }
            } : null, // Tombol nonaktif jika belum semua dijawab
          ),
        ),
      ),
    );
  }
}
