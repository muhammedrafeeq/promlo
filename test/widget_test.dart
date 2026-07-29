import 'package:flutter_test/flutter_test.dart';
import 'package:neural_forge/main.dart';

void main() {
  testWidgets('NeuralForgeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NeuralForgeApp());
  });
}
