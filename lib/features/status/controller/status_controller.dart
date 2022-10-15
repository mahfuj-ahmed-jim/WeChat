import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/features/status/repository/status_repository.dart';
import 'package:wechat/models/show_status.dart';

final statusControllerProvider = Provider(((ref) {
  final statusRepository = ref.read(statusRepositoryProvider);
  return StatusController(statusRepository: statusRepository, ref: ref);
}));

class StatusController {
  final StatusRepository statusRepository;
  final ProviderRef ref;

  StatusController({required this.statusRepository, required this.ref});

  void uploadStatus(
      {required File file,
      required MessageEnum type,
      required String caption,
      required List<String> whoCanSee,
      required BuildContext context}) {
    statusRepository.uploadStatus(
        file: file,
        type: type,
        caption: caption,
        whoCanSee: whoCanSee,
        context: context);
  }

  Stream<List<ShowStatus>> getStatus(BuildContext context) {
    return statusRepository.getStatus(context);
  }
}
