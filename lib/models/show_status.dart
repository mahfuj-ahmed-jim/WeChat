import 'package:wechat/models/status_model.dart';

class ShowStatus {
  final String userId;
  String userName;
  final String profilePic;
  bool isSeen = true;
  List<StatusModel> statusList = [];

  ShowStatus(
      {required this.userId, required this.userName, required this.profilePic});

  void addStatus(StatusModel statusModel) {
    statusList.add(statusModel);
  }

  void statusSeen(bool seen) {
    isSeen = seen;
  }
}
