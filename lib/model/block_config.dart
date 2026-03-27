class BlockConfig {
  final String id;
  final bool enabled;
  final int order;
  final String component;
  final Map<String, dynamic> config;

  BlockConfig({
    required this.id,
    required this.enabled,
    required this.order,
    required this.component,
    required this.config,
  });

  factory BlockConfig.fromJson(Map<String, dynamic> json) {
    return BlockConfig(
      id: json['id'] ?? '',
      enabled: json['enabled'] ?? true,
      order: json['order'] ?? 0,
      component: json['component'] ?? '',
      config: Map<String, dynamic>.from(json['config'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'enabled': enabled,
        'order': order,
        'component': component,
        'config': config,
      };

  // Config helpers
  bool getBool(String key, {bool defaultValue = false}) =>
      config[key] as bool? ?? defaultValue;

  String getString(String key, {String defaultValue = ''}) =>
      config[key] as String? ?? defaultValue;

  int getInt(String key, {int defaultValue = 0}) =>
      (config[key] as num?)?.toInt() ?? defaultValue;

  double getDouble(String key, {double defaultValue = 0.0}) =>
      (config[key] as num?)?.toDouble() ?? defaultValue;

  List<String> getStringList(String key) {
    final list = config[key];
    if (list is List) return list.map((e) => e.toString()).toList();
    return [];
  }
}

class PageConfig {
  final String slug;
  final List<BlockConfig> blocks;

  PageConfig({required this.slug, required this.blocks});

  factory PageConfig.fromJson(Map<String, dynamic> json) {
    final config = json['config'] ?? json;
    final blocksList = config['blocks'] as List<dynamic>? ?? [];
    return PageConfig(
      slug: json['slug'] ?? '',
      blocks: blocksList.map((b) => BlockConfig.fromJson(b)).toList(),
    );
  }

  List<BlockConfig> get enabledBlocks =>
      blocks.where((b) => b.enabled).toList()..sort((a, b) => a.order.compareTo(b.order));

  BlockConfig? getBlock(String blockId) {
    try {
      return blocks.firstWhere((b) => b.id == blockId);
    } catch (_) {
      return null;
    }
  }

  bool isBlockEnabled(String blockId) {
    final block = getBlock(blockId);
    return block?.enabled ?? false;
  }
}
