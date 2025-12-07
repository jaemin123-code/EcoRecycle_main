import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 대화 내용을 담을 리스트
  final List<Map<String, dynamic>> _messages = [
    {
      "text": "안녕하세요! 🌱\n저는 에코리사이클 AI 도우미입니다.\n무엇을 도와드릴까요?",
      "isUser": false,
    }
  ];

  // 발표용 '빠른 질문' 버튼 목록
  final List<String> _quickQuestions = [
    "내 포인트 확인",
    "플라스틱 버리는 법",
    "캔류 버리는 법",
    "유리병 버리는 법",
    "오늘의 환경 퀴즈",
  ];

  // 메시지 전송 처리 함수
  void _handleSubmitted(String text) {
    _textController.clear();
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isUser": true});
    });
    _scrollToBottom();

    // 챗봇 응답 (약간의 딜레이 후 실행)
    Future.delayed(const Duration(milliseconds: 500), () {
      _botResponse(text);
    });
  }

  // 챗봇의 지능 (규칙 기반 + Firebase 연동)
  Future<void> _botResponse(String input) async {
    String response = "";

    if (input.contains("포인트")) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          // DB에서 내 정보 가져오기
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            final myPoint = data['point'] ?? 0;
            response = "💰 현재 고객님의 포인트는 $myPoint P 입니다.\n분리배출 인증을 하면 더 쌓을 수 있어요!";
          } else {
            response = "회원 정보를 찾을 수 없습니다. 😢";
          }
        } catch (e) {
          response = "포인트를 조회하는 중 오류가 발생했습니다.";
        }
      } else {
        response = "로그인이 필요한 서비스입니다.";
      }
    } else if (input.contains("플라스틱")) {
      response = "🥤 [플라스틱 배출 팁]\n내용물을 깨끗이 비우고, 상표 라벨을 제거한 뒤 압착해서 버려주세요.";
    } else if (input.contains("캔")) {
      response = "🥫 [캔류 배출 팁]\n내용물을 비우고 헹군 뒤, 찌그러뜨려 배출해주세요. 뚜껑은 따로 모으는 것이 좋습니다.";
    } else if (input.contains("유리")) {
      response = "🍾 [유리병 배출 팁]\n깨지지 않게 조심하고, 뚜껑을 제거한 뒤 내용물을 비워서 배출해주세요.\n깨진 유리는 신문지에 싸서 일반 종량제 봉투에 버려야 합니다.";
    } else if (input.contains("퀴즈")) {
      response = "Q. 피자 박스는 종이류일까요?\n\n정답: 아닙니다! ❌\n기름이 묻은 피자 박스는 재활용이 불가능하므로 일반 쓰레기로 버려야 합니다.";
    } else {
      response = "죄송합니다. 아직 배우고 있는 중이라 잘 모르겠어요. 😅\n아래 버튼을 눌러서 질문해 주세요!";
    }

    if (mounted) {
      setState(() {
        _messages.add({"text": response, "isUser": false});
      });
      _scrollToBottom();
    }
  }

  // 화면 스크롤을 맨 아래로 내리기
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
        title: const Text("AI 상담사", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'];
                return Row(
                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser) const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
                    ),
                    if (!isUser) const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.green[100] : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
                            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                          ),
                        ),
                        child: Text(
                          msg['text'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: _quickQuestions.map((q) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ActionChip(
                    label: Text(q),
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    onPressed: () => _handleSubmitted(q),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "메시지를 입력하세요...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}