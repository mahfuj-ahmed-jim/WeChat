import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/features/chat/widgets/video_player.dart';

class DisplayMessage extends StatefulWidget {
  final String message;
  final MessageEnum type;

  const DisplayMessage({
    Key? key,
    required this.message,
    required this.type,
  }) : super(key: key);

  @override
  State<DisplayMessage> createState() => _DisplayMessageState();
}

class _DisplayMessageState extends State<DisplayMessage> {
  bool isAudioPlaying = false;
  final AudioPlayer audioPlayer = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return widget.type == MessageEnum.text
        ? Text(
            widget.message,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
        : widget.type == MessageEnum.image
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.message,
                ),
              )
            : widget.type == MessageEnum.gif
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: widget.message,
                    ),
                  )
                : widget.type == MessageEnum.audio
                    ? StatefulBuilder(builder: (context, setState) {
                        return IconButton(
                            onPressed: () async {
                              if (isAudioPlaying) {
                                await audioPlayer.pause();
                              } else {
                                await audioPlayer
                                    .play(UrlSource(widget.message));
                              }
                              setState(() {
                                isAudioPlaying = !isAudioPlaying;
                              });
                            },
                            icon: Icon(isAudioPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle));
                      })
                    : VideoPlayer(
                        videoUrl: widget.message,
                      );
  }
}
