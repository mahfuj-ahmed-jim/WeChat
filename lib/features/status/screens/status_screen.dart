import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/features/status/controller/status_controller.dart';
import 'package:wechat/features/status/widgets/status_list.dart';
import 'package:wechat/models/show_status.dart';

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<ShowStatus> seenList = [], unSeenList = [], myStatus = [];
    return StreamBuilder<List<ShowStatus>>(
        stream: ref.read(statusControllerProvider).getStatus(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          seenList = [];
          unSeenList = [];
          myStatus = [];
          for (var data in snapshot.data!) {
            if (data.userId == FirebaseAuth.instance.currentUser!.uid) {
              data.userName = 'My status';
              myStatus.add(data);
            } else {
              if (data.isSeen) {
                seenList.add(data);
              } else {
                unSeenList.add(data);
              }
            }
          }
          return SingleChildScrollView(
            child: ListView(
              primary: false,
              shrinkWrap: true,
              children: [
                myStatus.isNotEmpty
                    ? StatusList(true, myStatus)
                    : const SizedBox(),
                unSeenList.isNotEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          '    Recent update',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      )
                    : const SizedBox(),
                unSeenList.isNotEmpty
                    ? StatusList(false, unSeenList)
                    : const SizedBox(),
                seenList.isNotEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          '    Viewed update',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      )
                    : const SizedBox(),
                seenList.isNotEmpty
                    ? StatusList(true, seenList)
                    : const SizedBox()
              ],
            ),
          );
        });
  }
}
