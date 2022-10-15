import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/models/status_model.dart';

class StoryViewScreen extends StatefulWidget {
  static const String routeName = '/story-views-screen';
  final List<StatusModel> statuses;
  const StoryViewScreen({super.key, required this.statuses});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  StoryController storyController = StoryController();
  List<StoryItem> stories = [];

  @override
  void initState() {
    super.initState();
    initStoryPageItem();
  }

  void initStoryPageItem() {
    for (int i = 0; i < widget.statuses.length; i++) {
      stories.add(StoryItem.pageImage(
          url: widget.statuses[i].url, controller: storyController));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: stories.isEmpty
          ? const Loader()
          : StoryView(
              storyItems: stories,
              controller: storyController,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              }),
    );
  }
}
