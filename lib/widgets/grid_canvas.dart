import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/furniture.dart';
import '../models/zone.dart';
import '../providers/inventory_provider.dart';
import '../screens/chest_inventory_screen.dart';
import '../theme/app_theme.dart';
import 'doodle_painters.dart';
import 'furniture_tile.dart';

class GridCanvas extends StatefulWidget {
  final Zone zone;

  const GridCanvas({super.key, required this.zone});

  @override
  State<GridCanvas> createState() => _GridCanvasState();
}

class _GridCanvasState extends State<GridCanvas> {
  final GlobalKey _gridKey = GlobalKey();

  (int, int)? _getGridCoordsFromOffset(Offset localOffset, double cellSize) {
    final gx = (localOffset.dx / cellSize).floor();
    final gy = (localOffset.dy / cellSize).floor();
    if (gx >= 0 && gx < widget.zone.gridColumns && gy >= 0 && gy < widget.zone.gridRows) {
      return (gx, gy);
    }
    return null;
  }

  static const List<String> _letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final isEditor = provider.viewMode == AppViewMode.editor;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic cell size
        final headerLabelSpace = 24.0;
        final padding = 20.0;
        final maxAvailableWidth = constraints.maxWidth - padding * 2 - headerLabelSpace;
        final maxAvailableHeight = constraints.maxHeight - padding * 2 - headerLabelSpace;

        final cellWidth = maxAvailableWidth / widget.zone.gridColumns;
        final cellHeight = maxAvailableHeight / widget.zone.gridRows;
        final cellSize = (cellWidth < cellHeight ? cellWidth : cellHeight).clamp(38.0, 68.0);

