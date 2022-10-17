class ChatContact {
  final String name;
  final String phoneNumber;
  final String profilePic;
  final String contactId;
  final bool isMe;
  final bool isGroup;
  final DateTime timeSent;
  final String lastMessage;
  final int unseenMessages;
  ChatContact(
      {required this.name,
      required this.phoneNumber,
      required this.profilePic,
      required this.contactId,
      required this.isMe,
      required this.isGroup,
      required this.timeSent,
      required this.lastMessage,
      required this.unseenMessages});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'contactId': contactId,
      'isMe': isMe,
      'isGroup': isGroup,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'unseenMessages': unseenMessages
    };
  }

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
        name: map['name'] ?? '',
        phoneNumber: map['phoneNumber'] ?? '',
        profilePic: map['profilePic'] ?? '',
        contactId: map['contactId'] ?? '',
        isMe: map['isMe'] ?? true,
        isGroup: map['isGroup'] ?? true,
        timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
        lastMessage: map['lastMessage'] ?? '',
        unseenMessages: map['unseenMessages'] ?? '');
  }
}
