import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/furniture.dart';
import '../providers/inventory_provider.dart';
import '../screens/chest_inventory_screen.dart';
import '../theme/app_theme.dart';

class FurnitureEditPanel extends StatelessWidget {
  final Furniture furniture;
  final String zoneId;

  const FurnitureEditPanel({
    super.key,
    required this.furniture,
    required this.zoneId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final zone = provider.activeZone;
    final maxW = zone != null ? zone.gridColumns - furniture.gridX : 12;
    final maxH = zone != null ? zone.gridRows - furniture.gridY : 12;

    final currentW = furniture.effectiveWidth;
    final currentH = furniture.effectiveHeight;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.paperSurfaceWarm, // Sticky note yellow
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: const Border(
          top: BorderSide(color: AppTheme.penRed, width: 2.0),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.penRed.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header: Name, Dimensions & Close Button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.penRed, width: 1.2),
                    ),
                    child: Icon(
                      furniture.type.defaultIcon,
                      color: AppTheme.penRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          furniture.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.patrickHand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.penBlack,
                          ),
                        ),
                        Text(
                          '${furniture.dimensionsFormatted} ($currentW×$currentH celdas)',
                          style: GoogleFonts.patrickHand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.penBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Deselect / Finish Editing Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.penBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      elevation: 1,
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(
                      'Listo',
                      style: GoogleFonts.patrickHand(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => provider.setSelectedFurniture(null),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dimension Stepper Controls (Ancho & Largo in Meters)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.penBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    // Ancho Stepper
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              'Ancho:',
                              style: GoogleFonts.patrickHand(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.penBlack,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildStepButton(
                              icon: Icons.remove_rounded,
                              enabled: currentW > 1,
                              onTap: () => provider.resizeFurniture(furniture.id, currentW - 1, currentH),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '${(currentW * 0.5).toStringAsFixed(1)}m',
                                style: GoogleFonts.patrickHand(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.penBlueDark,
                                ),
                              ),
                            ),
                            _buildStepButton(
                              icon: Icons.add_rounded,
                              enabled: currentW < maxW,
                              onTap: () => provider.resizeFurniture(furniture.id, currentW + 1, currentH),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 1,
                      height: 24,
                      color: AppTheme.penBlue.withValues(alpha: 0.2),
                    ),
                    // Largo Stepper
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              'Largo:',
                              style: GoogleFonts.patrickHand(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.penBlack,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildStepButton(
                              icon: Icons.remove_rounded,
                              enabled: currentH > 1,
                              onTap: () => provider.resizeFurniture(furniture.id, currentW, currentH - 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '${(currentH * 0.5).toStringAsFixed(1)}m',
                                style: GoogleFonts.patrickHand(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.penBlueDark,
                                ),
                              ),
                            ),
                            _buildStepButton(
                              icon: Icons.add_rounded,
                              enabled: currentH < maxH,
                              onTap: () => provider.resizeFurniture(furniture.id, currentW, currentH + 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Action Buttons (Rotate, View Loot, Delete)
              Row(
                children: [
                  // Rotate Button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.penBlueDark,
                        side: const BorderSide(color: AppTheme.penBlue),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.rotate_right_rounded, size: 18),
                      label: Text(
                        'Rotar 90°',
                        style: GoogleFonts.patrickHand(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final ok = provider.rotateFurniture(furniture.id);
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.penRed,
                              content: Text(
                                'No hay espacio para rotar',
                                style: GoogleFonts.patrickHand(color: Colors.white, fontSize: 15),
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // View Items Button (or Architectural Structure Notice)
                  Expanded(
                    child: furniture.slotCapacity > 0
                        ? OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.penGreen,
                              side: const BorderSide(color: AppTheme.penGreen),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.all_inbox_rounded, size: 18),
                            label: Text(
                              'Ver Objetos',
                              style: GoogleFonts.patrickHand(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChestInventoryScreen(
                                    furnitureId: furniture.id,
                                    zoneId: zoneId,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.penBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.penBlue.withValues(alpha: 0.4), width: 1.0),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.meeting_room_outlined, size: 16, color: AppTheme.penBlue),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Paso / Acceso (Sin inventario)',
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
                  ),
                  const SizedBox(width: 8),

                  // Delete Button
                  IconButton(
                    tooltip: 'Borrar Mueble',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.penRed.withValues(alpha: 0.1),
                      side: const BorderSide(color: AppTheme.penRed),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.penRed, size: 20),
                    onPressed: () => provider.deleteFurniture(furniture.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: enabled ? AppTheme.paperSurfaceWarm : Colors.black12,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled ? AppTheme.penBlue : Colors.black26,
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppTheme.penBlue : Colors.black38,
        ),
      ),
    );
  }
}
