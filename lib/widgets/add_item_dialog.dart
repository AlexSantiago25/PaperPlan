import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import 'doodle_painters.dart';

class AddItemDialog extends StatefulWidget {
  final String furnitureId;
  final int? preselectedSlotIndex;

  const AddItemDialog({
    super.key,
    required this.furnitureId,
    this.preselectedSlotIndex,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();

  ItemRarity _selectedRarity = ItemRarity.common;
  ItemCategory _selectedCategory = ItemCategory.misc;
  int _quantity = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final success = Provider.of<InventoryProvider>(context, listen: false).addItemToFurniture(
        furnitureId: widget.furnitureId,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        rarity: _selectedRarity,
        category: _selectedCategory,
        quantity: _quantity,
        targetSlotIndex: widget.preselectedSlotIndex,
        tags: tags,
      );

      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.penRed,
            content: Text(
              'El contenedor ya está lleno',
              style: GoogleFonts.patrickHand(color: Colors.white, fontSize: 16),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            color: _selectedRarity.color,
            strokeWidth: 2.0,
            borderRadius: 16.0,
            isDoubleLine: _selectedRarity == ItemRarity.legendary || _selectedRarity == ItemRarity.epic,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedRarity.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedRarity.color, width: 1.5),
                        ),
                        child: Icon(
                          _selectedCategory.icon,
                          color: _selectedRarity.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anotar Nuevo Objeto',
                              style: GoogleFonts.patrickHand(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.penBlueDark,
                              ),
                            ),
                            Text(
                              widget.preselectedSlotIndex != null
                                  ? 'En Casilla #${widget.preselectedSlotIndex! + 1}'
                                  : 'En la siguiente casilla libre',
                              style: GoogleFonts.patrickHand(fontSize: 14, color: AppTheme.penBlue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    style: GoogleFonts.patrickHand(fontSize: 17, color: AppTheme.penBlack),
                    decoration: InputDecoration(
                      labelText: 'Nombre del Objeto',
                      labelStyle: GoogleFonts.patrickHand(fontSize: 16, color: AppTheme.penBlue),
                      hintText: 'Ej. Llaves de Repuesto, Cable USB-C, Pasaporte',
                      prefixIcon: const Icon(Icons.inventory_2_rounded, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Ingresa el nombre del objeto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextFormField(
                    controller: _descController,
                    style: GoogleFonts.patrickHand(fontSize: 16, color: AppTheme.penBlack),
                    decoration: InputDecoration(
                      labelText: 'Notas / Detalles',
                      labelStyle: GoogleFonts.patrickHand(fontSize: 16, color: AppTheme.penBlue),
                      hintText: 'Ej. Guardado en la esquina izquierda',
                      prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),

                  // Rarity Selector (Pen Inks)
                  Text(
                    'Color de Tinta / Rareza:',
                    style: GoogleFonts.patrickHand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.penBlueDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ItemRarity.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final rarity = ItemRarity.values[index];
                        final isSelected = _selectedRarity == rarity;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedRarity = rarity),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? rarity.color.withValues(alpha: 0.15)
                                  : AppTheme.paperSurfaceWarm,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? rarity.color : AppTheme.penBlue.withValues(alpha: 0.3),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  rarity.badgeIcon,
                                  size: 14,
                                  color: rarity.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rarity.displayName,
                                  style: GoogleFonts.patrickHand(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? rarity.color : AppTheme.penBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Selector
                  Text(
                    'Categoría:',
                    style: GoogleFonts.patrickHand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.penBlueDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: ItemCategory.values.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        selected: isSelected,
                        showCheckmark: false,
                        avatar: Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected ? Colors.white : AppTheme.penBlue,
                        ),
                        label: Text(
                          cat.displayName,
                          style: GoogleFonts.patrickHand(
                            fontSize: 14,
                            color: isSelected ? Colors.white : AppTheme.penBlack,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selectedColor: AppTheme.penBlue,
                        backgroundColor: AppTheme.paperSurfaceWarm,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppTheme.penBlueDark : AppTheme.penBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Quantity & Tags Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quantity
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.paperSurfaceWarm,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.penBlue.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cantidad',
                              style: GoogleFonts.patrickHand(fontSize: 13, color: AppTheme.penBlue),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.remove_rounded, size: 18),
                                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  onPressed: () => setState(() => _quantity++),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Tags Input
                      Expanded(
                        child: TextFormField(
                          controller: _tagsController,
                          style: GoogleFonts.patrickHand(fontSize: 15, color: AppTheme.penBlack),
                          decoration: InputDecoration(
                            labelText: 'Etiquetas (separadas por coma)',
                            labelStyle: GoogleFonts.patrickHand(fontSize: 14, color: AppTheme.penBlue),
                            hintText: 'ej. cables, viaje, llaves',
                            prefixIcon: const Icon(Icons.tag_rounded, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.patrickHand(fontSize: 16, color: AppTheme.penBlack.withValues(alpha: 0.6)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedRarity.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          'Guardar',
                          style: GoogleFonts.patrickHand(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
