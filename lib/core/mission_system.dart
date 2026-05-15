class Mission {
  final String id;
  final String title;
  final String description;
  final int goalValue;
  int currentValue;
  bool isCompleted;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.goalValue,
    this.currentValue = 0,
    this.isCompleted = false,
  });

  void update(int value) {
    if (isCompleted) return;
    currentValue += value;
    if (currentValue >= goalValue) {
      isCompleted = true;
    }
  }
}
