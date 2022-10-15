import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wechat/features/status/screens/story_view_screen.dart';
import 'package:wechat/models/show_status.dart';

class StatusList extends ConsumerWidget {
  final bool isSeen;
  final List<ShowStatus> statusList;
  const StatusList(this.isSeen, this.statusList, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      //physics: const ClampingScrollPhysics(),
      primary: false,
      itemCount: statusList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: index == 0 ? const EdgeInsets.only(top: 8) : EdgeInsets.zero,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, StoryViewScreen.routeName,
                      arguments: statusList[index]);
                },
                child: ListTile(
                  title: Text(
                    statusList[index].userName,
                    maxLines: 1,
                    style: const TextStyle(
                        overflow: TextOverflow.ellipsis, fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      maxLines: 1,
                      DateFormat('hh:mm a').format(statusList[index]
                          .statusList[statusList[index].statusList.length - 1]
                          .createdAt),
                      style: const TextStyle(
                          color: Colors.grey,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 14),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isSeen ? Colors.blueGrey : Colors.blue,
                    radius: 32,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        statusList[index]
                            .statusList[statusList[index].statusList.length - 1]
                            .url,
                      ),
                      radius: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
