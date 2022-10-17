// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/common/utils/utils.dart';
import 'package:wechat/common/widgets/error.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/features/chat/screens/mobile_chat_screen.dart';
import 'package:wechat/features/group/controller/group_controller.dart';
import 'package:wechat/features/select_contact/controller/select_contacts_controller.dart';
import 'package:wechat/features/select_contact/widget/selected_contacts.dart';
import 'package:wechat/models/group_model.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group';
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  File? image;
  final TextEditingController _groupNameController = TextEditingController();

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void createGoup() async {
    if (_groupNameController.text.trim().isNotEmpty) {
      GroupModel? groupModel = await ref
          .read(groupControllerProvider)
          .createGroup(
              context: context,
              name: _groupNameController.text.trim(),
              file: image,
              userList: ref.read(selectedGroupContacts));

      // coming bakc to the original state
      ref.read(selectedGroupContacts.state).update((state) => []);

      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        MobileChatScreen.routeName,
        arguments: {
          'name': groupModel!.name,
          'uid': groupModel.groupId,
          'isGroupChat': true,
          'profilePic': groupModel.groupPic,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Create Group'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(children: [
              image == null
                  ? const CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                      ),
                      radius: 64,
                    )
                  : CircleAvatar(
                      backgroundImage: FileImage(
                        image!,
                      ),
                      radius: 64,
                    ),
              Positioned(
                bottom: -10,
                left: 80,
                child: CircleAvatar(
                  backgroundColor: backgroundColor,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _groupNameController,
                decoration:
                    const InputDecoration(hintText: 'Enter group name '),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 12.00, left: 8),
              child: const Text(
                'Select Contacts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            ref.watch(getSelectContactProvider).when(
                  data: (contactList) =>
                      SelectedContact(contactList: contactList, isGroup: true),
                  error: (err, trace) => ErrorScreen(error: err.toString()),
                  loading: () => const Loader(),
                )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createGoup();
        },
        backgroundColor: tabColor,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}
