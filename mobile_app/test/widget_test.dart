// file: mobile_app\test\widget_test.dart


import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartAttendanceApp());

    expect(
      find.text('Smart Attendance System'),
      findsOneWidget,
    );
  });
}
