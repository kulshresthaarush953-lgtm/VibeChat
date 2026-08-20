import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServices{
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    //Sign in with email and passwords

    Future signIn(
      String email,
      String password,
    ) async {

      try{
         final UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, 
          password: password
          );
          User? user = result.user;
await FirebaseFirestore.instance
    .collection('users')
    .doc(user!.uid)
    .update({
  'isOnline': true,
});
return "success";                
        } on FirebaseAuthException catch(e){
          print("Firebase Error Code: ${e.code}");
        if (e.code == 'user-not-found'){
          print("User was not found.");
          return 'user-not-found';
        }
        else if(e.code == 'invalid-email'){
          print("The email address format is invalid.");
          return 'invalid-email';
        }
        else if(e.code == 'invalid-credential'){
          print("invalid credential entered.");
          return 'invalid-credential';
        }
      }  
      catch (e){
        print("An unexpected error has Occured!");
      }
    }
  
  Future signUp(
    String name,
    String email,
    String password,
  ) async {
    try{
      final existingUser = await FirebaseFirestore.instance
    .collection('users')
    .where('name', isEqualTo: name.trim())
    .get();

if (existingUser.docs.isNotEmpty) {
  return "name-already-in-use";
}
      final UserCredential result1 = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password,     
      );
      print("Sign UP METHOD CALLED");
      User? user = result1.user;
     
      print("USER CREATED");
      await _firestore
    .collection('users')
    .doc(user!.uid)
    .set({
      'name': name,
      'email': email,
      'isOnline': false,
    });
      return "Success";
      
       
    } on FirebaseAuthException catch(e){
      if (e.code == 'weak-password'){
        print("The Password provided is too weak.");
        return 'weak-password';
      }
      else if (e.code == 'email-already-in-use'){
        print("The email is already in use.");
        return 'email-already-in-use';
      }
      else if(e.code == 'invalid-email'){
        print("The Email format is invalid.");
        return 'invalid-email';
      }
    }
    catch (e){
      print("An unexpected error has Occured!");
    }
  }
  Future<void> signOut() async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({
      'isOnline': false,
    });
  } catch (e) {
    print(e);
  }

  await _auth.signOut();
}
}