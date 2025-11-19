// lib/features/insightmind/presentation/pages/result_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/score_provider.dart';
import 'main_nav_page.dart'; // Import untuk navigasi kembali

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(resultProvider);

    // Tentukan warna berdasarkan tingkat risiko untuk visual interaktif (Dark Mode Friendly)
    Color riskColor;
    switch (result.riskLevel) {
      case 'Tinggi':
        riskColor = Colors.redAccent.shade200; // Lebih cerah untuk Dark Mode
        break;
      case 'Sedang':
        riskColor = Colors.orangeAccent.shade200; // Lebih cerah untuk Dark Mode
        break;
      case 'Rendah':
      default:
        riskColor = Colors.greenAccent.shade200; // Lebih cerah untuk Dark Mode
        break;
    }

    // Tentukan warna untuk teks saran dan disclaimer
    final Color suggestionTextColor = Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8);
    final Color disclaimerTextColor = Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Screening'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Kembali ke MainNavPage (home) dan kosongkan stack
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavPage()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      // MENGHAPUS Container/BoxDecoration Gradien yang membuat warna tabrakan
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Skor Anda:',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7), 
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.score.toString(),
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent, // Warna yang sangat menonjol di Dark Mode
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tingkat Risiko: ${result.riskLevel}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: riskColor, // Warna dinamis sesuai risiko
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Menggunakan field suggestion dari usecase
                    Text(
                      result.suggestion, 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: suggestionTextColor, // Warna teks saran
                      ),
                    ),
                  ],
                ),
              ),
              // Disclaimer di bagian paling bawah
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // Menggunakan warna Card Theme yang sudah diatur gelap di src/app.dart
                    color: Theme.of(context).cardColor, 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Disclaimer: InsightMind bersifat edukatif, bukan alat diagnosis medis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: disclaimerTextColor, // Warna teks disclaimer
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
