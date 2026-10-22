import 'package:flutter/material.dart';
import 'furniture.dart';
import 'item.dart';

class Zone {
  final String id;
  final String name;
  final String description;
  final int gridColumns;
  final int gridRows;
  final List<Furniture> furnitureList;
  final int themeColorValue;
  final String iconKey;
  final int floor; // 1 = Planta Baja, 2 = Piso 1, -1 = Sótano, etc.
  final double floorX; // X position in the floor blueprint
  final double floorY; // Y position in the floor blueprint
  final bool isPatio; // true if outdoor patio / garden space
  final bool isHallway; // true if corridor / hallway connector

  const Zone({
    required this.id,
    required this.name,
    this.description = '',
    this.gridColumns = 8,
    this.gridRows = 8,
    this.furnitureList = const [],
    this.themeColorValue = 0xFF6366F1, // Indigo 500 default
    this.iconKey = 'meeting_room',
    this.floor = 1,
    this.floorX = 0.0,
    this.floorY = 0.0,
    this.isPatio = false,
    this.isHallway = false,
  });

  Color get themeColor => Color(themeColorValue);

  // Real world dimensions (1 cell = 0.5m / 50cm)
  double get realWidthMeters => gridColumns * 0.5;
  double get realHeightMeters => gridRows * 0.5;
  String get dimensionsFormatted => '${realWidthMeters.toStringAsFixed(1)}m × ${realHeightMeters.toStringAsFixed(1)}m';

  int get totalItemsCount {
    return furnitureList.fold(0, (sum, f) => sum + f.items.length);
  }

  int get totalSlotsCapacity {
    return furnitureList.fold(0, (sum, f) => sum + f.slotCapacity);
  }

  int get totalFurnitureCount => furnitureList.length;

  int get legendaryItemsCount {
    return furnitureList.fold(
      0,
      (sum, f) => sum + f.items.where((i) => i.rarity == ItemRarity.legendary).length,
    );
  }

  int get epicItemsCount {
    return furnitureList.fold(
      0,
      (sum, f) => sum + f.items.where((i) => i.rarity == ItemRarity.epic).length,
    );
  }

  Furniture? getFurnitureAt(int x, int y) {
    for (final furniture in furnitureList) {
      final w = furniture.effectiveWidth;
      final h = furniture.effectiveHeight;
      if (x >= furniture.gridX &&
          x < furniture.gridX + w &&
          y >= furniture.gridY &&
          y < furniture.gridY + h) {
        return furniture;
      }
    }
    return null;
  }

  bool isCellOccupied(int x, int y, {String? excludeFurnitureId}) {
    for (final furniture in furnitureList) {
      if (excludeFurnitureId != null && furniture.id == excludeFurnitureId) {
        continue;
      }
      final w = furniture.effectiveWidth;
      final h = furniture.effectiveHeight;
      if (x >= furniture.gridX &&
          x < furniture.gridX + w &&
          y >= furniture.gridY &&
          y < furniture.gridY + h) {
        return true;
      }
    }
    return false;
  }

  bool canPlaceFurniture({
    required int x,
    required int y,
    required int width,
    required int height,
    String? excludeFurnitureId,
  }) {
    // Check bounds
    if (x < 0 || y < 0 || x + width > gridColumns || y + height > gridRows) {
      return false;
    }

    // Check collision with other furniture
    for (int cx = x; cx < x + width; cx++) {
      for (int cy = y; cy < y + height; cy++) {
        if (isCellOccupied(cx, cy, excludeFurnitureId: excludeFurnitureId)) {
          return false;
        }
      }
    }
    return true;
  }

  Zone copyWith({
    String? id,
    String? name,
    String? description,
    int? gridColumns,
    int? gridRows,
    List<Furniture>? furnitureList,
    int? themeColorValue,
    String? iconKey,
    int? floor,
    double? floorX,
    double? floorY,
    bool? isPatio,
    bool? isHallway,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      gridColumns: gridColumns ?? this.gridColumns,
      gridRows: gridRows ?? this.gridRows,
      furnitureList: furnitureList ?? this.furnitureList,
      themeColorValue: themeColorValue ?? this.themeColorValue,
      iconKey: iconKey ?? this.iconKey,
      floor: floor ?? this.floor,
      floorX: floorX ?? this.floorX,
      floorY: floorY ?? this.floorY,
      isPatio: isPatio ?? this.isPatio,
      isHallway: isHallway ?? this.isHallway,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'gridColumns': gridColumns,
      'gridRows': gridRows,
      'furnitureList': furnitureList.map((f) => f.toMap()).toList(),
      'themeColorValue': themeColorValue,
      'iconKey': iconKey,
      'floor': floor,
      'floorX': floorX,
      'floorY': floorY,
      'isPatio': isPatio,
      'isHallway': isHallway,
    };
  }

  factory Zone.fromMap(Map<String, dynamic> map) {
    return Zone(
      id: map['id'] as String,
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      gridColumns: (map['gridColumns'] as int?) ?? 8,
      gridRows: (map['gridRows'] as int?) ?? 8,
      furnitureList: (map['furnitureList'] as List<dynamic>?)
              ?.map((fMap) => Furniture.fromMap(fMap as Map<String, dynamic>))
              .toList() ??
          [],
      themeColorValue: (map['themeColorValue'] as int?) ?? 0xFF6366F1,
      iconKey: (map['iconKey'] as String?) ?? 'meeting_room',
      floor: (map['floor'] as int?) ?? 1,
      floorX: (map['floorX'] as num?)?.toDouble() ?? 0.0,
      floorY: (map['floorY'] as num?)?.toDouble() ?? 0.0,
      isPatio: (map['isPatio'] as bool?) ?? false,
      isHallway: (map['isHallway'] as bool?) ?? false,
    );
  }
}
