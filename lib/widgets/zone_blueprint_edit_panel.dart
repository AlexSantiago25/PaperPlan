import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/zone.dart';
import '../providers/inventory_provider.dart';
import '../screens/zone_canvas_screen.dart';
import '../theme/app_theme.dart';

class ZoneBlueprintEditPanel extends StatelessWidget {
  final Zone zone;

  const ZoneBlueprintEditPanel({
    super.key,
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final currentCols = zone.gridColumns;
    final currentRows = zone.gridRows;

    final isPatio = zone.isPatio;
    final isHallway = zone.isHallway;
    final themeColor = isPatio
        ? AppTheme.penGreen
        : (isHallway ? const Color(0xFF64748B) : zone.themeColor);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.paperSurfaceWarm, // Yellow sticky note paper
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: const Border(
          top: BorderSide(color: AppTheme.penRed, width: 2.0),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.penBlueDark.withValues(alpha: 0.18),
            blurRadius: 12,
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
              // 1. Top Drag Handle
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

              // 2. Header: Icon, Name, Type Badge & Finish Button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: themeColor, width: 1.2),
                    ),
                    child: Icon(
                      isPatio
                          ? Icons.yard_rounded
                          : (isHallway ? Icons.view_timeline_outlined : _getIconForKey(zone.iconKey)),
                      color: themeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                zone.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.patrickHand(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.penBlack,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isPatio
                                    ? 'Patio'
                                    : (isHallway ? 'Pasillo' : 'Habitación'),
                                style: GoogleFonts.patrickHand(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${zone.dimensionsFormatted} ($currentCols×$currentRows celdas)',
                          style: GoogleFonts.patrickHand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.penBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Deselect Button
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
                    onPressed: () => provider.selectBlueprintZone(null),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 3. Stepper Dimension Controls (Ancho & Largo in meters/cells)
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
                              enabled: currentCols > 1,
                              onTap: () {
                                final ok = provider.resizeZone(zone.id, currentCols - 1, currentRows);
                                if (!ok) {
                                  _showErrorSnackBar(context, 'Los muebles no caben en este ancho');
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '${(currentCols * 0.5).toStringAsFixed(1)}m',
                                style: GoogleFonts.patrickHand(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.penBlueDark,
                                ),
                              ),
                            ),
                            _buildStepButton(
                              icon: Icons.add_rounded,
                              enabled: currentCols < 20,
                              onTap: () {
                                provider.resizeZone(zone.id, currentCols + 1, currentRows);
                              },
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
                              enabled: currentRows > 1,
                              onTap: () {
                                final ok = provider.resizeZone(zone.id, currentCols, currentRows - 1);
                                if (!ok) {
                                  _showErrorSnackBar(context, 'Los muebles no caben en este largo');
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '${(currentRows * 0.5).toStringAsFixed(1)}m',
                                style: GoogleFonts.patrickHand(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.penBlueDark,
                                ),
                              ),
                            ),
                            _buildStepButton(
                              icon: Icons.add_rounded,
                              enabled: currentRows < 20,
                              onTap: () {
                                provider.resizeZone(zone.id, currentCols, currentRows + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 4. Action Buttons Row: Rotate, Enter/Configure, Delete
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
                        'Rotar',
                        style: GoogleFonts.patrickHand(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final ok = provider.rotateZone(zone.id);
                        if (!ok) {
                          _showErrorSnackBar(context, 'No se puede rotar por muebles internos');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Enter Zone / Design Furniture
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: themeColor,
                        side: BorderSide(color: themeColor),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.brush_rounded, size: 16),
                      label: Text(
                        'Diseñar',
                        style: GoogleFonts.patrickHand(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        provider.setActiveZone(zone.id);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ZoneCanvasScreen(zoneId: zone.id),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Delete Zone Button
                  IconButton(
                    tooltip: 'Borrar Zona',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.penRed.withValues(alpha: 0.1),
                      side: const BorderSide(color: AppTheme.penRed),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.penRed, size: 20),
                    onPressed: () => _confirmDelete(context, provider),
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

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.penRed,
        content: Text(
          message,
          style: GoogleFonts.patrickHand(color: Colors.white, fontSize: 14),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete(BuildContext context, InventoryProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.paperSurfaceWarm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          '¿Eliminar "${zone.name}"?',
          style: GoogleFonts.patrickHand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.penRed,
          ),
        ),
        content: Text(
          'Se eliminará este espacio y todos los muebles y objetos que contiene.',
          style: GoogleFonts.patrickHand(fontSize: 15, color: AppTheme.penBlack),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancelar',
              style: GoogleFonts.patrickHand(fontSize: 16, color: AppTheme.penBlueDark),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.penRed),
            child: Text(
              'Eliminar',
              style: GoogleFonts.patrickHand(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.deleteZone(zone.id);
            },
          ),
        ],
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
