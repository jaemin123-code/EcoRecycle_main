import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// [중요] 아까 만드신 api_key.dart 파일이 있다면 import 유지하시고,
// 만약 안 만드셨다면 아래 import를 지우고 _apiKey 변수에 직접 키를 넣으세요.


class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // API 키 가져오기 (api_key.dart 파일이 없다면 여기에 직접 'AIza...' 키를 넣으세요)
  static const String _apiKey = ;

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  int _currentPoints = 0;
  bool _isTyping = false; // AI 생각 중 로딩 표시

  // 초기 메시지
  final List<Map<String, String>> _messages = [
    {
      "role": "bot",
      "text": "안녕하세요! 🌱\n저는 환경부 베테랑 AI 상담사 '에코봇'입니다.\n\n분리배출 방법이나 환경 상식,\n무엇이든 물어봐 주세요!"
    }
  ];

  final List<String> _questionChips = [
    "💰 내 포인트 확인",
    "플라스틱 버리는 법",
    "건전지는 어떻게 버려?",
    "음식물 쓰레기 기준",
    "스티로폼 분리배출",
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserPoints();
    _initGemini();
  }

  void _initGemini() {
    _model = GenerativeModel(
      // [수정] 이제는 이게 정답입니다!
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system('너는 환경부 베테랑 공무원...'),
    );
    _chatSession = _model.startChat();
  }

  // 내 포인트 가져오기
  Future<void> _fetchUserPoints() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _currentPoints = doc.data()?['point'] ?? 0;
          });
        }
      }
    } catch (e) {
      print("포인트 로드 실패: $e");
    }
  }

  // 메시지 전송 함수 (여기가 아까 에러났던 부분! 수정완료)
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. 사용자 메시지 추가
    setState(() {
      _messages.add({"role": "user", "text": text});
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();

    String responseText = "";

    // 2. 답변 생성 로직
    // (A) 포인트 질문 (DB 연동)
    if (text.contains("포인트") || text.contains("점수")) {
      await Future.delayed(const Duration(milliseconds: 500));
      responseText = "현재 회원님의 환경 포인트는\n총 $_currentPoints P 입니다! 🌱\n\n분리배출 인증으로 더 모아보세요!";
    }
    // (B) AI 질문 (Gemini 연동)
    else {
      try {
        final response = await _chatSession.sendMessage(Content.text(text));
        responseText = response.text ?? "죄송해요, 답변을 생성하지 못했어요. 다시 물어봐 주세요.";
      } catch (e) {
        // [에러 진단 코드]
        print("🚨 AI 에러 발생: $e");

        if (e.toString().contains("API key not valid")) {
          responseText = "API 키가 잘못되었습니다. 키 복사 과정에서 공백이 들어갔는지 확인해보세요!";
        } else if (e.toString().contains("User location is not supported")) {
          responseText = "현재 위치(국가)에서는 사용할 수 없다고 하네요. (VPN 문제일 수 있습니다)";
        } else if (e.toString().contains("404")) {
          responseText = "모델을 찾을 수 없대요. 코드의 모델명이 'gemini-pro'인지 확인하세요.";
        } else {
          responseText = "오류가 발생했습니다. 인터넷 연결을 확인해주세요. 😢\n(에러코드: $e)";
        }
      }
    }

    // 3. 봇 답변 추가
    if (mounted) {
      setState(() {
        _messages.add({"role": "bot", "text": responseText});
        _isTyping = false;
      });
      _scrollToBottom();
    }
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
        title: const Text("AI 상담사 에코봇", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 채팅 리스트
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 10),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 16, backgroundColor: Colors.green, child: Icon(Icons.smart_toy, size: 20, color: Colors.white)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
                          child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green)),
                        ),
                      ],
                    ),
                  );
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg['role'] == 'bot', msg['text']!);
              },
            ),
          ),

          // 추천 질문
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _questionChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = _questionChips[index];
                final isPoint = label.contains("포인트");
                return ActionChip(
                  avatar: isPoint ? const Icon(Icons.monetization_on, size: 16, color: Colors.orange) : null,
                  label: Text(label),
                  backgroundColor: isPoint ? Colors.yellow[50] : Colors.white,
                  side: BorderSide(color: isPoint ? Colors.orange : Colors.green.withOpacity(0.5)),
                  onPressed: () => _sendMessage(label),
                );
              },
            ),
          ),

          // 입력창
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: "궁금한 걸 물어보세요...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
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
            const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.smart_toy_rounded, color: Colors.white)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isBot ? Colors.white : Colors.green,
                borderRadius: BorderRadius.circular(18).copyWith(
                  topLeft: isBot ? Radius.zero : const Radius.circular(18),
                  bottomRight: isBot ? const Radius.circular(18) : Radius.zero,
                ),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 3, offset: const Offset(0, 2))],
              ),
              child: Text(text, style: TextStyle(color: isBot ? Colors.black87 : Colors.white, fontSize: 15, height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }
}