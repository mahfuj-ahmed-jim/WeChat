import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/common/provider/message_reply_provider.dart';
import 'package:wechat/common/repositories/common_firebase_storage_repository.dart';
import 'package:wechat/common/utils/utils.dart';
import 'package:wechat/features/auth/controller/auth_controller.dart';
import 'package:wechat/features/select_contact/controller/select_contacts_controller.dart';
import 'package:wechat/models/chat_contact_model.dart';
import 'package:wechat/models/group_model.dart';
import 'package:wechat/models/message_model.dart';
import 'package:wechat/models/user_model.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
      ref: ref),
);

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;
  ChatRepository(
      {required this.firestore, required this.auth, required this.ref});

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];

      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());

        if (chatContact.isGroup) {
          contacts.add(ChatContact(
              name: chatContact.name,
              phoneNumber: chatContact.phoneNumber,
              profilePic: chatContact.profilePic,
              contactId: chatContact.contactId,
              timeSent: chatContact.timeSent,
              lastMessage: chatContact.lastMessage,
              isMe: chatContact.isMe,
              isGroup: chatContact.isGroup,
              unseenMessages: chatContact.unseenMessages));
        } else {
          var userData = await firestore
              .collection('users')
              .doc(chatContact.contactId)
              .get();
          var user = UserModel.fromMap(userData.data()!);

          String? name = await ref
              .read(selectContactControllerProvider)
              .checkSavedUser(user.phoneNumber);

          if (name != null) {
            contacts.add(ChatContact(
                name: name,
                phoneNumber: user.phoneNumber,
                profilePic: user.profilePic,
                contactId: chatContact.contactId,
                timeSent: chatContact.timeSent,
                lastMessage: chatContact.lastMessage,
                isMe: chatContact.isMe,
                isGroup: chatContact.isGroup,
                unseenMessages: chatContact.unseenMessages));
          } else {
            contacts.add(ChatContact(
                name: user.phoneNumber,
                phoneNumber: user.phoneNumber,
                profilePic: user.profilePic,
                contactId: chatContact.contactId,
                timeSent: chatContact.timeSent,
                lastMessage: chatContact.lastMessage,
                isMe: chatContact.isMe,
                isGroup: chatContact.isGroup,
                unseenMessages: chatContact.unseenMessages));
          }
        }
      }
      return contacts;
    });
  }

  Stream<List<Message>> getChatStream(String recieverUserId, bool isGroup) {
    if (isGroup) {
      return firestore
          .collection('groups')
          .doc(recieverUserId)
          .collection('messages')
          .orderBy('timeSent')
          .snapshots()
          .map((event) {
        List<Message> messages = [];

        for (var document in event.docs) {
          messages.add(Message.fromMap(document.data()));
        }

        return messages;
      });
    } else {
      return firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .orderBy('timeSent')
          .snapshots()
          .map((event) {
        List<Message> messages = [];

        for (var document in event.docs) {
          messages.add(Message.fromMap(document.data()));
        }

        return messages;
      });
    }
  }

  void saveMessageToReceiverEnd(
      String name,
      String phoneNumber,
      String profilePic,
      String contactId,
      DateTime timeSent,
      String text,
      int unseenMessages,
      String uid,
      String receiverId,
      bool isGroup) async {
    try {
      var recieverChatContact = ChatContact(
          name: name,
          phoneNumber: phoneNumber,
          profilePic: profilePic,
          contactId: contactId,
          timeSent: timeSent,
          lastMessage: text,
          isMe: false,
          isGroup: isGroup,
          unseenMessages: unseenMessages);

      await firestore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(receiverId)
          .set(
            recieverChatContact.toMap(),
          );
    } catch (e) {
      //
    }
  }

  void saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel? recieverUserData,
    GroupModel? groupModel,
    String text,
    DateTime timeSent,
    bool isGroupChat,
  ) async {
    int unseenMessages = 1;

    if (isGroupChat) {
      // users -> reciever user id => chats -> current user id -> set data
      for (var memberId in groupModel!.membersUid) {
        try {
          var doc = (await firestore
              .collection('users')
              .doc(memberId)
              .collection('chats')
              .doc(groupModel.groupId)
              .get());
          unseenMessages = doc.get('unseenMessages') + 1;
        } catch (e) {
          //
        }

        saveMessageToReceiverEnd(
            groupModel.name,
            senderUserData.phoneNumber,
            groupModel.groupPic,
            groupModel.groupId,
            timeSent,
            text,
            unseenMessages,
            memberId,
            groupModel.groupId,
            isGroupChat);
      }
    } else {
      // users -> reciever user id => chats -> current user id -> set data
      try {
        var doc = await firestore
            .collection('users')
            .doc(recieverUserData!.uid)
            .collection('chats')
            .doc(auth.currentUser!.uid)
            .get();
        unseenMessages = doc.get('unseenMessages') + 1;
      } catch (e) {
        //
      }

      saveMessageToReceiverEnd(
          senderUserData.name,
          senderUserData.phoneNumber,
          senderUserData.profilePic,
          senderUserData.uid,
          timeSent,
          text,
          unseenMessages,
          recieverUserData!.uid,
          auth.currentUser!.uid,
          isGroupChat);
    }

    // users -> current user id  => chats -> reciever user id -> set data
    var senderChatContact = ChatContact(
        name: isGroupChat ? groupModel!.name : recieverUserData!.name,
        phoneNumber: senderUserData.phoneNumber,
        profilePic:
            isGroupChat ? groupModel!.groupPic : recieverUserData!.profilePic,
        contactId: isGroupChat ? groupModel!.groupId : recieverUserData!.uid,
        timeSent: timeSent,
        lastMessage: text,
        isMe: true,
        isGroup: isGroupChat,
        unseenMessages: 0);

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(isGroupChat ? groupModel!.groupId : recieverUserData!.uid)
        .set(
          senderChatContact.toMap(),
        );
  }

  void saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    var user = await ref.read(authControllerProvider).getUserById(userId: auth.currentUser!.uid);

    final message = Message(
        senderId: auth.currentUser!.uid,
        recieverid: recieverUserId,
        senderPhoneNumber: user!.phoneNumber,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageId: messageId,
        isSeen: false,
        repliedMessage: messageReply == null ? '' : messageReply.message,
        repliedTo: messageReply == null
            ? ''
            : messageReply.isMe
                ? auth.currentUser!.uid
                : recieverUserId,
        repliedMessageType:
            messageReply == null ? MessageEnum.text : messageReply.messageEnum);

    if (isGroupChat) {
      // groups -> group id -> chat -> message
      await firestore
          .collection('groups')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    } else {
      // users -> sender id -> reciever id -> messages -> message id -> store message
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );

      // users -> reciever id  -> sender id -> messages -> message id -> store message
      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(
            message.toMap(),
          );
    }
  }

  void sendTextMessage(
      {required BuildContext context,
      required String text,
      required String recieverUserId, // isGroupChat? recieverUserId = groupId
      required UserModel senderUser,
      required bool isGroupChat,
      required MessageReply? messageReply}) async {
    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      GroupModel? groupModel;
      if (isGroupChat) {
        var groupDoc =
            await firestore.collection('groups').doc(recieverUserId).get();
        groupModel = GroupModel.fromMap(groupDoc.data()!);
      }
      saveDataToContactsSubcollection(
        senderUser,
        recieverUserData,
        isGroupChat ? groupModel : null,
        text,
        timeSent,
        isGroupChat,
      );

      saveMessageToMessageSubcollection(
          recieverUserId:
              recieverUserId, // isGroupChat? recieverUserId = groupId
          text: text,
          timeSent: timeSent,
          messageType: MessageEnum.text,
          messageId: messageId,
          username: senderUser.name,
          isGroupChat: isGroupChat,
          messageReply: messageReply);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage(
      {required BuildContext context,
      required File file,
      required String recieverUserId,
      required UserModel senderUserData,
      required ProviderRef ref,
      required MessageEnum messageEnum,
      required bool isGroupChat,
      required MessageReply? messageReply}) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String fileUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
            'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
            file,
          );

      UserModel? recieverUserData;
      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        default:
          contactMsg = 'GIF';
      }

      GroupModel? groupModel;
      if (isGroupChat) {
        var groupDoc =
            await firestore.collection('groups').doc(recieverUserId).get();
        groupModel = GroupModel.fromMap(groupDoc.data()!);
      }
      saveDataToContactsSubcollection(
        senderUserData,
        recieverUserData,
        isGroupChat ? groupModel : null,
        contactMsg,
        timeSent,
        isGroupChat,
      );

      saveMessageToMessageSubcollection(
          recieverUserId: recieverUserId,
          text: fileUrl,
          timeSent: timeSent,
          messageId: messageId,
          username: senderUserData.name,
          messageType: messageEnum,
          isGroupChat: isGroupChat,
          messageReply: messageReply);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIFMessage(
      {required BuildContext context,
      required String gifUrl,
      required String recieverUserId,
      required UserModel senderUser,
      required bool isGroupChat,
      required MessageReply? messageReply}) async {
    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      GroupModel? groupModel;
      if (isGroupChat) {
        var groupDoc =
            await firestore.collection('groups').doc(recieverUserId).get();
        groupModel = GroupModel.fromMap(groupDoc.data()!);
      }
      saveDataToContactsSubcollection(
        senderUser,
        recieverUserData,
        isGroupChat ? groupModel : null,
        'GIF',
        timeSent,
        isGroupChat,
      );

      saveMessageToMessageSubcollection(
          recieverUserId: recieverUserId,
          text: gifUrl,
          timeSent: timeSent,
          messageType: MessageEnum.gif,
          messageId: messageId,
          username: senderUser.name,
          isGroupChat: isGroupChat,
          messageReply: messageReply);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(BuildContext context, String recieverUserId,
      String messageId, bool isGroup) async {
    try {
      // update unseen messages
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId) // group if is isGroup
          .update({"unseenMessages": 0});

      if (isGroup) {
        // group -> group id -> messages -> message id -> update message
        await firestore
            .collection('groups')
            .doc(recieverUserId) // group id
            .collection('messages')
            .doc(messageId)
            .update({'isSeen': true});

        // update unseen messages
        await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .collection('chats')
            .doc(recieverUserId) // group if is isGroup
            .update({"unseenMessages": 0});
      } else {
        // users -> user id -> reciever id -> messages -> message id -> store message
        await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .collection('chats')
            .doc(recieverUserId)
            .collection('messages')
            .doc(messageId)
            .update({'isSeen': true});

        // users -> reciever id  -> sender id -> messages -> message id -> update message
        await firestore
            .collection('users')
            .doc(recieverUserId)
            .collection('chats')
            .doc(auth.currentUser!.uid)
            .collection('messages')
            .doc(messageId)
            .update({'isSeen': true});
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
