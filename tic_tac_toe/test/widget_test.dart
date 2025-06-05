import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('TicTacToeApp renders and shows info', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    // Confirm that we see the Current Turn indicator at launch
    expect(
      find.textContaining('Current Turn: Player'),
      findsOneWidget,
    );

    // Confirm that the 3x3 grid is present by counting AnimatedContainer used for each cell (9)
    expect(find.byType(AnimatedContainer), findsNWidgets(9));

    // Confirm that the Reset Game button is present
    expect(find.text('Reset Game'), findsOneWidget);
  });
}
