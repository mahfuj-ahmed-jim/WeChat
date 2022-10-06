import 'package:flutter/material.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/features/chat/widgets/display_message.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum type;
  final String username;
  final bool isSeen;
  final bool previousMessage;

  const MyMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    required this.username,
    required this.isSeen,
    required this.previousMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45, minWidth: 160),
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8))),
          color: messageColor,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: previousMessage? 1.5 : 6),
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
                child: Row(
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: type == MessageEnum.text
                            ? Colors.white60
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.done_all,
                      size: 20,
                      color: type == MessageEnum.text
                          ? Colors.white60
                          : Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
