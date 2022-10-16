import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:story_view/story_view.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/features/status/controller/status_controller.dart';
import 'package:wechat/models/show_status.dart';
import 'package:wechat/models/status_model.dart';

class StoryViewScreen extends ConsumerStatefulWidget {
  static const String routeName = '/story-views-screen';
  final ShowStatus statuses;
  const StoryViewScreen({super.key, required this.statuses});

  @override
  // ignore: no_logic_in_create_state
  ConsumerState<StoryViewScreen> createState() =>
      // ignore: no_logic_in_create_state
      _StoryViewScreenState(statuses);
}

class _StoryViewScreenState extends ConsumerState<StoryViewScreen> {
  StoryController storyController = StoryController();
  String? caption;
  List<StoryItem> stories = [];
  String? time;
  bool isBuild = false;

  _StoryViewScreenState(ShowStatus statuses) {
    time = DateFormat('hh:mm a').format(statuses.statusList[0].createdAt);
  }

  @override
  void initState() {
    super.initState();
    initStoryPageItem();
  }

  @override
  void dispose() {
    super.dispose();
    storyController.dispose();
  }

  void initStoryPageItem() {
    for (int i = 0; i < widget.statuses.statusList.length; i++) {
      stories.add(StoryItem.pageImage(
        url: widget.statuses.statusList[i].url,
        controller: storyController,
        caption: widget.statuses.statusList[i].caption,
      ));
    }
  }

  void seenStatus(StatusModel statusModel) {
    ref.read(statusControllerProvider).seenStatus(statusModel: statusModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: stories.isEmpty
          ? const Loader()
          : Stack(
              children: [
                StoryView(
                  storyItems: stories,
                  controller: storyController,
                  onVerticalSwipeComplete: (direction) {
                    if (direction == Direction.down) {
                      Navigator.pop(context);
                    }
                  },
                  onComplete: () => Navigator.pop(context),
                  onStoryShow: (value) {
                    int position = stories.indexOf(value);
                    position != 0 ? isBuild = true : null;
                    if (isBuild) {
                      setState(() {
                        time = DateFormat('hh:mm a').format(
                            widget.statuses.statusList[position].createdAt);
                      });
                    }
                    seenStatus(widget.statuses.statusList[position]);
                  },
                ),
                Positioned(
                  top: 70,
                  left: 15,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        radius: 28,
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.statuses.profilePic),
                          radius: 26,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.statuses.userName,
                              maxLines: 1,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 18)),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              '$time',
                              maxLines: 1,
                              style: const TextStyle(
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
