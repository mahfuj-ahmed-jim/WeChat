import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/features/chat/widgets/video_player.dart';

class DisplayMessage extends StatelessWidget {
  final String message;
  final MessageEnum type;
  const DisplayMessage({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return type == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
        : type == MessageEnum.image
            ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                  imageUrl: message,
                ),
            )
            : VideoPlayer(
                videoUrl: message,
              );
  }
}
