import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _experienceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _diplomaImage;
  bool _isAdvocate = false;

  Future<void> _register() async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final userId = userCredential.user!.uid;

      Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _isAdvocate ? 'advocate' : 'user',
      };

      if (_isAdvocate) {
        userData.addAll({
          'experience': _experienceController.text.trim(),
          'diplomaUrl': await _uploadDiploma(userId),
        });
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).set(userData);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<String> _uploadDiploma(String userId) async {
    final ref = FirebaseStorage.instance.ref().child('diplomas').child(userId);
    await ref.putFile(File(_diplomaImage!.path));
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            CheckboxListTile(
              title: Text('Register as Advocate'),
              value: _isAdvocate,
              onChanged: (value) {
                setState(() {
                  _isAdvocate = value!;
                });
              },
            ),
            if (_isAdvocate) ...[
              TextField(
                controller: _experienceController,
                decoration: InputDecoration(labelText: 'Work Experience'),
              ),
              TextButton(
                onPressed: () async {
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    _diplomaImage = pickedFile;
                  });
                },
                child: Text('Upload Diploma'),
              ),
              if (_diplomaImage != null) Text('Diploma Uploaded'),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
