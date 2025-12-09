import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ★ [추가] 움직이는 캐릭터 위젯 불러오기
import '../character/animated_mascot.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  // 현재 상단에 표시될 이미지
  String topImage = 'assets/sprout.png';

  // 현재 착용 중인 드레스 인덱스 (-1이면 착용 안 함)
  int currentEquippedIndex = -1;

  // 아이템 데이터
  final List<Map<String, dynamic>> sprays = [
    {'image': 'assets/spray1.png', 'price': 100, 'growth': '8%', 'name': '기본 영양제'},
    {'image': 'assets/spray2.png', 'price': 200, 'growth': '10%', 'name': '고급 영양제'},
    {'image': 'assets/spray3.png', 'price': 300, 'growth': '12%', 'name': '특급 영양제'},
  ];

  final List<Map<String, dynamic>> dresses = [
    {'image': 'assets/dress1.png', 'price': 300, 'name': '스트로베리 드레스업'},
    {'image': 'assets/dress2.png', 'price': 300, 'name': '허니벌 드레스업'},
    {'image': 'assets/dress3.png', 'price': 400, 'name': '외계뿅뿅 드레스업'},
    {'image': 'assets/dress4.png', 'price': 150, 'name': '퐁실니트 드레스업'},
  ];

  // 구매 상태 관리
  late List<bool> sprayPurchased;
  late List<bool> dressOwned;

  // 로그인 유저 정보
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    sprayPurchased = List<bool>.filled(sprays.length, false);
    dressOwned = List<bool>.filled(dresses.length, false);
  }

  // 포인트 차감 + 사용 내역 저장 함수
  Future<bool> _deductPoints(int price, String itemName) async {
    if (user == null) return false;

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);

      return await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) return false;

        int currentPoints = snapshot.data()?['point'] ?? 0;

        if (currentPoints >= price) {
          // 1. 포인트 차감
          transaction.update(docRef, {'point': currentPoints - price});

          // 2. 사용 내역 기록 (수정할 부분)
          // ★★★ 사용자 문서 아래의 point_history 서브컬렉션에 기록하도록 수정 ★★★
          final historyRef = FirebaseFirestore.instance
              .collection('users').doc(user!.uid) // users/{uid} 문서
              .collection('point_history').doc(); // 그 아래 point_history 서브컬렉션

          transaction.set(historyRef, {
            'uid': user!.uid,
            'amount': price,
            'description': itemName,
            'type': 'use',
            'date': FieldValue.serverTimestamp(), // 'timestamp'를 'date'로 통일 (마이페이지 로직에 맞춤)
          });

          return true; // 성공
        } else {
          return false; // 잔액 부족
        }
      });
    } catch (e) {
      print("구매 오류: $e");
      return false;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Shop', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. 상단 미리보기 + 포인트 표시 영역
          Container(
            width: double.infinity,
            height: 180,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                // 초기화 버튼
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.grey),
                        tooltip: '초기화',
                        onPressed: () {
                          setState(() {
                            topImage = 'assets/sprout.png';
                            currentEquippedIndex = -1;
                          });
                          _showSnackBar('착용 상태가 초기화되었습니다.');
                        },
                      ),
                    ],
                  ),
                ),

                // ★ [수정됨] 중앙 이미지 -> 움직이는 캐릭터로 교체!
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedMascot(
                      imagePath: topImage, // 현재 선택된 이미지 경로 전달
                      width: 150,          // 크기 적절히 조절
                      height: 150,
                    ),
                  ),
                ),

                // 포인트 표시 (실시간 연동)
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('MY POINT', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Text("0 P", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green));
                          }
                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          final myPoint = data['point'] ?? 0;

                          return Text(
                            "$myPoint P",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. 분무기 리스트
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: sprays.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final spray = sprays[index];
                final int price = spray['price'];
                final String name = spray['name'] ?? '영양제';
                final bool isBought = sprayPurchased[index];

                return Container(
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(spray['image'], height: 50, fit: BoxFit.contain),
                      const SizedBox(height: 8),
                      Text('$price P', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBought ? Colors.grey : Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 30),
                        ),
                        onPressed: isBought ? null : () async {
                          bool success = await _deductPoints(price, name);
                          if (success) {
                            setState(() { sprayPurchased[index] = true; });
                            _showSnackBar('$name 구매 완료!');
                          } else {
                            _showSnackBar('포인트가 부족합니다!');
                          }
                        },
                        child: Text(isBought ? '완료' : '구매'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 3. 드레스 리스트
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: dresses.length,
              itemBuilder: (context, index) {
                final dress = dresses[index];
                final int price = dress['price'];
                final String name = dress['name'];
                final bool isOwned = dressOwned[index];
                final bool isEquipped = currentEquippedIndex == index;

                String btnText = !isOwned ? '$price P 구매' : (isEquipped ? '착용 중' : '착용하기');
                Color btnColor = !isOwned ? Colors.green : (isEquipped ? Colors.grey : Colors.orange);

                return GestureDetector(
                  onTap: () { setState(() { topImage = dress['image']; }); },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isEquipped ? Border.all(color: Colors.orange, width: 2) : Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(dress['image'], fit: BoxFit.contain),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(dress['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: btnColor, foregroundColor: Colors.white, minimumSize: const Size(100, 32)),
                                onPressed: isEquipped ? null : () async {
                                  if (!isOwned) {
                                    bool success = await _deductPoints(price, name);
                                    if (success) {
                                      setState(() { dressOwned[index] = true; });
                                      _showSnackBar('$name 구매 완료!');
                                    } else {
                                      _showSnackBar('포인트가 부족합니다!');
                                    }
                                  } else {
                                    setState(() {
                                      currentEquippedIndex = index;
                                      topImage = dress['image'];
                                    });
                                    _showSnackBar('아이템을 착용했습니다.');
                                  }
                                },
                                child: Text(btnText, style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}