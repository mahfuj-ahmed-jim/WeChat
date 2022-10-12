import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat/models/user_model.dart';

final selectContactsRepositoryProvider = Provider(
  (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({
    required this.firestore,
  });

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  Future<String?> checkSavedUser(String userPhoneNumber) async {
    String? name;
    List<Contact> mobileContacts = await getContacts();
    for (var contact in mobileContacts) {
      for (var number in contact.phones) {
        if (userPhoneNumber ==
            number.number.replaceAll('-', '').replaceAll(' ', '')) {
          name = contact.displayName;
        }
      }
    }
    return name;
  }

  Future<List<UserModel>> selectContact() async {
    List<UserModel> userList = [];
    try {
      var userCollection = await firestore.collection('users').get();

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String? name = await checkSavedUser(userData.phoneNumber);
        if (name != null) {
          userData.setName(name);
          userList.add(userData);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return userList;
  }
}
