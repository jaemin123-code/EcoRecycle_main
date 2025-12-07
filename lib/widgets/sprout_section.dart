import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shop/shop_screen.dart';

class SproutSection extends StatelessWidget {
  const SproutSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 로그인한 사용자 가져오기
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: double.infinity,
      height: 200, // 카드 높이
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // 연한 초록색 배경
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // 1. 가운데 캐릭터 이미지
          Center(
            child: Image.asset(
              'assets/sprout.png',
              height: 120,
              fit: BoxFit.contain,
            ),
          ),

          // 2. 우측 상단 포인트 표시 (★ 여기가 120P라고 적혀있던 곳입니다)
          Positioned(
            top: 15,
            right: 15,
            child: Row(
              children: [
                const Text(
                  "현재 포인트: ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // ★★★ 여기를 수정했습니다! (고정된 숫자 -> DB 실시간 데이터) ★★★
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // 데이터가 아직 로딩 안 됐거나 없을 때
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Text("0 P", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16));
                    }

                    // DB에서 진짜 점수 가져오기
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final myPoint = data['point'] ?? 0;

                    return Text(
                      "$myPoint P",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green
                      ),
                    );
                  },
                ),
                // ★★★ 수정 끝 ★★★

                const SizedBox(width: 8),

                // 상점 아이콘
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShopScreen()),
                    );
                  },
                  child: const Icon(Icons.store, size: 24, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}