import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/services/functions/auth_functions.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const databaseId = '64225d940a814ce2a13c';
const collectionUsersId = '64225dbbc19a15f6c9b0';
const collectionGroupsId = '64228e6e8336f92502c1';
const collectionMessagesId = '6423af82ee34f9662593';

class DatabaseService extends ChangeNotifier {
  final String? uid;
  DatabaseService({this.uid});
  Databases databases = Databases(client);

  // static saveUser(String name, email, uid) async {
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .set({'email': email, 'name': name});
  // }

  Future savingUserData(String fullName, String email) async {
    return await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionUsersId,
        documentId: uid!,
        data: {
          "fullName": fullName,
          "email": email,
          "groups": [],
          "profilePic": "",
          "uid": uid,
        });
  }

  // getting user data
  Future gettingUserData(String email) async {
    // QuerySnapshot snapshot =
    //     await userCollection.where("email", isEqualTo: email).get();
    // return snapshot;
  }

  // get user groups
  Future<Map<String, dynamic>> getUserGroups() async {
    final uid = await account.get();
    final documents = await databases.getDocument(
      databaseId: databaseId,
      collectionId: collectionUsersId,
      documentId: uid.$id,
    );
    return documents.data;
  }

  Future createGroup(BuildContext context, String groupName) async {
    String uuid = const Uuid().v4();
    try {
      final uid = await account.get();
      await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionGroupsId,
        documentId: uuid,
        data: {
          "groupName": groupName,
          "groupIcon": "",
          "admin": "${uid.$id}_${uid.name}",
          "members": ["${uid.$id}_${uid.name}"],
          "groupId": uuid,
          "recentMessage": "",
          "recentMessageSender": "",
          "recentMessageTime": "",
        },
      );

      final user = await databases.getDocument(
        databaseId: databaseId,
        collectionId: collectionUsersId,
        documentId: uid.$id,
      );
      List list = user.data['groups'];
      list.add("${uuid}_$groupName");
      await databases.updateDocument(
          databaseId: databaseId,
          collectionId: collectionUsersId,
          documentId: uid.$id,
          data: {
            "groups": list,
          });
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Group created successfully."),
        backgroundColor: Colors.green,
      ));
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  Future<DocumentList> getChats(String groupId) async {
    return databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionMessagesId,
        queries: [Query.equal('groupId', groupId)]);
  }

  Future getGroupAdmin(String groupId) async {
    final group = await databases.getDocument(
      databaseId: databaseId,
      collectionId: collectionGroupsId,
      documentId: groupId,
    );

    return group.data['admin'];
  }

  getGroupMembers(groupId) async {
    return await databases.getDocument(
      databaseId: databaseId,
      collectionId: collectionGroupsId,
      documentId: groupId,
    );
  }

  // search
  Future<DocumentList> searchByName(String groupName) {
    return databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionGroupsId,
        queries: [Query.equal('groupName', groupName)]);
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    final uid = await account.get();

    final document = await databases.getDocument(
      databaseId: databaseId,
      collectionId: collectionUsersId,
      documentId: uid.$id,
    );

    List groups = await document.data['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    final uid = await account.get();

    final user = await databases.getDocument(
      databaseId: databaseId,
      collectionId: collectionUsersId,
      documentId: uid.$id,
    );

    final group = await databases.getDocument(
      databaseId: databaseId,
      collectionId: collectionGroupsId,
      documentId: groupId,
    );

    List<dynamic> groups = await user.data['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await databases.updateDocument(
          databaseId: databaseId,
          collectionId: collectionUsersId,
          documentId: uid.$id,
          data: {
            "groups": ["${groupId}_$groupName"]
          });
      await databases.updateDocument(
          databaseId: databaseId,
          collectionId: collectionGroupsId,
          documentId: groupId,
          data: {
            "members": ["${uid}_$userName"]
          });
    } else {
      await databases.updateDocument(
          databaseId: databaseId,
          collectionId: collectionUsersId,
          documentId: uid.$id,
          data: {
            "groups": ["${groupId}_$groupName"]
          });
      await databases.updateDocument(
          databaseId: databaseId,
          collectionId: collectionGroupsId,
          documentId: groupId,
          data: {
            "members": ["${uid}_$userName"]
          });
    }
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    String uuid = const Uuid().v4();

    await databases.createDocument(
      databaseId: databaseId,
      collectionId: collectionMessagesId,
      documentId: uuid,
      data: chatMessageData,
    );
    await databases.updateDocument(
        databaseId: databaseId,
        collectionId: collectionGroupsId,
        documentId: groupId,
        data: {
          "recentMessage": chatMessageData['message'],
          "recentMessageSender": chatMessageData['sender'],
          "recentMessageTime": chatMessageData['time'].toString(),
        });
  }
}
