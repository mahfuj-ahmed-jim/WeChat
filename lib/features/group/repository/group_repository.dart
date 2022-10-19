import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat/common/repositories/common_firebase_storage_repository.dart';
import 'package:wechat/common/utils/utils.dart';
import 'package:wechat/features/chat/controller/chat_controller.dart';
import 'package:wechat/models/group_model.dart';
import 'package:wechat/models/user_model.dart';

final groupRepositoryProvider = Provider((ref) => GroupRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref));

class GroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  GroupRepository(
      {required this.firestore, required this.auth, required this.ref});

  Future<GroupModel?> createGroup(
      {required BuildContext context,
      required String name,
      required File? file,
      required List<UserModel> userList}) async {
    GroupModel? group;

    try {
      List<String> userIds = [];
      for (var user in userList) {
        userIds.add(user.uid);
      }
      var groupId = const Uuid().v1();

      String profileUrl;
      if (file == null) {
        profileUrl =
            'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';
      } else {
        profileUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'group/$groupId',
              file,
            );
      }

      List<String> admins = [auth.currentUser!.uid];

      group = GroupModel(
          senderId: auth.currentUser!.uid,
          name: name,
          groupId: groupId,
          lastMessage: '',
          groupPic: profileUrl,
          membersUid: [auth.currentUser!.uid, ...userIds],
          admins: admins,
          timeSent: DateTime.now());
      await firestore.collection('groups').doc(groupId).set(group.toMap());

      var userData =
          await firestore.collection('users').doc(auth.currentUser?.uid).get();
      var senderUserData = UserModel.fromMap(userData.data()!);

      ref.read(chatControllerProvider).saveDataToContactsSubcollection(
          senderUserData,
          null,
          group,
          '${senderUserData.name} created the group',
          DateTime.now(),
          true);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
    return group;
  }

  Future<GroupModel> getGroupDetails(
      {required String groupId}) async {
    GroupModel? groupModel;

    try {
      var doc = await firestore.collection('groups').doc(groupId).get();
      groupModel = GroupModel.fromMap(doc.data()!);
    } catch (e) {
      //
    }

    return groupModel!;
  }
  
}
