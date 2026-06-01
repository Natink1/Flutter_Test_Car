import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the smoke test app', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('NHK Car Rental'))),
      ),
    );

    expect(find.text('NHK Car Rental'), findsOneWidget);
  });
}
