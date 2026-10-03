import 'package:flutter_test/flutter_test.dart';
import 'package:mechconnect_app/main.dart';

void main() {
  testWidgets('MechConnect app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MechConnectApp());

    expect(find.byType(MechConnectApp), findsOneWidget);
  });
}