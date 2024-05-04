import 'package:firebase_database/firebase_database.dart';

class FirebaseDbReference{
  static getReference(){
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child("al_alif");
    return databaseReference;
  }
}