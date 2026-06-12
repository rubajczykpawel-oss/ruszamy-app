import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';

void main() {
  testWidgets('Ruszamy App shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RuszamyApp());

    expect(find.text('Ruszamy App'), findsOneWidget);
    expect(find.text('Zaloguj'), findsOneWidget);
  });
}