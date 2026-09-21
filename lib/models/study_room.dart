import '../services/api_config.dart';

class StudyRoom {
  final int? id;
  final String roomNumber;
  final String name;
  final String description;
  final String location;
  final int capacity;
  final double hourlyPrice;
  final bool available;
  final List<String> features;
  final String? imageUrl;

  const StudyRoom({
    this.id,
    this.roomNumber = '',
    required this.name,
    this.description = '',
    required this.location,
    required this.capacity,
    required this.hourlyPrice,
    required this.available,
    this.features = const [],
    this.imageUrl,
  });

  factory StudyRoom.fromJson(Map<String, dynamic> json) {
    int readInt(dynamic value) =>
        value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    double readDouble(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

    final rawFeatures = json['features'];
    final features = rawFeatures is List
        ? rawFeatures
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList()
        : (rawFeatures?.toString() ?? '')
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

    return StudyRoom(
      id: json['id'] == null ? null : readInt(json['id']),
      roomNumber: (json['roomNumber'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      capacity: readInt(json['capacity']),
      hourlyPrice: readDouble(json['hourlyPrice']),
      available: json['active'] == true || json['available'] == true,
      features: features,
      imageUrl: ApiConfig.resourceUrl(json['imageUrl']?.toString()),
    );
  }
}
