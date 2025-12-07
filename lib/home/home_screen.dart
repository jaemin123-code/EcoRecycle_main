import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';

// [중요] 각 페이지 import 경로 확인해주세요.
import '../mypage/mypage_screen.dart';
import '../widgets/shorts_tips_widget.dart';
import '../chat/chatbot_screen.dart';
import '../community/community_screen.dart';
import '../camera/ai_camera_screen.dart';
import '../widgets/sprout_section.dart';
import '../widgets/tip_menu.dart';
import '../cert/cert_section.dart';
import 'quiz_section.dart';
import 'eco_participation.dart';
import '../shop/shop_screen.dart';

// ---------------------------------------------------------
// [위젯 1] 사이드 메뉴에서 '환영합니다 닉네임님' 보여주는 위젯
// ---------------------------------------------------------
class DrawerNicknameDisplay extends StatelessWidget {
  const DrawerNicknameDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 로그인 안 했을 때
    if (user == null) {
      return const Text(
        '환영합니다 게스트님',
        style: TextStyle(color: Colors.white, fontSize: 18),
      );
    }

    // 로그인 했을 때 DB에서 닉네임 실시간 감시
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String nickname = "환경지킴이"; // 기본값

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          nickname = data['nickname'] ?? "환경지킴이";
        }

        return Text(
          '환영합니다 $nickname님!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold, // 굵게 표시
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------
// [위젯 2] 사이드 메뉴에서 '포인트' 보여주는 위젯
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
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("오류", style: TextStyle(color: Colors.white));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("내 포인트: 💰 0 P",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final points = data['point'] ?? 0;
        return Text("💰 $points P",
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white));
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
                  // [수정됨] 닉네임 표시 위젯 적용
                  const DrawerNicknameDisplay(),

                  // 포인트 표시 위젯
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0, top: 4.0),
                    child: RealtimePointDisplay(),
                  ),
                ],
              ),
            ),
            // 내 프로필 -> 마이페이지 이동
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('내 프로필'),
              onTap: () {
                Navigator.pop(context); // 서랍 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPageScreen()),
                );
              },
            ),
            // 상점 이동
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('상점'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopScreen()),
                );
              },
            ),
            // 커뮤니티 이동
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('우리 학교 커뮤니티'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CommunityScreen()),
                );
              },
            ),
          ],
        ),
      ),

      // 2. 상단 앱바
      appBar: AppBar(
        title: const Text('EcoRecycle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // 3. 메인 내용 (본문)
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SproutSection(), // 캐릭터 & 환영문구 (여기도 수정하셨죠?)
              const SizedBox(height: 16),
              const TipMenu(),
              const SizedBox(height: 16),
              const Text("분리배출 꿀팁 영상",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              SizedBox(
                height: 400,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  thickness: 12.0,
                  radius: const Radius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: ListView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      children: const [
                        SizedBox(
                          width: 200,
                          child: ShortsTipsWidget(
                            videoId: 'jBmjwMbgcQ8',
                            title: '분리수거 간단한 팁',
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: 200,
                          child: ShortsTipsWidget(
                            videoId: 'N2SmNNjqjkQ',
                            title: '깨진 유리병 안전하게 버리는 법',
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: 200,
                          child: ShortsTipsWidget(
                            videoId: 'J75SzKhnADA',
                            title: '분리수거 꿀템',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const EcoParticipationSection(),
              const SizedBox(height: 16),
              CertSection(),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),

      // 5. 하단 네비게이션 바
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 홈 버튼
              IconButton(
                icon: const Icon(Icons.home),
                color: Colors.green,
                onPressed: () {
                  _scrollController.animateTo(0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                },
                iconSize: 28,
              ),
              // 카메라 버튼
              ElevatedButton(
                onPressed: () async {
                  final cameras = await availableCameras();
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AiCameraScreen(cameras: cameras),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(14),
                  elevation: 4,
                ),
                child: const Icon(Icons.camera_alt, size: 28, color: Colors.white),
              ),
              // [마이페이지 버튼]
              IconButton(
                icon: const Icon(Icons.person),
                color: Colors.grey,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyPageScreen()),
                  );
                },
                iconSize: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}