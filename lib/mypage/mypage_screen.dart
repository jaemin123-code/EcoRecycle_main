import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// intl 패키지가 없어도 작동하도록 수동 포맷팅으로 변경했습니다. (패키지 오류 방지)

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // 레벨 계산 로직
  Map<String, dynamic> _calculateLevel(int points) {
    if (points < 1000) return {"level": "🌱 새싹 등급", "next": 1000, "progress": points / 1000};
    if (points < 3000) return {"level": "🌿 묘목 등급", "next": 3000, "progress": (points - 1000) / 2000};
    return {"level": "🌳 거목 등급", "next": 10000, "progress": 1.0};
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text("로그인이 필요합니다")));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: const Text("마이페이지", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final int points = data['point'] ?? 0;
          final String nickname = data['nickname'] ?? "환경지킴이";
          final levelInfo = _calculateLevel(points);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 1. 프로필 & 레벨 카드
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.green.shade200, width: 2)),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.green.shade50,
                                child: Image.asset('assets/images/character.png', width: 50, errorBuilder: (_,__,___) => const Icon(Icons.person, size: 40, color: Colors.green)),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(levelInfo['level'], style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 5),
                                Text(nickname, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("다음 등급까지", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                Text("${(levelInfo['progress'] * 100).toInt()}%", style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: levelInfo['progress'],
                                minHeight: 12,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("$points / ${levelInfo['next']} P", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // 2. 대시보드 (포인트 & 랭킹)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: _buildInfoCard(Icons.monetization_on, "보유 포인트", "$points P", Colors.amber[700]!)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildInfoCard(Icons.emoji_events, "나의 랭킹", "상위 5%", Colors.purple[400]!)),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 3. 메뉴 리스트
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("활동 관리", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          children: [
                            _buildMenuTile(Icons.history, "분리배출 인증 내역", onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const CertificationHistoryScreen()));
                            }),
                            _divider(),
                            _buildMenuTile(Icons.shopping_bag_outlined, "포인트 사용 내역", onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PointHistoryScreen()));
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text("계정 설정", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          children: [
                            _buildMenuTile(Icons.logout, "로그아웃", isDestructive: true, onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) Navigator.pop(context);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 15),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {required VoidCallback onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.grey[700]),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.black87, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
      onTap: onTap,
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 0.5, color: Colors.grey[200], indent: 20, endIndent: 20);
}

// -------------------------------------------------------------------------
// [서브 화면 1] 분리배출 인증 내역
// -------------------------------------------------------------------------
class CertificationHistoryScreen extends StatelessWidget {
  const CertificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("인증 내역", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('certifications')
            .where('uid', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("아직 인증한 내역이 없어요! 🗑️", style: TextStyle(color: Colors.grey)));
          }

          final docs = snapshot.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // 날짜 수동 포맷팅 (intl 패키지 없이)
              String dateStr = "";
              if (data['timestamp'] != null) {
                DateTime date = (data['timestamp'] as Timestamp).toDate();
                dateStr = "${date.month}월 ${date.day}일 ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
              }

              return Card(
                elevation: 0,
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                        ? Image.network(data['imageUrl'], width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)))
                        : Container(width: 60, height: 60, color: Colors.white, child: const Icon(Icons.image, color: Colors.grey)),
                  ),
                  title: Text(data['description'] ?? "분리배출 인증", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(dateStr),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(10)),
                    child: const Text("+ 100 P", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------------------
// [서브 화면 2] 포인트 사용 내역
// -------------------------------------------------------------------------
class PointHistoryScreen extends StatelessWidget {
  const PointHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("포인트 사용 내역", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('point_history')
            .where('uid', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("포인트를 사용한 적이 없어요! 🛍️", style: TextStyle(color: Colors.grey)));
          }

          // [여기가 수정된 부분입니다!] 오타 제거 완료
          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // 날짜 수동 포맷팅
              String dateStr = "";
              if (data['timestamp'] != null) {
                DateTime date = (data['timestamp'] as Timestamp).toDate();
                dateStr = "${date.year}.${date.month}.${date.day}";
              }

              // 포인트 타입에 따라 색상/부호 결정
              final isUse = data['type'] == 'use';
              final amountText = isUse ? "- ${data['amount']} P" : "+ ${data['amount']} P";
              final amountColor = isUse ? Colors.redAccent : Colors.blueAccent;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['description'] ?? "활동 내역", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text(dateStr, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                    Text(
                      amountText,
                      style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}