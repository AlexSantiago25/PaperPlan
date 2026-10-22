import 'package:flutter/material.dart';
import 'item.dart';

enum FurnitureType {
  chest,
  wardrobe,
  desk,
  bookshelf,
  safe,
  drawer,
  shelf,
  backpack,
  fridge,
  box,
  bed,
  door,
  window,
  stairs,
  patioPlant,
}

extension FurnitureTypeExtension on FurnitureType {
  String get displayName {
    switch (this) {
      case FurnitureType.chest:
        return 'Baúl / Caja Organizadora';
      case FurnitureType.wardrobe:
        return 'Armario / Ropero';
      case FurnitureType.desk:
        return 'Escritorio de Trabajo';
      case FurnitureType.bookshelf:
        return 'Estantería';
      case FurnitureType.safe:
        return 'Caja Fuerte';
      case FurnitureType.drawer:
        return 'Cajonera Tech';
      case FurnitureType.shelf:
        return 'Repisa Flotante';
      case FurnitureType.backpack:
        return 'Mochila Táctica';
      case FurnitureType.fridge:
        return 'Nevera';
      case FurnitureType.box:
        return 'Caja de Almacén';
      case FurnitureType.bed:
        return 'Cama / Bajo Cama';
      case FurnitureType.door:
        return 'Puerta de Paso';
      case FurnitureType.window:
        return 'Ventana Exterior';
      case FurnitureType.stairs:
        return 'Escaleras de Piso';
      case FurnitureType.patioPlant:
        return 'Macetas / Jardín';
    }
  }

  IconData get defaultIcon {
    switch (this) {
      case FurnitureType.chest:
        return Icons.all_inbox_rounded;
      case FurnitureType.wardrobe:
        return Icons.door_sliding_rounded;
      case FurnitureType.desk:
        return Icons.table_restaurant_rounded;
      case FurnitureType.bookshelf:
        return Icons.menu_book_rounded;
      case FurnitureType.safe:
        return Icons.lock_clock_rounded;
      case FurnitureType.drawer:
        return Icons.inventory_2_rounded;
      case FurnitureType.shelf:
        return Icons.view_compact_rounded;
      case FurnitureType.backpack:
        return Icons.backpack_rounded;
      case FurnitureType.fridge:
        return Icons.kitchen_rounded;
      case FurnitureType.box:
        return Icons.archive_rounded;
      case FurnitureType.bed:
        return Icons.bed_rounded;
      case FurnitureType.door:
        return Icons.meeting_room_outlined;
      case FurnitureType.window:
        return Icons.window_rounded;
      case FurnitureType.stairs:
        return Icons.stairs_rounded;
      case FurnitureType.patioPlant:
        return Icons.yard_rounded;
    }
  }

  int get defaultWidth {
    switch (this) {
      case FurnitureType.chest:
        return 1;
      case FurnitureType.wardrobe:
        return 2;
      case FurnitureType.desk:
        return 2;
      case FurnitureType.bookshelf:
        return 2;
      case FurnitureType.safe:
        return 1;
      case FurnitureType.drawer:
        return 1;
      case FurnitureType.shelf:
        return 2;
      case FurnitureType.backpack:
        return 1;
      case FurnitureType.fridge:
        return 1;
      case FurnitureType.box:
        return 1;
      case FurnitureType.bed:
        return 2;
      case FurnitureType.door:
        return 1;
      case FurnitureType.window:
        return 1;
      case FurnitureType.stairs:
        return 2;
      case FurnitureType.patioPlant:
        return 1;
    }
  }

  int get defaultHeight {
    switch (this) {
      case FurnitureType.chest:
        return 1;
      case FurnitureType.wardrobe:
        return 1;
      case FurnitureType.desk:
        return 1;
      case FurnitureType.bookshelf:
        return 1;
      case FurnitureType.safe:
        return 1;
      case FurnitureType.drawer:
        return 1;
      case FurnitureType.shelf:
        return 1;
      case FurnitureType.backpack:
        return 1;
      case FurnitureType.fridge:
        return 1;
      case FurnitureType.box:
        return 1;
      case FurnitureType.bed:
        return 2;
      case FurnitureType.door:
        return 1;
      case FurnitureType.window:
        return 1;
      case FurnitureType.stairs:
        return 2;
      case FurnitureType.patioPlant:
        return 1;
    }
  }

  int get defaultCapacity {
    switch (this) {
      case FurnitureType.chest:
        return 16;
      case FurnitureType.wardrobe:
        return 24;
      case FurnitureType.desk:
        return 12;
      case FurnitureType.bookshelf:
        return 18;
      case FurnitureType.safe:
        return 8;
      case FurnitureType.drawer:
        return 12;
      case FurnitureType.shelf:
        return 10;
      case FurnitureType.backpack:
        return 8;
      case FurnitureType.fridge:
        return 16;
      case FurnitureType.box:
        return 12;
      case FurnitureType.bed:
        return 16;
      case FurnitureType.door:
        return 0;
      case FurnitureType.window:
        return 0;
      case FurnitureType.stairs:
        return 0;
      case FurnitureType.patioPlant:
        return 4;
    }
  }

  bool get isArchitecturalElement {
    switch (this) {
      case FurnitureType.door:
      case FurnitureType.window:
      case FurnitureType.stairs:
        return true;
      default:
        return false;
    }
  }

