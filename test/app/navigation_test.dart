import 'package:findeck/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FinDeckApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('affiche le marché provisoire au démarrage', (tester) async {
    await pumpApp(tester);

    expect(find.textContaining('Aucune donnée de marché'), findsOneWidget);
    expect(find.text('Collection'), findsOneWidget);
    expect(find.text('Portefeuille'), findsOneWidget);
  });

  testWidgets('navigue entre Marché, Collection et Portefeuille', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Collection'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Les cartes, les packs et les gemmes'),
      findsOneWidget,
    );

    await tester.tap(find.text('Portefeuille'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aucun résultat financier'), findsOneWidget);

    await tester.tap(find.text('Marché'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aucune donnée de marché'), findsOneWidget);
  });
}
