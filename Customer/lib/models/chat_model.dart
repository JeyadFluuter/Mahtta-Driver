// lib/models/conversation.dart

enum ParticipantType {
  Customer,
  Driver,
}

extension ParticipantTypeExt on ParticipantType {
  String toJson() => toString().split('.').last;
  static ParticipantType fromJson(String s) => ParticipantType.values
      .firstWhere((e) => e.toString().split('.').last == s);
}

class Participant {
  final int id;
  final ParticipantType type;

  Participant({
    required this.id,
    required this.type,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json['id'] as int,
        type: ParticipantTypeExt.fromJson(json['type'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
      };
}

enum ConversationType {
  PRIVATE,
  GROUP,
}

extension ConversationTypeExt on ConversationType {
  String toJson() => toString().split('.').last;
  static ConversationType fromJson(String s) => ConversationType.values
      .firstWhere((e) => e.toString().split('.').last == s);
}

class Conversation {
  final List<Participant> participants;
  final ConversationType conversationType;
  final String subject;

  Conversation({
    required this.participants,
    required this.conversationType,
    required this.subject,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        participants: (json['participants'] as List<dynamic>)
            .map((e) => Participant.fromJson(e as Map<String, dynamic>))
            .toList(),
        conversationType:
            ConversationTypeExt.fromJson(json['conversation_type'] as String),
        subject: json['subject'] as String,
      );

  Map<String, dynamic> toJson() => {
        'participants': participants.map((p) => p.toJson()).toList(),
        'conversation_type': conversationType.toJson(),
        'subject': subject,
      };
}
