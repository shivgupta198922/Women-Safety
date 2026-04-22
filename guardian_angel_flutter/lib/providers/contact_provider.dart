import 'package:flutter/material.dart';
import 'package:guardian_angel_flutter/services/api_service.dart'; // Corrected import
import 'package:guardian_angel_flutter/models/contact_model.dart'; // Corrected import

class ContactProvider with ChangeNotifier {
  List<ContactModel> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ContactModel> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ContactProvider() {
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/contacts');
      final responseData = ApiService.handleResponse(response) as List;
      _contacts = responseData.map((json) => ContactModel.fromJson(json)).toList();
    } catch (error) {
      _errorMessage = error.toString();
      print('Error fetching contacts: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContact(String name, String phoneNumber, {String? email, String? relationship}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/contacts/add', {
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'relationship': relationship,
        'isEmergency': true,
      });
      final newContact = ContactModel.fromJson(ApiService.handleResponse(response));
      _contacts.add(newContact);
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      print('Error adding contact: $_errorMessage');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateContact(String id, String name, String phoneNumber, {String? email, String? relationship}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.put('/contacts/$id', {
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'relationship': relationship,
      });
      final updatedContact = ContactModel.fromJson(ApiService.handleResponse(response));
      final index = _contacts.indexWhere((contact) => contact.id == id);
      if (index != -1) {
        _contacts[index] = updatedContact;
      }
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      print('Error updating contact: $_errorMessage');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteContact(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.delete('/contacts/$id');
      _contacts.removeWhere((contact) => contact.id == id);
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      print('Error deleting contact: $_errorMessage');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}