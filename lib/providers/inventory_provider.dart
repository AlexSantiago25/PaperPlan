import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/furniture.dart';
import '../models/item.dart';
import '../models/zone.dart';
import '../services/storage_service.dart';

enum AppViewMode {
  exploration, // Reader mode: locked map, tap furniture to open chest
  editor,      // Editor mode: catalog open, drag-and-drop, rotate, delete
}

class SearchResult {
  final Item item;
  final Furniture furniture;
  final Zone zone;

  const SearchResult({
    required this.item,
    required this.furniture,
    required this.zone,
  });

  String get pathBreadcrumb => '${zone.name} › ${furniture.name} (Slot #${item.slotIndex + 1})';
}

class InventoryProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();

  List<Zone> _zones = [];
  String? _activeZoneId;
  String? _selectedFurnitureId;
  AppViewMode _viewMode = AppViewMode.exploration;
  String _searchQuery = '';
  bool _isLoading = true;
  int _selectedFloor = 1; // Current floor in house blueprint (1 = PB, 2 = Piso 1, -1 = Sótano)

  // Ghost placement state in editor
  int? _ghostX;
  int? _ghostY;
  int? _ghostWidth;
  int? _ghostHeight;
  bool _ghostIsValid = false;

  String? _selectedBlueprintZoneId; // Currently selected zone in blueprint architect mode

  InventoryProvider() {
    _initializeData();
  }

  // Getters
  List<Zone> get zones => _zones;
  bool get isLoading => _isLoading;
  AppViewMode get viewMode => _viewMode;
  String get searchQuery => _searchQuery;
  String? get activeZoneId => _activeZoneId;
  String? get selectedFurnitureId => _selectedFurnitureId;
  String? get selectedBlueprintZoneId => _selectedBlueprintZoneId;
  int get selectedFloor => _selectedFloor;

  List<int> get availableFloors {
    final floors = _zones.map((z) => z.floor).toSet();
    floors.add(1); // Floor 1 (Planta Baja) is always available
    final list = floors.toList()..sort();
    return list;
  }

  List<Zone> get zonesOnSelectedFloor {
    return _zones.where((z) => z.floor == _selectedFloor).toList();
  }

  int? get ghostX => _ghostX;
  int? get ghostY => _ghostY;
  int? get ghostWidth => _ghostWidth;
  int? get ghostHeight => _ghostHeight;
  bool get ghostIsValid => _ghostIsValid;

  Zone? get activeZone {
    if (_activeZoneId == null) return null;
    try {
      return _zones.firstWhere((z) => z.id == _activeZoneId);
    } catch (_) {
      return null;
    }
  }

  Zone? get selectedBlueprintZone {
    if (_selectedBlueprintZoneId == null) return null;
    try {
      return _zones.firstWhere((z) => z.id == _selectedBlueprintZoneId);
    } catch (_) {
      return null;
    }
  }

  Furniture? get selectedFurniture {
    final zone = activeZone;
    if (zone == null || _selectedFurnitureId == null) return null;
    try {
      return zone.furnitureList.firstWhere((f) => f.id == _selectedFurnitureId);
    } catch (_) {
      return null;
    }
  }

  // Aggregate stats
  int get totalZonesCount => _zones.length;

  int get totalItemsCount {
    return _zones.fold(0, (sum, z) => sum + z.totalItemsCount);
  }

  int get totalLegendaryCount {
    return _zones.fold(0, (sum, z) => sum + z.legendaryItemsCount);
  }

  int get totalEpicCount {
    return _zones.fold(0, (sum, z) => sum + z.epicItemsCount);
  }

  // Search Results
  List<SearchResult> get searchResults {
    if (_searchQuery.trim().isEmpty) return [];
    final query = _searchQuery.toLowerCase().trim();
    final List<SearchResult> results = [];

    for (final zone in _zones) {
      for (final furniture in zone.furnitureList) {
        for (final item in furniture.items) {
          final matchesName = item.name.toLowerCase().contains(query);
          final matchesDesc = item.description.toLowerCase().contains(query);
          final matchesCategory = item.category.displayName.toLowerCase().contains(query);
          final matchesTags = item.tags.any((tag) => tag.toLowerCase().contains(query));

          if (matchesName || matchesDesc || matchesCategory || matchesTags) {
            results.add(SearchResult(item: item, furniture: furniture, zone: zone));
          }
        }
      }
    }
    return results;
  }

  // Init
  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();
    _zones = await _storageService.loadZones();

    // Auto-layout zones in floor plan if unpositioned
    double currentX = 40.0;
    double currentY = 40.0;
    double maxRowHeight = 0;
    for (int i = 0; i < _zones.length; i++) {
      if (_zones[i].floorX == 0 && _zones[i].floorY == 0 && i > 0) {
        _zones[i] = _zones[i].copyWith(
          floorX: currentX,
          floorY: currentY,
        );
        final roomWidth = _zones[i].gridColumns * 28.0 + 80.0;
        final roomHeight = _zones[i].gridRows * 28.0 + 80.0;
        if (roomHeight > maxRowHeight) maxRowHeight = roomHeight;
        currentX += roomWidth + 40.0;
        if (currentX > 800) {
          currentX = 40.0;
          currentY += maxRowHeight + 40.0;
          maxRowHeight = 0;
        }
      } else if (_zones[i].floorX != 0 || _zones[i].floorY != 0) {
        final roomWidth = _zones[i].gridColumns * 28.0 + 80.0;
        final roomHeight = _zones[i].gridRows * 28.0 + 80.0;
        if (roomHeight > maxRowHeight) maxRowHeight = roomHeight;
        currentX = _zones[i].floorX + roomWidth + 40.0;
        currentY = _zones[i].floorY;
      }
    }

    if (_zones.isNotEmpty) {
      _activeZoneId = _zones.first.id;
      _selectedFloor = _zones.first.floor;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    await _storageService.saveZones(_zones);
  }

  // Navigation & Mode Management
  void setActiveZone(String zoneId) {
    _activeZoneId = zoneId;
    _selectedFurnitureId = null;
    _clearGhost();
    notifyListeners();
  }

  void setSelectedFloor(int floor) {
    _selectedFloor = floor;
    notifyListeners();
  }

  void updateZoneFloorPosition(String zoneId, double newX, double newY, {int? floor}) {
    final index = _zones.indexWhere((z) => z.id == zoneId);
    if (index != -1) {
      _zones[index] = _zones[index].copyWith(
        floorX: newX,
        floorY: newY,
        floor: floor ?? _zones[index].floor,
      );
      _save();
      notifyListeners();
    }
  }

  void setSelectedFurniture(String? furnitureId) {
    _selectedFurnitureId = furnitureId;
    notifyListeners();
  }

  void selectBlueprintZone(String? zoneId) {
    _selectedBlueprintZoneId = zoneId;
    notifyListeners();
  }

  void setViewMode(AppViewMode mode) {
    _viewMode = mode;
    _selectedFurnitureId = null;
    _clearGhost();
    notifyListeners();
  }

  void toggleViewMode() {
    _viewMode = _viewMode == AppViewMode.exploration ? AppViewMode.editor : AppViewMode.exploration;
    _selectedFurnitureId = null;
    _clearGhost();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Ghost updates for drag & drop
  void updateGhost({
    required int x,
    required int y,
    required int width,
    required int height,
    String? excludeFurnitureId,
  }) {
    final zone = activeZone;
    if (zone == null) return;

    final isValid = zone.canPlaceFurniture(
      x: x,
      y: y,
      width: width,
      height: height,
      excludeFurnitureId: excludeFurnitureId,
    );

    _ghostX = x;
    _ghostY = y;
    _ghostWidth = width;
    _ghostHeight = height;
    _ghostIsValid = isValid;
    notifyListeners();
  }

  void _clearGhost() {
    _ghostX = null;
    _ghostY = null;
    _ghostWidth = null;
    _ghostHeight = null;
    _ghostIsValid = false;
  }

  void clearGhost() {
    _clearGhost();
    notifyListeners();
  }

  // Zone CRUD
  void addZone({
    required String name,
    required String description,
    int gridColumns = 8,
    int gridRows = 8,
    int themeColorValue = 0xFF6366F1,
    String iconKey = 'meeting_room',
    int floor = 1,
    double floorX = 0.0,
    double floorY = 0.0,
    bool isPatio = false,
    bool isHallway = false,
  }) {
    // If floorX and floorY are 0, compute next free spot on that floor
    double finalX = floorX;
    double finalY = floorY;
    if (finalX == 0 && finalY == 0) {
      final zonesOnFloor = _zones.where((z) => z.floor == floor).toList();
      if (zonesOnFloor.isNotEmpty) {
        final lastZone = zonesOnFloor.last;
        final lastWidth = lastZone.gridColumns * 28.0;
        final rawX = lastZone.floorX + lastWidth;
        finalX = ((rawX / 28.0).round() * 28.0).toDouble();
        finalY = ((lastZone.floorY / 28.0).round() * 28.0).toDouble();
      } else {
        finalX = 56.0;
        finalY = 84.0;
      }
    }

    final newZone = Zone(
      id: _uuid.v4(),
      name: name,
      description: description,
      gridColumns: gridColumns,
      gridRows: gridRows,
      themeColorValue: themeColorValue,
      iconKey: iconKey,
      floor: floor,
      floorX: finalX,
      floorY: finalY,
      isPatio: isPatio,
      isHallway: isHallway,
      furnitureList: [],
    );
    _zones.add(newZone);
    _activeZoneId = newZone.id;
    _selectedFloor = floor;
    _save();
    notifyListeners();
  }

  void updateZone(Zone updatedZone) {
    final index = _zones.indexWhere((z) => z.id == updatedZone.id);
    if (index != -1) {
      _zones[index] = updatedZone;
      _save();
      notifyListeners();
    }
  }

  bool resizeZone(String zoneId, int targetCols, int targetRows) {
    final index = _zones.indexWhere((z) => z.id == zoneId);
    if (index == -1) return false;

    final zone = _zones[index];
    final clampedCols = targetCols.clamp(1, 24);
    final clampedRows = targetRows.clamp(1, 24);

    // Verify if all existing furniture still fits inside new bounds
    for (final f in zone.furnitureList) {
      if (f.gridX + f.effectiveWidth > clampedCols || f.gridY + f.effectiveHeight > clampedRows) {
        return false;
      }
    }

    _zones[index] = zone.copyWith(
      gridColumns: clampedCols,
      gridRows: clampedRows,
    );
    _save();
    notifyListeners();
    return true;
  }

  bool rotateZone(String zoneId) {
    final index = _zones.indexWhere((z) => z.id == zoneId);
    if (index == -1) return false;

    final zone = _zones[index];
    final newCols = zone.gridRows;
    final newRows = zone.gridColumns;

    // Check if furniture fits in swapped dimensions
    for (final f in zone.furnitureList) {
      if (f.gridX + f.effectiveWidth > newCols || f.gridY + f.effectiveHeight > newRows) {
        return false;
      }
    }

    _zones[index] = zone.copyWith(
      gridColumns: newCols,
      gridRows: newRows,
    );
    _save();
    notifyListeners();
    return true;
  }

  void deleteZone(String zoneId) {
    _zones.removeWhere((z) => z.id == zoneId);
    if (_activeZoneId == zoneId) {
      _activeZoneId = _zones.isNotEmpty ? _zones.first.id : null;
    }
    if (_selectedBlueprintZoneId == zoneId) {
      _selectedBlueprintZoneId = null;
    }
    _save();
    notifyListeners();
  }

  // Furniture CRUD
  bool addFurnitureToActiveZone({
    required FurnitureType type,
    required String name,
    required int x,
    required int y,
    int? customWidth,
    int? customHeight,
    int? slotCapacity,
  }) {
    final zone = activeZone;
    if (zone == null) return false;

    final width = customWidth ?? type.defaultWidth;
    final height = customHeight ?? type.defaultHeight;

    if (!zone.canPlaceFurniture(x: x, y: y, width: width, height: height)) {
      return false;
    }

    final newFurniture = Furniture(
      id: _uuid.v4(),
      name: name,
      type: type,
      gridX: x,
      gridY: y,
      gridWidth: width,
      gridHeight: height,
      rotation: 0,
      slotCapacity: slotCapacity ?? type.defaultCapacity,
      items: [],
    );

    final updatedList = List<Furniture>.from(zone.furnitureList)..add(newFurniture);
    updateZone(zone.copyWith(furnitureList: updatedList));
    _selectedFurnitureId = newFurniture.id;
    _clearGhost();
    return true;
  }

  bool moveFurniture(String furnitureId, int newX, int newY) {
    final zone = activeZone;
    if (zone == null) return false;

    final index = zone.furnitureList.indexWhere((f) => f.id == furnitureId);
    if (index == -1) return false;

    final furniture = zone.furnitureList[index];
    if (!zone.canPlaceFurniture(
      x: newX,
      y: newY,
      width: furniture.effectiveWidth,
      height: furniture.effectiveHeight,
      excludeFurnitureId: furnitureId,
    )) {
      return false;
    }

    final updatedFurniture = furniture.copyWith(gridX: newX, gridY: newY);
    final updatedList = List<Furniture>.from(zone.furnitureList)..[index] = updatedFurniture;
    updateZone(zone.copyWith(furnitureList: updatedList));
    _clearGhost();
    return true;
  }

  bool rotateFurniture(String furnitureId) {
    final zone = activeZone;
    if (zone == null) return false;

    final index = zone.furnitureList.indexWhere((f) => f.id == furnitureId);
    if (index == -1) return false;

    final furniture = zone.furnitureList[index];
    final newRotation = (furniture.rotation + 90) % 360;
    final tempFurniture = furniture.copyWith(rotation: newRotation);

    if (!zone.canPlaceFurniture(
      x: furniture.gridX,
      y: furniture.gridY,
      width: tempFurniture.effectiveWidth,
      height: tempFurniture.effectiveHeight,
      excludeFurnitureId: furnitureId,
    )) {
      return false; // Can't rotate due to collision or boundary
    }

    final updatedList = List<Furniture>.from(zone.furnitureList)..[index] = tempFurniture;
    updateZone(zone.copyWith(furnitureList: updatedList));
    return true;
  }

  bool resizeFurniture(String furnitureId, int targetEffectiveWidth, int targetEffectiveHeight) {
    final zone = activeZone;
    if (zone == null) return false;

    final index = zone.furnitureList.indexWhere((f) => f.id == furnitureId);
    if (index == -1) return false;

    final furniture = zone.furnitureList[index];

    // Constrain to minimum 1x1 cell and within room bounds
    final newEffW = targetEffectiveWidth.clamp(1, zone.gridColumns - furniture.gridX);
    final newEffH = targetEffectiveHeight.clamp(1, zone.gridRows - furniture.gridY);

    final isRotated = furniture.rotation == 90 || furniture.rotation == 270;
    final newGridWidth = isRotated ? newEffH : newEffW;
    final newGridHeight = isRotated ? newEffW : newEffH;

    final tempFurniture = furniture.copyWith(
      gridWidth: newGridWidth,
      gridHeight: newGridHeight,
    );

    if (!zone.canPlaceFurniture(
      x: furniture.gridX,
      y: furniture.gridY,
      width: tempFurniture.effectiveWidth,
      height: tempFurniture.effectiveHeight,
      excludeFurnitureId: furnitureId,
    )) {
      return false;
    }

    final updatedList = List<Furniture>.from(zone.furnitureList)..[index] = tempFurniture;
    updateZone(zone.copyWith(furnitureList: updatedList));
    return true;
  }

  void deleteFurniture(String furnitureId) {
    final zone = activeZone;
    if (zone == null) return;

    final updatedList = List<Furniture>.from(zone.furnitureList)
      ..removeWhere((f) => f.id == furnitureId);
    if (_selectedFurnitureId == furnitureId) {
      _selectedFurnitureId = null;
    }
    updateZone(zone.copyWith(furnitureList: updatedList));
  }

  // Item CRUD
  bool addItemToFurniture({
    required String furnitureId,
    required String name,
    String description = '',
    ItemRarity rarity = ItemRarity.common,
    ItemCategory category = ItemCategory.misc,
    int quantity = 1,
    int? targetSlotIndex,
    List<String> tags = const [],
    String iconKey = 'inventory_2',
  }) {
    final zone = activeZone;
    if (zone == null) return false;

    final fIndex = zone.furnitureList.indexWhere((f) => f.id == furnitureId);
    if (fIndex == -1) return false;

    final furniture = zone.furnitureList[fIndex];
    final slot = targetSlotIndex ?? furniture.nextAvailableSlotIndex;

    if (slot >= furniture.slotCapacity) {
      return false; // Container full
    }

    final newItem = Item(
      id: _uuid.v4(),
      name: name,
      description: description,
      rarity: rarity,
      category: category,
      quantity: quantity,
      slotIndex: slot,
      tags: tags,
      iconKey: iconKey,
    );

    // Remove any item existing at slot, if any
    final updatedItems = List<Item>.from(furniture.items)
      ..removeWhere((i) => i.slotIndex == slot)
      ..add(newItem);

    final updatedFurniture = furniture.copyWith(items: updatedItems);
    final updatedFurnitureList = List<Furniture>.from(zone.furnitureList)..[fIndex] = updatedFurniture;
    updateZone(zone.copyWith(furnitureList: updatedFurnitureList));
    return true;
  }

  void updateItemInFurniture({
    required String furnitureId,
    required Item updatedItem,
  }) {
    final zone = activeZone;
    if (zone == null) return;

    final fIndex = zone.furnitureList.indexWhere((f) => f.id == furnitureId);
    if (fIndex == -1) return;

    final furniture = zone.furnitureList[fIndex];
    final itemIndex = furniture.items.indexWhere((i) => i.id == updatedItem.id);
    if (itemIndex == -1) return;

    final updatedItems = List<Item>.from(furniture.items)..[itemIndex] = updatedItem;
    final updatedFurniture = furniture.copyWith(items: updatedItems);
    final updatedFurnitureList = List<Furniture>.from(zone.furnitureList)..[fIndex] = updatedFurniture;
    updateZone(zone.copyWith(furnitureList: updatedFurnitureList));
  }

  void deleteItemFromFurniture({
    required String furnitureId,
    required String itemId,
  }) {
    final zone = activeZone;
    if (zone == null) return;

    final fIndex = zone.furnitureList.indexWhere((f) => f.id == furnitureId);
    if (fIndex == -1) return;

    final furniture = zone.furnitureList[fIndex];
    final updatedItems = List<Item>.from(furniture.items)..removeWhere((i) => i.id == itemId);
    final updatedFurniture = furniture.copyWith(items: updatedItems);
    final updatedFurnitureList = List<Furniture>.from(zone.furnitureList)..[fIndex] = updatedFurniture;
    updateZone(zone.copyWith(furnitureList: updatedFurnitureList));
  }

  void moveItemSlot({
    required String furnitureId,
    required String itemId,
    required int newSlotIndex,
  }) {
    final zone = activeZone;
    if (zone == null) return;

    final fIndex = zone.furnitureList.indexWhere((f) => f.id == furnitureId);
    if (fIndex == -1) return;

    final furniture = zone.furnitureList[fIndex];
    if (newSlotIndex < 0 || newSlotIndex >= furniture.slotCapacity) return;

    final movingItem = furniture.items.firstWhere((i) => i.id == itemId);
    final existingItemAtSlot = furniture.getItemAtSlot(newSlotIndex);

    final updatedItems = List<Item>.from(furniture.items);

    if (existingItemAtSlot != null && existingItemAtSlot.id != movingItem.id) {
      // Swap slots!
      final targetIndex = updatedItems.indexWhere((i) => i.id == existingItemAtSlot.id);
      final sourceIndex = updatedItems.indexWhere((i) => i.id == movingItem.id);
      updatedItems[targetIndex] = existingItemAtSlot.copyWith(slotIndex: movingItem.slotIndex);
      updatedItems[sourceIndex] = movingItem.copyWith(slotIndex: newSlotIndex);
    } else {
      // Move to empty slot
      final sourceIndex = updatedItems.indexWhere((i) => i.id == movingItem.id);
      updatedItems[sourceIndex] = movingItem.copyWith(slotIndex: newSlotIndex);
    }

    final updatedFurniture = furniture.copyWith(items: updatedItems);
    final updatedFurnitureList = List<Furniture>.from(zone.furnitureList)..[fIndex] = updatedFurniture;
    updateZone(zone.copyWith(furnitureList: updatedFurnitureList));
  }

  // Reset to default seed
  Future<void> resetToSeedData() async {
    _zones = _storageService.getSeedZones();
    _activeZoneId = _zones.isNotEmpty ? _zones.first.id : null;
    _selectedFurnitureId = null;
    _clearGhost();
    _searchQuery = '';
    _save();
    notifyListeners();
  }
}
