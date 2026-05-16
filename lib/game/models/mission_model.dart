class MissionModel {
  final String id;
  final String title;
  final String description;
  final String reward;
  bool completed;

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    this.completed = false,
  });
}
