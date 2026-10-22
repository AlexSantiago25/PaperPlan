import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/doodle_painters.dart';
import 'chest_inventory_screen.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final results = provider.searchResults;

    if (provider.searchQuery.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppTheme.penBlue,
              ),
              const SizedBox(height: 12),
              Text(
                'No hay nada anotado con "${provider.searchQuery}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.patrickHand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.penBlueDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Prueba buscando por nombre, etiqueta (#cables, #viaje) o categoría.',
                textAlign: TextAlign.center,
                style: GoogleFonts.patrickHand(fontSize: 15, color: AppTheme.penBlack.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(10, 4, 16, 80),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final result = results[index];
        final item = result.item;
        final rarity = item.rarity;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
              color: rarity.color,
              strokeWidth: 1.6,
              borderRadius: 12.0,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChestInventoryScreen(
                        furnitureId: result.furniture.id,
                        zoneId: result.zone.id,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breadcrumb Path (Underlined in Pen Blue)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.paperSurfaceWarm,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.penBlue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.place_rounded,
                              size: 13,
                              color: AppTheme.penBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              result.pathBreadcrumb,
                              style: GoogleFonts.patrickHand(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.penBlueDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Item Row
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: PenHatchPainter(
                                      color: rarity.color.withValues(alpha: 0.25),
                                      spacing: 4.0,
                                      strokeWidth: 0.9,
                                      borderRadius: 10.0,
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: DoodleBorderPainter(
                                      color: rarity.color,
                                      strokeWidth: 1.5,
                                      borderRadius: 10.0,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Icon(
                                    item.category.icon,
                                    color: rarity.color,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: GoogleFonts.patrickHand(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.penBlack,
                                        ),
                                      ),
                                    ),
                                    if (item.quantity > 1)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: rarity.color, width: 1.0),
                                        ),
                                        child: Text(
                                          'x${item.quantity}',
                                          style: GoogleFonts.patrickHand(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: rarity.color,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      rarity.displayName,
                                      style: GoogleFonts.patrickHand(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: rarity.color,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '• ${item.category.displayName}',
                                      style: GoogleFonts.patrickHand(
                                        fontSize: 13,
                                        color: AppTheme.penBlack.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.penBlue,
                          ),
                        ],
                      ),

                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.patrickHand(
                            fontSize: 13,
                            color: AppTheme.penBlack.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
