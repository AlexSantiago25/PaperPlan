import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import 'doodle_painters.dart';

class ItemDetailModal extends StatefulWidget {
  final String furnitureId;
  final Item item;

  const ItemDetailModal({
    super.key,
    required this.furnitureId,
    required this.item,
  });

  @override
  State<ItemDetailModal> createState() => _ItemDetailModalState();
}

class _ItemDetailModalState extends State<ItemDetailModal> {
  late int _quantity;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late ItemRarity _rarity;
  late ItemCategory _category;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
    _nameController = TextEditingController(text: widget.item.name);
    _descController = TextEditingController(text: widget.item.description);
    _rarity = widget.item.rarity;
    _category = widget.item.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedItem = widget.item.copyWith(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : widget.item.name,
      description: _descController.text.trim(),
      quantity: _quantity,
      rarity: _rarity,
      category: _category,
    );
    Provider.of<InventoryProvider>(context, listen: false).updateItemInFurniture(
      furnitureId: widget.furnitureId,
      updatedItem: updatedItem,
    );
    Navigator.of(context).pop();
  }

  void _deleteItem() {
    Provider.of<InventoryProvider>(context, listen: false).deleteItemFromFurniture(
      furnitureId: widget.furnitureId,
      itemId: widget.item.id,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarity.color;

    return Dialog(
      backgroundColor: AppTheme.paperSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppTheme.paperSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomPaint(
          foregroundPainter: DoodleBorderPainter(
            color: rarityColor,
            strokeWidth: 2.2,
            borderRadius: 16.0,
            isDoubleLine: true,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rarity Banner & Category (Hand-stamped style)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: rarityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: rarityColor, width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_rarity.badgeIcon, size: 14, color: rarityColor),
                          const SizedBox(width: 6),
                          Text(
                            _rarity.displayName.toUpperCase(),
                            style: GoogleFonts.patrickHand(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: rarityColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.paperSurfaceWarm,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.penBlue.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_category.icon, size: 14, color: AppTheme.penBlueDark),
                          const SizedBox(width: 4),
                          Text(
                            _category.displayName,
                            style: GoogleFonts.patrickHand(fontSize: 13, color: AppTheme.penBlueDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Item Icon & Name
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: PenHatchPainter(
                                color: rarityColor.withValues(alpha: 0.3),
                                spacing: 4.5,
                                strokeWidth: 1.0,
                                crossHatch: true,
                                borderRadius: 12.0,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: DoodleBorderPainter(
                                color: rarityColor,
                                strokeWidth: 1.8,
                                borderRadius: 12.0,
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(_category.icon, color: rarityColor, size: 28),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: GoogleFonts.patrickHand(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.penBlack,
                            ),
                          ),
                          Text(
                            'Casilla #${widget.item.slotIndex + 1}',
                            style: GoogleFonts.patrickHand(fontSize: 15, color: AppTheme.penBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description or notes
                if (widget.item.description.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.paperSurfaceWarm, // Sticky note style
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.penBlue.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      widget.item.description,
                      style: GoogleFonts.patrickHand(fontSize: 15, color: AppTheme.penBlack, height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Tag Chips
                if (widget.item.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.item.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.penBlue.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '#$tag',
                          style: GoogleFonts.patrickHand(fontSize: 13, color: AppTheme.penBlue),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],

                // Quantity Modifier (+ / -)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.penBlue.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cantidad en casilla:',
                        style: GoogleFonts.patrickHand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.penBlack,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded),
                            color: _quantity > 1 ? AppTheme.penBlue : Colors.grey,
                            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.paperSurfaceWarm,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.penBlue.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              '$_quantity',
                              style: GoogleFonts.patrickHand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.penBlack,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            color: AppTheme.penBlue,
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Tachar / Borrar de la libreta',
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.penRed),
                      onPressed: _deleteItem,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cerrar',
                        style: GoogleFonts.patrickHand(fontSize: 17, color: AppTheme.penBlack.withValues(alpha: 0.6)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.penBlue),
                      onPressed: _saveChanges,
                      child: Text('Guardar', style: GoogleFonts.patrickHand(fontSize: 17)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
