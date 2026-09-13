import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:al_manara_system/main.dart';
import 'package:al_manara_system/screens/login_screen.dart';
import 'package:al_manara_system/screens/navigation_screen.dart';
import 'package:al_manara_system/services/auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android login, real books, secure session restore and logout', (tester) async {
    await AuthService.instance.logout();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'ahmad@library.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.byType(MainScreen), findsOneWidget);
    expect(AuthService.instance.client.token, isNotEmpty);
    AuthService.instance.client.token = null;
    await AuthService.instance.restore();
    expect(AuthService.instance.user.value!.username, 'ahmad@library.com');
    expect(AuthService.instance.client.token, isNotEmpty);
    await tester.tap(find.text('الكتب').last);
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.text('1984'), findsWidgets);
    await AuthService.instance.logout();
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
