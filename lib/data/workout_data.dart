import 'package:flutter/material.dart';

class WorkoutItem {
  final String category; // latihan/program/tantangan
  final String title;
  final String subtitle;
  final String imageUrl;
  final int defaultMinutes;

  const WorkoutItem({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.defaultMinutes,
  });
}

// ✅ SEMUA GAMBAR COWO GYM (NO CEWEK)
const List<WorkoutItem> kItems = [
  // ===================== LATIHAN (UMUM) =====================
  WorkoutItem(
    category: "latihan",
    title: "Tabata 4 Menit",
    subtitle: "Latihan cepat, pembakar kalori",
    imageUrl:
    "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 4,
  ),
  WorkoutItem(
    category: "latihan",
    title: "HIIT Pembakar Lemak",
    subtitle: "Menengah • full body",
    imageUrl:
    "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 8,
  ),
  WorkoutItem(
    category: "latihan",
    title: "Cardio Tanpa Alat",
    subtitle: "Pemula • stamina & fatburn",
    imageUrl:
    "https://images.unsplash.com/photo-1517964603305-11c0f6f66012?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 10,
  ),

  // ===================== LATIHAN: CORE =====================
  WorkoutItem(
    category: "latihan",
    title: "Core Builder",
    subtitle: "Core • stabilitas & kekuatan",
    imageUrl:
    "https://images.unsplash.com/photo-1517964603305-11c0f6f66012?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 8,
  ),
  WorkoutItem(
    category: "latihan",
    title: "Core Burn 6 Menit",
    subtitle: "Core • pemula • tanpa alat",
    imageUrl:
    "https://images.unsplash.com/photo-1599058918144-1ffabb6ab9a0?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 6,
  ),

  // ===================== LATIHAN: CARDIO =====================
  WorkoutItem(
    category: "latihan",
    title: "Cardio Sprint 7 Menit",
    subtitle: "Cardio • pembakar kalori",
    imageUrl:
    "https://images.unsplash.com/photo-1594381898411-846e7d193883?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 7,
  ),
  WorkoutItem(
    category: "latihan",
    title: "Cardio Endurance",
    subtitle: "Cardio • stamina • menengah",
    imageUrl:
    "https://images.unsplash.com/photo-1579758629938-03607ccdbaba?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 12,
  ),

  // ===================== LATIHAN: LOWER =====================
  WorkoutItem(
    category: "latihan",
    title: "Lower Body Blast",
    subtitle: "Lower • kaki & glutes",
    imageUrl:
    "https://images.unsplash.com/photo-1593079831268-3381b0db4a77?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 10,
  ),
  WorkoutItem(
    category: "latihan",
    title: "Legs & Glutes 8 Menit",
    subtitle: "Lower • pemula • tanpa alat",
    imageUrl:
    "https://images.unsplash.com/photo-1517964603305-11c0f6f66012?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 8,
  ),

  // ===================== LATIHAN: OTOT PERUT (ABS) =====================
  WorkoutItem(
    category: "latihan",
    title: "Abs Shred 6 Menit",
    subtitle: "Otot perut • kencengin core",
    imageUrl:
    "https://images.unsplash.com/photo-1550345332-09e3ac987658?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 6,
  ),
  WorkoutItem(
    category: "latihan",
    title: "3 Latihan Singkirkan Lemak Perut",
    subtitle: "Otot perut • pemula • tanpa alat",
    imageUrl:
    "https://images.pexels.com/photos/1552106/pexels-photo-1552106.jpeg?auto=compress&cs=tinysrgb&w=1200",
    defaultMinutes: 6,
  ),

  // ===================== LATIHAN: LENGAN (ARMS) =====================
  WorkoutItem(
    category: "latihan",
    title: "Arms Pump 8 Menit",
    subtitle: "Lengan • biceps & triceps",
    imageUrl:
    "https://images.pexels.com/photos/1552106/pexels-photo-1552106.jpeg?auto=compress&cs=tinysrgb&w=1200",
    defaultMinutes: 8,
  ),
  WorkoutItem(
    category: "latihan",
    title: "Triceps Burner",
    subtitle: "Lengan • fokus triceps",
    imageUrl:
    "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 7,
  ),

  // ===================== LATIHAN: DADA (CHEST) =====================
  WorkoutItem(
    category: "latihan",
    title: "Chest Builder",
    subtitle: "Dada • push-up focused",
    imageUrl:
    "https://images.unsplash.com/photo-1590487988256-9ed24133863e?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 9,
  ),
  WorkoutItem(
    category: "latihan",
    title: "Push-Up Challenge 5 Menit",
    subtitle: "Dada • cepat & efektif",
    imageUrl:
    "https://images.unsplash.com/photo-1517964603305-11c0f6f66012?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 5,
  ),

  // ===================== LATIHAN: KAKI (LEGS) =====================
  WorkoutItem(
    category: "latihan",
    title: "Leg Day 10 Menit",
    subtitle: "Kaki • strength & endurance",
    imageUrl:
    "https://images.pexels.com/photos/1552106/pexels-photo-1552106.jpeg?auto=compress&cs=tinysrgb&w=1200",
    defaultMinutes: 10,
  ),
  WorkoutItem(
    category: "latihan",
    title: "Squat Burner 6 Menit",
    subtitle: "Kaki • squat focused",
    imageUrl:
    "https://images.unsplash.com/photo-1579758629938-03607ccdbaba?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 6,
  ),

  // ===================== LATIHAN: BAHU (SHOULDERS) =====================
  WorkoutItem(
    category: "latihan",
    title: "Shoulder Strong",
    subtitle: "Bahu • shoulder stability",
    imageUrl:
    "https://images.unsplash.com/photo-1517963879433-6ad2b056d712?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 8,
  ),
  WorkoutItem(
    category: "latihan",
    title: "Delts Burner 7 Menit",
    subtitle: "Bahu • deltoid focused",
    imageUrl:
    "https://images.unsplash.com/photo-1517964603305-11c0f6f66012?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 7,
  ),

  // ===================== LATIHAN: PUNGGUNG (BACK) =====================
  WorkoutItem(
    category: "latihan",
    title: "Back Builder",
    subtitle: "Punggung • posture & strength",
    imageUrl:
    "https://images.unsplash.com/photo-1605296867724-fa87a8ef53fd?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 9,
  ),
  WorkoutItem(
    category: "latihan",
    title: "Pull Workout 8 Menit",
    subtitle: "Punggung • pull focused",
    imageUrl:
    "https://images.unsplash.com/photo-1554284126-aa88f22d8b74?auto=format&fit=crop&w=1400&q=80",
    defaultMinutes: 8,
  ),

  // ===================== PROGRAM =====================
  WorkoutItem(
    category: "program",
    title: "Upper Body Builder",
    subtitle: "Program 14 hari • menengah",
    imageUrl:
    "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1400&q=80",
    defaultMinutes: 12,
  ),
  WorkoutItem(
    category: "program",
    title: "Program Full Body Pemula",
    subtitle: "7 hari • gampang diikuti",
    imageUrl:
    "https://images.unsplash.com/photo-1593079831268-3381b0db4a77?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 10,
  ),
  WorkoutItem(
    category: "program",
    title: "Strength & Stamina",
    subtitle: "21 hari • progresif",
    imageUrl:
    "https://images.unsplash.com/photo-1517964603305-11c0f6f66012?auto=format&fit=crop&w=1200&q=80",
    defaultMinutes: 15,
  ),

  // ===================== TANTANGAN =====================
  WorkoutItem(
    category: "tantangan",
    title: "Tantangan Seluruh Tubuh",
    subtitle: "Full body plan progresif",
    imageUrl:
    "https://images.unsplash.com/photo-1554284126-aa88f22d8b74?auto=format&fit=crop&w=1400&q=80",
    defaultMinutes: 10,
  ),
];
