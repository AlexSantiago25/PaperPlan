import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import 'doodle_painters.dart';

class FloorSelectorWidget extends StatelessWidget {
  const FloorSelectorWidget({super.key});

  String _getFloorLabel(int floor) {
    if (floor == -1) return 'Sótano';
    if (floor == 1) return 'PB (Planta Baja)';
    if (floor == 2) return 'P1 (Planta Alta)';
    return 'Piso $floor';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final floors = provider.availableFloors;
    final activeFloor = provider.selectedFloor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.penBlueDark.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: const DoodleBorderPainter(
          color: AppTheme.penBlue,
          strokeWidth: 1.8,
          borderRadius: 12.0,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.apartment_rounded, size: 18, color: AppTheme.penBlueDark),
              const SizedBox(width: 8),
              Text(
                'Piso:',
                style: GoogleFonts.patrickHand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.penBlueDark,
                ),
              ),
              const SizedBox(width: 8),
              ...floors.map((floor) {
                final isSelected = activeFloor == floor;
                return GestureDetector(
                  onTap: () => provider.setSelectedFloor(floor),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.penBlue : AppTheme.paperSurfaceWarm,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.penBlueDark : AppTheme.penBlue.withValues(alpha: 0.3),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Text(
                      _getFloorLabel(floor),
                      style: GoogleFonts.patrickHand(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppTheme.penBlack,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 4),
              // Add floor button
              InkWell(
                onTap: () {
                  final nextFloor = floors.last + 1;
                  provider.setSelectedFloor(nextFloor);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.penBlue,
                      duration: const Duration(seconds: 1),
                      content: Text(
                        'Piso $nextFloor seleccionado. Agrega habitaciones en este piso.',
                        style: GoogleFonts.patrickHand(fontSize: 15, color: Colors.white),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.penBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.penBlue.withValues(alpha: 0.4), width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 14, color: AppTheme.penBlue),
                      const SizedBox(width: 2),
                      Text(
                        '+ Piso',
                        style: GoogleFonts.patrickHand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.penBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
