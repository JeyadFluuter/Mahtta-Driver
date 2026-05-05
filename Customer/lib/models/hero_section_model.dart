import 'package:biadgo/constants/apiUrl.dart';

class HeroSectionModel {
  String image;

  HeroSectionModel({required this.image});

  factory HeroSectionModel.fromJson(Map<String, dynamic> json) {
    return HeroSectionModel(
      image: json['image'] != null ? "$ImageUrl${json['image']}" : '',
    );
  }
}
