import 'package:firebase_auth/firebase_auth.dart';
import 'package:diet_tracking_project/services/firestore_service.dart';
import '../models/user_data_model.dart';

/// Datasource for Firestore operations
class FirestoreDatasource {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user data from Firestore
  Future<UserDataModel?> getCurrentUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      final userDoc = await _firestoreService.getUserById(currentUser.uid);
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      
      return UserDataModel.fromFirebaseData(userData);
    } catch (e) {
      throw Exception('Error getting user data: ${e.toString()}');
    }
  }

  /// Check if user is authenticated
  bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
