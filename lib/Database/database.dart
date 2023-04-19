import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;

  AppUser(this.uid);
}

class AppUserData {
  final String uid;
  final String name;
  final List<dynamic> likes;
  final List<dynamic> wishlist;

  AppUserData({required this.uid, required this.name, required this.likes, required this.wishlist});
}

class DatabaseService {
  final String uid ;

  DatabaseService(this.uid);

  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> addUser(String name) async {
    return await usersCollection.doc(uid).set({
      'name': name,
      'likes': [],
      'wishlist': [],
    });
  }

  AppUserData _userFromSnapshot(DocumentSnapshot<Object?> snapshot) {
    var data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) throw Exception("utilisateur introuvable");
    return AppUserData(
      uid: snapshot.id,
      name: data['name'],
      likes: data['likes'],
      wishlist: data['wishlist'],
    );
  }

  Stream<AppUserData> get user {
    return usersCollection.doc(uid).snapshots().map(_userFromSnapshot);
  }

}