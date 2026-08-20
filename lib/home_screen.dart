import 'package:flutter/material.dart';
import 'package:vibe_chat/auth_screen.dart';
import 'package:vibe_chat/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';
import 'package:vibe_chat/services/chat_services.dart';
import 'new_chat_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final ChatServices _chatServices = ChatServices();
  List<DocumentSnapshot> searchResults = [];
   bool hasSearched = false;
  
  final AuthServices _authServices = AuthServices();
  final TextEditingController searchController = TextEditingController();
    Future searchUser() async {
  QuerySnapshot result =
      await FirebaseFirestore.instance
          .collection('users')
          .where(
               'name',
                isEqualTo: searchController.text,
          )
         .get();

print("Searching for: ${searchController.text}");
print("Results: ${result.docs.length}");
  setState(() {
    hasSearched = true;
    searchResults = result.docs;
  });
  }
  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        title: Text(
          'Vibe Chat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _authServices.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen())
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      backgroundColor: Colors.grey[800],
      body: Column(
        children: [
          Expanded(
  child: !hasSearched
      ? StreamBuilder(
          stream: _chatServices.getUserChats(),
          builder: (context, snapshot) {

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Something went wrong",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final chats = snapshot.data!.docs;

            if (chats.isEmpty) {
              return const Center(
                child: Text(
                  "No chats yet",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {

                final chat =
                    chats[index].data() as Map<String, dynamic>;

                List users = chat['users'];

String otherUserUID = users.firstWhere(
  (uid) => uid != FirebaseAuth.instance.currentUser!.uid,
);

return FutureBuilder(
  future: _chatServices.getUserData(otherUserUID),
  builder: (context, userSnapshot) {

    if (!userSnapshot.hasData) {
      return const SizedBox();
    }

    final userData =
        userSnapshot.data!.data() as Map<String, dynamic>;

  return Column(
    children: [
    ListTile(
  leading: CircleAvatar(
  radius: 24,
  backgroundColor: Colors.amberAccent,
  child: Text(
    userData['name'][0].toUpperCase(),
    style: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  ),
),

  title: Text(
    userData['name'],
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 17,
    ),
  ),

  subtitle: Text(
    chat['lastMessage'],
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      color: Colors.grey,
      fontSize: 14,
    ),
  ),

  trailing: Text(
    TimeOfDay.fromDateTime(
      (chat['lastMessageTime'] as Timestamp).toDate(),
    ).format(context),

    style: const TextStyle(
      color: Colors.grey,
      fontSize: 12,
    ),
  ),

  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiverName: userData['name'],
          receiverUID: otherUserUID,
        ),
      ),
    );
  },
),
 Divider(
      color: Colors.grey.shade700,
      indent: 75,
      endIndent: 15,
      height: 1,
    ),

    ]
);
  },
);
              },
            );
          },
        )

      : searchResults.isEmpty
          ? const Center(
              child: Text(
                "No results found",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )

          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {

                final user =
                    searchResults[index].data()
                        as Map<String, dynamic>;

                return ListTile(
                  title: Text(
                    user['name'],
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  subtitle: Text(
                    user['email'],
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          receiverName: user['name'],
                          receiverUID: searchResults[index].id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
)
        ],
      ),
      floatingActionButton: FloatingActionButton(
  backgroundColor: Colors.amber,
  child: const Icon(
    Icons.chat,
    color: Colors.black,
  ),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NewChatScreen(),
      ),
    );
    // We'll navigate to NewChatScreen next.
  },
),
    );
  }
}