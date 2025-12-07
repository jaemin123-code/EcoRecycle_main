import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
// [중요] 귀여운 아이콘 패키지 import
import 'package:material_symbols_icons/symbols.dart';

import '../mypage/mypage_screen.dart';
import '../widgets/shorts_tips_widget.dart';
import '../chat/chatbot_screen.dart';
import '../community/community_screen.dart';
import '../camera/ai_camera_screen.dart';
import '../widgets/sprout_section.dart';
import '../widgets/tip_menu.dart';
import '../cert/cert_section.dart'; // 인증하기 버튼 위젯
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
// [메인 화면]
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
              leading: const Icon(Symbols.person_rounded), // 둥근 아이콘
              title: const Text('내 프로필'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPageScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Symbols.store_rounded), // 둥근 아이콘
              title: const Text('상점'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Symbols.group_rounded), // 둥근 아이콘
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

      // 3. 메인 내용
      body: SingleChildScrollView(
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
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: ListView(
                      controller: _scrollController,
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
                ),
              ),

              const SizedBox(height: 16),
              const EcoParticipationSection(),
              const SizedBox(height: 16),
              CertSection(), // const 제거됨
              const SizedBox(height: 16),
              const QuizSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // 4. 플로팅 버튼 (챗봇)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen()));
        },
        backgroundColor: Colors.green,
        // 아이콘 변경: 둥근 말풍선
        child: const Icon(Symbols.chat_bubble_rounded, color: Colors.white, weight: 600),
      ),

      // 5. 하단 네비게이션 바 (아이콘 대폭 업그레이드!)
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // [홈] 둥근 집 모양, weight(두께) 600으로 통통하게
              IconButton(
                icon: const Icon(Symbols.home_rounded, weight: 600),
                color: Colors.green,
                onPressed: () {
                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                },
                iconSize: 32,
              ),

              // [카메라] 둥근 렌즈 모양
              ElevatedButton(
                onPressed: () async {
                  final cameras = await availableCameras();
                  if (context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AiCameraScreen(cameras: cameras)));
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(14),
                  elevation: 4,
                ),
                child: const Icon(Symbols.photo_camera_rounded, size: 30, color: Colors.white),
              ),

              // [마이페이지] 둥근 사람 모양
              IconButton(
                icon: const Icon(Symbols.person_rounded, weight: 600),
                color: Colors.grey,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPageScreen()));
                },
                iconSize: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}