import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wechat/common/widgets/error.dart';
import 'package:wechat/features/auth/screens/login_screen.dart';
import 'package:wechat/features/auth/screens/otp_screen.dart';
import 'package:wechat/features/auth/screens/user_information_screen.dart';
import 'package:wechat/features/chat/screens/mobile_chat_screen.dart';
import 'package:wechat/features/select_contact/screens/select_contacts_screen.dart';
import 'package:wechat/features/status/screens/confirm_status_screen.dart';
import 'package:wechat/features/status/screens/story_view_screen.dart';
import 'package:wechat/models/status_model.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OTPScreen(
          verificationId: verificationId,
        ),
      );
    case UserInformationScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const UserInformationScreen(),
      );
    case SelectContactsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const SelectContactsScreen(),
      );
    case StoryViewScreen.routeName:
      final statuses = settings.arguments as List<StatusModel>;
      return MaterialPageRoute(
        builder: (context) => StoryViewScreen(
          statuses: statuses,
        ),
      );
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      final isGroupChat = arguments['isGroupChat'];
      final profilePic = arguments['profilePic'];
      return MaterialPageRoute(
        builder: (context) => MobileChatScreen(
          name: name,
          uid: uid,
          isGroupChat: isGroupChat,
          profilePic: profilePic,
        ),
      );
    case ConfirmStatusScreen.routeName:
      final file = settings.arguments as File;
      return MaterialPageRoute(builder: (context) => ConfirmStatusScreen(file));
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: ErrorScreen(error: 'This page doesn\'t exist'),
        ),
      );
  }
}
