import 'package:wechat/models/status_model.dart';

class ContactStatus {
  String uid;
  String name;
  String profilePic;
  List<StatusModel> statusList = [];

  ContactStatus(
      {required this.uid, required this.name, required this.profilePic});

  // ignore: no_leading_underscores_for_local_identifiers
  setlastStory(DateTime? _lastStory) {}

  addStatusList(StatusModel statusModel) {
    statusList.add(statusModel);
  }
}
