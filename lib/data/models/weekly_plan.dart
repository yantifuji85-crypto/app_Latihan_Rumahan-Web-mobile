class WorkoutStepPlan {
  final String name;
  final int seconds;

  const WorkoutStepPlan({required this.name, required this.seconds});

  Map<String, dynamic> toMap() => {
    'name': name,
    'seconds': seconds,
  };

  factory WorkoutStepPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutStepPlan(
      name: (map['name'] ?? '').toString(),
      seconds: (map['seconds'] ?? 0) as int,
    );
  }
}

class WeeklyDayPlan {
  final int day;
  final String title;
  final String level;
  final List<WorkoutStepPlan> steps;

  const WeeklyDayPlan({
    required this.day,
    required this.title,
    required this.level,
    required this.steps,
  });

  Map<String, dynamic> toMap() => {
    'day': day,
    'title': title,
    'level': level,
    'steps': steps.map((e) => e.toMap()).toList(),
  };

  factory WeeklyDayPlan.fromMap(Map<String, dynamic> map) {
    final rawSteps = (map['steps'] as List?) ?? const [];
    return WeeklyDayPlan(
      day: (map['day'] ?? 1) as int,
      title: (map['title'] ?? '').toString(),
      level: (map['level'] ?? 'Pemula').toString(),
      steps: rawSteps
          .whereType<Map>()
          .map((e) => WorkoutStepPlan.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

// ✅ INI yang dipanggil dari FirestoreService
List<WeeklyDayPlan> defaultWeeklyPlan() {
  return const [
    WeeklyDayPlan(
      day: 1,
      title: "Full Body Basic",
      level: "Pemula",
      steps: [
        WorkoutStepPlan(name: "Jumping Jack", seconds: 30),
        WorkoutStepPlan(name: "Squat", seconds: 30),
        WorkoutStepPlan(name: "Plank", seconds: 20),
      ],
    ),
    WeeklyDayPlan(
      day: 2,
      title: "Lower Body",
      level: "Pemula",
      steps: [
        WorkoutStepPlan(name: "Squat", seconds: 35),
        WorkoutStepPlan(name: "Lunge", seconds: 30),
        WorkoutStepPlan(name: "Wall Sit", seconds: 25),
      ],
    ),
    WeeklyDayPlan(
      day: 3,
      title: "Core",
      level: "Pemula",
      steps: [
        WorkoutStepPlan(name: "Plank", seconds: 25),
        WorkoutStepPlan(name: "Crunch", seconds: 30),
        WorkoutStepPlan(name: "Mountain Climber", seconds: 25),
      ],
    ),
    WeeklyDayPlan(
      day: 4,
      title: "Upper Body",
      level: "Pemula",
      steps: [
        WorkoutStepPlan(name: "Push Up", seconds: 25),
        WorkoutStepPlan(name: "Shoulder Tap", seconds: 25),
        WorkoutStepPlan(name: "Plank", seconds: 20),
      ],
    ),
    WeeklyDayPlan(
      day: 5,
      title: "Cardio Light",
      level: "Pemula",
      steps: [
        WorkoutStepPlan(name: "Jumping Jack", seconds: 35),
        WorkoutStepPlan(name: "High Knees", seconds: 25),
        WorkoutStepPlan(name: "Butt Kicks", seconds: 25),
      ],
    ),
    WeeklyDayPlan(
      day: 6,
      title: "Mix & Match",
      level: "Pemula",
      steps: [
        WorkoutStepPlan(name: "Squat", seconds: 30),
        WorkoutStepPlan(name: "Push Up", seconds: 25),
        WorkoutStepPlan(name: "Plank", seconds: 25),
      ],
    ),
    WeeklyDayPlan(
      day: 7,
      title: "Recovery",
      level: "Ringan",
      steps: [
        WorkoutStepPlan(name: "Stretch", seconds: 40),
        WorkoutStepPlan(name: "Breathing", seconds: 40),
      ],
    ),
  ];
}