        final totalGridWidth = cellSize * widget.zone.gridColumns;
        final totalGridHeight = cellSize * widget.zone.gridRows;

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Scale and Metric Ruler Chip
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.paperSurfaceWarm,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.penBlue.withValues(alpha: 0.35), width: 1.0),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.straighten_rounded, size: 14, color: AppTheme.penBlue),
                            const SizedBox(width: 5),
                            Text(
                              '1 casilla = 0.5m (50cm) • ${widget.zone.dimensionsFormatted} (${(widget.zone.realWidthMeters * widget.zone.realHeightMeters).toStringAsFixed(0)} m²)',
                              style: GoogleFonts.patrickHand(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.penBlueDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Grid Frame with Sea Battle 2 Letters (A, B, C...) & Numbers (1, 2, 3...)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Axis: Letters (A, B, C, D...)
                        Padding(
                          padding: EdgeInsets.only(top: headerLabelSpace),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(widget.zone.gridRows, (rowIdx) {
                              final letter = rowIdx < _letters.length ? _letters[rowIdx] : '${rowIdx + 1}';
                              return SizedBox(
                                width: headerLabelSpace,
                                height: cellSize,
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: GoogleFonts.patrickHand(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.penBlueDark,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        // Main Board with Top Numbers (1, 2, 3...)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Axis: Numbers (1, 2, 3...)
                            SizedBox(
                              height: headerLabelSpace,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(widget.zone.gridColumns, (colIdx) {
                                  return SizedBox(
                                    width: cellSize,
                                    child: Center(
                                      child: Text(
                                        '${colIdx + 1}',
                                        style: GoogleFonts.patrickHand(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.penBlueDark,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),

                            // The Squared Canvas Box (Double Hand-drawn Blue Pen Border)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.penBlueDark.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                foregroundPainter: const DoodleBorderPainter(
                                  color: AppTheme.penBlue,
                                  strokeWidth: 2.2,
                                  borderRadius: 8.0,
                                  isDoubleLine: true,
                                ),
                                child: DragTarget<Object>(
                                  key: _gridKey,
                                  onWillAcceptWithDetails: (details) => isEditor,
                                  onMove: (details) {
                                    if (!isEditor) return;
                                    final renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
                                    if (renderBox == null) return;

                                    final localOffset = renderBox.globalToLocal(details.offset);
                                    final coords = _getGridCoordsFromOffset(localOffset, cellSize);

                                    if (coords != null) {
                                      final (gx, gy) = coords;
                                      if (details.data is FurnitureType) {
                                        final fType = details.data as FurnitureType;
                                        provider.updateGhost(
                                          x: gx,
                                          y: gy,
                                          width: fType.defaultWidth,
                                          height: fType.defaultHeight,
                                        );
                                      } else if (details.data is Furniture) {
                                        final f = details.data as Furniture;
                                        provider.updateGhost(
                                          x: gx,
                                          y: gy,
                                          width: f.effectiveWidth,
                                          height: f.effectiveHeight,
                                          excludeFurnitureId: f.id,
                                        );
                                      }
                                    }
                                  },
                                  onLeave: (data) => provider.clearGhost(),
                                  onAcceptWithDetails: (details) {
                                    if (!isEditor) return;
                                    final renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
                                    if (renderBox == null) return;

                                    final localOffset = renderBox.globalToLocal(details.offset);
                                    final coords = _getGridCoordsFromOffset(localOffset, cellSize);

                                    if (coords != null) {
                                      final (gx, gy) = coords;
                                      if (details.data is FurnitureType) {
                                        final fType = details.data as FurnitureType;
                                        provider.addFurnitureToActiveZone(
                                          type: fType,
                                          name: fType.displayName,
                                          x: gx,
                                          y: gy,
                                        );
                                      } else if (details.data is Furniture) {
                                        final f = details.data as Furniture;
                                        provider.moveFurniture(f.id, gx, gy);
                                      }
                                    }
                                    provider.clearGhost();
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    return SizedBox(
                                      width: totalGridWidth,
                                      height: totalGridHeight,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          // Layer 1: Notebook Ruled Squares
                                          _buildNotebookGridFloor(cellSize),

                                          // Layer 2: Placed Furniture Items (Sea Battle 2 doodles)
                                          ...widget.zone.furnitureList.map((furniture) {
                                            return Positioned(
                                              left: furniture.gridX * cellSize,
                                              top: furniture.gridY * cellSize,
                                              child: FurnitureTile(
                                                furniture: furniture,
                                                cellSize: cellSize,
                                                onTap: () => _openChestScreen(context, furniture),
                                              ),
                                            );
                                          }),

                                          // Layer 3: Ghost Placement with Pen Hatching Preview
                                          if (isEditor && provider.ghostX != null && provider.ghostY != null)
                                            Positioned(
                                              left: provider.ghostX! * cellSize,
                                              top: provider.ghostY! * cellSize,
                                              width: provider.ghostWidth! * cellSize,
                                              height: provider.ghostHeight! * cellSize,
                                              child: IgnorePointer(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: (provider.ghostIsValid
                                                            ? AppTheme.penGreen
                                                            : AppTheme.penRed)
                                                        .withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned.fill(
                                                        child: CustomPaint(
                                                          painter: PenHatchPainter(
                                                            color: provider.ghostIsValid
                                                                ? AppTheme.penGreen
                                                                : AppTheme.penRed,
                                                            spacing: 5.0,
                                                            strokeWidth: 1.2,
                                                            crossHatch: true,
                                                            borderRadius: 8.0,
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned.fill(
                                                        child: CustomPaint(
                                                          painter: DoodleBorderPainter(
                                                            color: provider.ghostIsValid
                                                                ? AppTheme.penGreen
                                                                : AppTheme.penRed,
                                                            strokeWidth: 2.0,
                                                            borderRadius: 8.0,
                                                            isDoubleLine: true,
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Icon(
                                                          provider.ghostIsValid
                                                              ? Icons.check_rounded
                                                              : Icons.close_rounded,
                                                          color: provider.ghostIsValid
                                                              ? AppTheme.penGreen
                                                              : AppTheme.penRed,
                                                          size: 24,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotebookGridFloor(double cellSize) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.zone.gridColumns,
        childAspectRatio: 1.0,
      ),
      itemCount: widget.zone.gridColumns * widget.zone.gridRows,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.paperGridLine,
              width: 0.8,
            ),
          ),
        );
      },
    );
  }

  void _openChestScreen(BuildContext context, Furniture furniture) {
    if (furniture.slotCapacity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: furniture.color,
          duration: const Duration(seconds: 1),
          content: Text(
            '${furniture.name}: Estructura arquitectónica (sin almacenamiento).',
            style: GoogleFonts.patrickHand(fontSize: 15, color: Colors.white),
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChestInventoryScreen(
          furnitureId: furniture.id,
          zoneId: widget.zone.id,
        ),
      ),
    );
  }
}
