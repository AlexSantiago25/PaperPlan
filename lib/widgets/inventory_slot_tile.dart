import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../theme/app_theme.dart';
import 'doodle_painters.dart';

class InventorySlotTile extends StatelessWidget {
  final int slotIndex;
  final Item? item;
  final VoidCallback? onTap;
  final Function(int targetSlotIndex, String sourceItemId)? onItemDropped;

  const InventorySlotTile({
    super.key,
    required this.slotIndex,
    this.item,
    this.onTap,
    this.onItemDropped,
  });

  @override
  Widget build(BuildContext context) {
    final hasItem = item != null;
    final rarityColor = hasItem ? item!.rarity.color : AppTheme.penBlue.withValues(alpha: 0.3);

    final slotContent = Container(
      decoration: BoxDecoration(
        color: hasItem
            ? (item!.rarity == ItemRarity.legendary
                ? AppTheme.highlighterYellow.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.9))
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // 1. Diagonal Pen Hatching inside occupied slot
          if (hasItem)
            Positioned.fill(
              child: CustomPaint(
                painter: PenHatchPainter(
                  color: rarityColor.withValues(alpha: 0.2),
                  spacing: 4.5,
                  strokeWidth: 0.9,
                  crossHatch: item!.rarity == ItemRarity.legendary || item!.rarity == ItemRarity.epic,
                  borderRadius: 10.0,
                ),
              ),
            ),

          // 2. Hand-drawn Border
          Positioned.fill(
            child: CustomPaint(
              painter: DoodleBorderPainter(
                color: hasItem ? rarityColor : AppTheme.paperGridLine.withValues(alpha: 0.9),
                strokeWidth: hasItem ? 1.8 : 1.0,
                borderRadius: 10.0,
                isDoubleLine: hasItem && (item!.rarity == ItemRarity.legendary || item!.rarity == ItemRarity.epic),
              ),
            ),
          ),

          // 3. Slot Number (#1, #2...)
          Positioned(
            top: 2,
            left: 5,
            child: Text(
              '#${slotIndex + 1}',
              style: GoogleFonts.patrickHand(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: hasItem ? rarityColor.withValues(alpha: 0.6) : AppTheme.penBlue.withValues(alpha: 0.4),
              ),
            ),
          ),

          // 4. Center Item Icon (Doodle style)
          Center(
            child: hasItem
                ? Hero(
                    tag: 'item_icon_${item!.id}',
                    child: Icon(
                      item!.category.icon,
                      color: rarityColor,
                      size: 26,
                    ),
                  )
                : Icon(
                    Icons.add_rounded,
                    color: AppTheme.penBlue.withValues(alpha: 0.25),
                    size: 20,
                  ),
          ),

          // 5. Item Name (Handwritten label at bottom)
          if (hasItem)
            Positioned(
              left: 4,
              right: 4,
              bottom: 3,
              child: Text(
                item!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.patrickHand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.penBlack,
                  letterSpacing: -0.2,
                ),
              ),
            ),

          // 6. Quantity Badge (Handwritten ink count)
          if (hasItem && item!.quantity > 1)
            Positioned(
              top: 3,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: rarityColor, width: 1.0),
                ),
                child: Text(
                  'x${item!.quantity}',
                  style: GoogleFonts.patrickHand(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: rarityColor,
                  ),
                ),
              ),
            ),

          // 7. Rarity Star / Stamp (Top Right if quantity is 1)
          if (hasItem && item!.quantity == 1)
            Positioned(
              top: 3,
              right: 4,
              child: Icon(
                item!.rarity.badgeIcon,
                size: 13,
                color: rarityColor,
              ),
            ),
        ],
      ),
    );

    // Support DragTarget for swapping / reordering items in chest
    return DragTarget<Item>(
      onWillAcceptWithDetails: (details) => details.data.slotIndex != slotIndex,
      onAcceptWithDetails: (details) {
        onItemDropped?.call(slotIndex, details.data.id);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        Widget clickableSlot = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: isHovered
                    ? Border.all(color: AppTheme.penGreen, width: 2.5)
                    : null,
              ),
              child: slotContent,
            ),
          ),
        );

        if (hasItem) {
          return Draggable<Item>(
            data: item!,
            feedback: Material(
              color: Colors.transparent,
              child: Opacity(
                opacity: 0.9,
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: slotContent,
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.25,
              child: slotContent,
            ),
            child: clickableSlot,
          );
        }

        return clickableSlot;
      },
    );
  }
}
