import 'package:flutter/material.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/features/chat/widgets/display_message.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    required this.repliedText,
    required this.username,
    required this.repliedMessageType,
    required this.previousMessage,
  }) : super(key: key);
  final String message;
  final String date;
  final MessageEnum type;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;
  final bool previousMessage;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: type != MessageEnum.text
                ? BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 70,
                    minWidth: 160,
                    maxHeight: (MediaQuery.of(context).size.height / 2) - 70)
                : BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 45,
                    minWidth: 160,
                  ),
            child: Card(
              elevation: 1,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8))),
              color: senderMessageColor,
              margin: EdgeInsets.symmetric(
                  horizontal: 15, vertical: previousMessage ? 1.5 : 5),
              child: Stack(
                children: [
                  Padding(
                    padding: type == MessageEnum.text
                        ? const EdgeInsets.only(
                            left: 10.5,
                            right: 10.5,
                            top: 6,
                            bottom: 25,
                          )
                        : const EdgeInsets.all(2),
                    child: DisplayMessage(
                      message: message,
                      type: type,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 10,
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: type == MessageEnum.text
                            ? Colors.white60
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          type == MessageEnum.text
              ? Container()
              : IconButton(
                  onPressed: (() {}),
                  icon: const Icon(Icons.share),
                ),
        ],
      ),
    );
  }
}
