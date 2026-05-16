// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_udcapp/main.dart';

void main() {
  testWidgets('Shows Login when not logged in', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());

    // First frame shows splash; then it decides.
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Crear cuenta'), findsOneWidget);
  });

  testWidgets('Register creates user and enters Home', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Registro'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Usuario'),
      'danie',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      '1234',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmar contraseña'),
      '1234',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.textContaining('Bienvenido'), findsOneWidget);
  });
}
