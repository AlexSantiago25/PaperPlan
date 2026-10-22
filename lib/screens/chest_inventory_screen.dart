import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/furniture.dart';
import '../models/item.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/doodle_painters.dart';
import '../widgets/inventory_slot_tile.dart';
import '../widgets/item_detail_modal.dart';

class ChestInventoryScreen extends StatefulWidget {
  final String furnitureId;
  final String zoneId;

  const ChestInventoryScreen({
    super.key,
    required this.furnitureId,
    required this.zoneId,
  });

  @override
  State<ChestInventoryScreen> createState() => _ChestInventoryScreenState();
}

class _ChestInventoryScreenState extends State<ChestInventoryScreen> {
  ItemRarity? _filterRarity;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final zone = provider.zones.firstWhere(
      (z) => z.id == widget.zoneId,
      orElse: () => provider.zones.first,
    );

    final furniture = zone.furnitureList.firstWhere(
      (f) => f.id == widget.furnitureId,
      orElse: () => zone.furnitureList.first,
    );

    final occupiedCount = furniture.occupiedSlotsCount;
    final totalSlots = furniture.slotCapacity;
    final occupancyPercent = (occupiedCount / totalSlots).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.paperBackground,
      body: NotebookPaperBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.penBlueDark,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: furniture.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: furniture.color, width: 1.5),
                      ),
                      child: Icon(
                        furniture.type.defaultIcon,
                        color: furniture.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            furniture.name,
                            style: GoogleFonts.patrickHand(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.penBlueDark,
                            ),
                          ),
                          Text(
                            '${zone.name} • ${furniture.type.displayName}',
                            style: GoogleFonts.patrickHand(
                              fontSize: 13,
                              color: AppTheme.penBlack.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Anotar Nuevo Objeto',
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppTheme.penBlue,
                        size: 26,
                      ),
                      onPressed: () =>
                          _openAddItemDialog(context, furniture.id),
                    ),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.fromLTRB(36, 4, 16, 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.paperSurfaceWarm,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.penBlue, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.penBlueDark.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(1, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.inventory_2_rounded,
                              size: 16,
                              color: AppTheme.penBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Espacios de Guardado:',
                              style: GoogleFonts.patrickHand(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.penBlack,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$occupiedCount / $totalSlots Objetos',
                          style: GoogleFonts.patrickHand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: occupiedCount == totalSlots
                                ? AppTheme.penRed
                                : AppTheme.penBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: occupancyPercent,
                        minHeight: 7,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          occupancyPercent > 0.85
                              ? AppTheme.penRed
                              : (occupancyPercent > 0.6
                                    ? AppTheme.penGold
                                    : AppTheme.penBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Rarity Filter Bar (Ballpoint Pens)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(36, 0, 16, 6),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(
                        'Todos',
                        style: GoogleFonts.patrickHand(fontSize: 14),
                      ),
                      selected: _filterRarity == null,
                      onSelected: (_) => setState(() => _filterRarity = null),
                      selectedColor: AppTheme.penBlue,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _filterRarity == null
                            ? Colors.white
                            : AppTheme.penBlack,
                        fontWeight: _filterRarity == null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppTheme.penBlue),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ...ItemRarity.values.map((r) {
                      final isSelected = _filterRarity == r;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                r.badgeIcon,
                                size: 13,
                                color: isSelected ? Colors.white : r.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                r.displayName,
                                style: GoogleFonts.patrickHand(fontSize: 14),
                              ),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (_) => setState(() {
                            _filterRarity = isSelected ? null : r;
                          }),
                          selectedColor: r.color,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.penBlack,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: r.color),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Inventory Grid of Slots (Notebook Sheet)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(36, 4, 16, 0),
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 80, top: 4),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: totalSlots,
                    itemBuilder: (context, slotIdx) {
                      final itemAtSlot = furniture.getItemAtSlot(slotIdx);

                      // Filter check
                      if (_filterRarity != null &&
                          itemAtSlot != null &&
                          itemAtSlot.rarity != _filterRarity) {
                        return InventorySlotTile(
                          slotIndex: slotIdx,
                          item: null,
                          onTap: () => _openAddItemDialog(
                            context,
                            furniture.id,
                            slotIndex: slotIdx,
                          ),
                        );
                      }

                      return InventorySlotTile(
                        slotIndex: slotIdx,
                        item: itemAtSlot,
                        onTap: () {
                          if (itemAtSlot != null) {
                            _openItemDetailModal(
                              context,
                              furniture.id,
                              itemAtSlot,
                            );
                          } else {
                            _openAddItemDialog(
                              context,
                              furniture.id,
                              slotIndex: slotIdx,
                            );
                          }
                        },
                        onItemDropped: (targetSlot, sourceItemId) {
                          provider.moveItemSlot(
                            furnitureId: furniture.id,
                            itemId: sourceItemId,
                            newSlotIndex: targetSlot,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.penGold,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.draw_rounded, size: 20),
        label: Text(
          'Anotar Objeto',
          style: GoogleFonts.patrickHand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () => _openAddItemDialog(context, furniture.id),
      ),
    );
  }

  void _openAddItemDialog(
    BuildContext context,
    String furnitureId, {
    int? slotIndex,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        furnitureId: furnitureId,
        preselectedSlotIndex: slotIndex,
      ),
    );
  }

  void _openItemDetailModal(
    BuildContext context,
    String furnitureId,
    Item item,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          ItemDetailModal(furnitureId: furnitureId, item: item),
    );
  }
}
