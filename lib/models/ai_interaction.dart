import 'package:cloud_firestore/cloud_firestore.dart';

class AiInteraction {
  final String id;
  final String userId;
  final String type;
  final String userMessage;
  final String aiResponse;
  final DateTime createdAt;

  const AiInteraction({
    required this.id,
    required this.userId,
    required this.type,
    required this.userMessage,
    required this.aiResponse,
    required this.createdAt,
  });

  factory AiInteraction.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AiInteraction(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      type: d['type'] as String? ?? 'chat',
      userMessage: d['userMessage'] as String? ?? '',
      aiResponse: d['aiResponse'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'userMessage': userMessage,
        'aiResponse': aiResponse,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
