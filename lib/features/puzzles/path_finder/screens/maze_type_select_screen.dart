import 'package:flutter/material.dart';

import '../models/maze_difficulty.dart';
import '../models/maze_type.dart';

class MazeTypeSelectSheet extends StatefulWidget {
  const MazeTypeSelectSheet({
    super.key,
    required this.initialType,
    required this.initialDifficulty,
    required this.initialMapIndex,
    required this.onStart,
  });

  final MazeType initialType;
  final MazeDifficulty initialDifficulty;
  /// 0-based map index (0..29).
  final int initialMapIndex;
  final void Function(MazeType type, MazeDifficulty difficulty, int mapIndex)
      onStart;

  @override
  State<MazeTypeSelectSheet> createState() => _MazeTypeSelectSheetState();
}

class _MazeTypeSelectSheetState extends State<MazeTypeSelectSheet> {
  late MazeType _selectedType;
  late MazeDifficulty _selectedDifficulty;
  late int _selectedMapIndex;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedDifficulty = widget.initialDifficulty;
    _selectedMapIndex =
        widget.initialMapIndex.clamp(0, MazeDifficulty.mapsPerDifficulty - 1);
  }

  String _sizeHint(MazeDifficulty diff, int mapIndex) {
    return switch (_selectedType) {
      MazeType.square => '${diff.squareGridSizeForMap(mapIndex)}×${diff.squareGridSizeForMap(mapIndex)}',
      MazeType.circular => () {
          final c = diff.circularConfigForMap(mapIndex);
          return '${c.$1} rings';
        }(),
      MazeType.triangle => '${diff.triangleRowsForMap(mapIndex)} rows',
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF181824),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Maze Geometry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: MazeType.values.map((type) {
                final isSelected = type == _selectedType;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C5CE7)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFA29BFE)
                              : Colors.white12,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            switch (type) {
                              MazeType.square => Icons.grid_on,
                              MazeType.circular => Icons.trip_origin,
                              MazeType.triangle => Icons.change_history,
                            },
                            color: isSelected ? Colors.white : Colors.white60,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            type.displayName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Difficulty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: MazeDifficulty.values.map((diff) {
                final isSelected = diff == _selectedDifficulty;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDifficulty = diff),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00CEC9)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              isSelected ? Colors.white : Colors.white12,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            diff.displayName,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            diff == MazeDifficulty.hard
                                ? '~${diff.estimatedSolveTimeSeconds ~/ 60} min'
                                : '~${diff.estimatedSolveTimeSeconds}s',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black54
                                  : Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  '${_selectedDifficulty.displayName} Maps',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '90 total · ${_sizeHint(_selectedDifficulty, _selectedMapIndex)}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Easy 30 · Medium 30 · Hard 30  ·  now: ${_selectedDifficulty.displayName} ${_selectedMapIndex + 1}/30',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: MazeDifficulty.mapsPerDifficulty,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedMapIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMapIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C5CE7)
                            : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFA29BFE)
                              : Colors.white12,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onStart(
                    _selectedType,
                    _selectedDifficulty,
                    _selectedMapIndex,
                  );
                },
                child: Text(
                  'Play Map ${_selectedMapIndex + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
