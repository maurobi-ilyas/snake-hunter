import '../game/components/prey_animal.dart';

class PreyPool {
  final List<PreyAnimal> _ratPool = [];
  final List<PreyAnimal> _rabbitPool = [];
  final List<PreyAnimal> _frogPool = [];

  PreyAnimal get(int type) {
    List<PreyAnimal> pool;
    if (type == 0) pool = _ratPool;
    else if (type == 1) pool = _rabbitPool;
    else pool = _frogPool;

    if (pool.isNotEmpty) {
      final prey = pool.removeLast();
      prey.state = AIState.wandering;
      return prey;
    }

    if (type == 0) return PreyAnimal(type: 0, baseSpeed: 100);
    if (type == 1) return PreyAnimal(type: 1, baseSpeed: 140);
    return PreyAnimal(type: 2, baseSpeed: 120);
  }

  void release(PreyAnimal prey) {
    if (prey.type == 0) _ratPool.add(prey);
    else if (prey.type == 1) _rabbitPool.add(prey);
    else _frogPool.add(prey);
  }
}
