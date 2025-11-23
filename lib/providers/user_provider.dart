import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await supabase.from('users').insert(user.toMap());
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create user profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _currentUser = UserModel.fromMap(response);
      }
    } catch (e) {
      _error = 'Failed to fetch user profile';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUserProfile(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await supabase
          .from('users')
          .update(user.toMap())
          .eq('id', user.id);

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update user profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}