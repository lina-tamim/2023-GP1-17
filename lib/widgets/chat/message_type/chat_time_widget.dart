import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Models/message.dart';
import '../../../utils/app_images.dart';
import '../../../utils/functions/public_methods.dart';
import '../../../utils/functions/time_functions.dart';

class ChatTimeWidget extends StatelessWidget {
  const ChatTimeWidget({required this.message, required this.isMe, Key? key})
      : super(key: key);

  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            TimeFunctions.timeInDigits(message.timestamp),
            style: isMe || true
                ? const TextStyle(color: Colors.white70, fontSize: 12)
                : TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .color!
                        .withOpacity(1),
                    fontSize: 12,
                  ),
          ),
          const SizedBox(width: 10),
          if (message.sendBy == getUid())
            SizedBox(
              height: 8,
              child: Image.asset(
                message.sendTo[0].seen
                    ? AppImages.doubleTickBlue
                    : AppImages.doubleTickGrey,
                color: message.sendTo[0].seen ? Colors.blue : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
