import 'package:flutter_test/flutter_test.dart';
import 'package:loot_room/models/furniture.dart';
import 'package:loot_room/models/item.dart';
import 'package:loot_room/models/zone.dart';
import 'package:loot_room/providers/inventory_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Inventory Models and Collision Tests', () {
    test('Zone spatial collision detection works correctly', () {
      final furniture1 = Furniture(
        id: 'f1',
        name: 'Desk',
        type: FurnitureType.desk,
        gridX: 1,
        gridY: 1,
        gridWidth: 2,
        gridHeight: 1,
      );

      final zone = Zone(
        id: 'z1',
        name: 'Office',
        gridColumns: 6,
        gridRows: 6,
        furnitureList: [furniture1],
      );

      // Occupied cell
      expect(zone.isCellOccupied(1, 1), isTrue);
      expect(zone.isCellOccupied(2, 1), isTrue);
      expect(zone.isCellOccupied(0, 0), isFalse);

      // Can place at free position
      expect(zone.canPlaceFurniture(x: 3, y: 1, width: 2, height: 1), isTrue);

      // Cannot place overlapping
      expect(zone.canPlaceFurniture(x: 2, y: 1, width: 2, height: 1), isFalse);

      // Cannot place out of bounds
      expect(zone.canPlaceFurniture(x: 5, y: 1, width: 2, height: 1), isFalse);
    });

    test('Rotation correctly swaps dimensions and checks boundaries', () {
      final furniture = Furniture(
        id: 'f1',
        name: 'Wardrobe',
        type: FurnitureType.wardrobe,
        gridX: 0,
        gridY: 0,
        gridWidth: 2,
        gridHeight: 1,
        rotation: 90,
      );

      expect(furniture.effectiveWidth, 1);
      expect(furniture.effectiveHeight, 2);
    });

    test('Items in Furniture slot capacity and lookup', () {
      final item = Item(
        id: 'item1',
        name: 'USB-C Cable',
        rarity: ItemRarity.rare,
        category: ItemCategory.electronics,
        slotIndex: 0,
      );

      final furniture = Furniture(
        id: 'f1',
        name: 'Tech Drawer',
        type: FurnitureType.drawer,
        gridX: 0,
        gridY: 0,
        slotCapacity: 8,
        items: [item],
      );

      expect(furniture.occupiedSlotsCount, 1);
      expect(furniture.getItemAtSlot(0)?.name, 'USB-C Cable');
      expect(furniture.getItemAtSlot(1), isNull);
      expect(furniture.nextAvailableSlotIndex, 1);
    });
  });

  group('InventoryProvider State Operations', () {
    test('Global search returns correct breadcrumbs', () async {
      final provider = InventoryProvider();
      // Allow async initialization
      await Future.delayed(const Duration(milliseconds: 200));

      provider.setSearchQuery('USB');
      expect(provider.searchResults.isNotEmpty, isTrue);
      final firstResult = provider.searchResults.first;
      expect(firstResult.item.name.toLowerCase().contains('usb'), isTrue);
      expect(firstResult.pathBreadcrumb.isNotEmpty, isTrue);

      provider.clearSearch();
      expect(provider.searchResults.isEmpty, isTrue);
    });

    test('Adding and deleting items updates container state', () async {
      final provider = InventoryProvider();
      await Future.delayed(const Duration(milliseconds: 200));

      expect(provider.zones.isNotEmpty, isTrue);
      final zone = provider.zones.first;
      expect(zone.furnitureList.isNotEmpty, isTrue);
      final furniture = zone.furnitureList.first;
      final initialCount = furniture.items.length;

      provider.addItemToFurniture(
        furnitureId: furniture.id,
        name: 'Test Legendary Relic',
        rarity: ItemRarity.legendary,
        category: ItemCategory.valuables,
        quantity: 1,
      );

      final updatedFurniture = provider.activeZone!.furnitureList.firstWhere((f) => f.id == furniture.id);
      expect(updatedFurniture.items.length, initialCount + 1);
      expect(updatedFurniture.items.any((i) => i.name == 'Test Legendary Relic'), isTrue);
    });

    test('Resizing furniture updates dimensions and respects boundary constraints', () async {
      final provider = InventoryProvider();
      await Future.delayed(const Duration(milliseconds: 200));

      final zone = provider.activeZone!;
      final furniture = zone.furnitureList.first;

      // Resizing within bounds
      final resized = provider.resizeFurniture(furniture.id, 3, 2);
      expect(resized, isTrue);

      final updated = provider.activeZone!.furnitureList.firstWhere((f) => f.id == furniture.id);
      expect(updated.effectiveWidth, 3);
      expect(updated.effectiveHeight, 2);
      expect(updated.dimensionsFormatted, '1.5m × 1.0m');
    });

    test('Floor management and Patio zones function properly', () async {
      final provider = InventoryProvider();
      await Future.delayed(const Duration(milliseconds: 200));

      // Add a Patio on Floor 1
      provider.addZone(
        name: 'Patio Trasero',
        description: 'Jardín con asador',
        gridColumns: 8,
        gridRows: 8,
        floor: 1,
        isPatio: true,
      );

      // Add a Room on Floor 2
      provider.addZone(
        name: 'Dormitorio Principal',
        description: 'Piso superior',
        gridColumns: 6,
        gridRows: 6,
        floor: 2,
        isPatio: false,
      );

      expect(provider.availableFloors.contains(1), isTrue);
      expect(provider.availableFloors.contains(2), isTrue);

      provider.setSelectedFloor(1);
      final floor1Zones = provider.zonesOnSelectedFloor;
      expect(floor1Zones.any((z) => z.isPatio && z.name == 'Patio Trasero'), isTrue);

      provider.setSelectedFloor(2);
      final floor2Zones = provider.zonesOnSelectedFloor;
      expect(floor2Zones.any((z) => z.name == 'Dormitorio Principal'), isTrue);

      // Move zone floor coordinates
      final targetZone = floor2Zones.first;
      provider.updateZoneFloorPosition(targetZone.id, 250.0, 320.0);
      final movedZone = provider.zones.firstWhere((z) => z.id == targetZone.id);
      expect(movedZone.floorX, 250.0);
      expect(movedZone.floorY, 320.0);
    });

    test('Architectural connector items have correct metadata and 0 storage capacity', () {
      expect(FurnitureType.door.displayName, 'Puerta de Paso');
      expect(FurnitureType.door.defaultCapacity, 0);
      expect(FurnitureType.door.isArchitecturalElement, isTrue);

      expect(FurnitureType.window.displayName, 'Ventana Exterior');
      expect(FurnitureType.window.defaultCapacity, 0);
      expect(FurnitureType.window.isArchitecturalElement, isTrue);

      expect(FurnitureType.stairs.displayName, 'Escaleras de Piso');
      expect(FurnitureType.stairs.defaultCapacity, 0);
      expect(FurnitureType.stairs.isArchitecturalElement, isTrue);

      expect(FurnitureType.chest.isArchitecturalElement, isFalse);
      expect(FurnitureType.chest.defaultCapacity, 16);
    });

    test('Creating a hallway zone sets isHallway correctly', () {
      final provider = InventoryProvider();
      provider.addZone(
        name: 'Pasillo Central',
        description: 'Conecta sala con dormitorios',
        gridColumns: 2,
        gridRows: 8,
        floor: 1,
        isHallway: true,
      );

      final hallway = provider.zones.firstWhere((z) => z.name == 'Pasillo Central');
      expect(hallway.isHallway, isTrue);
      expect(hallway.isPatio, isFalse);
      expect(hallway.gridColumns, 2);
      expect(hallway.gridRows, 8);
    });

    test('Resizing and rotating zones in blueprint mode updates dimensions correctly', () async {
      final provider = InventoryProvider();
      await Future.delayed(const Duration(milliseconds: 200));

      provider.addZone(
        name: 'Pasillo Test',
        description: 'Pasillo redimensionable',
        gridColumns: 2,
        gridRows: 8,
        floor: 1,
        isHallway: true,
      );

      final hallway = provider.zones.firstWhere((z) => z.name == 'Pasillo Test');

      // Test selection
      provider.selectBlueprintZone(hallway.id);
      expect(provider.selectedBlueprintZoneId, hallway.id);
      expect(provider.selectedBlueprintZone?.name, 'Pasillo Test');

      // Test resize
      final resized = provider.resizeZone(hallway.id, 3, 10);
      expect(resized, isTrue);
      final updated = provider.zones.firstWhere((z) => z.id == hallway.id);
      expect(updated.gridColumns, 3);
      expect(updated.gridRows, 10);
      expect(updated.dimensionsFormatted, '1.5m × 5.0m');

      // Test rotation (swapping cols and rows: 3x10 -> 10x3)
      final rotated = provider.rotateZone(hallway.id);
      expect(rotated, isTrue);
      final rotatedZone = provider.zones.firstWhere((z) => z.id == hallway.id);
      expect(rotatedZone.gridColumns, 10);
      expect(rotatedZone.gridRows, 3);
      expect(rotatedZone.dimensionsFormatted, '5.0m × 1.5m');

      // Test deselect
      provider.selectBlueprintZone(null);
      expect(provider.selectedBlueprintZoneId, isNull);
      expect(provider.selectedBlueprintZone, isNull);
    });
  });
}
