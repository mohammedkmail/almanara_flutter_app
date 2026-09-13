import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:al_manara_system/main.dart';
import 'package:al_manara_system/screens/splash_screen.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
