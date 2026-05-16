import 'package:flutter/material.dart';

import '../core/services/local_storage_service.dart';
import '../game/models/skin_model.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _coins = 0;
  String _selectedSkin = 'green_neon';
  List<String> _ownedSkins = ['green_neon'];

  final List<SkinModel> _skins = [
    SkinModel(id: 'green_neon',   name: 'Green Neon',    price: 0,   owned: true,  color: Colors.greenAccent, glowColor: Colors.greenAccent),
    SkinModel(id: 'blue_plasma',  name: 'Blue Plasma',   price: 50,  owned: false, color: Colors.blueAccent,  glowColor: Colors.blue),
    SkinModel(id: 'purple_shadow',name: 'Purple Shadow', price: 100, owned: false, color: Colors.purpleAccent,glowColor: Colors.purple),
    SkinModel(id: 'red_inferno',  name: 'Red Inferno',   price: 150, owned: false, color: Colors.redAccent,   glowColor: Colors.red),
    SkinModel(id: 'gold_legend',  name: 'Gold Legend',   price: 300, owned: false, color: Colors.amber,       glowColor: Colors.orange),
    SkinModel(id: 'cyan_frost',   name: 'Cyan Frost',    price: 200, owned: false, color: Colors.cyanAccent,  glowColor: Colors.cyan),
  ];

  @override
  void initState() {
    super.initState();
    _coins = LocalStorageService.getCoins();
    _selectedSkin = LocalStorageService.getSkin();
    _ownedSkins = LocalStorageService.getOwnedSkins();

    for (final s in _skins) {
      s.owned = _ownedSkins.contains(s.id);
    }
  }

  Future<void> _buySkin(SkinModel skin) async {
    if (skin.owned || _coins < skin.price) return;

    setState(() {
      _coins -= skin.price;
      skin.owned = true;
      _ownedSkins.add(skin.id);
    });

    await LocalStorageService.saveCoins(_coins);
    await LocalStorageService.addOwnedSkin(skin.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: skin.color,
        content: Text('${skin.name} unlocked! 🎉',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _selectSkin(SkinModel skin) async {
    if (!skin.owned) return;
    setState(() => _selectedSkin = skin.id);
    await LocalStorageService.saveSkin(skin.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        title: const Text('SNAKE SHOP'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('$_coins',
                    style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview current skin
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF0D1117),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(builder: (_) {
                  final current = _skins.firstWhere(
                    (s) => s.id == _selectedSkin,
                    orElse: () => _skins.first,
                  );
                  return Column(
                    children: [
                      Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: current.color,
                          boxShadow: [
                            BoxShadow(color: current.glowColor.withOpacity(0.6), blurRadius: 15),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Active: ${current.name}',
                          style: TextStyle(color: current.color, fontWeight: FontWeight.bold)),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Skin grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: _skins.length,
              itemBuilder: (_, i) => _SkinCard(
                skin: _skins[i],
                isSelected: _selectedSkin == _skins[i].id,
                playerCoins: _coins,
                onBuy: () => _buySkin(_skins[i]),
                onSelect: () => _selectSkin(_skins[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkinCard extends StatelessWidget {
  final SkinModel skin;
  final bool isSelected;
  final int playerCoins;
  final VoidCallback onBuy;
  final VoidCallback onSelect;

  const _SkinCard({
    required this.skin,
    required this.isSelected,
    required this.playerCoins,
    required this.onBuy,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = playerCoins >= skin.price;

    return GestureDetector(
      onTap: skin.owned ? onSelect : (canAfford ? onBuy : null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF0D1117),
          border: Border.all(
            color: isSelected
                ? skin.color
                : skin.owned
                    ? skin.color.withOpacity(0.3)
                    : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: skin.glowColor.withOpacity(0.3), blurRadius: 16)]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Snake preview
              Container(
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: skin.color,
                  boxShadow: [
                    BoxShadow(color: skin.glowColor.withOpacity(0.5), blurRadius: 8),
                  ],
                ),
              ),

              Text(
                skin.name,
                style: TextStyle(
                  color: skin.owned ? skin.color : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),

              // Action button
              if (skin.owned)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isSelected ? skin.color : skin.color.withOpacity(0.15),
                    border: Border.all(color: skin.color.withOpacity(0.5)),
                  ),
                  child: Text(
                    isSelected ? 'ACTIVE' : 'USE',
                    style: TextStyle(
                      color: isSelected ? Colors.black : skin.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      '${skin.price}',
                      style: TextStyle(
                        color: canAfford ? Colors.amber : Colors.white30,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
