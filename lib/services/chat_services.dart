import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendMessage(
  String receiverUID,
  String message,
  
) async {
  final currentUser = _auth.currentUser!;

  final senderUID = currentUser.uid;
  final senderEmail = currentUser.email;
  Map<String, dynamic> newMessage = {
     'senderUID': senderUID,
     'senderEmail': senderEmail,
     'receiverUID': receiverUID,
     'message': message,
     'timestamp': Timestamp.now(),
     'isRead': false,
  };

  List<String> ids = [senderUID, receiverUID];
ids.sort();

String chatID = ids.join("_");

await _firestore
    .collection('chats')
    .doc(chatID)
    .collection('messages')
    .add(newMessage);
    await _firestore
    .collection('chats')
    .doc(chatID)
    .set(
      {
        'users': [senderUID, receiverUID],
        'lastMessage': message,
        'lastMessageTime': Timestamp.now(),
      },
      SetOptions(merge: true),
    );
 }

 Stream<QuerySnapshot> getMessages(
  String userUID,
  String otherUserUID,
) {
  List<String> ids = [userUID, otherUserUID];
  ids.sort();

  String chatID = ids.join("_");

  return _firestore
      .collection('chats')
      .doc(chatID)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots();
}
Stream<QuerySnapshot> getUserChats() {
  return _firestore
      .collection('chats')
      .where(
        'users',
        arrayContains: _auth.currentUser!.uid,
      )
      .orderBy(
        'lastMessageTime',
        descending: true,
      )
      .snapshots();
}
Future<DocumentSnapshot> getUserData(String uid) async {
  return await _firestore
      .collection('users')
      .doc(uid)
      .get();
}
Future<void> markMessagesAsRead(String otherUserUID) async {
  print("markMessagesAsRead called");
  final currentUserUID = _auth.currentUser!.uid;

  final ids = [currentUserUID, otherUserUID];
  ids.sort();

  final chatID = ids.join("_");

  final unreadMessages = await _firestore
      .collection("chats")
      .doc(chatID)
      .collection("messages")
      .where("receiverUID", isEqualTo: currentUserUID)
      .where("isRead", isEqualTo: false)
      .get();

  print("Unread messages: ${unreadMessages.docs.length}");

  for (var doc in unreadMessages.docs) {
    await doc.reference.update({
      "isRead": true,
    });
  }
}
}
