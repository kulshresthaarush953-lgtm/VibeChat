import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController searchController = TextEditingController();

  List<DocumentSnapshot> searchResults = [];
  bool hasSearched = false;

  Future searchUser() async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where(
          'name',
          isEqualTo: searchController.text.trim(),
        )
        .get();

    setState(() {
      hasSearched = true;
      searchResults = result.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],

      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "New Chat",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,

              onChanged: (value) async {

                if (value.trim().isEmpty) {
                  setState(() {
                    hasSearched = false;
                    searchResults.clear();
                  });
                } else {
                  await searchUser();
                }

              },

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "Search users...",
                hintStyle: const TextStyle(color: Colors.white70),

                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Colors.white),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Colors.amber),
                ),
              ),
            ),
          ),

          Expanded(

            child: !hasSearched
                ? const Center(
                    child: Text(
                      "Search for someone",
                      style: TextStyle(color: Colors.white),
                    ),
                  )

                : searchResults.isEmpty

                    ? const Center(
                        child: Text(
                          "No users found",
                          style: TextStyle(color: Colors.white),
                        ),
                      )

                    : ListView.builder(

                        itemCount: searchResults.length,

                        itemBuilder: (context, index) {

                          final user =
                              searchResults[index].data()
                                  as Map<String, dynamic>;

                          return ListTile(

                            leading: CircleAvatar(
                              backgroundColor: Colors.amber,
                              child: Text(
                                user['name'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

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

                              Navigator.pushReplacement(
                                context,

                                MaterialPageRoute(

                                  builder: (_) => ChatScreen(

                                    receiverName: user['name'],

                                    receiverUID:
                                        searchResults[index].id,

                                  ),

                                ),

                              );

                            },

                          );

                        },

                      ),

          ),

        ],
      ),
    );
  }
}