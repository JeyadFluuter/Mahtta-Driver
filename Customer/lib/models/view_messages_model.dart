import 'dart:convert';

List<ViewMessagesModel> viewmessagesFromJson(String str) {
  final jsonData = json.decode(str);
  final dataList = jsonData["data"] as List;
  return dataList.map((item) => ViewMessagesModel.fromJson(item)).toList();
}

String viewmessagesFromJsonModelToJson(List<ViewMessagesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ViewMessagesModel {
  final int? conversationId;
  final String? page;

  ViewMessagesModel({
    this.conversationId,
    this.page,
  });

  factory ViewMessagesModel.fromJson(Map<String, dynamic> json) {
    return ViewMessagesModel(
      conversationId: json['conversation_id'],
      page: json['page'],
    );
  }

  Map<String, dynamic> toJson() => {
        "conversation_id": conversationId,
        "page": page,
      };
}
