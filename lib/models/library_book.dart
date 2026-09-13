import 'package:flutter/material.dart';

class LibraryBook {
  final int? id;
  final String title;
  final String author;
  final String category;
  final String description;
  final String isbn;
  final bool available;
  final int physicalSaleStock;
  final double? physicalSalePrice;
  final double? borrowingFee;
  final bool digitalAvailable;
  final double? digitalPurchasePrice;
  final double? digitalRentalPrice;
  final bool membershipIncluded;
  final String? coverUrl;

  // مؤقت للواجهة فقط إلى أن تأتي صور الأغلفة من الـ API.
  final Color coverColor;
  final bool darkText;

  const LibraryBook({
    this.id,
    required this.title,
    required this.author,
    required this.category,
    this.description = '',
    this.isbn = '',
    required this.available,
    this.physicalSaleStock = 0,
    this.physicalSalePrice,
    this.borrowingFee,
    this.digitalAvailable = false,
    this.digitalPurchasePrice,
    this.digitalRentalPrice,
    this.membershipIncluded = false,
    this.coverUrl,
    required this.coverColor,
    this.darkText = false,
  });

  factory LibraryBook.fromJson(Map<String, dynamic> json) {
    final dynamic authorValue = json['author'];
    final dynamic categoryValue = json['category'];

    String readName(dynamic value) {
      if (value is Map<String, dynamic>) {
        return (value['name'] ?? value['fullName'] ?? '').toString();
      }
      return (value ?? '').toString();
    }

    double? readDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return LibraryBook(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? ''}'),
      title: (json['title'] ?? '').toString(),
      author: readName(authorValue),
      category: readName(categoryValue),
      description: (json['description'] ?? '').toString(),
      isbn: (json['isbn'] ?? '').toString(),
      available: json['available'] == true || json['isAvailable'] == true,
      physicalSaleStock: json['physicalSaleStock'] is int
          ? json['physicalSaleStock'] as int
          : int.tryParse('${json['physicalSaleStock'] ?? 0}') ?? 0,
      physicalSalePrice: readDouble(json['physicalSalePrice']),
      borrowingFee: readDouble(json['borrowingFee']),
      digitalAvailable: json['digitalAvailable'] == true,
      digitalPurchasePrice: readDouble(json['digitalPurchasePrice']),
      digitalRentalPrice: readDouble(json['digitalRentalPrice']),
      membershipIncluded: json['membershipIncluded'] == true,
      coverUrl: json['coverUrl']?.toString(),
      coverColor: const Color(0xFF0B4F4C),
    );
  }
}
