import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/common/provider/message_reply_provider.dart';
import 'package:wechat/features/chat/widgets/display_message.dart';

class MessageReplyPreview extends ConsumerWidget {
  final String name;
  const MessageReplyPreview(this.name, {Key? key}) : super(key: key);

  void cancelReply(WidgetRef ref) {
    ref.read(messageReplyProvider.state).update((state) => null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  messageReply!.isMe
                      ? 'Replying to yourself'
                      : 'Replying to $name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
                onTap: () => cancelReply(ref),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: messageReply.messageEnum == MessageEnum.text
                    ? MediaQuery.of(context).size.width
                    : 180,
                minWidth: 60,
                maxHeight: messageReply.messageEnum == MessageEnum.text
                    ? MediaQuery.of(context).size.height
                    : 120),
            child: Opacity(
              opacity: 0.7,
              child: DisplayMessage(
                message: messageReply.message,
                type: messageReply.messageEnum,
                isReply: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
