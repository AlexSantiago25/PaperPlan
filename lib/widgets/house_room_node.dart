import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/furniture.dart';
import '../models/zone.dart';
import '../providers/inventory_provider.dart';
import '../screens/chest_inventory_screen.dart';
import '../screens/zone_canvas_screen.dart';
import '../theme/app_theme.dart';
import 'doodle_painters.dart';

class HouseRoomNode extends StatefulWidget {
  final Zone zone;
  final bool isArchitectMode;
  final double cellSize;
  final VoidCallback? onSelected;

  const HouseRoomNode({
    super.key,
    required this.zone,
    required this.isArchitectMode,
    this.cellSize = 28.0,
    this.onSelected,
  });

  @override
  State<HouseRoomNode> createState() => _HouseRoomNodeState();
}

class _HouseRoomNodeState extends State<HouseRoomNode> {
  late double _currentX;
  late double _currentY;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentX = widget.zone.floorX;
    _currentY = widget.zone.floorY;
  }

  @override
  void didUpdateWidget(HouseRoomNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging) {
      _currentX = widget.zone.floorX;
      _currentY = widget.zone.floorY;
    }
  }

  void _snapAndSavePosition() {
    // Snap to exact multiples of widget.cellSize (28.0px) for seamless alignment
    final snappedX = ((_currentX / widget.cellSize).round() * widget.cellSize).toDouble().clamp(0.0, 2500.0);
    final snappedY = ((_currentY / widget.cellSize).round() * widget.cellSize).toDouble().clamp(0.0, 2500.0);
    setState(() {
      _currentX = snappedX;
      _currentY = snappedY;
      _isDragging = false;
    });
    Provider.of<InventoryProvider>(context, listen: false).updateZoneFloorPosition(
      widget.zone.id,
      snappedX,
      snappedY,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final isSelected = widget.isArchitectMode && provider.selectedBlueprintZoneId == widget.zone.id;

    final roomWidth = widget.zone.gridColumns * widget.cellSize;
    final roomHeight = widget.zone.gridRows * widget.cellSize;
    final isPatio = widget.zone.isPatio;
    final themeColor = widget.zone.themeColor;

    return Positioned(
      left: _currentX,
      top: _currentY,
      child: GestureDetector(
        onTap: widget.isArchitectMode
            ? () => provider.selectBlueprintZone(widget.zone.id)
            : null,
        onPanStart: widget.isArchitectMode
            ? (_) {
                setState(() => _isDragging = true);
                provider.selectBlueprintZone(widget.zone.id);
              }
            : null,
        onPanUpdate: widget.isArchitectMode
            ? (details) {
                setState(() {
                  _currentX += details.delta.dx;
                  _currentY += details.delta.dy;
                });
              }
            : null,
        onPanEnd: widget.isArchitectMode ? (_) => _snapAndSavePosition() : null,
        child: Container(
          width: roomWidth,
          decoration: BoxDecoration(
            color: isPatio
                ? const Color(0xFFF0FDF4).withValues(alpha: 0.9) // Soft garden green
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _isDragging || isSelected
                    ? AppTheme.penRed.withValues(alpha: isSelected ? 0.4 : 0.3)
                    : (widget.isArchitectMode
                        ? AppTheme.penRed.withValues(alpha: 0.15)
                        : AppTheme.penBlueDark.withValues(alpha: 0.12)),
                blurRadius: _isDragging || isSelected ? 16 : 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: CustomPaint(
            foregroundPainter: DoodleBorderPainter(
              color: widget.isArchitectMode
                  ? (isSelected || _isDragging ? AppTheme.penRed : AppTheme.penRed.withValues(alpha: 0.6))
                  : (isPatio ? AppTheme.penGreen : themeColor),
              strokeWidth: isSelected ? 3.0 : (widget.isArchitectMode ? 2.2 : 2.0),
              borderRadius: 10.0,
              isDoubleLine: isSelected || (!isPatio && !widget.isArchitectMode),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Room Header Tag
                _buildRoomHeader(),

                // Room Interior Grid with Furniture
                SizedBox(
                  width: roomWidth,
                  height: roomHeight,
                  child: Stack(
                    children: [
                      // Layer 1: Notebook Squares Floor
                      _buildGridLines(),

                      // Layer 2: Furniture and Architectural elements
                      ...widget.zone.furnitureList.map((furniture) {
                        return Positioned(
                          left: furniture.gridX * widget.cellSize,
                          top: furniture.gridY * widget.cellSize,
                          width: furniture.effectiveWidth * widget.cellSize,
                          height: furniture.effectiveHeight * widget.cellSize,
                          child: _buildFurnitureBlueprintTile(furniture),
                        );
                      }),

                      // Layer 3: Architect drag & selection overlay
                      if (widget.isArchitectMode)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.penRed.withValues(alpha: 0.08)
                                  : AppTheme.penRed.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.paperSurfaceWarm : Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.penRed : AppTheme.penRed.withValues(alpha: 0.7),
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSelected ? Icons.edit_note_rounded : Icons.open_with_rounded,
                                        size: 14,
                                        color: AppTheme.penRed,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isSelected ? 'Editando Zona' : 'Arrastrar',
                                        style: GoogleFonts.patrickHand(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.penRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomHeader() {
    final isPatio = widget.zone.isPatio;
    final isHallway = widget.zone.isHallway;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isPatio
            ? const Color(0xFFDCFCE7)
            : (isHallway ? const Color(0xFFF1F5F9) : AppTheme.paperSurfaceWarm),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(
          bottom: BorderSide(
            color: (isHallway ? const Color(0xFF64748B) : widget.zone.themeColor).withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPatio
                  ? Icons.yard_rounded
                  : (isHallway ? Icons.view_timeline_outlined : _getIconForKey(widget.zone.iconKey)),
              size: 14,
              color: isPatio
                  ? AppTheme.penGreen
                  : (isHallway ? const Color(0xFF64748B) : widget.zone.themeColor),
            ),
            const SizedBox(width: 4),
            Text(
              widget.zone.name,
              style: GoogleFonts.patrickHand(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.penBlack,
              ),
            ),
            const SizedBox(width: 6),
            // Dimensions / Enter Button
            if (!widget.isArchitectMode)
              InkWell(
                onTap: () {
                  final provider = Provider.of<InventoryProvider>(context, listen: false);
                  provider.setActiveZone(widget.zone.id);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ZoneCanvasScreen(zoneId: widget.zone.id),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: widget.zone.themeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: widget.zone.themeColor, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.zone.dimensionsFormatted,
                        style: GoogleFonts.patrickHand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: widget.zone.themeColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 9,
                        color: widget.zone.themeColor,
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                widget.zone.dimensionsFormatted,
                style: GoogleFonts.patrickHand(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.penBlack.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridLines() {
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
              color: widget.zone.isPatio
                  ? AppTheme.penGreen.withValues(alpha: 0.15)
                  : AppTheme.paperGridLine.withValues(alpha: 0.7),
              width: 0.6,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFurnitureBlueprintTile(Furniture furniture) {
    final isDoorOrWindow = furniture.type == FurnitureType.door || furniture.type == FurnitureType.window;
    final color = furniture.color;

    return GestureDetector(
      onTap: !widget.isArchitectMode
          ? () {
              if (furniture.slotCapacity == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: color,
                    duration: const Duration(seconds: 1),
                    content: Text(
                      '${furniture.name}: Estructura de paso (sin almacenamiento)',
                      style: GoogleFonts.patrickHand(fontSize: 14, color: Colors.white),
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
          : null,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isDoorOrWindow
              ? color.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            // Pen hatching
            Positioned.fill(
              child: CustomPaint(
                painter: PenHatchPainter(
                  color: color.withValues(alpha: 0.2),
                  spacing: 4.0,
                  strokeWidth: 0.8,
                  borderRadius: 4.0,
                ),
              ),
            ),
            // Border
            Positioned.fill(
              child: CustomPaint(
                painter: DoodleBorderPainter(
                  color: color,
                  strokeWidth: isDoorOrWindow ? 1.5 : 1.2,
                  borderRadius: 4.0,
                  isDoubleLine: furniture.items.isNotEmpty,
                ),
              ),
            ),
            // Center icon & name
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        furniture.type.defaultIcon,
                        color: color,
                        size: widget.cellSize > 24 ? 14 : 11,
                      ),
                      if (widget.cellSize >= 28 && furniture.effectiveWidth >= 2 && furniture.effectiveHeight >= 2)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            furniture.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.patrickHand(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.penBlack,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Item count pill
            if (furniture.items.isNotEmpty)
              Positioned(
                top: 1,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${furniture.items.length}',
                    style: GoogleFonts.patrickHand(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      case 'computer':
        return Icons.computer_rounded;
      case 'bed':
        return Icons.bed_rounded;
      case 'construction':
        return Icons.construction_rounded;
      case 'kitchen':
        return Icons.kitchen_rounded;
      case 'inventory_2':
        return Icons.inventory_2_rounded;
      case 'garage':
        return Icons.garage_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'yard':
        return Icons.yard_rounded;
      case 'hallway':
        return Icons.view_timeline_outlined;
      default:
        return Icons.meeting_room_rounded;
    }
  }
}
