import 'package:flame/components.dart';
import 'components/prey_animal.dart';

class PreyPool {
  final List<PreyAnimal> _available = [];
  final List<PreyAnimal> _active = [];

  PreyAnimal get(int type) {
    // Basic pooling logic
    // In a real implementation, we would reuse instances
    // For now, we'll return new ones but keep the structure
    if (type == 0) return Rat();
    if (type == 1) return Rabbit();
    return Frog();
  }

  void release(PreyAnimal prey) {
    prey.removeFromParent();
    // Logic to reset and store in _available
  }
}
