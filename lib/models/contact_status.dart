import 'package:wechat/models/status_model.dart';

class ContactStatus {
  String? uid;
  String? name;
  String? profilePic;
  List<StatusModel> statusList = [];

  ContactStatus({required this.statusList});

  addStatusList(StatusModel statusModel) {
    statusList.add(statusModel);
  }

  Map<String, dynamic> toMap() {
    return {
      'statusList': statusList.map((StatusModel) => StatusModel.toMap()).toList(),
    };
  }

  factory ContactStatus.fromMap(Map<String, dynamic> map) {
    return ContactStatus(
      statusList: List<StatusModel>.from(map['statusList']),
    );
  }
}
