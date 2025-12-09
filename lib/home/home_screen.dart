import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
import 'package:material_symbols_icons/symbols.dart';

// 👇 파일 경로가 다르면 빨간 줄이 뜰 수 있습니다. 본인 프로젝트 경로에 맞게 수정해주세요.
import '../mypage/mypage_screen.dart';
import '../widgets/shorts_tips_widget.dart';
import '../chat/chatbot_screen.dart'; // 챗봇 화면 import
import '../community/community_screen.dart';
import '../camera/ai_camera_screen.dart';
import '../widgets/sprout_section.dart';
import '../widgets/tip_menu.dart';
import '../cert/cert_section.dart';
import 'quiz_section.dart';
import 'eco_participation.dart';
import '../shop/shop_screen.dart';


// ---------------------------------------------------------
// [위젯 1] 사이드 메뉴 닉네임
// ---------------------------------------------------------
class DrawerNicknameDisplay extends StatelessWidget {
  const DrawerNicknameDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Text('환영합니다 게스트님', style: TextStyle(color: Colors.white, fontSize: 18));
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String nickname = "환경지킴이";
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          nickname = data['nickname'] ?? "환경지킴이";
        }
        return Text('환영합니다 $nickname님', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
      },
    );
  }
}

// ---------------------------------------------------------
// [위젯 2] 사이드 메뉴 포인트
// ---------------------------------------------------------
class RealtimePointDisplay extends StatelessWidget {
  const RealtimePointDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Text("로그인 필요", style: TextStyle(color: Colors.white));
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("오류", style: TextStyle(color: Colors.white));
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("💰 0 P", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final points = data['point'] ?? 0;
        return Text("💰 $points P", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white));
      },
    );
  }
}

// ---------------------------------------------------------
// [메인 화면 클래스]
// ---------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. 사이드 메뉴 (Drawer)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const DrawerNicknameDisplay(),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0, top: 4.0),
                    child: RealtimePointDisplay(),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Symbols.person_rounded),
              title: const Text('내 프로필'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPageScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Symbols.store_rounded),
              title: const Text('상점'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Symbols.group_rounded),
              title: const Text('우리 학교 커뮤니티'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunityScreen()));
              },
            ),
          ],
        ),
      ),

      // 2. 상단 앱바
      appBar: AppBar(
        title: const Text('EcoRecycle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // 3. 메인 내용 (Stack 구조)
      body: Stack(
        children: [
          // (1) 기존 화면 내용 (맨 밑바닥)
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SproutSection(),
                  const SizedBox(height: 16),
                  const TipMenu(),
                  const SizedBox(height: 16),
                  const Text("분리배출 꿀팁 영상", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 400,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        SizedBox(width: 200, child: ShortsTipsWidget(videoId: 'jBmjwMbgcQ8', title: '분리수거 간단한 팁')),
                        SizedBox(width: 10),
                        SizedBox(width: 200, child: ShortsTipsWidget(videoId: 'N2SmNNjqjkQ', title: '깨진 유리병 안전하게 버리는 법')),
                        SizedBox(width: 10),
                        SizedBox(width: 200, child: ShortsTipsWidget(videoId: 'J75SzKhnADA', title: '분리수거 꿀템')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const EcoParticipationSection(),
                  const SizedBox(height: 16),
                  const CertSection(),
                  const SizedBox(height: 16),
                  const QuizSection(),
                  const SizedBox(height: 80), // 하단 여백
                ],
              ),
            ),
          ),

          // (2) 챗봇 버튼 (화면 오른쪽 아래에 고정)
          Positioned(
            bottom: 20, // 바닥에서 20만큼 위
            right: 20,  // 오른쪽에서 20만큼 안쪽
            child: FloatingActionButton(
              heroTag: "chatbot",
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: () {
                // 👇 클래스 이름 확인 필수 (ChatbotScreen)
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen()));
              },
            ),
          ),
        ],
      ),

      // 4. 플로팅 버튼 (가운데 카메라)
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () async {
            try {
              final cameras = await availableCameras();
              if (context.mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AiCameraScreen(cameras: cameras)));
              }
            } catch (e) {
              print("카메라 에러: $e");
            }
          },
          backgroundColor: Colors.green,
          shape: const CircleBorder(),
          elevation: 4.0,
          child: const Icon(Symbols.photo_camera_rounded, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // 위치 고정

      // 5. 하단 네비게이션 바
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // 가운데 파내기
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Symbols.home_rounded, weight: 600),
                color: Colors.green,
                iconSize: 32,
                onPressed: () {
                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                },
              ),

              const SizedBox(width: 40), // 가운데 공간 확보

              IconButton(
                icon: const Icon(Symbols.person_rounded, weight: 600),
                color: Colors.grey,
                iconSize: 32,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPageScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}