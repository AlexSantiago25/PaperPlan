import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import 'doodle_painters.dart';

enum SpaceType { room, hallway, patio }

class CreateZoneDialog extends StatefulWidget {
  final int? initialFloor;

  const CreateZoneDialog({
    super.key,
    this.initialFloor,
  });

  @override
  State<CreateZoneDialog> createState() => _CreateZoneDialogState();
}

class _CreateZoneDialogState extends State<CreateZoneDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  SpaceType _spaceType = SpaceType.room;
  int _gridCols = 8;
  int _gridRows = 8;
  int _selectedColorValue = 0xFF1D4ED8; // Royal Blue default
  String _selectedIconKey = 'meeting_room';
  late int _selectedFloor;

  final List<int> _colorOptions = [
    0xFF1D4ED8, // Bic Blue
    0xFF16A34A, // Green Pen
    0xFF64748B, // Slate Pen (Pasillos)
    0xFF7C3AED, // Purple Pen
    0xFFDC2626, // Red Pen
    0xFFD97706, // Amber / Gold Pen
    0xFF0284C7, // Cyan Pen
    0xFF0D9488, // Teal Pen
    0xFFDB2777, // Pink Pen
    0xFF4F46E5, // Indigo Pen
    0xFFEA580C, // Orange Pen
    0xFF18181B, // Black Pen
  ];

  final List<Map<String, dynamic>> _iconOptions = [
    {'key': 'meeting_room', 'icon': Icons.meeting_room_rounded, 'name': 'Cuarto'},
    {'key': 'hallway', 'icon': Icons.view_timeline_outlined, 'name': 'Pasillo'},
    {'key': 'yard', 'icon': Icons.yard_rounded, 'name': 'Patio'},
    {'key': 'computer', 'icon': Icons.computer_rounded, 'name': 'Oficina'},
    {'key': 'bed', 'icon': Icons.bed_rounded, 'name': 'Dormitorio'},
    {'key': 'construction', 'icon': Icons.construction_rounded, 'name': 'Taller'},
    {'key': 'kitchen', 'icon': Icons.kitchen_rounded, 'name': 'Cocina'},
    {'key': 'inventory_2', 'icon': Icons.inventory_2_rounded, 'name': 'Almacén'},
    {'key': 'garage', 'icon': Icons.garage_rounded, 'name': 'Garaje'},
    {'key': 'shield', 'icon': Icons.shield_rounded, 'name': 'Búnker'},
  ];

  final List<Map<String, dynamic>> _hallwayDimensions = [
    {'cols': 2, 'rows': 6, 'label': '2×6 (1×3m)'},
    {'cols': 2, 'rows': 8, 'label': '2×8 (1×4m)'},
    {'cols': 2, 'rows': 10, 'label': '2×10 (1×5m)'},
    {'cols': 6, 'rows': 2, 'label': '6×2 (3×1m)'},
    {'cols': 8, 'rows': 2, 'label': '8×2 (4×1m)'},
    {'cols': 10, 'rows': 2, 'label': '10×2 (5×1m)'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedFloor = widget.initialFloor ?? 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialFloor == null) {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      _selectedFloor = provider.selectedFloor;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _getFloorLabel(int floor) {
    if (floor == -1) return 'Sótano (-1)';
    if (floor == 1) return 'Planta Baja (PB)';
    if (floor == 2) return 'Planta Alta (P1)';
    return 'Piso $floor';
  }

  void _onSpaceTypeChanged(SpaceType type) {
    setState(() {
      _spaceType = type;
      if (type == SpaceType.room) {
        _gridCols = 8;
        _gridRows = 8;
        _selectedIconKey = 'meeting_room';
        _selectedColorValue = 0xFF1D4ED8;
        if (_nameController.text.isEmpty || _nameController.text == 'Pasillo' || _nameController.text == 'Patio') {
          _nameController.text = '';
        }
      } else if (type == SpaceType.hallway) {
        _gridCols = 2;
        _gridRows = 8;
        _selectedIconKey = 'hallway';
        _selectedColorValue = 0xFF64748B;
        if (_nameController.text.isEmpty) {
          _nameController.text = 'Pasillo Conector';
        }
      } else if (type == SpaceType.patio) {
        _gridCols = 8;
        _gridRows = 8;
        _selectedIconKey = 'yard';
        _selectedColorValue = 0xFF16A34A;
        if (_nameController.text.isEmpty) {
          _nameController.text = 'Patio Exterior';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final availableFloors = provider.availableFloors;
    if (!availableFloors.contains(_selectedFloor)) {
      availableFloors.add(_selectedFloor);
      availableFloors.sort();
    }

    final isPatio = _spaceType == SpaceType.patio;
    final isHallway = _spaceType == SpaceType.hallway;

    return Dialog(
      backgroundColor: AppTheme.paperSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.paperSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomPaint(
          foregroundPainter: DoodleBorderPainter(
            color: Color(_selectedColorValue),
            strokeWidth: 2.2,
            borderRadius: 16.0,
            isDoubleLine: !isPatio,
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
                          color: Color(_selectedColorValue).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(_selectedColorValue), width: 1.5),
                        ),
                        child: Icon(
                          _iconOptions.firstWhere(
                            (i) => i['key'] == _selectedIconKey,
                            orElse: () => _iconOptions.first,
                          )['icon'] as IconData,
                          color: Color(_selectedColorValue),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPatio
                                  ? 'Trazar Patio / Exterior'
                                  : (isHallway ? 'Trazar Pasillo Conector' : 'Dibujar Habitación'),
                              style: GoogleFonts.patrickHand(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Color(_selectedColorValue),
                              ),
                            ),
                            Text(
                              isPatio
                                  ? 'Área abierta sin paredes cerradas'
                                  : (isHallway ? 'Corredor para unir cuartos en el plano' : 'Cuarto para almacenar y organizar'),
                              style: GoogleFonts.patrickHand(fontSize: 13, color: AppTheme.penBlack.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Space Type 3-Way Selector (Habitación, Pasillo, Patio)
                  Row(
                    children: [
                      // 1. Habitación
                      Expanded(
                        child: _buildTypeChip(
                          title: 'Habitación',
                          icon: Icons.meeting_room_rounded,
                          isSelected: _spaceType == SpaceType.room,
                          activeColor: AppTheme.penBlue,
                          onTap: () => _onSpaceTypeChanged(SpaceType.room),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 2. Pasillo
                      Expanded(
                        child: _buildTypeChip(
                          title: 'Pasillo',
                          icon: Icons.view_timeline_outlined,
                          isSelected: _spaceType == SpaceType.hallway,
                          activeColor: const Color(0xFF64748B),
                          onTap: () => _onSpaceTypeChanged(SpaceType.hallway),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 3. Patio
                      Expanded(
                        child: _buildTypeChip(
                          title: 'Patio',
                          icon: Icons.yard_rounded,
                          isSelected: _spaceType == SpaceType.patio,
                          activeColor: AppTheme.penGreen,
                          onTap: () => _onSpaceTypeChanged(SpaceType.patio),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Floor Selector (Piso)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Piso de la Casa:',
                        style: GoogleFonts.patrickHand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.penBlueDark,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          final nextFloor = (availableFloors.isNotEmpty ? availableFloors.last : 1) + 1;
                          setState(() {
                            _selectedFloor = nextFloor;
                          });
                        },
                        child: Text(
                          '+ Nuevo Piso',
                          style: GoogleFonts.patrickHand(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.penBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: availableFloors.map((fl) {
                        final isSelected = _selectedFloor == fl;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFloor = fl),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.penBlueDark : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? AppTheme.penBlack : AppTheme.penBlue.withValues(alpha: 0.4),
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Text(
                              _getFloorLabel(fl),
                              style: GoogleFonts.patrickHand(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : AppTheme.penBlack,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name Input
                  TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    style: GoogleFonts.patrickHand(fontSize: 17, color: AppTheme.penBlack),
                    decoration: InputDecoration(
                      labelText: isPatio
                          ? 'Nombre del Patio / Terraza'
                          : (isHallway ? 'Nombre del Pasillo' : 'Nombre de la Habitación'),
                      labelStyle: GoogleFonts.patrickHand(fontSize: 16, color: AppTheme.penBlue),
                      hintText: isPatio
                          ? 'Ej. Patio Trasero, Jardín'
                          : (isHallway ? 'Ej. Pasillo Central, Corredor PB' : 'Ej. Mi Cuarto, Sala, Cocina'),
                      prefixIcon: Icon(
                        isPatio ? Icons.yard_rounded : (isHallway ? Icons.view_timeline_outlined : Icons.edit_rounded),
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Ingresa un nombre para la zona';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Description Input
                  TextFormField(
                    controller: _descController,
                    style: GoogleFonts.patrickHand(fontSize: 16, color: AppTheme.penBlack),
                    decoration: InputDecoration(
                      labelText: 'Anotaciones / Notas (Opcional)',
                      labelStyle: GoogleFonts.patrickHand(fontSize: 16, color: AppTheme.penBlue),
                      hintText: isHallway
                          ? 'Ej. Conecta la sala con la cocina'
                          : 'Ej. Segundo piso, lado de la ventana',
                      prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Grid Dimension Selector Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isHallway
                              ? 'Formato del Pasillo:'
                              : (isPatio ? 'Dimensiones del Patio:' : 'Dimensiones del Cuarto:'),
                          style: GoogleFonts.patrickHand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.penBlueDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.penBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '1 cuad. = 0.5m',
                          style: GoogleFonts.patrickHand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.penBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Dimensions Selector
                  if (isHallway)
                    // Hallway rectangular formats
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _hallwayDimensions.map((hDim) {
                          final cols = hDim['cols'] as int;
                          final rows = hDim['rows'] as int;
                          final isSelected = _gridCols == cols && _gridRows == rows;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _gridCols = cols;
                              _gridRows = rows;
                            }),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF64748B) : AppTheme.paperSurfaceWarm,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppTheme.penBlack : AppTheme.penBlue.withValues(alpha: 0.4),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Text(
                                hDim['label'] as String,
                                style: GoogleFonts.patrickHand(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : AppTheme.penBlack,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  else
                    // Room & Patio square formats
                    Row(
                      children: [6, 8, 10, 12].map((size) {
                        final isSelected = _gridCols == size && _gridRows == size;
                        final meters = (size * 0.5).toStringAsFixed(1);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _gridCols = size;
                              _gridRows = size;
                            }),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isPatio ? AppTheme.penGreen : AppTheme.penBlue)
                                    : AppTheme.paperSurfaceWarm,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? (isPatio ? const Color(0xFF14532D) : AppTheme.penBlueDark)
                                      : AppTheme.penBlue.withValues(alpha: 0.4),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${size}x$size',
                                        style: GoogleFonts.patrickHand(
                                          fontSize: 15,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? Colors.white : AppTheme.penBlack,
                                        ),
                                      ),
                                      Text(
                                        '${meters}x${meters}m',
                                        style: GoogleFonts.patrickHand(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white.withValues(alpha: 0.9) : AppTheme.penBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 6),

                  // Real Dimension Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(_selectedColorValue).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(_selectedColorValue).withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.straighten_rounded, size: 16, color: Color(_selectedColorValue)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tamaño real: ${(_gridCols * 0.5).toStringAsFixed(1)}m × ${(_gridRows * 0.5).toStringAsFixed(1)}m (${(_gridCols * 0.5 * _gridRows * 0.5).toStringAsFixed(1)} m²)',
                            style: GoogleFonts.patrickHand(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(_selectedColorValue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Icon Picker
                  Text(
                    'Icono del Plano:',
                    style: GoogleFonts.patrickHand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.penBlueDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _iconOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = _iconOptions[index];
                        final isSelected = _selectedIconKey == item['key'];
                        return InkWell(
                          onTap: () => setState(() => _selectedIconKey = item['key'] as String),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected ? Color(_selectedColorValue).withValues(alpha: 0.2) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Color(_selectedColorValue) : AppTheme.penBlue.withValues(alpha: 0.3),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: isSelected ? Color(_selectedColorValue) : AppTheme.penBlueDark.withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Color Theme Selector
                  Text(
                    'Tinta del Plano:',
                    style: GoogleFonts.patrickHand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.penBlueDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _colorOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final cVal = _colorOptions[index];
                        final isSelected = _selectedColorValue == cVal;
                        return Center(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedColorValue = cVal),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: isSelected ? 36 : 30,
                              height: isSelected ? 36 : 30,
                              decoration: BoxDecoration(
                                color: Color(cVal),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppTheme.penBlack : Colors.white,
                                  width: isSelected ? 2.5 : 1.5,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Color(cVal).withValues(alpha: 0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.patrickHand(fontSize: 17, color: AppTheme.penBlack.withValues(alpha: 0.6)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(_selectedColorValue),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        icon: Icon(
                          isPatio ? Icons.yard_rounded : (isHallway ? Icons.view_timeline_outlined : Icons.draw_rounded),
                          size: 18,
                        ),
                        label: Text(
                          isPatio ? 'Trazar Patio' : (isHallway ? 'Trazar Pasillo' : 'Crear Habitación'),
                          style: GoogleFonts.patrickHand(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Provider.of<InventoryProvider>(context, listen: false).addZone(
                              name: _nameController.text.trim(),
                              description: _descController.text.trim(),
                              gridColumns: _gridCols,
                              gridRows: _gridRows,
                              themeColorValue: _selectedColorValue,
                              iconKey: _selectedIconKey,
                              floor: _selectedFloor,
                              isPatio: isPatio,
                              isHallway: isHallway,
                            );
                            Navigator.of(context).pop();
                          }
                        },
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

  Widget _buildTypeChip({
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppTheme.paperSurfaceWarm,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.penBlack : activeColor.withValues(alpha: 0.3),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 15, color: isSelected ? Colors.white : activeColor),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: GoogleFonts.patrickHand(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppTheme.penBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
