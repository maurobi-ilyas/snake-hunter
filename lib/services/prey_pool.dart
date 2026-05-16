import 'dart:math';
import '../game/components/prey_animal.dart';

class PreyPool {
  final List<PreyAnimal> _pool = [];
  final List<AnimalType> _typeWeights = [
    AnimalType.mouse, AnimalType.mouse, AnimalType.mouse, // 50% mouse
    AnimalType.rabbit, AnimalType.rabbit, // 33% rabbit  
    AnimalType.frog, // 17% frog
    AnimalType.bird, // 8% bird
    AnimalType.chick // 8% chick
  ];
  final Random _random = Random();

  PreyAnimal get([int? type]) {
    if (_pool.isNotEmpty) {
      final prey = _pool.removeLast();
      prey.state = AIState.wandering;
      return prey;
    }

    // Select animal type based on weights or specific type
    final animalType = type != null 
        ? AnimalType.values[type % AnimalType.values.length]
        : _typeWeights[_random.nextInt(_typeWeights.length)];

    // Base speeds for each animal type
    final double baseSpeed = switch (animalType) {
      AnimalType.mouse => 100.0,
      AnimalType.rabbit => 140.0,
      AnimalType.frog => 120.0,
      AnimalType.bird => 180.0,
      AnimalType.chick => 130.0,
    };

    return PreyAnimal(type: animalType, speed: baseSpeed);
  }

  void release(PreyAnimal prey) {
    prey.state = AIState.eaten;
    _pool.add(prey);
  }
}