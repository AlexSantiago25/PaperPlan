import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/zone.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/create_zone_dialog.dart';
import '../widgets/doodle_painters.dart';
import '../widgets/global_search_bar.dart';
import 'house_blueprint_screen.dart';
import 'search_results_view.dart';
import 'zone_canvas_screen.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  String _getFloorLabel(int floor) {
    if (floor == -1) return '🏢 Sótano (-1)';
    if (floor == 1) return '🏢 PB (Planta Baja)';
    if (floor == 2) return '🏢 P1 (Planta Alta)';
    return '🏢 Piso $floor';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.paperBackground,
      body: NotebookPaperBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Notebook Header (Sea Battle 2 Game Header Style)
              _buildNotebookHeader(context, provider),

              // Top Search Bar
              const Padding(
                padding: EdgeInsets.fromLTRB(42, 4, 16, 8),
                child: GlobalSearchBar(),
              ),

              // Main View: Either Search Results or Zones List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: provider.searchQuery.isNotEmpty
                      ? const SearchResultsView()
                      : _buildHubContent(context, provider),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.penBlue,
        icon: const Icon(Icons.edit_location_alt_rounded, size: 20),
        label: Text(
          '+ Nueva Zona',
          style: GoogleFonts.patrickHand(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateZoneDialog(),
          );
        },
      ),
    );
  }

  Widget _buildNotebookHeader(BuildContext context, InventoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(42, 10, 16, 4),
      child: Row(
        children: [
          // PaperPlan Brand Logo
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppTheme.penBlue, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.penBlue.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.asset(
                'assets/PaperPlanLogo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.draw_rounded,
                  color: AppTheme.penBlue,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PaperPlan 📝',
                  style: GoogleFonts.patrickHand(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.penBlueDark,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Plano & Inventario en Libreta Cuadriculada',
                  style: GoogleFonts.patrickHand(
                    fontSize: 13,
                    color: AppTheme.penBlack.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.penBlueDark),
            color: AppTheme.paperSurfaceWarm,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.penBlue, width: 1.5),
            ),
            onSelected: (val) {
              if (val == 'reset') {
                provider.resetToSeedData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.penBlue,
                    content: Text(
                      'Planos de demostración restaurados',
                      style: GoogleFonts.patrickHand(fontSize: 16),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    const Icon(Icons.restart_alt_rounded, color: AppTheme.penBlue, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Restaurar Planos Demo',
                      style: GoogleFonts.patrickHand(fontSize: 16, color: AppTheme.penBlack),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHubContent(BuildContext context, InventoryProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.penBlue),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 4, 16, 90),
      children: [
        // Stats Overview
        _buildStatsOverview(provider),
        const SizedBox(height: 14),

        // Prominent House Blueprint Banner Button
        _buildHouseBlueprintBanner(context, provider),
        const SizedBox(height: 16),

        // Zones Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.map_rounded,
                  size: 18,
                  color: AppTheme.penBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  'Zonas y Planos Dibujados',
                  style: GoogleFonts.patrickHand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.penBlueDark,
                  ),
                ),
              ],
            ),
            Text(
              '${provider.zones.length} Zonas',
              style: GoogleFonts.patrickHand(fontSize: 14, color: AppTheme.penBlack.withValues(alpha: 0.6)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Zones List Cards
        if (provider.zones.isEmpty)
          _buildEmptyZonesPrompt(context)
        else
          ...provider.zones.map((zone) => _buildZoneCard(context, provider, zone)),
      ],
    );
  }

  Widget _buildHouseBlueprintBanner(BuildContext context, InventoryProvider provider) {
    final floorCount = provider.availableFloors.length;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Soft blueprint blue
        borderRadius: BorderRadius.circular(14),
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
          color: AppTheme.penBlueDark,
          strokeWidth: 2.2,
          borderRadius: 14.0,
          isDoubleLine: true,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HouseBlueprintScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.penBlue,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.penBlue.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '🗺️ Ver Plano de la Casa',
                              style: GoogleFonts.patrickHand(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.penBlueDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.penBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$floorCount Pisos',
                                style: GoogleFonts.patrickHand(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.penBlueDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Explora toda la casa, une cuartos, patios y pasillos',
                          style: GoogleFonts.patrickHand(
                            fontSize: 13,
                            color: AppTheme.penBlack.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.penBlueDark,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(InventoryProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.paperSurfaceWarm, // Sticky note yellow
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.penBlueDark.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: const DoodleBorderPainter(
          color: AppTheme.penBlue,
          strokeWidth: 1.8,
          borderRadius: 12.0,
          isDoubleLine: true,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Cuartos',
                  value: '${provider.totalZonesCount}',
                  color: AppTheme.penBlue,
                ),
              ),
              Container(width: 1, height: 28, color: AppTheme.penBlue.withValues(alpha: 0.3)),
              Expanded(
                child: _buildStatItem(
                  label: 'Objetos',
                  value: '${provider.totalItemsCount}',
                  color: AppTheme.penBlack,
                ),
              ),
              Container(width: 1, height: 28, color: AppTheme.penBlue.withValues(alpha: 0.3)),
              Expanded(
                child: _buildStatItem(
                  label: 'Legendarios',
                  value: '${provider.totalLegendaryCount}',
                  color: AppTheme.penGold,
                ),
              ),
              Container(width: 1, height: 28, color: AppTheme.penBlue.withValues(alpha: 0.3)),
              Expanded(
                child: _buildStatItem(
                  label: 'Épicos',
                  value: '${provider.totalEpicCount}',
                  color: AppTheme.penPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.patrickHand(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.patrickHand(
            fontSize: 12,
            color: AppTheme.penBlack.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneCard(
    BuildContext context,
    InventoryProvider provider,
    Zone zone,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: zone.isPatio ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.penBlueDark.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: DoodleBorderPainter(
          color: zone.isPatio ? AppTheme.penGreen : zone.themeColor,
          strokeWidth: 1.8,
          borderRadius: 12.0,
          isDoubleLine: !zone.isPatio,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              provider.setActiveZone(zone.id);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ZoneCanvasScreen(zoneId: zone.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon, Name, Dimensions
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (zone.isPatio ? AppTheme.penGreen : zone.themeColor).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: zone.isPatio ? AppTheme.penGreen : zone.themeColor, width: 1.2),
                        ),
                        child: Icon(
                          zone.isPatio ? Icons.yard_rounded : _getIconForKey(zone.iconKey),
                          color: zone.isPatio ? AppTheme.penGreen : zone.themeColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              zone.name,
                              style: GoogleFonts.patrickHand(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.penBlack,
                              ),
                            ),
                            if (zone.description.isNotEmpty) ...[
                              Text(
                                zone.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.patrickHand(
                                  fontSize: 13,
                                  color: AppTheme.penBlack.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.paperSurfaceWarm,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: zone.isPatio ? AppTheme.penGreen : zone.themeColor, width: 1.0),
                        ),
                        child: Text(
                          zone.dimensionsFormatted,
                          style: GoogleFonts.patrickHand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: zone.isPatio ? AppTheme.penGreen : zone.themeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Middle Stats badges
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      _buildZoneMetricBadge(
                        label: _getFloorLabel(zone.floor),
                        color: AppTheme.penBlueDark,
                      ),
                      if (zone.isPatio)
                        _buildZoneMetricBadge(
                          label: '🌿 Patio / Exterior',
                          color: AppTheme.penGreen,
                        ),
                      if (zone.isHallway)
                        _buildZoneMetricBadge(
                          label: '🚶 Pasillo Conector',
                          color: const Color(0xFF64748B),
                        ),
                      _buildZoneMetricBadge(
                        label: '📐 ${(zone.realWidthMeters * zone.realHeightMeters).toStringAsFixed(1)} m²',
                        color: AppTheme.penBlueDark,
                      ),
                      _buildZoneMetricBadge(
                        label: '${zone.gridColumns}x${zone.gridRows}',
                        color: zone.isPatio ? AppTheme.penGreen : zone.themeColor,
                      ),
                      _buildZoneMetricBadge(
                        label: '${zone.totalFurnitureCount} Objetos',
                        color: AppTheme.penBlue,
                      ),
                      _buildZoneMetricBadge(
                        label: '${zone.totalItemsCount} Guardados',
                        color: AppTheme.penGreen,
                      ),
                      if (zone.legendaryItemsCount > 0)
                        _buildZoneMetricBadge(
                          label: '${zone.legendaryItemsCount} ⭐',
                          color: AppTheme.penGold,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bottom Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: zone.isPatio ? AppTheme.penGreen : zone.themeColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          icon: const Icon(Icons.grid_on_rounded, size: 16),
                          label: Text(
                            zone.isPatio
                                ? 'Abrir Plano del Patio'
                                : (zone.isHallway ? 'Abrir Plano del Pasillo' : 'Abrir Plano Cuadriculado'),
                            style: GoogleFonts.patrickHand(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            provider.setActiveZone(zone.id);
                            provider.setViewMode(AppViewMode.exploration);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ZoneCanvasScreen(zoneId: zone.id),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'Borrar Plano',
                        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.penRed, size: 20),
                        onPressed: () => _showDeleteZoneDialog(context, provider, zone),
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

  Widget _buildZoneMetricBadge({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1.0),
      ),
      child: Text(
        label,
        style: GoogleFonts.patrickHand(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyZonesPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            const Icon(Icons.edit_note_rounded, size: 56, color: AppTheme.penBlue),
            const SizedBox(height: 12),
            Text(
              'No hay planos dibujados en la libreta',
              style: GoogleFonts.patrickHand(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.penBlueDark),
            ),
            const SizedBox(height: 6),
            Text(
              'Toca "+ Nueva Zona" para empezar a trazar tu primera habitación.',
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(fontSize: 15, color: AppTheme.penBlack.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: Text('Dibujar Primera Zona', style: GoogleFonts.patrickHand(fontSize: 16)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const CreateZoneDialog(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteZoneDialog(BuildContext context, InventoryProvider provider, Zone zone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Borrar plano de ${zone.name}?'),
        content: Text(
          'Se borrarán todos los muebles y anotaciones de esta habitación.',
          style: GoogleFonts.patrickHand(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: GoogleFonts.patrickHand(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.penRed),
            onPressed: () {
              provider.deleteZone(zone.id);
              Navigator.of(context).pop();
            },
            child: Text('Borrar Plano', style: GoogleFonts.patrickHand(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      case 'yard':
        return Icons.yard_rounded;
      case 'hallway':
        return Icons.view_timeline_outlined;
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
      default:
        return Icons.meeting_room_rounded;
    }
  }
}
