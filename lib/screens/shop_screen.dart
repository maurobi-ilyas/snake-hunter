import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Text(message, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSkinTab(),
                    _buildThemeTab(),
                    _buildTrailTab(),
                    _buildBoostTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
            style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'NEON SHOP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 15)],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Text(
                  '$_coins',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.cyanAccent.withOpacity(0.4), Colors.blueAccent.withOpacity(0.2)],
          ),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.6), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.15), blurRadius: 10)],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white30,
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'SKINS', icon: Icon(Icons.gesture, size: 20)),
          Tab(text: 'ARENAS', icon: Icon(Icons.map_rounded, size: 20)),
          Tab(text: 'TRAILS', icon: Icon(Icons.auto_graph_rounded, size: 20)),
          Tab(text: 'BOOSTS', icon: Icon(Icons.bolt_rounded, size: 20)),
        ],
      ),
    );
  }

  Widget _buildSkinTab() {
    final current = _skins.firstWhere((s) => s.id == _selectedSkin, orElse: () => _skins.first);
    return Column(
      children: [
        _buildPreviewHeader('ACTIVE SKIN', current.name, current.color, current.glowColor),
        Expanded(
          child: _buildGrid(_skins.length, (i) => _SkinCard(
            skin: _skins[i],
            isSelected: _selectedSkin == _skins[i].id,
            playerCoins: _coins,
            onBuy: () => _buySkin(_skins[i]),
            onSelect: () => _selectSkin(_skins[i]),
          )),
        ),
      ],
    );
  }

  Widget _buildThemeTab() {
    final current = _themes.firstWhere((s) => s.id == _selectedTheme, orElse: () => _themes.first);
    return Column(
      children: [
        _buildPreviewHeader('ACTIVE ARENA', current.name, current.color, current.glowColor, icon: current.icon),
        Expanded(
          child: _buildGrid(_themes.length, (i) => _GenericItemCard(
            item: _themes[i],
            isSelected: _selectedTheme == _themes[i].id,
            playerCoins: _coins,
            onBuy: () => _buyTheme(_themes[i]),
            onSelect: () => _selectTheme(_themes[i]),
          )),
        ),
      ],
    );
  }

  Widget _buildTrailTab() {
    final current = _trails.firstWhere((s) => s.id == _selectedTrail, orElse: () => _trails.first);
    return Column(
      children: [
        _buildPreviewHeader('ACTIVE TRAIL', current.name, current.color, current.glowColor, icon: current.icon),
        Expanded(
          child: _buildGrid(_trails.length, (i) => _GenericItemCard(
            item: _trails[i],
            isSelected: _selectedTrail == _trails[i].id,
            playerCoins: _coins,
            onBuy: () => _buyTrail(_trails[i]),
            onSelect: () => _selectTrail(_trails[i]),
          )),
        ),
      ],
    );
  }

  Widget _buildBoostTab() {
    return Column(
      children: [
        _buildPreviewHeader('POWER-UPS', 'ENHANCE GAMEPLAY', Colors.amber, Colors.orange, icon: Icons.flash_on_rounded),
        Expanded(
          child: _buildGrid(_boosts.length, (i) => _BoostCard(
            item: _boosts[i],
            playerCoins: _coins,
            count: LocalStorageService.getBoostCount(_boosts[i].id),
            onBuy: () => _buyBoost(_boosts[i]),
          )),
        ),
      ],
    );
  }

  Widget _buildGrid(int itemCount, Widget Function(int) itemBuilder) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemCount: itemCount,
      itemBuilder: (_, i) => itemBuilder(i).animate().fadeIn(delay: (i * 40).ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
    );
  }

  Widget _buildPreviewHeader(String title, String subtitle, Color color, Color glowColor, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), Colors.white.withOpacity(0.01)],
        ),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: glowColor.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 15)],
            ),
            child: Icon(icon ?? Icons.auto_awesome_rounded, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 1,
                    shadows: [Shadow(color: glowColor.withOpacity(0.5), blurRadius: 8)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: isSelected ? skin.color.withOpacity(0.12) : Colors.white.withOpacity(0.03),
          border: Border.all(
            color: isSelected ? skin.color : (skin.owned ? skin.color.withOpacity(0.4) : Colors.white.withOpacity(0.08)),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected ? [BoxShadow(color: skin.color.withOpacity(0.1), blurRadius: 12)] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 22,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                gradient: LinearGradient(colors: [skin.color, skin.glowColor.withOpacity(0.7)]),
                boxShadow: [BoxShadow(color: skin.glowColor.withOpacity(0.8), blurRadius: 15)],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              skin.name.toUpperCase(),
              style: TextStyle(
                color: skin.owned ? Colors.white : Colors.white38,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            _buildActionLabel(skin.owned, isSelected, canAfford, skin.price, skin.color),
          ],
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: isSelected ? item.color.withOpacity(0.12) : Colors.white.withOpacity(0.03),
          border: Border.all(
            color: isSelected ? item.color : (item.owned ? item.color.withOpacity(0.4) : Colors.white.withOpacity(0.08)),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 42),
            const SizedBox(height: 14),
            Text(
              item.name.toUpperCase(),
              style: TextStyle(
                color: item.owned ? Colors.white : Colors.white38,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            _buildActionLabel(item.owned, isSelected, canAfford, item.price, item.color),
          ],
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white.withOpacity(0.03),
          border: Border.all(
            color: count > 0 ? item.color.withOpacity(0.5) : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(item.icon, color: item.color, size: 42),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: item.color.withOpacity(0.5), blurRadius: 10)],
                    ),
                    child: Text('$count', style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.name.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
            ),
            const SizedBox(height: 14),
            _buildActionLabel(false, false, canAfford, item.price, item.color, isConsumable: true),
          ],
        ),
      ),
    );
  }
}

Widget _buildActionLabel(bool owned, bool isSelected, bool canAfford, int price, Color color, {bool isConsumable = false}) {
  if (owned && !isConsumable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? color : color.withOpacity(0.15),
        boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 15)] : [],
        border: isSelected ? null : Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        isSelected ? 'ACTIVE' : 'EQUIP',
        style: TextStyle(color: isSelected ? Colors.black : color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  } else {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: canAfford ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.06),
        border: Border.all(color: canAfford ? Colors.amber.withOpacity(0.4) : Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on_rounded, color: canAfford ? Colors.amber : Colors.white24, size: 16),
          const SizedBox(width: 8),
          Text(
            '$price',
            style: TextStyle(color: canAfford ? Colors.amber : Colors.white24, fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
