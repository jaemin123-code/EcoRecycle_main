import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cert_upload.dart';

class CertScreen extends StatelessWidget {
  const CertScreen({super.key});

  // 날짜를 "0000년 00월 00일" 형태로 변환하는 함수
  String _formatDate(DateTime date) {
    return "${date.year}년 ${date.month}월 ${date.day}일";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("에코 인증"),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.camera_alt),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CertUploadScreen()),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("아직 업로드된 인증이 없어요."));
          }

          final docs = snapshot.data!.docs;

          // 1. 데이터를 날짜별로 그룹핑하기 위한 Map 생성
          Map<String, List<QueryDocumentSnapshot>> groupedData = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            // timestamp가 없으면 현재 시간으로 처리 (에러 방지)
            final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
            final DateTime dateTime = timestamp.toDate();

            // 날짜 키 생성 (예: "2024년 12월 4일")
            final String dateKey = _formatDate(dateTime);

            if (!groupedData.containsKey(dateKey)) {
              groupedData[dateKey] = [];
            }
            groupedData[dateKey]!.add(doc);
          }

          // 2. 그룹핑된 키(날짜)를 리스트로 변환
          final dateKeys = groupedData.keys.toList();

          // 3. 리스트뷰로 날짜별 섹션 출력
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: dateKeys.length,
            itemBuilder: (context, index) {
              final dateKey = dateKeys[index];
              final dayDocs = groupedData[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 헤더
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      dateKey,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // 해당 날짜의 그리드 뷰
                  GridView.builder(
                    shrinkWrap: true, // 리스트뷰 안에서 그리드뷰를 쓸 때 필수
                    physics: const NeverScrollableScrollPhysics(), // 스크롤 충돌 방지
                    itemCount: dayDocs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, gridIndex) {
                      final data = dayDocs[gridIndex].data() as Map<String, dynamic>;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          data['imageUrl'],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: const Center(child: Icon(Icons.error)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10), // 날짜 그룹 간 간격
                ],
              );
            },
          );
        },
      ),
    );
  }
}