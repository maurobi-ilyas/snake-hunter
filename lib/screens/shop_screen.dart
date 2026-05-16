import 'package:flutter/material.dart';

import '../core/services/local_storage_service.dart';
import '../game/models/skin_model.dart';

class ShopItem {
  final String id;
  final String name;
  final int price;
  bool owned;
  final Color color;
  final Color glowColor;
  final IconData? icon;

  ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.owned,
    required this.color,
    required this.glowColor,
    this.icon,
  });
}

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _coins = 0;

  String _selectedSkin = 'green_neon';
  List<String> _ownedSkins = [];

  String _selectedTheme = 'cyber_river';
  List<String> _ownedThemes = [];

  String _selectedTrail = 'none';
  List<String> _ownedTrails = [];

  final List<SkinModel> _skins = [
    SkinModel(id: 'green_neon',   name: 'Neon Green',    price: 0,   owned: true,  color: Colors.greenAccent, glowColor: Colors.greenAccent),
    SkinModel(id: 'blue_plasma',  name: 'Blue Plasma',   price: 50,  owned: false, color: Colors.blueAccent,  glowColor: Colors.blue),
    SkinModel(id: 'purple_shadow',name: 'Purple Shadow', price: 100, owned: false, color: Colors.purpleAccent,glowColor: Colors.purple),
    SkinModel(id: 'red_inferno',  name: 'Red Inferno',   price: 150, owned: false, color: Colors.redAccent,   glowColor: Colors.red),
    SkinModel(id: 'gold_legend',  name: 'Golden Snake',  price: 300, owned: false, color: Colors.amber,       glowColor: Colors.orange),
    SkinModel(id: 'cyber_snake',  name: 'Cyber Snake',   price: 500, owned: false, color: Colors.cyanAccent,  glowColor: Colors.cyan),
  ];

  final List<ShopItem> _themes = [
    ShopItem(id: 'neon_city',   name: 'Neon City',   price: 100, owned: false, color: Colors.pinkAccent,   glowColor: Colors.pink, icon: Icons.location_city),
    ShopItem(id: 'cyber_river', name: 'Cyber River', price: 0,   owned: true,  color: Colors.cyan,         glowColor: Colors.cyanAccent, icon: Icons.water),
    ShopItem(id: 'dark_lab',    name: 'Dark Lab',    price: 150, owned: false, color: Colors.deepPurple,   glowColor: Colors.purpleAccent, icon: Icons.science),
    ShopItem(id: 'lava_core',   name: 'Lava Core',   price: 250, owned: false, color: Colors.deepOrange,   glowColor: Colors.orangeAccent, icon: Icons.local_fire_department),
    ShopItem(id: 'ice_world',   name: 'Ice World',   price: 200, owned: false, color: Colors.lightBlue,    glowColor: Colors.blueAccent, icon: Icons.ac_unit),
  ];

  final List<ShopItem> _trails = [
    ShopItem(id: 'none',            name: 'No Trail',       price: 0,   owned: true,  color: Colors.grey,           glowColor: Colors.white24, icon: Icons.do_not_disturb),
    ShopItem(id: 'neon_trail',      name: 'Neon Trail',     price: 150, owned: false, color: Colors.greenAccent,    glowColor: Colors.green, icon: Icons.blur_on),
    ShopItem(id: 'electric_trail',  name: 'Electric Trail', price: 200, owned: false, color: Colors.blueAccent,     glowColor: Colors.blue, icon: Icons.flash_on),
    ShopItem(id: 'water_trail',     name: 'Water Trail',    price: 180, owned: false, color: Colors.cyanAccent,     glowColor: Colors.cyan, icon: Icons.water_drop),
    ShopItem(id: 'fire_trail',      name: 'Fire Trail',     price: 300, owned: false, color: Colors.deepOrangeAccent, glowColor: Colors.orange, icon: Icons.local_fire_department),
  ];

  final List<ShopItem> _boosts = [
    ShopItem(id: 'slow_motion', name: 'Slow Motion', price: 50,  owned: false, color: Colors.blueAccent,   glowColor: Colors.blue, icon: Icons.speed),
    ShopItem(id: 'shield',      name: 'Shield',      price: 80,  owned: false, color: Colors.greenAccent,  glowColor: Colors.green, icon: Icons.shield),
    ShopItem(id: 'double_coin', name: 'Double Coin', price: 100, owned: false, color: Colors.amber,        glowColor: Colors.orange, icon: Icons.monetization_on),
    ShopItem(id: 'magnet_food', name: 'Magnet Food', price: 150, owned: false, color: Colors.purpleAccent, glowColor: Colors.purple, icon: Icons.all_out),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  void _loadData() {
    _coins = LocalStorageService.getCoins();
    _selectedSkin = LocalStorageService.getSkin();
    _ownedSkins = LocalStorageService.getOwnedSkins();
    _selectedTheme = LocalStorageService.getTheme();
    _ownedThemes = LocalStorageService.getOwnedThemes();
    _selectedTrail = LocalStorageService.getTrail();
    _ownedTrails = LocalStorageService.getOwnedTrails();

    for (final s in _skins) s.owned = _ownedSkins.contains(s.id);
    for (final t in _themes) t.owned = _ownedThemes.contains(t.id);
    for (final tr in _trails) tr.owned = _ownedTrails.contains(tr.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    _showSnack('${skin.name} unlocked! 🎉', skin.color);
  }

  Future<void> _selectSkin(SkinModel skin) async {
    if (!skin.owned) return;
    setState(() => _selectedSkin = skin.id);
    await LocalStorageService.saveSkin(skin.id);
  }

  Future<void> _buyTheme(ShopItem theme) async {
    if (theme.owned || _coins < theme.price) return;
    setState(() {
      _coins -= theme.price;
      theme.owned = true;
      _ownedThemes.add(theme.id);
    });
    await LocalStorageService.saveCoins(_coins);
    await LocalStorageService.addOwnedTheme(theme.id);
    _showSnack('${theme.name} unlocked! 🌃', theme.color);
  }

  Future<void> _selectTheme(ShopItem theme) async {
    if (!theme.owned) return;
    setState(() => _selectedTheme = theme.id);
    await LocalStorageService.saveTheme(theme.id);
  }

  Future<void> _buyTrail(ShopItem trail) async {
    if (trail.owned || _coins < trail.price) return;
    setState(() {
      _coins -= trail.price;
      trail.owned = true;
      _ownedTrails.add(trail.id);
    });
    await LocalStorageService.saveCoins(_coins);
    await LocalStorageService.addOwnedTrail(trail.id);
    _showSnack('${trail.name} unlocked! 💫', trail.color);
  }

  Future<void> _selectTrail(ShopItem trail) async {
    if (!trail.owned) return;
    setState(() => _selectedTrail = trail.id);
    await LocalStorageService.saveTrail(trail.id);
  }

  Future<void> _buyBoost(ShopItem boost) async {
    if (_coins < boost.price) return;
    setState(() {
      _coins -= boost.price;
    });
    await LocalStorageService.saveCoins(_coins);
    await LocalStorageService.addBoost(boost.id, 1);
    int currentCount = LocalStorageService.getBoostCount(boost.id);
    _showSnack('${boost.name} purchased! (Total: $currentCount)', boost.color);
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(message, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        title: const Text('NEON SHOP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                const SizedBox(width: 6),
                Text('$_coins', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabs: const [
            Tab(text: 'SKINS', icon: Icon(Icons.gesture)),
            Tab(text: 'ARENAS', icon: Icon(Icons.map)),
            Tab(text: 'TRAILS', icon: Icon(Icons.moving)),
            Tab(text: 'BOOSTS', icon: Icon(Icons.flash_on)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSkinTab(),
          _buildThemeTab(),
          _buildTrailTab(),
          _buildBoostTab(),
        ],
      ),
    );
  }

  Widget _buildSkinTab() {
    final current = _skins.firstWhere((s) => s.id == _selectedSkin, orElse: () => _skins.first);
    return Column(
      children: [
        _buildPreviewHeader('Active Skin', current.name, current.color, current.glowColor),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1),
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
    );
  }

  Widget _buildThemeTab() {
    final current = _themes.firstWhere((s) => s.id == _selectedTheme, orElse: () => _themes.first);
    return Column(
      children: [
        _buildPreviewHeader('Active Arena', current.name, current.color, current.glowColor, icon: current.icon),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1),
            itemCount: _themes.length,
            itemBuilder: (_, i) => _GenericItemCard(
              item: _themes[i],
              isSelected: _selectedTheme == _themes[i].id,
              playerCoins: _coins,
              onBuy: () => _buyTheme(_themes[i]),
              onSelect: () => _selectTheme(_themes[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrailTab() {
    final current = _trails.firstWhere((s) => s.id == _selectedTrail, orElse: () => _trails.first);
    return Column(
      children: [
        _buildPreviewHeader('Active Trail', current.name, current.color, current.glowColor, icon: current.icon),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1),
            itemCount: _trails.length,
            itemBuilder: (_, i) => _GenericItemCard(
              item: _trails[i],
              isSelected: _selectedTrail == _trails[i].id,
              playerCoins: _coins,
              onBuy: () => _buyTrail(_trails[i]),
              onSelect: () => _selectTrail(_trails[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoostTab() {
    return Column(
      children: [
        _buildPreviewHeader('Power-Ups', 'Consumables', Colors.amber, Colors.orange, icon: Icons.inventory),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1),
            itemCount: _boosts.length,
            itemBuilder: (_, i) => _BoostCard(
              item: _boosts[i],
              playerCoins: _coins,
              count: LocalStorageService.getBoostCount(_boosts[i].id),
              onBuy: () => _buyBoost(_boosts[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewHeader(String title, String subtitle, Color color, Color glowColor, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0D111A),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: glowColor.withOpacity(0.15), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
          ] else ...[
            Container(
              width: 50,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color,
                boxShadow: [BoxShadow(color: glowColor.withOpacity(0.6), blurRadius: 12)],
              ),
            ),
            const SizedBox(width: 16),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
            ],
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

  const _SkinCard({required this.skin, required this.isSelected, required this.playerCoins, required this.onBuy, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final canAfford = playerCoins >= skin.price;

    return GestureDetector(
      onTap: skin.owned ? onSelect : (canAfford ? onBuy : null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? skin.color.withOpacity(0.1) : const Color(0xFF0D111A),
          border: Border.all(color: isSelected ? skin.color : (skin.owned ? skin.color.withOpacity(0.3) : Colors.white12), width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: skin.glowColor.withOpacity(0.2), blurRadius: 15)] : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 14,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: skin.color,
                  boxShadow: [BoxShadow(color: skin.glowColor.withOpacity(0.6), blurRadius: 10)],
                ),
              ),
              Text(skin.name, style: TextStyle(color: skin.owned ? skin.color : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
              _buildActionButton(skin.owned, isSelected, canAfford, skin.price, skin.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenericItemCard extends StatelessWidget {
  final ShopItem item;
  final bool isSelected;
  final int playerCoins;
  final VoidCallback onBuy;
  final VoidCallback onSelect;

  const _GenericItemCard({required this.item, required this.isSelected, required this.playerCoins, required this.onBuy, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final canAfford = playerCoins >= item.price;

    return GestureDetector(
      onTap: item.owned ? onSelect : (canAfford ? onBuy : null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? item.color.withOpacity(0.1) : const Color(0xFF0D111A),
          border: Border.all(color: isSelected ? item.color : (item.owned ? item.color.withOpacity(0.3) : Colors.white12), width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: item.glowColor.withOpacity(0.2), blurRadius: 15)] : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(item.icon, color: item.color, size: 28),
              Text(item.name, style: TextStyle(color: item.owned ? item.color : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
              _buildActionButton(item.owned, isSelected, canAfford, item.price, item.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoostCard extends StatelessWidget {
  final ShopItem item;
  final int playerCoins;
  final int count;
  final VoidCallback onBuy;

  const _BoostCard({required this.item, required this.playerCoins, required this.count, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    final canAfford = playerCoins >= item.price;

    return GestureDetector(
      onTap: canAfford ? onBuy : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0D111A),
          border: Border.all(color: count > 0 ? item.color.withOpacity(0.5) : Colors.white12, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Icon(item.icon, color: item.color, size: 28),
                  if (count > 0)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                      child: Text('$count', style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
              _buildActionButton(false, false, canAfford, item.price, item.color, isConsumable: true),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildActionButton(bool owned, bool isSelected, bool canAfford, int price, Color color, {bool isConsumable = false}) {
  if (owned && !isConsumable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? color : color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        isSelected ? 'DIGUNAKAN' : 'GUNAKAN',
        style: TextStyle(color: isSelected ? Colors.black : color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  } else {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: canAfford ? Colors.amber.withOpacity(0.15) : Colors.white.withOpacity(0.05),
        border: Border.all(color: canAfford ? Colors.amber.withOpacity(0.5) : Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monetization_on, color: canAfford ? Colors.amber : Colors.white30, size: 12),
          const SizedBox(width: 4),
          Text(
            '$price',
            style: TextStyle(color: canAfford ? Colors.amber : Colors.white30, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
