import 'package:flutter_test/flutter_test.dart';
import 'package:snake_hunter/main.dart';
import 'package:provider/provider.dart';
import 'package:snake_hunter/services/game_state.dart';

void main() {
  testWidgets('Snake Hunter Title Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameState(),
        child: const SnakeHunterApp(),
      ),
    );

    expect(find.text('SNAKE HUNTER'), findsOneWidget);
  });
}
