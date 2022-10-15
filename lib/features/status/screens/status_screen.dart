import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/features/status/controller/status_controller.dart';
import 'package:wechat/models/show_status.dart';

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ShowStatus>>(
        stream: ref.read(statusControllerProvider).getStatus(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: index == 0
                    ? const EdgeInsets.only(top: 10)
                    : EdgeInsets.zero,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: ListTile(
                        title: Text(
                          snapshot.data![index].userName,
                          maxLines: 1,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            maxLines: 1,
                            DateFormat('hh:mm a').format(snapshot
                                .data![index]
                                .statusList[
                                    snapshot.data![index].statusList.length - 1]
                                .createdAt),
                            style: const TextStyle(
                                color: Colors.grey,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 14),
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: snapshot.data![index].isSeen
                              ? Colors.blueGrey
                              : Colors.blue,
                          radius: 32,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              snapshot
                                  .data![index]
                                  .statusList[
                                      snapshot.data![index].statusList.length -
                                          1]
                                  .url,
                            ),
                            radius: 26,
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
        });
  }
}
