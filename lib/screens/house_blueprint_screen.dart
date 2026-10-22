import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/create_zone_dialog.dart';
import '../widgets/doodle_painters.dart';
import '../widgets/floor_selector_widget.dart';
import '../widgets/house_room_node.dart';
import '../widgets/zone_blueprint_edit_panel.dart';

class HouseBlueprintScreen extends StatefulWidget {
  const HouseBlueprintScreen({super.key});

  @override
  State<HouseBlueprintScreen> createState() => _HouseBlueprintScreenState();
}

class _HouseBlueprintScreenState extends State<HouseBlueprintScreen> {
  final TransformationController _transformationController =
      TransformationController();
  bool _isArchitectMode = false;
  static const double _canvasSize = 2800.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerView();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _centerView() {
    final matrix = Matrix4.identity()
      ..setTranslationRaw(-400.0, -350.0, 0.0)
      ..storage[0] = 0.85
      ..storage[5] = 0.85;
    _transformationController.value = matrix;
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale < 2.2) {
      final matrix = _transformationController.value.clone();
      matrix.storage[0] *= 1.25;
      matrix.storage[5] *= 1.25;
      _transformationController.value = matrix;
    }
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 0.35) {
      final matrix = _transformationController.value.clone();
      matrix.storage[0] *= 0.8;
      matrix.storage[5] *= 0.8;
      _transformationController.value = matrix;
    }
  }

  String _getFloorTitle(int floor) {
    if (floor == -1) return 'Sótano (-1)';
    if (floor == 1) return 'Planta Baja (PB)';
    if (floor == 2) return 'Planta Alta (P1)';
    return 'Piso $floor';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final zonesOnFloor = provider.zonesOnSelectedFloor;
    final currentFloor = provider.selectedFloor;
    final selectedZone = provider.selectedBlueprintZone;

    return Scaffold(
      backgroundColor: AppTheme.paperBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(1200),
              minScale: 0.3,
              maxScale: 2.5,
              constrained: false,
              panEnabled: true,
              scaleEnabled: true,
              child: SizedBox(
                width: _canvasSize,
                height: _canvasSize,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (provider.selectedBlueprintZoneId != null) {
                            provider.selectBlueprintZone(null);
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppTheme.paperBackground,
                          ),
                          child: CustomPaint(painter: BlueprintGridPainter()),
                        ),
                      ),
                    ),

                    if (zonesOnFloor.isEmpty)
                      Positioned(
                        left: 450,
                        top: 400,
                        child: _buildEmptyFloorNotice(context, currentFloor),
                      )
                    else
                      ...zonesOnFloor.map((zone) {
                        return HouseRoomNode(
                          key: ValueKey(zone.id),
                          zone: zone,
                          isArchitectMode: _isArchitectMode,
                          cellSize: 28.0,
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.penBlueDark.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(1, 3),
                    ),
                  ],
                ),
                child: CustomPaint(
                  foregroundPainter: const DoodleBorderPainter(
                    color: AppTheme.penBlue,
                    strokeWidth: 1.8,
                    borderRadius: 14.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.penBlueDark,
                          size: 20,
                        ),
                        tooltip: 'Volver al Inicio',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Plano de la Casa',
                                    style: GoogleFonts.patrickHand(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.penBlueDark,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.penBlue.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppTheme.penBlue,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      _getFloorTitle(currentFloor),
                                      style: GoogleFonts.patrickHand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.penBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _isArchitectMode
                                  ? (selectedZone != null
                                        ? 'Ajusta tamaño o rotación en el panel inferior'
                                        : 'Toca un cuarto o pasillo para editarlo o arrastrarlo')
                                  : 'Toca un cuarto para entrar o ver sus objetos',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.patrickHand(
                                fontSize: 12,
                                color: _isArchitectMode
                                    ? AppTheme.penRed
                                    : AppTheme.penBlack.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isArchitectMode = !_isArchitectMode;
                            provider.selectBlueprintZone(null);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _isArchitectMode
                                ? AppTheme.penRed
                                : AppTheme.penBlue,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isArchitectMode
                                  ? AppTheme.penBlack
                                  : AppTheme.penBlueDark,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isArchitectMode
                                    ? Icons.design_services_rounded
                                    : Icons.explore_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _isArchitectMode ? 'Arquitecto' : 'Explorar',
                                style: GoogleFonts.patrickHand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
            ),
          ),
          Positioned(
            top: 76,
            left: 16,
            right: 16,
            child: const SafeArea(child: FloorSelectorWidget()),
          ),
          if (_isArchitectMode && selectedZone == null)
            Positioned(
              bottom: 85,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.paperSurfaceWarm,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.penRed, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.penRed.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: AppTheme.penRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Modo Arquitecto: Toca un cuarto o pasillo para cambiar su tamaño/rotación, o arrástralo para alinearlo.',
                        style: GoogleFonts.patrickHand(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.penBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            right: 16,
            bottom: (_isArchitectMode && selectedZone != null)
                ? 185
                : (_isArchitectMode ? 140 : 85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildZoomButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Acercar Zoom',
                  onTap: _zoomIn,
                ),
                const SizedBox(height: 8),
                _buildZoomButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Alejar Zoom',
                  onTap: _zoomOut,
                ),
                const SizedBox(height: 8),
                _buildZoomButton(
                  icon: Icons.center_focus_strong_rounded,
                  tooltip: 'Centrar Plano',
                  onTap: _centerView,
                ),
              ],
            ),
          ),
          if (selectedZone == null)
            Positioned(
              left: 20,
              bottom: 20,
              child: FloatingActionButton.extended(
                heroTag: 'add_room_blueprint_fab',
                backgroundColor: AppTheme.penBlue,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_home_rounded, size: 20),
                label: Text(
                  '+ Habitación / Pasillo',
                  style: GoogleFonts.patrickHand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const CreateZoneDialog(),
                  );
                },
              ),
            ),

          if (_isArchitectMode && selectedZone != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ZoneBlueprintEditPanel(zone: selectedZone),
            ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.penBlueDark.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppTheme.penBlueDark, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFloorNotice(BuildContext context, int currentFloor) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.penBlueDark.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: const DoodleBorderPainter(
          color: AppTheme.penBlue,
          strokeWidth: 1.8,
          borderRadius: 14.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.apartment_rounded,
              size: 48,
              color: AppTheme.penBlue,
            ),
            const SizedBox(height: 10),
            Text(
              'Piso sin habitaciones',
              style: GoogleFonts.patrickHand(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.penBlueDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Aún no hay habitaciones ni patios trazados en ${_getFloorTitle(currentFloor)}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.patrickHand(
                fontSize: 14,
                color: AppTheme.penBlack.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_home_rounded, size: 18),
              label: Text(
                'Dibujar en este Piso',
                style: GoogleFonts.patrickHand(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
}

class BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const gridSpacing = 28.0;
    final gridPaint = Paint()
      ..color = AppTheme.penBlue.withValues(alpha: 0.12)
      ..strokeWidth = 0.7;

    final majorGridPaint = Paint()
      ..color = AppTheme.penBlue.withValues(alpha: 0.25)
      ..strokeWidth = 1.2;

    int col = 0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      final isMajor = col % 5 == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isMajor ? majorGridPaint : gridPaint,
      );
      col++;
    }

    int row = 0;
    for (double y = 0; y < size.height; y += gridSpacing) {
      final isMajor = row % 5 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMajor ? majorGridPaint : gridPaint,
      );
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
