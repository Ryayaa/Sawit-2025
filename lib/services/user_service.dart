import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // sesuaikan dengan path model kamu

class UserService {
  static Future<UserModel?> getAdminUser() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromDocument(snapshot.docs.first.data());
    } else {
      return null;
    }
  }
}
