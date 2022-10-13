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
import 'package:wechat/models/status_model.dart';

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
                .doc('user')
                .collection(userId)
                .doc(statusId)
                .set(status.toMap());
            Navigator.pop(context);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
