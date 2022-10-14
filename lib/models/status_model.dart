import 'package:wechat/common/enums/message_enum.dart';

class StatusModel {
  final String url;
  final MessageEnum type;
  final String caption;
  final DateTime createdAt;
  final String statusId;
  final List<String> whoCanSee;

  StatusModel(
      {required this.url,
      required this.type,
      required this.caption,
      required this.createdAt,
      required this.statusId,
      required this.whoCanSee});

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'type': type.type,
      'caption': caption,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'statusId': statusId,
      'whoCanSee': whoCanSee,
    };
  }

  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      url: map['url'] ?? '',
      type: (map['type'] as String).toEnum(),
      caption: map['caption'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      statusId: map['statusId'] ?? '',
      whoCanSee: List<String>.from(map['whoCanSee']),
    );
  }
}
