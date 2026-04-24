// lib/core/constants/board_color_themes.dart
import 'package:flutter/material.dart';

class BoardColorTheme {
  final String id;
  final String name;
  final String emoji;
  final Color ring1;       // birincil halka rengi
  final Color ring2;       // ikincil halka rengi
  final Color outerBull;   // yeşil dış boğa
  final Color bullseye;    // kırmızı merkez
  final Color background;  // tahta arka planı
  final Color wire;        // teller / sınır çizgileri
  final Color glowColor;   // parlama efekti rengi
  final Color numberColor; // numara rengi

  const BoardColorTheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.ring1,
    required this.ring2,
    required this.outerBull,
    required this.bullseye,
    required this.background,
    required this.wire,
    required this.glowColor,
    required this.numberColor,
  });

  // ─── Temalar ──────────────────────────────────────────────────
  static const classic = BoardColorTheme(
    id: 'classic',
    name: 'Klasik',
    emoji: '🎯',
    ring1: Color(0xFFCC1818),
    ring2: Color(0xFF1A1A1A),
    outerBull: Color(0xFF00C853),
    bullseye: Color(0xFFCC1818),
    background: Color(0xFF2A1A08),
    wire: Color(0xFFD4AF37),
    glowColor: Color(0xFFCC1818),
    numberColor: Colors.white,
  );

  static const ocean = BoardColorTheme(
    id: 'ocean',
    name: 'Okyanus',
    emoji: '🌊',
    ring1: Color(0xFF0055CC),
    ring2: Color(0xFF001840),
    outerBull: Color(0xFF00D9FF),
    bullseye: Color(0xFF0055CC),
    background: Color(0xFF001030),
    wire: Color(0xFF00D9FF),
    glowColor: Color(0xFF0077FF),
    numberColor: Color(0xFF00D9FF),
  );

  static const forest = BoardColorTheme(
    id: 'forest',
    name: 'Orman',
    emoji: '🌲',
    ring1: Color(0xFF00A847),
    ring2: Color(0xFF0A1F0A),
    outerBull: Color(0xFF76FF03),
    bullseye: Color(0xFF00A847),
    background: Color(0xFF061406),
    wire: Color(0xFF76FF03),
    glowColor: Color(0xFF00C853),
    numberColor: Color(0xFF76FF03),
  );

  static const sunset = BoardColorTheme(
    id: 'sunset',
    name: 'Gün Batımı',
    emoji: '🌅',
    ring1: Color(0xFFE85C1A),
    ring2: Color(0xFF1A0A00),
    outerBull: Color(0xFFFFD700),
    bullseye: Color(0xFFE85C1A),
    background: Color(0xFF140600),
    wire: Color(0xFFFFD700),
    glowColor: Color(0xFFFF7043),
    numberColor: Color(0xFFFFD700),
  );

  static const neon = BoardColorTheme(
    id: 'neon',
    name: 'Neon',
    emoji: '⚡',
    ring1: Color(0xFF6C63FF),
    ring2: Color(0xFF08081A),
    outerBull: Color(0xFF00E5FF),
    bullseye: Color(0xFFFF2D92),
    background: Color(0xFF03030F),
    wire: Color(0xFF00E5FF),
    glowColor: Color(0xFF6C63FF),
    numberColor: Color(0xFF00E5FF),
  );

  static const List<BoardColorTheme> all = [classic, ocean, forest, sunset, neon];

  static BoardColorTheme fromId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => classic);
}
