import 'package:flutter_test/flutter_test.dart';

import 'package:nova_driver/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NovaDriverApp());
    // Bottom nav labels
    expect(find.text('Xarita'), findsOneWidget);
    expect(find.text('Daromad'), findsOneWidget);
  });
}
