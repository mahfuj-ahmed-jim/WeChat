import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/features/chat/screens/mobile_chat_screen.dart';
import 'package:wechat/models/user_model.dart';

final selectedGroupContacts = StateProvider<List<UserModel>>((ref) => []);

class SelectedContact extends ConsumerStatefulWidget {
  final List<UserModel> contactList;
  final bool isGroup;
  const SelectedContact(
      {super.key, required this.contactList, required this.isGroup});

  @override
  ConsumerState<SelectedContact> createState() => _SelectedContactState();
}

class _SelectedContactState extends ConsumerState<SelectedContact> {
  List<int> selectedIndex = [];

  void chatScreen(BuildContext context, int index) {
    Navigator.pushNamed(
      context,
      MobileChatScreen.routeName,
      arguments: {
        'name': widget.contactList[index].name,
        'uid': widget.contactList[index].uid,
        'isGroupChat': false,
        'profilePic': widget.contactList[index].profilePic,
      },
    );
  }

  void selectContacts(int index, UserModel userModel) {
    if (selectedIndex.contains(index)) {
      selectedIndex.remove(index);
    } else {
      selectedIndex.add(index);
    }
    setState(() {});
    ref
        .read(selectedGroupContacts.state)
        .update((state) => [...state, userModel]);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: widget.contactList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding:
              index == 0 ? const EdgeInsets.only(top: 10) : EdgeInsets.zero,
          child: Column(
            children: [
              Container(
                color: selectedIndex.contains(index)
                    ? tabColor.withOpacity(0.2)
                    : backgroundColor,
                child: InkWell(
                  onTap: () {
                    !widget.isGroup
                        ? chatScreen(context, index)
                        : selectContacts(index, widget.contactList[index]);
                  },
                  child: ListTile(
                    title: Text(
                      widget.contactList[index].name,
                      maxLines: 1,
                      style: const TextStyle(
                          overflow: TextOverflow.ellipsis, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        maxLines: 1,
                        widget.contactList[index].status,
                        style: const TextStyle(
                            color: Colors.grey,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 14),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        widget.contactList[index].profilePic,
                      ),
                      radius: 30,
                    ),
                  ),
                ),
              ),
              const Divider(color: dividerColor, indent: 85)
            ],
          ),
        );
      },
    );
  }
}
