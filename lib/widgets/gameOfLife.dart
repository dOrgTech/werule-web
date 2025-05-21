import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameOfLife extends StatefulWidget {
  const GameOfLife({super.key});

  @override
  _GameOfLifeState createState() => _GameOfLifeState();
}

class _GameOfLifeState extends State<GameOfLife> {
  // late List<List<int>> grid;
  List<List<int>> grid = [];
  Timer? timer;
  int rows = 10;
  int cols = 10;
  final double resolution = 60;
  final double initialProbability =
      0.3; // 30% chance for each cell to be alive initially

  @override
  void initState() {
    super.initState();
    // Initialize grid in initState to avoid late initialization error
    _initGrid();
  }

  void _initGrid() {
    // Setup grid moved from didChangeDependencies to ensure grid is initialized before build
    WidgetsBinding.instance.addPostFrameCallback((_) => setupGrid());
  }

  void setupGrid() {
    final screenSize = MediaQuery.of(context).size;
    cols = (screenSize.width / resolution).floor();
    rows = (screenSize.height / resolution).floor();

    // Adjusted to initialize grid with initial probability correctly
    grid = List.generate(
        cols,
        (_) => List.generate(
            rows, (_) => Random().nextDouble() < initialProbability ? 1 : 0));

    timer =
        Timer.periodic(const Duration(milliseconds: 120), (Timer t) => _updateGrid());
  }

  void _updateGrid() {
    setState(() {
      grid = _computeNext(grid);
    });
  }

  List<List<int>> _computeNext(List<List<int>> oldGrid) {
    List<List<int>> newGrid =
        List.generate(cols, (_) => List.generate(rows, (_) => 0));
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        int state = oldGrid[i][j];
        int neighbours = _countNeighbours(oldGrid, i, j);

        if (state == 0 && neighbours == 3) {
          newGrid[i][j] = 1; // Birth condition
        } else if (state == 1 && (neighbours < 2 || neighbours > 3)) {
          newGrid[i][j] = Random().nextDouble() > 0.1
              ? 0
              : 1; // Death condition with a small chance to survive
        } else {
          newGrid[i][j] = state;
        }
      }
    }
    return newGrid;
  }

  int _countNeighbours(List<List<int>> grid, int x, int y) {
    int sum = 0;
    for (int i = -1; i < 2; i++) {
      for (int j = -1; j < 2; j++) {
        int col = (x + i + cols) % cols;
        int row = (y + j + rows) % rows;
        sum += grid[col][row];
      }
    }
    sum -= grid[x][y];
    return sum;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure grid is initialized before building the widget
    return Scaffold(
      body: CustomPaint(
        painter: GameOfLifePainter(grid, resolution),
        child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }
}

class GameOfLifePainter extends CustomPainter {
  final List<List<int>> grid;
  final double resolution;
  final Paint cellPaint;
  final Paint borderPaint;

  GameOfLifePainter(this.grid, this.resolution)
      : cellPaint = Paint()..color = const Color.fromARGB(255, 109, 109, 109),
        borderPaint = Paint()
          ..color = const Color.fromARGB(255, 190, 190, 190); // Border color

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate border size as a fraction of resolution
    double borderSize = resolution * 0.1; // Example: 10% of the cell size

    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j] == 1) {
          // Draw the main cell
          canvas.drawRect(
              Rect.fromLTWH(
                  i * resolution, j * resolution, resolution, resolution),
              cellPaint);

          // Draw the border (smaller rectangle inside)
          canvas.drawRect(
              Rect.fromLTWH(
                  i * resolution + borderSize,
                  j * resolution + borderSize,
                  resolution - borderSize * 2,
                  resolution - borderSize * 2),
              borderPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
