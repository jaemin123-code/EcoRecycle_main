import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. 전체 랭킹 데이터 (기존 데이터 유지)
  final List<Map<String, dynamic>> classRanking = [
    {"name": "1학년 1반", "points": 1850},
    {"name": "3학년 2반", "points": 1620},
    {"name": "2학년 5반", "points": 1450},
    {"name": "1학년 3반", "points": 980},
    {"name": "2학년 1반", "points": 850},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("우리 학교 커뮤니티", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "🏫 학급 찾기"), // 카테고리 탭
            Tab(text: "🏆 명예의 전당"), // 랭킹 탭
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClassCategoryTab(), // 학년/반 카테고리 화면
          _buildRankingTab(),       // 랭킹 화면
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // 1. 학년/반 카테고리 탭 (요청하신 기능)
  // ----------------------------------------------------------------
  Widget _buildClassCategoryTab() {
    // 1~3학년 생성
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6, // 1학년 ~ 6학년
      itemBuilder: (context, gradeIndex) {
        int grade = gradeIndex + 1; // 학년 (1 ~ 6)

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            // 카테고리 제목 (학년)
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Text("$grade", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
            title: Text("$grade학년", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            // 카테고리 내부 (1반 ~ 6반 리스트)
            children: List.generate(6, (classIndex) {
              int classNum = classIndex + 1; // 반 (1~6)
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.class_outlined, color: Colors.grey),
                title: Text("$grade학년 $classNum반", style: const TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  // 반을 누르면 해당 반 게시판으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassBoardScreen(grade: grade, classNum: classNum),
                    ),
                  );
                },
              );
            }),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------------
  // 2. 전체 랭킹 탭 (기존 기능 유지)
  // ----------------------------------------------------------------
  Widget _buildRankingTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classRanking.length,
      itemBuilder: (context, index) {
        final item = classRanking[index];
        Color rankColor;
        if (index == 0) rankColor = const Color(0xFFFFD700);
        else if (index == 1) rankColor = const Color(0xFFC0C0C0);
        else if (index == 2) rankColor = const Color(0xFFCD7F32);
        else rankColor = Colors.green;

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: rankColor,
              foregroundColor: Colors.white,
              child: Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text("${item['name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text("${item['points']} P", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------------
// [추가] 상세 반 게시판 화면 (반을 클릭했을 때 나오는 화면)
// ----------------------------------------------------------------
class ClassBoardScreen extends StatelessWidget {
  final int grade;
  final int classNum;

  const ClassBoardScreen({super.key, required this.grade, required this.classNum});

  @override
  Widget build(BuildContext context) {
    // 예시 공지사항 데이터
    final List<Map<String, String>> notices = [
      {"title": "📢 이번 주 청소 구역 안내", "content": "1분단: 교실 / 2분단: 복도 / 3분단: 특별구역"},
      {"title": "♻️ 페트병 뚜껑 모으기 캠페인", "content": "이번 달 말까지 페트병 뚜껑 100개 모으면 학급 포인트 지급!"},
      {"title": "🗓️ 중간고사 일정 안내", "content": "다음 주 수요일부터 3일간 중간고사가 진행됩니다."},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("$grade학년 $classNum반 게시판"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 상단 반 정보 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.green[50],
            child: Column(
              children: [
                const Icon(Icons.groups, size: 50, color: Colors.green),
                const SizedBox(height: 10),
                Text(
                  "$grade학년 $classNum반에 오신 것을 환영합니다! 👋",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text("오늘도 깨끗한 지구를 위해 힘내봐요!", style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),

          // 공지사항 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.campaign, color: Colors.orange),
                    title: Text(notices[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(notices[index]['content']!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("글쓰기 기능은 준비 중입니다!")),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}