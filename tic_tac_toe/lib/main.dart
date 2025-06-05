import 'package:flutter/material.dart';

// Color scheme constants as per requirements
const Color kPrimaryColor = Color(0xFFFFFFFF);   // #ffffff
const Color kSecondaryColor = Color(0xFF222222); // #222222
const Color kAccentColor = Color(0xFF4CAF50);    // #4caf50

void main() {
  runApp(const TicTacToeApp());
}

// PUBLIC_INTERFACE
class TicTacToeApp extends StatelessWidget {
  /// This is the root of the TicTacToe Classic app.
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TicTacToe Classic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          primaryContainer: kPrimaryColor,
          surface: kPrimaryColor,
          // 'background' is deprecated, so we use 'surface' for scaffold background coloring as well
        ),
        scaffoldBackgroundColor: kPrimaryColor,
        primaryColor: kPrimaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
              color: kSecondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 22
          ),
          bodyMedium: TextStyle(
            color: kSecondaryColor,
            fontSize: 18,
          ),
        ),
      ),
      home: const TicTacToeHomePage(),
    );
  }
}

// PUBLIC_INTERFACE
class TicTacToeHomePage extends StatefulWidget {
  /// Main container widget for the game UI and logic.
  const TicTacToeHomePage({super.key});

  @override
  State<TicTacToeHomePage> createState() => _TicTacToeHomePageState();
}

enum PlayerMark { X, O }

class _TicTacToeHomePageState extends State<TicTacToeHomePage> {
  List<PlayerMark?> board = List<PlayerMark?>.filled(9, null);
  PlayerMark currentPlayer = PlayerMark.X;
  bool gameOver = false;
  List<int>? winningIndices;
  String gameStatus = "Player X's Turn";

  // All possible winning combinations
  final List<List<int>> winPatterns = const [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  // PUBLIC_INTERFACE
  void _handleCellTap(int index) {
    if (board[index] != null || gameOver) return;
    setState(() {
      board[index] = currentPlayer;
      _checkGameStatus();
      if (!gameOver) {
        currentPlayer = currentPlayer == PlayerMark.X ? PlayerMark.O : PlayerMark.X;
        gameStatus = "Player ${_playerMarkToStr(currentPlayer)}'s Turn";
      }
    });
  }

  // PUBLIC_INTERFACE
  void _resetGame() {
    setState(() {
      board = List<PlayerMark?>.filled(9, null);
      currentPlayer = PlayerMark.X;
      gameOver = false;
      winningIndices = null;
      gameStatus = "Player X's Turn";
    });
  }

  // PUBLIC_INTERFACE
  void _checkGameStatus() {
    // Check for a winner
    for (var pattern in winPatterns) {
      PlayerMark? first = board[pattern[0]];
      if (first != null &&
          board[pattern[1]] == first &&
          board[pattern[2]] == first) {
        gameOver = true;
        winningIndices = pattern;
        gameStatus = "Player ${_playerMarkToStr(first)} Wins!";
        return;
      }
    }
    // Check for draw
    if (board.every((mark) => mark != null)) {
      gameOver = true;
      winningIndices = null;
      gameStatus = "It's a Draw!";
    }
  }

  // Utility to convert PlayerMark to String
  String _playerMarkToStr(PlayerMark? p) {
    if (p == PlayerMark.X) return 'X';
    if (p == PlayerMark.O) return 'O';
    return '';
  }

  /// Builds the 3x3 grid.
  Widget _buildGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kSecondaryColor.withOpacity(0.07),
            blurRadius: 14,
            spreadRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          itemCount: 9,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, i) => _buildCell(i),
        ),
      ),
    );
  }

  /// Builds each cell of the grid. Highlights if it is part of the winning combination.
  Widget _buildCell(int index) {
    final mark = board[index];
    bool highlight = winningIndices?.contains(index) == true;
    return GestureDetector(
      onTap: () => _handleCellTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: highlight ? kAccentColor.withOpacity(0.3) : kPrimaryColor,
          border: Border.all(
            color: highlight ? kAccentColor : kSecondaryColor,
            width: highlight ? 3.5 : 1.4,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: mark == null
              ? const SizedBox.shrink()
              : Text(
                  _playerMarkToStr(mark),
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: highlight
                        ? kAccentColor
                        : (mark == PlayerMark.X ? kSecondaryColor : kSecondaryColor.withOpacity(0.85)),
                  ),
                ),
        ),
      ),
    );
  }

  /// Main layout: Status, Grid, Game State, and Reset Button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Current Player's turn (above grid)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Text(
                  !gameOver
                      ? "Current Turn: Player ${_playerMarkToStr(currentPlayer)}"
                      : (winningIndices != null ? "Winner: Player ${_playerMarkToStr(board[winningIndices!.first])}" : "Draw!"),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kSecondaryColor,
                  ),
                ),
              ),
              // 3x3 Grid
              _buildGrid(),
              const SizedBox(height: 32),
              // Game status & Reset button (below grid)
              Text(
                // eg. "Player X's Turn", "Player O Wins!", "It's a Draw!"
                gameStatus,
                style: TextStyle(
                  color: gameOver
                      ? (winningIndices != null ? kAccentColor : kSecondaryColor.withOpacity(0.7))
                      : kSecondaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 130,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    backgroundColor: kAccentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: _resetGame,
                  child: const Text("Reset Game"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
