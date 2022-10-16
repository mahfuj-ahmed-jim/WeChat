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

  Future<bool> checkUserGotAccount(String userNumber) async {
    bool isFound = false;
    try {
      var userCollection =
          await firestore.collection('users').get(); // users list from firebase
      for (var document in userCollection.docs) {
        var userData =
            UserModel.fromMap(document.data()); // convert to userModel class
        if (userData.phoneNumber == userNumber) {
          isFound = true;
          break;
        }
      }
    } catch (e) {
      //
    }
    return isFound;
  }

  Future<List<UserModel>> selectContact() async {
    List<UserModel> userList = [];
    try {
      var userCollection =
          await firestore.collection('users').get(); // users list from firebase
      for (var document in userCollection.docs) {
        var userData =
            UserModel.fromMap(document.data()); // convert to userModel class
        String? name = await checkSavedUser(
            userData.phoneNumber); // checking if exist in mobile contact or not
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

  Future<List<Contact>> unselectContact() async {
    List<Contact> unselectContact = [];
    var contacts = await getContacts();
    for (var contact in contacts) {
      for (var numbers in contact.phones) {
        if (!await checkUserGotAccount(
            numbers.number.replaceAll('-', '').replaceAll(' ', ''))) {
          unselectContact.add(contact);
        }
      }
    }
    return unselectContact;
  }
}
