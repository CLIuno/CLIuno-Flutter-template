import 'package:flutter_test/flutter_test.dart';

import 'package:cliuno_flutter_template/main.dart';

void main() {
  testWidgets('unauthenticated app starts on the login screen', (
    tester,
  ) async {
    await tester.pumpWidget(const CliunoApp());

    expect(find.text('Login'), findsWidgets);
    expect(find.text("Don't have an account? Register"), findsOneWidget);
  });
}
