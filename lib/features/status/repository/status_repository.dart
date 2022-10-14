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
import 'package:wechat/models/contact_status.dart';
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
          url: url,
          type: type,
          caption: caption,
          createdAt: DateTime.now(),
          statusId: statusId,
          whoCanSee: whoCanSee);
      await firestore
          .collection('status')
          .doc('users')
          .collection(userId)
          .doc(statusId)
          .set(status.toMap());
      Navigator.pop(context);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<ContactStatus>> getStatus(BuildContext context) async {
    List<ContactStatus> statses = [];

    try {
      var userCollection =
          await firestore.collection('users').get(); // users list from firebase
      for (var document in userCollection.docs) {
        var userData =
            UserModel.fromMap(document.data()); // convert to userModel class
        String? name = await ref
            .read(selectContactControllerProvider)
            .checkSavedUser(userData
                .phoneNumber); // checking if exist in mobile contact or not
        if (name != null) {
          try {
            var snapShot = await firestore
                .collection('status')
                .doc('users')
                .collection(userData.uid)
                .orderBy('createdAt')
                .where('createdAt',
                    isGreaterThan: DateTime.now()
                        .subtract(const Duration(hours: 24))
                        .millisecondsSinceEpoch)
                .get();
            ContactStatus contactStatus = ContactStatus(
                uid: userData.uid, name: name, profilePic: userData.profilePic);
            if (snapShot.docs.isNotEmpty) {
              for (var tempStatus in snapShot.docs) {
                var status = StatusModel.fromMap(tempStatus.data());
                if(status.whoCanSee.contains(auth.currentUser!.uid)){
                  contactStatus.addStatusList(status);
                }
              }
              if(contactStatus.statusList.isNotEmpty){
                statses.add(contactStatus);
              }
            }
          } catch (e) {
            //
          }
        }
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }

    return statses;
  }
}
