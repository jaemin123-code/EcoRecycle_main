import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CertUploadScreen extends StatefulWidget {
  const CertUploadScreen({super.key});

  @override
  State<CertUploadScreen> createState() => _CertUploadScreenState();
}

class _CertUploadScreenState extends State<CertUploadScreen> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  final User? user = FirebaseAuth.instance.currentUser;

  // 이미지 선택
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 업로드 로직 (기존과 동일)
  Future<void> _uploadCertification() async {
    if (_textController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("사진과 내용을 모두 입력해주세요!")));
      return;
    }
    if (user == null) return;

    setState(() => _isUploading = true);

    try {
      // 1. 스토리지 업로드
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = FirebaseStorage.instance.ref().child('certifications/$fileName.jpg');
      await storageRef.putFile(_selectedImage!);
      final String imageUrl = await storageRef.getDownloadURL();

      // 2. DB 저장
      await FirebaseFirestore.instance.collection('certifications').add({
        'uid': user!.uid,
        'description': _textController.text,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. 포인트 지급
      final userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (snapshot.exists) {
          int currentPoint = snapshot.data()?['point'] ?? 0;
          transaction.update(userRef, {'point': currentPoint + 100});
        }
      });

      // 4. 내역 저장
      await FirebaseFirestore.instance.collection('point_history').add({
        'uid': user!.uid,
        'amount': 100,
        'description': '분리배출 인증 보상',
        'type': 'earn',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("인증 완료! 100P 지급! 🎉")));
        Navigator.pop(context);
      }
    } catch (e) {
      print("오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("업로드 실패")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("인증 글쓰기", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                    : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "인증 내용을 입력하세요...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadCertification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("업로드하고 포인트 받기", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}