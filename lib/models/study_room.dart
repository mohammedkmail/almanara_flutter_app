class StudyRoom {
  final int? id;
  final String name;
  final String location;
  final int capacity;
  final double hourlyPrice;
  final bool available;
  final List<String> features;
  final String? imageUrl;

  const StudyRoom({
    this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.hourlyPrice,
    required this.available,
    this.features = const [],
    this.imageUrl,
  });

  factory StudyRoom.fromJson(Map<String, dynamic> json) {
    final dynamic featuresValue = json['features'];

    return StudyRoom(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? ''}'),
      name: (json['name'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      capacity: json['capacity'] is int
          ? json['capacity'] as int
          : int.tryParse('${json['capacity'] ?? 0}') ?? 0,
      hourlyPrice: json['hourlyPrice'] is num
          ? (json['hourlyPrice'] as num).toDouble()
          : double.tryParse('${json['hourlyPrice'] ?? 0}') ?? 0,
      available: json['available'] == true || json['status'] == 'AVAILABLE',
      features: featuresValue is List
          ? featuresValue.map((item) => item.toString()).toList()
          : const [],
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}
