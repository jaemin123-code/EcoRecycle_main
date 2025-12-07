import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ★ 1. 로그인 정보 가져오기 위해 필수 추가

class CertUploadScreen extends StatefulWidget {
  const CertUploadScreen({super.key});

  @override
  State<CertUploadScreen> createState() => _CertUploadScreenState();
}

class _CertUploadScreenState extends State<CertUploadScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      // ★ 속도를 위해 80 -> 30으로 낮추는 것을 추천합니다!
      final picked = await _picker.pickImage(source: source, imageQuality: 30);
      if (picked == null) return;

      setState(() {
        _image = File(picked.path);
      });
    } catch (e) {
      print("❌ 사진 선택 실패: $e");
    }
  }

  Future<void> upload() async {
    if (_image == null) return;

    // ★ 2. 현재 로그인한 사용자 정보 가져오기 (가장 중요!)
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 상태가 아닙니다. 다시 로그인 해주세요.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('업로드 중... 잠시만 기다려주세요!')),
    );

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // 1. 스토리지에 사진 업로드
      print("🚀 1. 스토리지 업로드 시작");
      final storageRef = FirebaseStorage.instance.ref("certifications/$fileName.jpg");
      await storageRef.putFile(_image!);

      final imageUrl = await storageRef.getDownloadURL();
      print("✅ 이미지 URL 획득: $imageUrl");

      // 2. 게시물 정보 Firestore 저장
      print("🚀 2. Firestore posts 컬렉션 저장 시작");
      await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'description': '#에코인증',
        'userId': user.uid, // ★ 'my_id'를 진짜 user.uid로 변경
        'email': user.email, // (선택) 누가 썼는지 알기 쉽게 이메일도 추가
      });
      print("✅ 게시물 저장 완료");

      // 3. 포인트 지급
      print("🚀 3. 포인트 적립 시작");
      // ★ 여기서도 'my_id'를 user.uid로 변경해야 내 포인트가 오릅니다.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'point': FieldValue.increment(100),
          'last_activity': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      print("✅ 포인트 적립 완료");

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("인증 완료! 100 포인트 획득! 🎉"),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      }

    } catch (e) {
      print("❌ 에러 발생: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("실패: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("사진 인증하기"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: AbsorbPointer(
        absorbing: _isUploading,
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey[200],
                      child: _image == null
                          ? const Center(child: Text("사진을 선택하세요"))
                          : Image.file(_image!, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () => _pickImage(ImageSource.camera),
                          label: const Text("카메라"),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          icon: const Icon(Icons.photo),
                          onPressed: () => _pickImage(ImageSource.gallery),
                          label: const Text("앨범"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isUploading ? Colors.grey : Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      onPressed: _isUploading ? null : upload,
                      child: Text(
                        _isUploading ? "처리 중..." : "게시물 올리고 포인트 받기",
                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isUploading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}