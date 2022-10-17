import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat/common/repositories/common_firebase_storage_repository.dart';
import 'package:wechat/common/utils/utils.dart';
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

  void createGroup(
      {required BuildContext context,
      required String name,
      required File? file,
      required List<UserModel> userList}) async {
    try {
      print('1');
      List<String> userIds = [];
      for (var user in userList) {
        userIds.add(user.uid);
        print(user.uid);
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
      GroupModel group = GroupModel(
          senderId: auth.currentUser!.uid,
          name: name,
          groupId: groupId,
          lastMessage: '',
          groupPic: profileUrl,
          membersUid: [auth.currentUser!.uid, ...userIds],
          admins: admins,
          timeSent: DateTime.now());
      await firestore.collection('groups').doc(groupId).set(group.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
