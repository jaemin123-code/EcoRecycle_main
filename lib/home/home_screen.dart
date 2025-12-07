import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';

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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
        }
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
                  const Text('환영합니다', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0, top: 4.0),
                    child: RealtimePointDisplay(),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('내 프로필'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('상점'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('우리 학교 커뮤니티'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunityScreen()));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('EcoRecycle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                  trackVisibility: true,
                  interactive: true,
                  thickness: 12.0,
                  radius: const Radius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: ListView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      // ★★★ 여기 'children: const [...]'에서 'const'를 제거했습니다! ★★★
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
              const CertSection(),
              const SizedBox(height: 16),
              const QuizSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: const Icon(Icons.home), color: Colors.green, onPressed: () {}, iconSize: 28),
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
                child: const Icon(Icons.camera_alt, size: 28, color: Colors.white),
              ),
              IconButton(
                  icon: const Icon(Icons.people),
                  color: Colors.grey,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CommunityScreen()),
                    );
                  },
                  iconSize: 28
              ),
            ],
          ),
        ),
      ),
    );
  }
}