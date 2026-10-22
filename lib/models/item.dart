import 'package:flutter/material.dart';

enum ItemRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

extension ItemRarityExtension on ItemRarity {
  String get displayName {
    switch (this) {
      case ItemRarity.common:
        return 'Común';
      case ItemRarity.uncommon:
        return 'Poco Común';
      case ItemRarity.rare:
        return 'Raro';
      case ItemRarity.epic:
        return 'Épico';
      case ItemRarity.legendary:
        return 'Legendario';
    }
  }

  Color get color {
    switch (this) {
      case ItemRarity.common:
        return const Color(0xFF1D4ED8); // Royal Blue Bic Ink
      case ItemRarity.uncommon:
        return const Color(0xFF16A34A); // Green Pen Ink
      case ItemRarity.rare:
        return const Color(0xFF0284C7); // Cyan Pen Ink
      case ItemRarity.epic:
        return const Color(0xFF7C3AED); // Purple Gel Pen Ink
      case ItemRarity.legendary:
        return const Color(0xFFD97706); // Amber / Highlighter Gold Ink
    }
  }

  Color get glowColor {
    switch (this) {
      case ItemRarity.common:
        return const Color(0x261D4ED8);
      case ItemRarity.uncommon:
        return const Color(0x3316A34A);
      case ItemRarity.rare:
        return const Color(0x330284C7);
      case ItemRarity.epic:
        return const Color(0x337C3AED);
      case ItemRarity.legendary:
        return const Color(0x4DD97706);
    }
  }

  IconData get badgeIcon {
    switch (this) {
      case ItemRarity.common:
        return Icons.circle_outlined;
      case ItemRarity.uncommon:
        return Icons.change_history;
      case ItemRarity.rare:
        return Icons.diamond_outlined;
      case ItemRarity.epic:
        return Icons.auto_awesome;
      case ItemRarity.legendary:
        return Icons.military_tech;
    }
  }
}

enum ItemCategory {
  electronics,
  tools,
  documents,
  clothing,
  valuables,
  accessories,
  gaming,
  stationery,
  misc,
}

extension ItemCategoryExtension on ItemCategory {
  String get displayName {
    switch (this) {
      case ItemCategory.electronics:
        return 'Electrónica';
      case ItemCategory.tools:
        return 'Herramientas';
      case ItemCategory.documents:
        return 'Documentos';
      case ItemCategory.clothing:
        return 'Ropa';
      case ItemCategory.valuables:
        return 'Objetos de Valor';
      case ItemCategory.accessories:
        return 'Accesorios';
      case ItemCategory.gaming:
        return 'Gaming';
      case ItemCategory.stationery:
        return 'Papelería';
      case ItemCategory.misc:
        return 'Varios';
    }
  }

  IconData get icon {
    switch (this) {
      case ItemCategory.electronics:
        return Icons.devices;
      case ItemCategory.tools:
        return Icons.construction;
      case ItemCategory.documents:
        return Icons.description;
      case ItemCategory.clothing:
        return Icons.checkroom;
      case ItemCategory.valuables:
        return Icons.vpn_key;
      case ItemCategory.accessories:
        return Icons.watch;
      case ItemCategory.gaming:
        return Icons.sports_esports;
      case ItemCategory.stationery:
        return Icons.draw;
      case ItemCategory.misc:
        return Icons.category;
    }
  }
}

class Item {
  final String id;
  final String name;
  final String description;
  final ItemRarity rarity;
  final ItemCategory category;
  final int quantity;
  final int slotIndex;
  final List<String> tags;
  final String iconKey;

  const Item({
    required this.id,
    required this.name,
    this.description = '',
    this.rarity = ItemRarity.common,
    this.category = ItemCategory.misc,
    this.quantity = 1,
    required this.slotIndex,
    this.tags = const [],
    this.iconKey = 'inventory_2',
  });

  Item copyWith({
    String? id,
    String? name,
    String? description,
    ItemRarity? rarity,
    ItemCategory? category,
    int? quantity,
    int? slotIndex,
    List<String>? tags,
    String? iconKey,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rarity: rarity ?? this.rarity,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      slotIndex: slotIndex ?? this.slotIndex,
      tags: tags ?? this.tags,
      iconKey: iconKey ?? this.iconKey,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rarity': rarity.name,
      'category': category.name,
      'quantity': quantity,
      'slotIndex': slotIndex,
      'tags': tags,
      'iconKey': iconKey,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      rarity: ItemRarity.values.firstWhere(
        (r) => r.name == map['rarity'],
        orElse: () => ItemRarity.common,
      ),
      category: ItemCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => ItemCategory.misc,
      ),
      quantity: (map['quantity'] as int?) ?? 1,
      slotIndex: (map['slotIndex'] as int?) ?? 0,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      iconKey: (map['iconKey'] as String?) ?? 'inventory_2',
    );
  }
}
