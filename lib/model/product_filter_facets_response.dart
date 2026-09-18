import 'dart:convert';

ProductFilterFacetsResponse productFilterFacetsResponseFromJson(String str) =>
    ProductFilterFacetsResponse.fromJson(json.decode(str));

class ProductFilterFacetsResponse {
  final List<FilterFacet> categories;
  final List<FilterFacet> tags;
  final List<FilterFacet> collections;

  ProductFilterFacetsResponse({
    required this.categories,
    required this.tags,
    required this.collections,
  });

  factory ProductFilterFacetsResponse.fromJson(Map<String, dynamic> json) {
    List<FilterFacet> values(String key, String labelKey) =>
        (json[key] as List<dynamic>? ?? [])
            .map((value) => FilterFacet.fromJson(value, labelKey))
            .toList();

    return ProductFilterFacetsResponse(
      categories: values('product_categories', 'name'),
      tags: values('product_tags', 'value'),
      collections: values('collections', 'title'),
    );
  }
}

class FilterFacet {
  final String id;
  final String label;
  final int count;

  FilterFacet({required this.id, required this.label, required this.count});

  factory FilterFacet.fromJson(Map<String, dynamic> json, String labelKey) =>
      FilterFacet(
        id: json['id']?.toString() ?? '',
        label: json[labelKey]?.toString() ?? '',
        count: (json['count'] as num?)?.toInt() ?? 0,
      );
}
