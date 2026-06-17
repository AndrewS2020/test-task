import 'package:flutter_test/flutter_test.dart';
import 'package:swim_success/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SwimSuccessApp());
    expect(find.text('Swim Success'), findsOneWidget);
  });
}
