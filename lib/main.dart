import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cert/cert_upload.dart';
import 'home/home_screen.dart';
import 'firebase_options.dart'; // 이 파일이 프로젝트에 있어야 합니다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -----------------------------------------------------------
  // 1. Firebase 초기화 (중복 실행 방지 & 에러 처리)
  // -----------------------------------------------------------
  try {
    // 앱이 이미 실행 중인지 확인하고, 실행 안 된 경우에만 초기화
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // 혹시라도 초기화 중 에러가 나면 콘솔에 출력하고 계속 진행
    print("⚠️ Firebase 초기화 경고(무시 가능): $e");
  }

  // -----------------------------------------------------------
  // 2. 자동 로그인 시도 (익명 로그인)
  // -----------------------------------------------------------
  try {
    // 현재 로그인된 사용자가 없으면 로그인 시도
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
      print("✅ 새롭게 익명 로그인 성공!");
    } else {
      print("✅ 이미 로그인 되어 있습니다. UID: ${FirebaseAuth.instance.currentUser?.uid}");
    }
  } catch (e) {
    print("⚠️ 로그인 과정 오류: $e");
  }

  // -----------------------------------------------------------
  // 3. Firestore 설정 (선택 사항)
  // -----------------------------------------------------------
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false, // 오프라인 캐시 끄기 (데이터 꼬임 방지)
  );

  // -----------------------------------------------------------
  // 4. 앱 실행
  // -----------------------------------------------------------
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 오른쪽 위 'Debug' 띠 제거
      title: 'Eco Recycle App',
      theme: ThemeData(
        primarySwatch: Colors.green, // 앱의 기본 색상
        useMaterial3: true,          // 최신 디자인 적용
        fontFamily: 'Pretendard',    // (폰트가 있다면 적용, 없으면 기본 폰트)
      ),
      // 앱이 켜지면 가장 먼저 보여줄 화면
      home: const HomeScreen(),

      // 화면 이동 경로 설정
      routes: {
        '/certUpload': (context) => const CertUploadScreen(),
      },
    );
  }
}