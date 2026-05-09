import 'dart:convert';
import 'package:piaggio_driver/constants/api_Url.dart';

class OffersDriverModel {
  final int id;
  final String title;
  final String body;
  final String image;
  final String startsAt;
  final String endsAt;

  final String link;

  OffersDriverModel({
    required this.id,
    required this.title,
    required this.body,
    required this.image,
    required this.startsAt,
    required this.endsAt,
    required this.link,
  });

  factory OffersDriverModel.fromMap(Map<String, dynamic> json) {
    return OffersDriverModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      image: json['image'] != null ? "$imageUrl${json['image']}" : '',
      startsAt: json['starts_at'] ?? '',
      endsAt: json['ends_at'] ?? '',
      link: json['link'] ?? '',
    );
  }

  static List<OffersDriverModel> listFromJson(String str) {
    final data = jsonDecode(str) as List;
    return data.map((e) => OffersDriverModel.fromMap(e)).toList();
  }
}
