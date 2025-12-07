import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cert_upload.dart'; // 글쓰기 화면

// ---------------------------------------------------------
// [메인] 에코 인증 게시판 (그리드 화면)
// ---------------------------------------------------------
class CertScreen extends StatelessWidget {
  const CertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("에코 인증 게시판", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. 상단 헤더 (게시물 수 + 글쓰기 버튼)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.eco, color: Colors.green, size: 40),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("#에코 인증", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('certifications').snapshots(),
                      builder: (context, snapshot) {
                        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return Text("게시물 : $count개", style: TextStyle(color: Colors.grey[600]));
                      },
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CertUploadScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("인증하고 포인트 받기", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // 2. 사진 그리드 갤러리
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('certifications').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("아직 인증 게시물이 없어요. 첫 인증을 남겨보세요!", style: TextStyle(color: Colors.grey)));
                }

                final docs = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 한 줄에 3개
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 1, // 정사각형
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final imageUrl = data['imageUrl'];

                    return GestureDetector(
                      onTap: () {
                        // [수정된 부분] 상세 페이지로 이동!
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CertDetailScreen(data: data),
                          ),
                        );
                      },
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Hero( // Hero 애니메이션 추가 (화면 전환 시 부드럽게)
                        tag: imageUrl,
                        child: Image.network(imageUrl, fit: BoxFit.cover),
                      )
                          : Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// [추가된 화면] 인증 상세 페이지 (크게 보기)
// ---------------------------------------------------------
class CertDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const CertDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // 날짜 변환
    String dateStr = "날짜 정보 없음";
    if (data['timestamp'] != null) {
      DateTime date = (data['timestamp'] as Timestamp).toDate();
      dateStr = "${date.year}년 ${date.month}월 ${date.day}일 ${date.hour}:${date.minute}";
    }

    return Scaffold(
      backgroundColor: Colors.white, // 배경 흰색
      appBar: AppBar(
        title: const Text("인증 상세", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // 뒤로가기 버튼 검은색
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 큰 이미지
            SizedBox(
              width: double.infinity,
              child: data['imageUrl'] != null
                  ? Hero(
                tag: data['imageUrl'],
                child: Image.network(
                  data['imageUrl'],
                  fit: BoxFit.contain, // 사진 비율 유지하며 다 보여주기
                ),
              )
                  : Container(height: 300, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
            ),

            // 2. 내용 및 날짜
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 표시
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        dateStr,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 본문 내용
                  Text(
                    data['description'] ?? "내용이 없습니다.",
                    style: const TextStyle(fontSize: 18, height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}