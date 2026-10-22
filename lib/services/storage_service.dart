import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/furniture.dart';
import '../models/item.dart';
import '../models/zone.dart';

class StorageService {
  static const String _storageKey = 'loot_room_zones_data_v1';
  final _uuid = const Uuid();

  Future<void> saveZones(List<Zone> zones) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = zones.map((z) => z.toMap()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      // Ignore or log error
    }
  }

  Future<List<Zone>> loadZones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded
            .map((item) => Zone.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Fallback to initial seed
    }
    return getSeedZones();
  }

  List<Zone> getSeedZones() {
    // Zone 1: Oficina / Estudio
    final deskItems = [
      Item(
        id: _uuid.v4(),
        name: 'Cable USB-C 100W Braided',
        description: 'Cable ultra-resistente de 2 metros para carga rápida.',
        rarity: ItemRarity.rare,
        category: ItemCategory.electronics,
        quantity: 2,
        slotIndex: 0,
        tags: ['cables', 'usb-c', 'carga'],
        iconKey: 'cable',
      ),
      Item(
        id: _uuid.v4(),
        name: 'SSD Externo 2TB NVMe',
        description: 'Almacenamiento de alta velocidad para backups.',
        rarity: ItemRarity.epic,
        category: ItemCategory.electronics,
        quantity: 1,
        slotIndex: 1,
        tags: ['backup', 'ssd', 'trabajo'],
        iconKey: 'save',
      ),
      Item(
        id: _uuid.v4(),
        name: 'Bloc de Notas & Bolígrafo Táctico',
        description: 'Para anotar ideas rápidas y contraseñas secretas.',
        rarity: ItemRarity.common,
        category: ItemCategory.stationery,
        quantity: 3,
        slotIndex: 2,
        tags: ['papeleria', 'notas'],
        iconKey: 'edit_note',
      ),
    ];

    final techDrawerItems = [
      Item(
        id: _uuid.v4(),
        name: 'Pasaporte & Documentos de Identidad',
        description: 'Documentación oficial clasificada para viajes internacionales.',
        rarity: ItemRarity.legendary,
        category: ItemCategory.documents,
        quantity: 1,
        slotIndex: 0,
        tags: ['viajes', 'oficial', 'seguridad'],
        iconKey: 'badge',
      ),
      Item(
        id: _uuid.v4(),
        name: 'Cargador GaN 65W Multi-puerto',
        description: 'Cargador compacto con 2x USB-C y 1x USB-A.',
        rarity: ItemRarity.uncommon,
        category: ItemCategory.electronics,
        quantity: 1,
        slotIndex: 1,
        tags: ['cargador', 'viaje'],
        iconKey: 'power',
      ),
      Item(
        id: _uuid.v4(),
        name: 'Auriculares Noise Cancelling',
        description: 'Cancelación activa de ruido para máxima concentración.',
        rarity: ItemRarity.epic,
        category: ItemCategory.gaming,
        quantity: 1,
        slotIndex: 4,
        tags: ['audio', 'bluetooth'],
        iconKey: 'headphones',
      ),
    ];

    final bookshelfItems = [
      Item(
        id: _uuid.v4(),
        name: 'Manual de Algoritmos y Estructuras',
        description: 'El libro sagrado de la programación.',
        rarity: ItemRarity.rare,
        category: ItemCategory.documents,
        quantity: 1,
        slotIndex: 0,
        tags: ['libros', 'codigo'],
        iconKey: 'menu_book',
      ),
      Item(
        id: _uuid.v4(),
        name: 'Figura Coleccionable Retro',
        description: 'Edición limitada para decorar la base.',
        rarity: ItemRarity.epic,
        category: ItemCategory.valuables,
        quantity: 1,
        slotIndex: 2,
        tags: ['coleccion', 'figura'],
        iconKey: 'token',
      ),
    ];

    final officeFurniture = [
      Furniture(
        id: _uuid.v4(),
        name: 'Escritorio Setup Pro',
        type: FurnitureType.desk,
        gridX: 2,
        gridY: 1,
        gridWidth: 3,
        gridHeight: 2,
        rotation: 0,
        slotCapacity: 12,
        items: deskItems,
      ),
      Furniture(
        id: _uuid.v4(),
        name: 'Cajonera Tech & Docs',
        type: FurnitureType.drawer,
        gridX: 5,
        gridY: 1,
        gridWidth: 1,
        gridHeight: 2,
        rotation: 0,
        slotCapacity: 16,
        items: techDrawerItems,
      ),
      Furniture(
        id: _uuid.v4(),
        name: 'Estantería Principal',
        type: FurnitureType.bookshelf,
        gridX: 1,
        gridY: 5,
        gridWidth: 3,
        gridHeight: 1,
        rotation: 0,
        slotCapacity: 18,
        items: bookshelfItems,
      ),
      Furniture(
        id: _uuid.v4(),
        name: 'Mochila Urbana',
        type: FurnitureType.backpack,
        gridX: 6,
        gridY: 5,
        gridWidth: 1,
        gridHeight: 1,
        rotation: 0,
        slotCapacity: 8,
        items: [],
      ),
    ];

    final zone1 = Zone(
      id: _uuid.v4(),
      name: 'Oficina / Estudio',
      description: 'Zona de trabajo de alta productividad y hardware.',
      gridColumns: 8,
      gridRows: 8,
      themeColorValue: 0xFF6366F1, // Indigo
      iconKey: 'computer',
      floor: 2, // Planta Alta
      floorX: 56.0,
      floorY: 84.0,
      furnitureList: officeFurniture,
    );

    final zoneHallwayP1 = Zone(
      id: _uuid.v4(),
      name: 'Pasillo Distribuidor P1',
      description: 'Conecta la oficina con el dormitorio principal.',
      gridColumns: 2,
      gridRows: 8,
      themeColorValue: 0xFF64748B,
      iconKey: 'hallway',
      floor: 2, // Planta Alta
      floorX: 280.0,
      floorY: 84.0,
      isHallway: true,
      furnitureList: [],
    );

    // Zone 2: Dormitorio Principal (Planta Alta)
    final wardrobeItems = [
      Item(
        id: _uuid.v4(),
        name: 'Chaqueta de Cuero Legendaria',
        description: 'Protección +10 contra el frío con estilo cyberpunk.',
        rarity: ItemRarity.legendary,
        category: ItemCategory.clothing,
        quantity: 1,
        slotIndex: 0,
        tags: ['ropa', 'invierno'],
        iconKey: 'dry_cleaning',
      ),
      Item(
        id: _uuid.v4(),
        name: 'Set de Camisetas Negras',
        description: 'Uniforme diario de desarrollador.',
        rarity: ItemRarity.common,
        category: ItemCategory.clothing,
        quantity: 5,
        slotIndex: 1,
        tags: ['ropa', 'diario'],
        iconKey: 'checkroom',
      ),
    ];

    final nightstandItems = [
      Item(
        id: _uuid.v4(),
        name: 'Reloj Automático Vintage',
        description: 'Mecanismo suizo de alta precisión.',
        rarity: ItemRarity.rare,
        category: ItemCategory.accessories,
        quantity: 1,
        slotIndex: 0,
        tags: ['reloj', 'joyas'],
        iconKey: 'watch',
      ),
      Item(
        id: _uuid.v4(),
        name: 'Gafas de Lectura Blue-Light',
        description: 'Protección para largas sesiones frente a pantallas.',
        rarity: ItemRarity.uncommon,
        category: ItemCategory.accessories,
        quantity: 1,
        slotIndex: 1,
        tags: ['gafas', 'vision'],
        iconKey: 'visibility',
      ),
    ];

    final bedroomFurniture = [
      Furniture(
        id: _uuid.v4(),
        name: 'Cama King Size',
        type: FurnitureType.bed,
        gridX: 2,
        gridY: 1,
        gridWidth: 3,
        gridHeight: 3,
        rotation: 0,
        slotCapacity: 16,
        items: [],
      ),
      Furniture(
        id: _uuid.v4(),
        name: 'Armario Principal',
        type: FurnitureType.wardrobe,
        gridX: 1,
        gridY: 5,
        gridWidth: 3,
        gridHeight: 2,
        rotation: 0,
        slotCapacity: 24,
        items: wardrobeItems,
      ),
      Furniture(
        id: _uuid.v4(),
        name: 'Mesa de Noche Izquierda',
        type: FurnitureType.chest,
        gridX: 1,
        gridY: 1,
        gridWidth: 1,
        gridHeight: 1,
        rotation: 0,
        slotCapacity: 8,
        items: nightstandItems,
      ),
      Furniture(
        id: _uuid.v4(),
        name: 'Puerta hacia Pasillo',
        type: FurnitureType.door,
        gridX: 0,
        gridY: 3,
        gridWidth: 1,
        gridHeight: 1,
        rotation: 0,
        slotCapacity: 0,
        items: [],
      ),
    ];

    final zone2 = Zone(
      id: _uuid.v4(),
      name: 'Dormitorio Principal',
      description: 'Habitación de descanso e inventario personal.',
      gridColumns: 8,
      gridRows: 8,
      themeColorValue: 0xFF8B5CF6, // Violet
      iconKey: 'bed',
      floor: 2, // Planta Alta
      floorX: 336.0,
      floorY: 84.0,
      furnitureList: bedroomFurniture,
    );

    // Zone 3: Taller & Garaje (Planta Baja)
    final toolboxItems = [
      Item(
        id: _uuid.v4(),
        name: 'Juego de Destornilladores de Precisión',
        description: 'Puntas magnéticas para reparación de dispositivos.',
        rarity: ItemRarity.rare,
        category: ItemCategory.tools,
        quantity: 1,
        slotIndex: 0,
        tags: ['herramientas', 'reparacion'],
        iconKey: 'build',
      ),
      Item(
        id: _uuid.v4(),
        name: 'Cinta Aislante Reforzada',
        description: 'Repara todo temporalmente o para siempre.',
        rarity: ItemRarity.common,
        category: ItemCategory.tools,
        quantity: 4,
        slotIndex: 1,
        tags: ['ferreteria', 'cinta'],
        iconKey: 'handyman',
      ),
      Item(
        id: _uuid.v4(),
        name: 'Multímetro Digital Pro',
        description: 'Medición de voltaje, corriente y resistencia.',
        rarity: ItemRarity.epic,
        category: ItemCategory.tools,
        quantity: 1,
        slotIndex: 3,
        tags: ['electronica', 'medicion'],
        iconKey: 'electric_meter',
      ),
    ];

    final workshopFurniture = [
      Furniture(
        id: _uuid.v4(),
        name: 'Caja de Herramientas Master',
        type: FurnitureType.box,
        gridX: 1,
        gridY: 1,
        gridWidth: 2,
        gridHeight: 1,
        rotation: 0,
        slotCapacity: 16,
        items: toolboxItems,
      ),
      Furniture(
        id: _uuid.v4(),
        name: 'Caja Fuerte Acorazada',
        type: FurnitureType.safe,
        gridX: 6,
        gridY: 1,
        gridWidth: 1,
        gridHeight: 1,
        rotation: 0,
        slotCapacity: 8,
        items: [
          Item(
            id: _uuid.v4(),
            name: 'Llave Maestra de Respaldo',
            description: 'Abre el búnker y los accesos de emergencia.',
            rarity: ItemRarity.legendary,
            category: ItemCategory.valuables,
            quantity: 1,
            slotIndex: 0,
            tags: ['llaves', 'seguridad'],
            iconKey: 'key',
          )
        ],
      ),
      Furniture(
        id: _uuid.v4(),
        name: 'Escaleras al 2do Piso',
        type: FurnitureType.stairs,
        gridX: 5,
        gridY: 5,
        gridWidth: 2,
        gridHeight: 2,
        rotation: 0,
        slotCapacity: 4,
        items: [],
      ),
    ];

    final zone3 = Zone(
      id: _uuid.v4(),
      name: 'Taller & Garaje',
      description: 'Inventario de herramientas, refacciones y equipo pesado.',
      gridColumns: 8,
      gridRows: 8,
      themeColorValue: 0xFF10B981, // Emerald
      iconKey: 'construction',
      floor: 1, // Planta Baja
      floorX: 56.0,
      floorY: 84.0,
      furnitureList: workshopFurniture,
    );

    final zoneHallwayPB = Zone(
      id: _uuid.v4(),
      name: 'Pasillo Principal PB',
      description: 'Conecta el taller/garaje con el patio y jardín.',
      gridColumns: 2,
      gridRows: 8,
      themeColorValue: 0xFF64748B,
      iconKey: 'hallway',
      floor: 1, // Planta Baja
      floorX: 280.0,
      floorY: 84.0,
      isHallway: true,
      furnitureList: [],
    );

    // Zone 4: Patio Exterior & Jardín (Planta Baja)
    final patioFurniture = [
      Furniture(
        id: _uuid.v4(),
        name: 'Macetas de Bambú & Plantas',
        type: FurnitureType.patioPlant,
        gridX: 1,
        gridY: 1,
        gridWidth: 2,
        gridHeight: 1,
        rotation: 0,
        slotCapacity: 4,
        items: [],
      ),
      Furniture(
        id: _uuid.v4(),
        name: 'Caja de Jardinería',
        type: FurnitureType.box,
        gridX: 5,
        gridY: 4,
        gridWidth: 2,
        gridHeight: 1,
        rotation: 0,
        slotCapacity: 12,
        items: [],
      ),
    ];

    final zone4 = Zone(
      id: _uuid.v4(),
      name: 'Patio & Terraza Exterior',
      description: 'Espacio abierto al aire libre para plantas y relax.',
      gridColumns: 8,
      gridRows: 8,
      themeColorValue: 0xFF16A34A, // Green
      iconKey: 'yard',
      floor: 1, // Planta Baja
      floorX: 336.0,
      floorY: 84.0,
      isPatio: true, // Outdoor space
      furnitureList: patioFurniture,
    );

    return [zone3, zoneHallwayPB, zone4, zone1, zoneHallwayP1, zone2];
  }
}
