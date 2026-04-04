import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CarLensApp widget tree builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('CARLENS'),
          ),
        ),
      ),
    );
    expect(find.text('CARLENS'), findsOneWidget);
  });
}
