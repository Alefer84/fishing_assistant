import 'package:flutter_test/flutter_test.dart';

import 'package:fishing_assistant/main.dart';

void main() {
  testWidgets('App boots to the Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const FishingAssistantApp());
    await tester.pump();

    expect(find.text('Fishing Assistant'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Moon'), findsOneWidget);
  });
}
