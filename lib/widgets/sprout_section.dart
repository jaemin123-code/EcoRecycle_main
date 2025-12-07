import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../shop/shop_screen.dart'; // 상점 이동을 위해 import

class SproutSection extends StatelessWidget {
  const SproutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220, // 캐릭터 크기에 맞춰 높이 조절 가능
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // 연한 초록색 배경 (사진과 유사하게)
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // 1. 중앙 캐릭터 이미지
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20), // 텍스트와 겹치지 않게 살짝 내림
                Image.asset(
                  'assets/sprout.png',
                  height: 130,
                  // 이미지가 없을 경우를 대비한 아이콘 (테스트용)
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.emoji_nature, size: 100, color: Colors.green);
                  },
                ),
              ],
            ),
          ),

          // 2. [추가] 왼쪽 상단: 환영 문구 (닉네임)
          const Positioned(
            top: 0,
            left: 0,
            child: _WelcomeMessage(),
          ),

          // 3. 오른쪽 상단: 현재 포인트 (상점 아이콘 포함)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // 포인트 누르면 상점으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopScreen()),
                );
              },
              child: const _PointDisplay(),
            ),
          ),
        ],
      ),
    );
  }
}

// 닉네임을 가져와서 보여주는 위젯
class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 로그인 안 된 상태면 기본 문구
    if (user == null) {
      return const Text("환영합니다!", style: TextStyle(fontWeight: FontWeight.bold));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String nickname = "환경지킴이"; // 기본 닉네임

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          nickname = data['nickname'] ?? "환경지킴이";
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "환영합니다",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  nickname, // 닉네임 표시
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  "님",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// 포인트를 가져와서 보여주는 위젯
class _PointDisplay extends StatelessWidget {
  const _PointDisplay();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        int point = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          point = data['point'] ?? 0;
        }

        return Row(
          children: [
            Text(
              "현재 포인트: $point P",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(width: 5),
            Icon(Icons.store, size: 20, color: Colors.green[700]),
          ],
        );
      },
    );
  }
}