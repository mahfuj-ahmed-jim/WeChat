import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/common/widgets/error.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/features/select_contact/controller/select_contacts_controller.dart';
import 'package:wechat/features/status/controller/status_controller.dart';

class ConfirmStatusScreen extends ConsumerStatefulWidget {
  static const String routeName = '/confirm-status-screen';
  final File file;
  const ConfirmStatusScreen(this.file, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConfirmStatusScreenState();
}

class _ConfirmStatusScreenState extends ConsumerState<ConfirmStatusScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool wideImage = false;
  bool isShowEmojiContainer = false;
  FocusNode focusNode = FocusNode();

  void isWidder() async {
    var decodedImage = await decodeImageFromList(widget.file.readAsBytesSync());
    if (decodedImage.width >= decodedImage.height) {
      setState(() {
        wideImage = true;
      });
    }
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  void uploadStatus() {
    ref.read(getSelectContactProvider).when(
        data: (contactList) {
          List<String> whoCanSee = [];
          for (var list in contactList) {
            whoCanSee.add(list.uid);
          }
          ref.read(statusControllerProvider).uploadStatus(
              file: widget.file,
              type: MessageEnum.image,
              caption: _messageController.text.trim(),
              whoCanSee: whoCanSee,
              context: context);
        },
        error: (err, trace) => ErrorScreen(error: err.toString()),
        loading: (() => const Loader()));
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isWidder();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const Center(
            child: Loader(),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: wideImage ? BoxFit.fitWidth : BoxFit.cover,
                    image: FileImage(widget.file))),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: isShowEmojiContainer ? 0 : 30),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        focusNode: focusNode,
                        controller: _messageController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: SizedBox(
                              width: 50,
                              child: IconButton(
                                onPressed: () {
                                  toggleEmojiKeyboardContainer();
                                },
                                icon: const Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          hintText: 'Add a caption',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                        right: 2,
                        left: 2,
                      ),
                      child: GestureDetector(
                        onTap: (() => uploadStatus()),
                        child: const CircleAvatar(
                          backgroundColor: tabColor,
                          radius: 25,
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              isShowEmojiContainer
                  ? SizedBox(
                      height: 310,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          setState(() {
                            _messageController.text =
                                _messageController.text + emoji.emoji;
                          });
                        },
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ],
      ),
    );
  }
}
