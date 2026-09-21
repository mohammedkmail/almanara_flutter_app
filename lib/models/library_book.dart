import 'package:flutter/material.dart';

import '../services/api_config.dart';

class LibraryBook {
  final int? id;
  final String title;
  final int? authorId;
  final String author;
  final int? categoryId;
  final String category;
  final String description;
  final String isbn;
  final bool available;
  final int availableCopies;
  final int totalCopies;
  final int physicalSaleStock;
  final double? physicalSalePrice;
  final double? borrowingFee;
  final double? effectiveBorrowingFee;
  final bool borrowingIncluded;
  final bool digitalAvailable;
  final double? digitalPurchasePrice;
  final double? digitalRentalPrice;
  final bool membershipIncluded;
  final bool hasDigitalAccess;
  final String? digitalContent;
  final bool active;
  final String? coverUrl;
  final String? publisher;
  final int? publishYear;
  final int? pageCount;
  final String? language;
  final String? metadataSource;
  final Color coverColor;
  final bool darkText;

  const LibraryBook({
    this.id,
    required this.title,
    this.authorId,
    required this.author,
    this.categoryId,
    required this.category,
    this.description = '',
    this.isbn = '',
    required this.available,
    this.availableCopies = 0,
    this.totalCopies = 0,
    this.physicalSaleStock = 0,
    this.physicalSalePrice,
    this.borrowingFee,
    this.effectiveBorrowingFee,
    this.borrowingIncluded = false,
    this.digitalAvailable = false,
    this.digitalPurchasePrice,
    this.digitalRentalPrice,
    this.membershipIncluded = false,
    this.hasDigitalAccess = false,
    this.digitalContent,
    this.active = true,
    this.coverUrl,
    this.publisher,
    this.publishYear,
    this.pageCount,
    this.language,
    this.metadataSource,
    this.coverColor = const Color(0xFF0B4F4C),
    this.darkText = false,
  });

  double get userBorrowingFee => effectiveBorrowingFee ?? borrowingFee ?? 0;

  factory LibraryBook.fromJson(Map<String, dynamic> json) {
    String readName(dynamic value) {
      if (value is Map) {
        return (value['name'] ?? value['fullName'] ?? '').toString();
      }
      return (value ?? '').toString();
    }

    int? readId(dynamic value) {
      if (value is Map) return _readInt(value['id']);
      return _readInt(value);
    }

    return LibraryBook(
      id: _readInt(json['id']),
      title: (json['title'] ?? '').toString(),
      authorId: readId(json['author']),
      author: readName(json['author']),
      categoryId: readId(json['category']),
      category: readName(json['category']),
      description: (json['description'] ?? '').toString(),
      isbn: (json['isbn'] ?? '').toString(),
      available: json['available'] == true,
      availableCopies: _readInt(json['availableCopies']) ?? 0,
      totalCopies: _readInt(json['totalCopies']) ?? 0,
      physicalSaleStock: _readInt(json['physicalSaleStock']) ?? 0,
      physicalSalePrice: _readDouble(json['physicalSalePrice']),
      borrowingFee: _readDouble(json['borrowingFee']),
      effectiveBorrowingFee: _readDouble(json['effectiveBorrowingFee']),
      borrowingIncluded: json['borrowingIncluded'] == true,
      digitalAvailable: json['digitalAvailable'] == true,
      digitalPurchasePrice: _readDouble(json['digitalPurchasePrice']),
      digitalRentalPrice: _readDouble(json['digitalRentalPrice']),
      membershipIncluded: json['membershipIncluded'] == true,
      hasDigitalAccess: json['hasDigitalAccess'] == true,
      digitalContent: json['digitalContent']?.toString(),
      active: json['active'] != false,
      coverUrl: ApiConfig.resourceUrl(json['coverUrl']?.toString()),
      publisher: json['publisher']?.toString(),
      publishYear: _readInt(json['publishYear']),
      pageCount: _readInt(json['pageCount']),
      language: json['language']?.toString(),
      metadataSource: json['metadataSource']?.toString(),
    );
  }
}

int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _readDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
