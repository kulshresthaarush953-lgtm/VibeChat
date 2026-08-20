import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibe_chat/services/chat_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String receiverName;
  final String receiverUID;
  const ChatScreen({
    super.key,
    required this.receiverName,
    required this.receiverUID,
  });

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ChatServices _chatServices = ChatServices();
  final ImagePicker _picker = ImagePicker();
  final currentUser = FirebaseAuth.instance.currentUser!;
  @override
void initState() {
  super.initState();

  _chatServices.markMessagesAsRead(
    widget.receiverUID,
  );
}
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection('users')
      .doc(widget.receiverUID)
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return Text(
        widget.receiverName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final data = snapshot.data!.data() as Map<String, dynamic>;

    final isOnline = data['isOnline'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.receiverName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        Text(
          isOnline ? "Online" : "Offline",
          style: TextStyle(
            color: isOnline ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  },
),
      ),
      body: 
      Column(
        children: [
          Expanded(
  child: StreamBuilder(
    stream: _chatServices.getMessages(
      currentUser.uid,
      widget.receiverUID,
    ),
    builder: (context, snapshot) {
 if (snapshot.hasError) {
  debugPrint("ERROR: ${snapshot.error}");

  return Center(
    child: Text(
      "${snapshot.error}",
      style: const TextStyle(color: Colors.white),
    ),
  );
}

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final messages = snapshot.data!.docs;
      WidgetsBinding.instance.addPostFrameCallback((_) {
  if (scrollController.hasClients) {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
});

      return ListView.builder(
        controller: ScrollController(),
        itemCount: messages.length,
        reverse: false,
        itemBuilder: (context, index) {
          final data =
              messages[index].data() as Map<String, dynamic>;
              final DateTime time =
    (data['timestamp'] as Timestamp).toDate();

final formattedTime =
    DateFormat('h:mm a').format(time);

          final isMe = data['senderUID'] == currentUser.uid;
final bool isRead = data["isRead"] ?? false;

return Align(
  alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.75,
    ),
  child: Container(
    margin: const EdgeInsets.symmetric(
      vertical: 4,
      horizontal: 10,
    ),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isMe ? Colors.amber : Colors.grey[700],
      borderRadius: BorderRadius.only(
  topLeft: const Radius.circular(18),
  topRight: const Radius.circular(18),
  bottomLeft: Radius.circular(isMe ? 18 : 0),
  bottomRight: Radius.circular(isMe ? 0 : 18),
),
    ),
    child: Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  mainAxisSize: MainAxisSize.min,
  children: [

    Text(
      data['message'],
      style: TextStyle(
        color: isMe ? Colors.black : Colors.white,
        fontSize: 16,
      ),
    ),

    const SizedBox(height: 4),

   Row(
  mainAxisSize: MainAxisSize.min,
  children: [

    Text(
      formattedTime,
      style: TextStyle(
        fontSize: 11,
        color: isMe
            ? Colors.black54
            : Colors.white70,
      ),
    ),

    if (isMe) ...[
      const SizedBox(width: 4),

      Icon(
  isRead
      ? Icons.done_all
      : Icons.done,
  size: 16,
  color: isRead
      ? Colors.blue
      : Colors.black54,
),
    ],
  ],
),
  ],
),
  ),
  ),
);
        },
      );
    },
  ),
),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(
      onPressed: () async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,
  );

  if (image != null) {
    print(image.path);
  }
},
      icon: const Icon(
        Icons.image,
        color: Colors.white,
      ),
    ),
                Expanded(
  child: TextField(
    controller: messageController,
    style: const TextStyle(
      color: Colors.white,
    ),
    decoration: InputDecoration(
      hintText: "Type a message...",
      hintStyle: const TextStyle(
        color: Colors.white70,
      ),

      filled: true,
      fillColor: Colors.grey[700],

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    ),
  ),
),
                SizedBox(width: 10,),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.amber,

                  child: IconButton(
                    onPressed: () async {

  if (messageController.text.trim().isNotEmpty) {

    await _chatServices.sendMessage(
      widget.receiverUID,
      messageController.text.trim(),
    );

    messageController.clear();
  }
},
                    icon: const Icon(
                      Icons.send,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ) 
    );
  }
}