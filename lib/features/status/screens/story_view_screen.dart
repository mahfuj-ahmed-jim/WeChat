import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/models/show_status.dart';

class StoryViewScreen extends StatefulWidget {
  static const String routeName = '/story-views-screen';
  final ShowStatus statuses;
  const StoryViewScreen({super.key, required this.statuses});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  StoryController storyController = StoryController();
  String? caption, time;
  List<StoryItem> stories = [];

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
          caption: widget.statuses.statusList[i].caption));
    }
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
                          const Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: Text(
                              'Just Now',
                              maxLines: 1,
                              style: TextStyle(
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
