class FacilityDetailsModel {
  final String name;
  final List<String> images;
  final Map<String, String> information;
  final Map<String, String> features;
  final String description;

  FacilityDetailsModel({
    required this.name,
    required this.images,
    required this.information,
    required this.features,
    required this.description,
  });

  factory FacilityDetailsModel.fromJson(Map<String, dynamic> json) {
    // Parse images - could be a list of strings or list of objects
    List<String> imageList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        for (var img in json['images']) {
          if (img is String) {
            imageList.add(img);
          } else if (img is Map && img['url'] != null) {
            imageList.add(img['url'].toString());
          } else if (img is Map && img['image_url'] != null) {
            imageList.add(img['image_url'].toString());
          } else if (img is Map && img['path'] != null) {
            imageList.add(img['path'].toString());
          }
        }
      }
    }

    // Parse information - could be a map or a list of key-value pairs
    Map<String, String> infoMap = {};
    if (json['information'] != null) {
      if (json['information'] is Map) {
        json['information'].forEach((key, value) {
          infoMap[key.toString()] = value?.toString() ?? '';
        });
      } else if (json['information'] is List) {
        for (var item in json['information']) {
          if (item is Map && item['key'] != null && item['value'] != null) {
            infoMap[item['key'].toString()] = item['value'].toString();
          }
        }
      }
    }

    // Also check for common field names
    if (json['facility_info'] != null && infoMap.isEmpty) {
      if (json['facility_info'] is Map) {
        json['facility_info'].forEach((key, value) {
          infoMap[key.toString()] = value?.toString() ?? '';
        });
      }
    }

    // Parse features - could be a map or a list of key-value pairs
    Map<String, String> featuresMap = {};
    if (json['features'] != null) {
      if (json['features'] is Map) {
        json['features'].forEach((key, value) {
          featuresMap[key.toString()] = value?.toString() ?? '';
        });
      } else if (json['features'] is List) {
        for (var item in json['features']) {
          if (item is Map && item['key'] != null && item['value'] != null) {
            featuresMap[item['key'].toString()] = item['value'].toString();
          }
        }
      }
    }

    return FacilityDetailsModel(
      name: json['name']?.toString() ?? json['facility_name']?.toString() ?? '',
      images: imageList,
      information: infoMap,
      features: featuresMap,
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'images': images,
      'information': information,
      'features': features,
      'description': description,
    };
  }
}

