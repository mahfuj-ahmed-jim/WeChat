import 'package:wechat/common/enums/message_enum.dart';

class StatusModel {
  final String userId;
  final String url;
  final MessageEnum type;
  final String caption;
  final DateTime createdAt;
  final String statusId;
  final List<String> whoCanSee;
  final List<String> seen;

  StatusModel(
      {required this.userId,
      required this.url,
      required this.type,
      required this.caption,
      required this.createdAt,
      required this.statusId,
      required this.whoCanSee,
      required this.seen});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'url': url,
      'type': type.type,
      'caption': caption,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'statusId': statusId,
      'whoCanSee': whoCanSee,
      'seen': seen
    };
  }

  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      userId: map['userId'] ?? '',
      url: map['url'] ?? '',
      type: (map['type'] as String).toEnum(),
      caption: map['caption'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      statusId: map['statusId'] ?? '',
      whoCanSee: List<String>.from(map['whoCanSee']).toList(),
      seen: List<String>.from(map['seen']).toList(),
    );
  }
}
