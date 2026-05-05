class CreateChatMessagesModel {
  final int conversationId;
  final String message;

  CreateChatMessagesModel({
    required this.conversationId,
    required this.message,
  });

  factory CreateChatMessagesModel.fromJson(Map<String, dynamic> json) {
    return CreateChatMessagesModel(
      conversationId: json["conversation_id"] ?? 0,
      message: json["message"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "conversation_id": conversationId,
        "message": message,
      };
}
