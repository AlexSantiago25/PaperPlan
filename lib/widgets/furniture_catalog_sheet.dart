import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/furniture.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import 'doodle_painters.dart';

class FurnitureCatalogSheet extends StatelessWidget {
  const FurnitureCatalogSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.paperSurfaceWarm, // Sticky note yellow
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: const Border(
          top: BorderSide(color: AppTheme.penBlue, width: 2.0),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.penBlueDark.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 6, bottom: 4),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.penBlue.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header Row (Fixed RenderFlex overflow with Expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    color: AppTheme.penBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Catálogo de Muebles (Toca o mantén para arrastrar)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.patrickHand(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.penBlueDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.penRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.penRed, width: 1.0),
                    ),
                    child: Text(
                      'Editor',
                      style: GoogleFonts.patrickHand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.penRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Horizontally Scrollable List with LongPressDraggable for frictionless scrolling
            SizedBox(
              height: 108,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: FurnitureType.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final type = FurnitureType.values[index];
                  return _CatalogItemCard(type: type);
                },
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _CatalogItemCard extends StatelessWidget {
  final FurnitureType type;

  const _CatalogItemCard({required this.type});

  void _placeItemInFirstAvailableSlot(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final zone = provider.activeZone;
    if (zone == null) return;

    final w = type.defaultWidth;
    final h = type.defaultHeight;

    // Search for first free position
    for (int y = 0; y <= zone.gridRows - h; y++) {
      for (int x = 0; x <= zone.gridColumns - w; x++) {
        if (zone.canPlaceFurniture(x: x, y: y, width: w, height: h)) {
          final ok = provider.addFurnitureToActiveZone(
            type: type,
            name: type.displayName,
            x: x,
            y: y,
          );
          if (ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppTheme.penGreen,
                duration: const Duration(seconds: 1),
                content: Text(
                  '${type.displayName} colocado en (${x + 1}, ${y + 1})',
                  style: GoogleFonts.patrickHand(fontSize: 15, color: Colors.white),
                ),
              ),
            );
            return;
          }
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.penRed,
        duration: const Duration(seconds: 2),
        content: Text(
          'No hay espacio libre en la cuadrícula para ${type.displayName}',
          style: GoogleFonts.patrickHand(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemWidget = Container(
      width: 90,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // 1. Diagonal Pen Hatching
          Positioned.fill(
            child: CustomPaint(
              painter: PenHatchPainter(
                color: type.defaultColor.withValues(alpha: 0.18),
                spacing: 5.0,
                strokeWidth: 0.9,
                borderRadius: 10.0,
              ),
            ),
          ),
          // 2. Hand-drawn border
          Positioned.fill(
            child: CustomPaint(
              painter: DoodleBorderPainter(
                color: type.defaultColor,
                strokeWidth: 1.5,
                borderRadius: 10.0,
              ),
            ),
          ),
          // 3. Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type.defaultIcon,
                  color: type.defaultColor,
                  size: 22,
                ),
                const SizedBox(height: 2),
                Text(
                  type.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.patrickHand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.penBlack,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(type.defaultWidth * 0.5).toStringAsFixed(1)}×${(type.defaultHeight * 0.5).toStringAsFixed(1)}m',
                        style: GoogleFonts.patrickHand(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.penBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type.isArchitecturalElement
                            ? '• Paso'
                            : '• ${type.defaultCapacity} sl',
                        style: GoogleFonts.patrickHand(
                          fontSize: 11,
                          fontWeight: type.isArchitecturalElement ? FontWeight.bold : FontWeight.normal,
                          color: type.isArchitecturalElement ? AppTheme.penPurple : AppTheme.penBlack.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // LongPressDraggable allows effortless horizontal scrolling on normal swipe,
    // and dragging when holding down. Tap directly places the furniture in the next free spot!
    return LongPressDraggable<FurnitureType>(
      data: type,
      hapticFeedbackOnStart: true,
      delay: const Duration(milliseconds: 150),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.9,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: PenHatchPainter(
                      color: type.defaultColor.withValues(alpha: 0.4),
                      spacing: 5.0,
                      strokeWidth: 1.2,
                      crossHatch: true,
                      borderRadius: 10.0,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: DoodleBorderPainter(
                      color: type.defaultColor,
                      strokeWidth: 2.2,
                      borderRadius: 10.0,
                      isDoubleLine: true,
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    type.defaultIcon,
                    color: type.defaultColor,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: itemWidget,
      ),
      child: InkWell(
        onTap: () => _placeItemInFirstAvailableSlot(context),
        borderRadius: BorderRadius.circular(10),
        child: itemWidget,
      ),
    );
  }
}
