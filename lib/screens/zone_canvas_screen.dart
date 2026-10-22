import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/zone.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/doodle_painters.dart';
import '../widgets/furniture_catalog_sheet.dart';
import '../widgets/furniture_edit_panel.dart';
import '../widgets/grid_canvas.dart';

class ZoneCanvasScreen extends StatelessWidget {
  final String zoneId;

  const ZoneCanvasScreen({super.key, required this.zoneId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final zone = provider.zones.firstWhere(
      (z) => z.id == zoneId,
      orElse: () => provider.zones.isNotEmpty ? provider.zones.first : const Zone(id: 'none', name: 'Zona'),
    );

    final isEditor = provider.viewMode == AppViewMode.editor;

    return Scaffold(
      backgroundColor: AppTheme.paperBackground,
      body: NotebookPaperBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar (Sea Battle 2 Header style)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.penBlueDark),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: zone.themeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.penBlack, width: 1.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.patrickHand(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.penBlueDark,
                            ),
                          ),
                          Text(
                            '${zone.dimensionsFormatted} (${zone.gridColumns}x${zone.gridRows}) • ${zone.totalFurnitureCount} Muebles • ${zone.totalItemsCount} Objetos',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.patrickHand(
                              fontSize: 13,
                              color: AppTheme.penBlack.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mode Toggle Switch Button (Explorar vs Dibujar/Editor)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isEditor ? AppTheme.penRed : AppTheme.penBlue,
                          width: 1.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModeButton(
                            icon: Icons.visibility_rounded,
                            label: 'Explorar',
                            isActive: !isEditor,
                            activeColor: AppTheme.penBlue,
                            onTap: () {
                              if (isEditor) provider.setViewMode(AppViewMode.exploration);
                            },
                          ),
                          const SizedBox(width: 4),
                          _buildModeButton(
                            icon: Icons.edit_rounded,
                            label: 'Dibujar',
                            isActive: isEditor,
                            activeColor: AppTheme.penRed,
                            onTap: () {
                              if (!isEditor) provider.setViewMode(AppViewMode.editor);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Mode Hint Banner (Sticky Note style)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isEditor
                      ? AppTheme.penRed.withValues(alpha: 0.1)
                      : AppTheme.paperSurfaceWarm,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isEditor ? AppTheme.penRed.withValues(alpha: 0.5) : AppTheme.penBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isEditor ? Icons.edit_note_rounded : Icons.touch_app_rounded,
                      size: 16,
                      color: isEditor ? AppTheme.penRed : AppTheme.penBlue,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isEditor
                            ? 'Modo Dibujo: Arrastra muebles del catálogo al plano. Toca uno para rotarlo o borrarlo.'
                            : 'Modo Exploración: Toca cualquier mueble o contenedor para ver sus objetos guardados.',
                        style: GoogleFonts.patrickHand(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isEditor ? AppTheme.penRed : AppTheme.penBlueDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main 2D Grid Canvas (The Notebook Grid)
              Expanded(
                child: GridCanvas(zone: zone),
              ),

              // Bottom Drawer in Editor Mode (Switches between Edit Panel and Catalog Sheet)
              if (isEditor)
                provider.selectedFurniture != null
                    ? FurnitureEditPanel(
                        furniture: provider.selectedFurniture!,
                        zoneId: zone.id,
                      )
                    : const FurnitureCatalogSheet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? Colors.white : AppTheme.penBlack.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.patrickHand(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : AppTheme.penBlack.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
