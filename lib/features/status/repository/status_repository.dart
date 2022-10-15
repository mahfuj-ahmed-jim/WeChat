// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/common/repositories/common_firebase_storage_repository.dart';
import 'package:wechat/common/utils/utils.dart';
import 'package:wechat/features/select_contact/controller/select_contacts_controller.dart';
import 'package:wechat/models/show_status.dart';
import 'package:wechat/models/status_model.dart';
import 'package:wechat/models/user_model.dart';

final statusRepositoryProvider = Provider(((ref) => StatusRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref)));

class StatusRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  StatusRepository(
      {required this.firestore, required this.auth, required this.ref});

  void uploadStatus(
      {required File file,
      required MessageEnum type,
      required String caption,
      required List<String> whoCanSee,
      required BuildContext context}) async {
    try {
      String statusId = const Uuid().v1();
      String userId = auth.currentUser!.uid;
      String url = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase('/status/$userId/${type.type}/$statusId', file);

      StatusModel status = StatusModel(
          userId: userId,
          url: url,
          type: type,
          caption: caption,
          createdAt: DateTime.now(),
          statusId: statusId,
          whoCanSee: whoCanSee,
          seen: []);

      await firestore.collection('status').doc(statusId).set(status.toMap());

      Navigator.pop(context);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<List<ShowStatus>> getStatus(BuildContext context) {
    return firestore
        .collection('status')
        .orderBy('createdAt')
        .where(
          'createdAt',
          isGreaterThan: DateTime.now()
              .subtract(const Duration(hours: 24))
              .millisecondsSinceEpoch,
        )
        .snapshots()
        .asyncMap((event) async {
      List<ShowStatus> statses = [];
      for (var document in event.docs) {
        var status = StatusModel.fromMap(document.data());
        var userDocuments =
            await firestore.collection('users').doc(status.userId).get();
        var userData = UserModel.fromMap(userDocuments.data()!);

        String? name = await ref
            .read(selectContactControllerProvider)
            .checkSavedUser(userData.phoneNumber);

        if (name != null && status.whoCanSee.contains(auth.currentUser!.uid)) {
          bool found = false;
          for (int i = 0; i < statses.length; i++) {
            if (statses[i].userId == userData.uid) {
              statses[i].addStatus(status);
              found = true;
              if (!status.seen.contains(auth.currentUser!.uid)) {
                statses[i].statusSeen(false);
              }
              break;
            }
          }
          if (!found) {
            ShowStatus showStatus = ShowStatus(
                userId: userData.uid,
                userName: name,
                profilePic: userData.profilePic);
            if (!status.seen.contains(auth.currentUser!.uid)) {
              showStatus.statusSeen(false);
            }
            showStatus.addStatus(status);
            statses.add(showStatus);
          }
        }
      }
      return statses;
    });
  }
}
