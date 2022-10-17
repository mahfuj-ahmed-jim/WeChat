import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/common/widgets/error.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/features/select_contact/controller/select_contacts_controller.dart';
import 'package:wechat/features/select_contact/widget/selected_contacts.dart';

class SelectContactsScreen extends ConsumerWidget {
  static const String routeName = '/select-contact';
  const SelectContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select contact'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: ref.watch(getSelectContactProvider).when(
            data: (contactList) => ListView(
              primary: false,
              children: [
                contactList.isNotEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          '    Contact on WeChat',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      )
                    : const SizedBox(),
                SelectedContact(contactList: contactList, isGroup: false),
                ref.watch(unselectContactControllerProvider).when(
                    data: (unselectContactList) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            unselectContactList.isNotEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Text(
                                      '    Invite to WeChat',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15),
                                    ),
                                  )
                                : const SizedBox(),
                            ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                itemCount: unselectContactList.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: (() {}),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Text(
                                              unselectContactList[index]
                                                  .displayName,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Colors.grey[350],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                              onPressed: () {},
                                              child: const Text(
                                                'Invite',
                                                style:
                                                    TextStyle(color: tabColor),
                                              ))
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                    error: (err, trace) => const SizedBox(),
                    loading: (() => const SizedBox()))
              ],
            ),
            error: (err, trace) => ErrorScreen(error: err.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