  Color get defaultColor {
    switch (this) {
      case FurnitureType.chest:
        return const Color(0xFFD97706); // Amber 600
      case FurnitureType.wardrobe:
        return const Color(0xFF8B5CF6); // Violet 500
      case FurnitureType.desk:
        return const Color(0xFF0EA5E9); // Sky 500
      case FurnitureType.bookshelf:
        return const Color(0xFF10B981); // Emerald 500
      case FurnitureType.safe:
        return const Color(0xFFE11D48); // Rose 600
      case FurnitureType.drawer:
        return const Color(0xFF6366F1); // Indigo 500
      case FurnitureType.shelf:
        return const Color(0xFF14B8A6); // Teal 500
      case FurnitureType.backpack:
        return const Color(0xFFF59E0B); // Amber 500
      case FurnitureType.fridge:
        return const Color(0xFF06B6D4); // Cyan 500
      case FurnitureType.box:
        return const Color(0xFF78716C); // Stone 500
      case FurnitureType.bed:
        return const Color(0xFF3B82F6); // Blue 500
      case FurnitureType.door:
        return const Color(0xFF8B5CF6); // Violet
      case FurnitureType.window:
        return const Color(0xFF0284C7); // Cyan
      case FurnitureType.stairs:
        return const Color(0xFFD97706); // Amber
      case FurnitureType.patioPlant:
        return const Color(0xFF16A34A); // Green
    }
  }
}

class Furniture {
  final String id;
  final String name;
  final FurnitureType type;
  final int gridX;
  final int gridY;
  final int gridWidth;
  final int gridHeight;
  final int rotation; // 0, 90, 180, 270
  final int slotCapacity;
  final List<Item> items;
  final int? customColor;
  final String? customIconKey;

  const Furniture({
    required this.id,
    required this.name,
    required this.type,
    required this.gridX,
    required this.gridY,
    this.gridWidth = 1,
    this.gridHeight = 1,
    this.rotation = 0,
    this.slotCapacity = 16,
    this.items = const [],
    this.customColor,
    this.customIconKey,
  });

  int get effectiveWidth => (rotation == 90 || rotation == 270) ? gridHeight : gridWidth;
  int get effectiveHeight => (rotation == 90 || rotation == 270) ? gridWidth : gridHeight;

  // Real world dimensions (1 cell = 0.5m / 50cm)
  double get realWidthMeters => effectiveWidth * 0.5;
  double get realHeightMeters => effectiveHeight * 0.5;
  String get dimensionsFormatted => '${realWidthMeters.toStringAsFixed(1)}m × ${realHeightMeters.toStringAsFixed(1)}m';
  String get dimensionsWithCells => '${realWidthMeters.toStringAsFixed(1)}m × ${realHeightMeters.toStringAsFixed(1)}m ($effectiveWidth×$effectiveHeight)';

  int get occupiedSlotsCount => items.length;
  double get occupancyRatio => slotCapacity > 0 ? (items.length / slotCapacity).clamp(0.0, 1.0) : 0.0;

  Color get color => customColor != null ? Color(customColor!) : type.defaultColor;

  Item? getItemAtSlot(int slotIndex) {
    try {
      return items.firstWhere((item) => item.slotIndex == slotIndex);
    } catch (_) {
      return null;
    }
  }

  int get nextAvailableSlotIndex {
    final occupied = items.map((e) => e.slotIndex).toSet();
    for (int i = 0; i < slotCapacity; i++) {
      if (!occupied.contains(i)) return i;
    }
    return items.length;
  }

  Furniture copyWith({
    String? id,
    String? name,
    FurnitureType? type,
    int? gridX,
    int? gridY,
    int? gridWidth,
    int? gridHeight,
    int? rotation,
    int? slotCapacity,
    List<Item>? items,
    int? customColor,
    String? customIconKey,
  }) {
    return Furniture(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
      rotation: rotation ?? this.rotation,
      slotCapacity: slotCapacity ?? this.slotCapacity,
      items: items ?? this.items,
      customColor: customColor ?? this.customColor,
      customIconKey: customIconKey ?? this.customIconKey,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'gridX': gridX,
      'gridY': gridY,
      'gridWidth': gridWidth,
      'gridHeight': gridHeight,
      'rotation': rotation,
      'slotCapacity': slotCapacity,
      'items': items.map((i) => i.toMap()).toList(),
      'customColor': customColor,
      'customIconKey': customIconKey,
    };
  }

  factory Furniture.fromMap(Map<String, dynamic> map) {
    return Furniture(
      id: map['id'] as String,
      name: map['name'] as String,
      type: FurnitureType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => FurnitureType.chest,
      ),
      gridX: (map['gridX'] as int?) ?? 0,
      gridY: (map['gridY'] as int?) ?? 0,
      gridWidth: (map['gridWidth'] as int?) ?? 1,
      gridHeight: (map['gridHeight'] as int?) ?? 1,
      rotation: (map['rotation'] as int?) ?? 0,
      slotCapacity: (map['slotCapacity'] as int?) ?? 16,
      items: (map['items'] as List<dynamic>?)
              ?.map((itemMap) => Item.fromMap(itemMap as Map<String, dynamic>))
              .toList() ??
          [],
      customColor: map['customColor'] as int?,
      customIconKey: map['customIconKey'] as String?,
    );
  }
}
