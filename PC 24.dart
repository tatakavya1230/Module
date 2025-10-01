import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:async'; // Required for Future

void main() {
  runApp(
    const ProviderScope(
      child: MusicColorApp(),
    ),
  );
}

// Riverpod providers for state management
final colorStateProvider = StateNotifierProvider<ColorStateNotifier, ColorState>((ref) {
  return ColorStateNotifier();
});

// Color state model
class ColorState {
  final Color appBarColor;
  final Color scaffoldColor;
  final String currentNote;

  const ColorState({
    required this.appBarColor,
    required this.scaffoldColor,
    required this.currentNote,
  });

  ColorState copyWith({
    Color? appBarColor,
    Color? scaffoldColor,
    String? currentNote,
  }) {
    return ColorState(
      appBarColor: appBarColor ?? this.appBarColor,
      scaffoldColor: scaffoldColor ?? this.scaffoldColor,
      currentNote: currentNote ?? this.currentNote,
    );
  }
}

// Color state notifier
class ColorStateNotifier extends StateNotifier<ColorState> {
  ColorStateNotifier() : super(const ColorState(
    appBarColor: Colors.blue,
    scaffoldColor: Colors.blueAccent,
    currentNote: 'C',
  ));

  static const List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  static const List<String> _notes = [
    'C', 'D', 'E', 'F', 'G', 'A', 'B', 'C#', 'D#', 'F#'
  ];

  void changeColorsAndPlayNote() {
    final random = Random();
    final colorIndex = random.nextInt(_colors.length);
    final noteIndex = random.nextInt(_notes.length);
    
    final selectedColor = _colors[colorIndex];
    final selectedNote = _notes[noteIndex];
    
    // Create a lighter shade for scaffold
    final scaffoldColor = Color.lerp(selectedColor, Colors.white, 0.7) ?? selectedColor;
    
    state = state.copyWith(
      appBarColor: selectedColor,
      scaffoldColor: scaffoldColor,
      currentNote: selectedNote,
    );
  }
}

class MusicColorApp extends ConsumerWidget {
  const MusicColorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorState = ref.watch(colorStateProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music & Color App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: colorState.scaffoldColor,
        appBar: AppBar(
          title: const Text(
            'Music & Color App',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: colorState.appBarColor,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        body: const MusicColorBody(),
      ),
    );
  }
}

class MusicColorBody extends ConsumerWidget {
  const MusicColorBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorState = ref.watch(colorStateProvider);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Current note display
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // Fix: Replaced withOpacity with Color.fromARGB for explicit alpha
                color: Color.fromARGB((0.9 * 255).round(), (Colors.white.r * 255).round(), (Colors.white.g * 255).round(), (Colors.white.b * 255).round()),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // Fix: Replaced withOpacity with Color.fromARGB for explicit alpha
                    color: Color.fromARGB((0.1 * 255).round(), (Colors.black.r * 255).round(), (Colors.black.g * 255).round(), (Colors.black.b * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.music_note,
                    size: 60,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current Note: ${colorState.currentNote}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Main action button
            ElevatedButton.icon(
              onPressed: () async {
                // Change colors and note
                ref.read(colorStateProvider.notifier).changeColorsAndPlayNote();
                
                // Simulate playing the note
                await _playNote(colorState.currentNote);
              },
              icon: const Icon(Icons.play_arrow, size: 28),
              label: const Text(
                'Change Colors & Play Note',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorState.appBarColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Fix: Replaced withOpacity with Color.fromARGB for explicit alpha
                color: Color.fromARGB((0.8 * 255).round(), (Colors.white.r * 255).round(), (Colors.white.g * 255).round(), (Colors.white.b * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.black54,
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the button to change colors and play a random music note!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simulate playing different notes
  Future<void> _playNote(String note) async {
    // Since audioplayers is not allowed, we simulate sound playback
    // by calling our custom SystemSoundPlayer (which just prints)
    await SystemSoundPlayer.playNote(note);
  }
}

// Alternative implementation using system sounds (simulated for this example)
class SystemSoundPlayer {
  static Future<void> playNote(String note) async {
    // This would ideally use Flutter's system sound capabilities
    // For this example, we'll just print the note being played to the console
    debugPrint('🎵 Playing note: $note (simulated)');
  }
}