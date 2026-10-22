import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/furniture.dart';
import '../models/item.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import 'doodle_painters.dart';

class FurnitureTile extends StatelessWidget {
  final Furniture furniture;
  final double cellSize;
  final VoidCallback? onTap;

  const FurnitureTile({
    super.key,
    required this.furniture,
    required this.cellSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final isEditor = provider.viewMode == AppViewMode.editor;
    final isSelected = provider.selectedFurnitureId == furniture.id;

    final width = furniture.effectiveWidth * cellSize;
    final height = furniture.effectiveHeight * cellSize;

    final hasLegendary = furniture.items.any((i) => i.rarity == ItemRarity.legendary);
    final hasEpic = furniture.items.any((i) => i.rarity == ItemRarity.epic);

    // Pen Ink Color
    Color penColor = furniture.color;
    if (isSelected) {
      penColor = AppTheme.penRed;
    } else if (hasLegendary) {
      penColor = AppTheme.penGold;
    } else if (hasEpic) {
      penColor = AppTheme.penPurple;
    }

    final tileBox = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.penRed.withValues(alpha: 0.14)
            : (hasLegendary
                ? AppTheme.highlighterYellow.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.9)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Diagonal Pen Hatching Fill
          Positioned.fill(
            child: CustomPaint(
              painter: PenHatchPainter(
                color: penColor.withValues(alpha: isSelected ? 0.35 : 0.22),
                spacing: 5.0,
                strokeWidth: 1.0,
                crossHatch: isSelected || hasLegendary,
                borderRadius: 8.0,
              ),
            ),
          ),

          // 2. Hand-drawn Double Sketch Border
          Positioned.fill(
            child: CustomPaint(
              painter: DoodleBorderPainter(
                color: penColor,
                strokeWidth: isSelected ? 2.6 : 1.8,
                borderRadius: 8.0,
                isDoubleLine: isSelected || hasLegendary || hasEpic,
              ),
            ),
          ),

          // 3. Furniture Icon, Name & Real Dimensions
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    furniture.type.defaultIcon,
                    color: penColor,
                    size: (width < 60 || height < 60) ? 18 : 24,
                  ),
                  if (width >= 48 && height >= 42) ...[
                    const SizedBox(height: 1),
                    Text(
                      furniture.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.patrickHand(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: penColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                  // Real World Dimensions Tag (e.g. 1.0m × 0.5m)
                  if (width >= 52 && height >= 50)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: penColor.withValues(alpha: 0.5), width: 0.8),
                      ),
                      child: Text(
                        furniture.dimensionsFormatted,
                        style: GoogleFonts.patrickHand(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.penBlack,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 4. Pen Badge (Slot Count in Top-Right)
          Positioned(
            top: 2,
            right: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: hasLegendary
                      ? AppTheme.penGold
                      : (hasEpic ? AppTheme.penPurple : AppTheme.penBlue),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasLegendary)
                    const Icon(
                      Icons.star_rounded,
                      size: 10,
                      color: AppTheme.penGold,
                    ),
                  Text(
                    '${furniture.occupiedSlotsCount}/${furniture.slotCapacity}',
                    style: GoogleFonts.patrickHand(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: hasLegendary
                          ? AppTheme.penGold
                          : (hasEpic ? AppTheme.penPurple : AppTheme.penBlueDark),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Rotation indicator (Bottom Left)
          if (furniture.rotation != 0)
            Positioned(
              bottom: 2,
              left: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: penColor, width: 0.8),
                ),
                child: Text(
                  '${furniture.rotation}°',
                  style: GoogleFonts.patrickHand(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: penColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final clickableContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isEditor) {
            provider.setSelectedFurniture(isSelected ? null : furniture.id);
          } else {
            onTap?.call();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: tileBox,
      ),
    );

    if (isEditor) {
      return Draggable<Furniture>(
        data: furniture,
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.85,
            child: SizedBox(
              width: width,
              height: height,
              child: tileBox,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: SizedBox(
            width: width,
            height: height,
            child: tileBox,
          ),
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: clickableContent,
        ),
      );
    }

    return Hero(
      tag: 'furniture_hero_${furniture.id}',
      child: SizedBox(
        width: width,
        height: height,
        child: clickableContent,
      ),
    );
  }
}
