import 'package:flutter/material.dart';
// [필수] 파이어베이스 패키지 추가
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 기존 데이터 파일 import
import 'package:Ecorecycle/guide/recycle_data.dart';
import 'package:Ecorecycle/guide/recycle_model.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // [수정] 포인트 변수 (초기값 0)
  int _currentPoints = 0;
  // 로딩 상태 확인용
  bool _isLoading = true;

  // 채팅 메시지 리스트
  final List<Map<String, String>> _messages = [
    {
      "role": "bot",
      "text": "안녕하세요! 🌱\n저는 에코리사이클 AI 도우미입니다.\n\n궁금한 쓰레기 이름을 입력하거나,\n아래 버튼을 눌러보세요!"
    }
  ];

  final List<String> _questionChips = [
    "💰 내 포인트 확인",
    "플라스틱 버리는 법",
    "종이류 버리는 법",
    "캔류/유리병 버리는 법",
    "비닐류 버리는 법",
    "스티로폼 버리는 법",
    "건전지 버리는 법",
    "음식물 쓰레기 기준",
  ];

  @override
  void initState() {
    super.initState();
    // [중요] 앱이 켜지자마자 내 포인트를 가져옵니다.
    _fetchUserPoints();
  }

  // 🔥 [NEW] Firebase에서 내 포인트 가져오는 함수
  Future<void> _fetchUserPoints() async {
    try {
      // 1. 현재 로그인한 사용자 가져오기
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // 2. Firestore의 'users' 컬렉션에서 내 UID 문서 찾기
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          // 3. 'point' 필드 값 가져오기 (필드명이 'point'라고 가정)
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _currentPoints = data['point'] ?? 0; // 없으면 0
            _isLoading = false;
          });
        }
      } else {
        // 로그인 안 된 상태
        setState(() {
          _currentPoints = 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("포인트 불러오기 실패: $e");
      setState(() => _isLoading = false);
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _controller.clear();
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 500), () {
      String response = _generateBotResponse(text);
      setState(() {
        _messages.add({"role": "bot", "text": response});
      });
      _scrollToBottom();
    });
  }

  // 3. 답변 생성 로직 (업그레이드 버전)
  String _generateBotResponse(String input) {
    // 사용자가 입력한 문장에 포함된 단어를 기준으로 답변을 찾습니다.

    // (0) 기본 인사 및 감성 대화
    if (input.contains("안녕") || input.contains("반가")) {
      return "안녕하세요! 오늘도 지구를 지키러 오셨군요! 🌱\n무엇을 도와드릴까요?";
    }
    if (input.contains("고마") || input.contains("감사")) {
      return "별말씀을요! 에코리사이클과 함께해주셔서 감사합니다. 💚";
    }
    if (input.contains("누구") || input.contains("소개")) {
      return "저는 여러분의 분리배출을 돕는 AI 상담사 '에코봇'입니다! 🤖";
    }

    // (1) 포인트 질문
    if (input.contains("포인트") || input.contains("점수")) {
      if (_isLoading) {
        return "잠시만요, 포인트 장부를 확인하고 있어요... 📖";
      }
      return "현재 회원님의 환경 포인트는\n총 $_currentPoints P 입니다! 🌱";
    }

    // (2) 플라스틱 (페트병 포함)
    else if (input.contains("플라스틱") || input.contains("페트") || input.contains("pet")) {
      return _formatGuide(recycleData[0]);
    }
    // (3) 종이/박스
    else if (input.contains("종이") || input.contains("박스") || input.contains("책") || input.contains("신문")) {
      return _formatGuide(recycleData[1]);
    }
    // (4) 캔/유리
    else if (input.contains("캔") || input.contains("유리") || input.contains("병") || input.contains("통조림")) {
      return _formatGuide(recycleData[2]);
    }
    // (5) 비닐 (뽁뽁이 포함)
    else if (input.contains("비닐") || input.contains("뽁뽁이") || input.contains("필름")) {
      if (recycleData.length > 3) return _formatGuide(recycleData[3]);
      return "🥡 [비닐류 배출 팁]\n\n• 음식물 등 이물질을 깨끗이 씻어주세요.\n• 흩날리지 않게 투명 봉투에 담아 배출!\n• 스티커가 붙은 비닐은 제거하거나 일반쓰레기로 버려주세요.";
    }
    // (6) 스티로폼
    else if (input.contains("스티로폼") || input.contains("스펀지")) {
      return "📦 [스티로폼 배출 팁]\n\n• 흰색 스티로폼만 배출 가능합니다.\n• 테이프와 운송장 스티커는 완전히 제거해주세요.\n• 코팅된 유색 스티로폼이나 과일 포장망은 종량제 봉투에 버려주세요!";
    }
    // (7) 건전지/형광등
    else if (input.contains("건전지") || input.contains("배터리") || input.contains("형광등")) {
      return "🔋 [유해 폐기물 주의]\n\n건전지와 형광등은 일반 쓰레기가 아닙니다!\n화재 및 환경 오염 위험이 있으니 반드시 아파트나 주민센터의 '전용 수거함'에 넣어주세요.";
    }
    // (8) 음식물
    else if (input.contains("음식물") || input.contains("뼈") || input.contains("껍질")) {
      return "🍎 [음식물 쓰레기 기준]\n\n• 동물이 먹을 수 있으면 음식물, 아니면 일반쓰레기!\n• 뼈(치킨/족발), 조개껍데기, 달걀껍질, 딱딱한 씨앗은 '일반쓰레기'입니다.";
    }

    // 그 외 모르는 질문
    else {
      return "죄송해요, 아직 배우고 있는 중이라 잘 모르겠어요. 😢\n'플라스틱', '캔', '안녕' 처럼 핵심 단어로 물어봐 주시겠어요?";
    }
  }

  String _formatGuide(RecycleGuide guide) {
    StringBuffer sb = StringBuffer();
    sb.writeln("📢 [${guide.title}] 배출 방법");
    sb.writeln("💡 핵심: ${guide.subTitle}\n");
    sb.writeln("✅ 이렇게 버려주세요:");
    for (var step in guide.steps) sb.writeln("• $step");
    if (guide.possibleItems.isNotEmpty) {
      sb.writeln("\n🙆 가능 품목:\n• ${guide.possibleItems[0].name} 등");
    }
    return sb.toString();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI 상담사"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isBot = msg['role'] == 'bot';
                return _buildMessageBubble(isBot, msg['text']!);
              },
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _questionChips.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = _questionChips[index];
                final isPointButton = label.contains("포인트");

                return ActionChip(
                  avatar: isPointButton
                      ? const Icon(Icons.monetization_on, size: 18, color: Colors.orange)
                      : null,
                  label: Text(label),
                  backgroundColor: isPointButton ? Colors.yellow[50] : Colors.white,
                  surfaceTintColor: isPointButton ? Colors.yellow[100] : Colors.green[50],
                  side: BorderSide(
                    color: isPointButton
                        ? Colors.orange.withOpacity(0.5)
                        : Colors.green.withOpacity(0.5),
                  ),
                  labelStyle: TextStyle(
                    color: isPointButton ? Colors.orange[900] : Colors.green[800],
                    fontSize: 13,
                    fontWeight: isPointButton ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () => _sendMessage(label),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt_rounded, color: Colors.green),
                  onPressed: () {
                    // 카메라 기능
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "궁금한 쓰레기를 물어보세요...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(bool isBot, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(Icons.smart_toy_rounded, color: Colors.green),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBot ? Colors.white : Colors.green,
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: isBot ? Radius.zero : const Radius.circular(16),
                  bottomRight: isBot ? const Radius.circular(16) : Radius.zero,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)
                ],
              ),
              child: Text(text,
                  style: TextStyle(color: isBot ? Colors.black87 : Colors.white, height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }
}