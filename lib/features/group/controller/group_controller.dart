import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat/features/group/repository/group_repository.dart';
import 'package:wechat/models/group_model.dart';
import 'package:wechat/models/user_model.dart';

final groupControllerProvider = Provider(((ref) {
  final groupRepository = ref.read(groupRepositoryProvider);
  return GroupController(groupRepository: groupRepository, ref: ref);
}));

class GroupController {
  final GroupRepository groupRepository;
  final ProviderRef ref;

  GroupController({required this.groupRepository, required this.ref});

  Future<GroupModel?> createGroup(
      {required BuildContext context,
      required String name,
      required File? file,
      required List<UserModel> userList}) {
    return groupRepository.createGroup(
        context: context, name: name, file: file, userList: userList);
  }
}
