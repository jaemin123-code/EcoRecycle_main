import 'package:flutter/material.dart';
// ★ [중요] 캐릭터 위젯 import (경로가 다르면 수정해주세요)
import '../character/animated_mascot.dart';

// ==========================================
// 1. 홈 화면에서 보이는 버튼 (QuizSection)
// ==========================================
class QuizSection extends StatelessWidget {
  const QuizSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 버튼 누르면 퀴즈 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuizPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.orange.shade100,
                blurRadius: 6,
                offset: const Offset(0, 4)
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.quiz, color: Colors.orange, size: 40),
            const SizedBox(width: 15),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "환경 퀴즈 시작",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "재미있게 환경 지식 테스트",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. 새 창으로 열리는 퀴즈 페이지 (QuizPage)
// ==========================================
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentStep = 0;
  int currentQuestionIndex = 0;
  Map<int, int> correctAnswersCount = {};

  // 퀴즈 데이터 (기존 데이터 유지)
  final List<List<Map<String, dynamic>>> quizData = [
    // 1단계
    [
      {'question': '플라스틱 병을 버릴 때 가장 먼저 해야 하는 일은?', 'options': ['뚜껑을 닫는다', '내용물을 비운다', '라벨을 제거한다', '그냥 버린다'], 'answer': 1, 'explanation': '재활용 효율을 위해 플라스틱 병은 내용물을 비우고 배출해야 합니다.'},
      {'question': '종이컵은 어떤 통에 넣어야 할까요?', 'options': ['플라스틱', '종이', '유리', '음식물'], 'answer': 1, 'explanation': '종이컵은 종이류로 분리배출해야 합니다.'},
      {'question': '유리병을 버릴 때 주의할 점은?', 'options': ['뚜껑 제거', '깨끗하게 세척', '색깔별 구분', '모두 해당'], 'answer': 3, 'explanation': '유리병은 뚜껑 제거, 세척, 색깔별 구분 후 배출해야 합니다.'},
      {'question': '음식물 쓰레기는 어느 통에 넣어야 할까요?', 'options': ['플라스틱', '종이', '유리', '음식물'], 'answer': 3, 'explanation': '음식물 쓰레기는 음식물 전용 통에 버립니다.'},
      {'question': '페트병 뚜껑은 어떻게 처리해야 할까요?', 'options': ['뚜껑과 함께 버린다', '뚜껑 제거 후 버린다', '종이 통에 넣는다', '버리지 않는다'], 'answer': 1, 'explanation': '뚜껑은 제거하고 병만 배출해야 재활용 효율이 높습니다.'},
    ],
    // 2단계
    [
      {'question': '종이박스에 음식물이 묻어 있다면 어떻게 해야 할까요?', 'options': ['그냥 버린다', '오염된 부분 제거 후 종이 통에 버린다', '플라스틱 통에 넣는다', '재사용만 한다'], 'answer': 1, 'explanation': '오염된 부분을 제거하고 종이류로 배출하면 재활용이 가능합니다.'},
      {'question': '캔류를 버리기 전 처리해야 하는 일은?', 'options': ['내용물을 비운다', '라벨 제거', '압착', '모두 해당'], 'answer': 3, 'explanation': '캔류는 내용물을 비우고, 라벨 제거 후 압착하여 배출해야 합니다.'},
      {'question': '플라스틱과 종이를 동시에 섞어 버리면 발생하는 문제는?', 'options': ['재활용 불가', '환경 오염', '자원 낭비', '모두 해당'], 'answer': 3, 'explanation': '혼합 배출 시 재활용이 어려워 환경 오염과 자원 낭비가 발생합니다.'},
      {'question': '유리병 색깔을 구분하는 이유는?', 'options': ['재활용 효율 향상', '미관상 보기 좋음', '안전 문제', '모두 해당'], 'answer': 0, 'explanation': '유리병 색깔별 분류는 재활용 효율을 높이기 위함입니다.'},
      {'question': '일반 비닐봉투는 어느 통에 버려야 할까요?', 'options': ['플라스틱', '종이', '음식물', '재활용 불가'], 'answer': 3, 'explanation': '일반 비닐봉투는 재활용이 어렵기 때문에 쓰레기 통에 버립니다.'},
    ],
    // 3단계
    [
      {'question': 'PET병 라벨은 왜 제거해야 할까요?', 'options': ['재활용 과정 방해', '색 혼합 방지', '화학적 처리 필요', '모두 해당'], 'answer': 3, 'explanation': '라벨 제거는 재활용 과정에서 문제를 방지하고 효율을 높이기 위해 필요합니다.'},
      {'question': '재활용 플라스틱을 분류하는 기준이 아닌 것은?', 'options': ['재질 종류', '색상', '브랜드', '용도'], 'answer': 2, 'explanation': '브랜드는 재활용 분류 기준이 되지 않습니다.'},
      {'question': '종이류를 재활용할 때 가장 큰 문제는 무엇인가요?', 'options': ['오염', '습기', '크기', '색상'], 'answer': 0, 'explanation': '오염된 종이는 재활용이 어렵습니다.'},
      {'question': '캔류를 재활용할 때 압착하는 이유는?', 'options': ['부피 축소', '재활용 효율', '운반 비용 절감', '모두 해당'], 'answer': 3, 'explanation': '캔을 압착하면 부피가 줄고 운반 효율과 재활용 효율이 모두 향상됩니다.'},
      {'question': '재활용 플라스틱의 화학적 변형을 방지하는 방법은?', 'options': ['혼합 배출 금지', '고온 세척', '색상 혼합', '압착'], 'answer': 0, 'explanation': '재질별 분리 배출을 통해 화학적 변형을 방지합니다.'},
    ],
    // 4단계
    [
      {'question': '유리병 재활용 과정에서 깨진 유리가 문제되는 이유는?', 'options': ['기계 손상', '재활용 효율 저하', '안전 문제', '모두 해당'], 'answer': 3, 'explanation': '깨진 유리는 기계 손상, 효율 저하, 안전 문제를 모두 유발합니다.'},
      {'question': '재활용 종이류에서 코팅된 종이는 어떻게 분류되나요?', 'options': ['플라스틱', '종이', '유리', '재활용 불가'], 'answer': 0, 'explanation': '코팅 종이는 재활용 플라스틱으로 분류됩니다.'},
      {'question': '페트병 재활용 시 색상별 분류가 중요한 이유는?', 'options': ['제품 색상 유지', '재활용 과정 효율', '소재 혼합 방지', '모두 해당'], 'answer': 3, 'explanation': '색상별 분류는 제품 품질과 재활용 효율을 위해 필요합니다.'},
      {'question': '캔류 재활용 시 남은 음식물 문제는?', 'options': ['부패', '악취', '재활용 불가', '모두 해당'], 'answer': 3, 'explanation': '음식물이 남아 있으면 부패, 악취, 재활용 불가 문제가 발생합니다.'},
      {'question': '재활용 과정에서 플라스틱을 세척하는 이유는?', 'options': ['오염 제거', '냄새 제거', '재활용 효율 향상', '모두 해당'], 'answer': 3, 'explanation': '세척을 통해 오염과 냄새를 제거하고 재활용 효율을 높입니다.'},
    ],
    // 5단계
    [
      {'question': '일회용 플라스틱 사용 제한 정책이 효과적인 이유는?', 'options': ['폐기물 감소', '재활용 비용 절감', '환경오염 감소', '모두 해당'], 'answer': 3, 'explanation': '정책은 폐기물, 비용, 환경오염 모두 감소에 기여합니다.'},
      {'question': '재활용 플라스틱 혼합 배출 시 발생하는 화학적 문제는?', 'options': ['물성 변화', '재활용 불가', '환경 오염', '모두 해당'], 'answer': 3, 'explanation': '혼합 배출 시 플라스틱의 물성 변화와 재활용 불가, 환경 오염이 발생합니다.'},
      {'question': '종이류 재활용 과정에서 첨가되는 화학약품의 주 목적은?', 'options': ['오염 제거', '색상 보존', '섬유 재생', '모두 해당'], 'answer': 3, 'explanation': '화학약품은 오염 제거, 색상 보존, 섬유 재생을 위해 사용됩니다.'},
      {'question': '유리병 재활용 과정에서 색상 혼합 시 문제점은?', 'options': ['제품 품질 저하', '재활용 효율 감소', '폐기 증가', '모두 해당'], 'answer': 3, 'explanation': '색상 혼합은 제품 품질 저하와 재활용 효율 감소, 폐기 증가를 초래합니다.'},
      {'question': '재활용 쓰레기 운반 비용 절감 방법으로 적절한 것은?', 'options': ['압축', '재질별 분리', '대형 수거 차량 사용', '모두 해당'], 'answer': 3, 'explanation': '압축, 분리, 대형 차량 모두 운반 비용 절감에 기여합니다.'},
    ],
  ];

  void answerQuestion(int selectedIndex) {
    bool isCorrect = selectedIndex == quizData[currentStep][currentQuestionIndex]['answer'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          isCorrect ? '정답입니다! 🎉' : '틀렸습니다! 😢',
          style: TextStyle(color: isCorrect ? Colors.green : Colors.red),
        ),
        content: Text(
          quizData[currentStep][currentQuestionIndex]['explanation'],
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (isCorrect) {
                  correctAnswersCount[currentStep] = (correctAnswersCount[currentStep] ?? 0) + 1;
                }

                // 다음 문제로 이동
                if (currentQuestionIndex < quizData[currentStep].length - 1) {
                  currentQuestionIndex++;
                } else {
                  currentQuestionIndex = 0;
                  // 단계 완료 메시지나 처리를 여기에 추가할 수 있습니다.
                }
              });
            },
            child: const Text('다음 문제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = quizData[currentStep][currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("환경 퀴즈", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 단계 선택 버튼
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: quizData.length,
              itemBuilder: (context, step) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentStep == step ? Colors.green : Colors.grey.shade200,
                      foregroundColor: currentStep == step ? Colors.white : Colors.black87,
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        currentStep = step;
                        currentQuestionIndex = 0;
                      });
                    },
                    child: Text('단계 ${step + 1}'),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // ★ [수정됨] 정지된 이미지 대신 "움직이는 캐릭터" 추가!
                  // 기존: Image.asset('assets/quiz.png', ...)
                  const SizedBox(height: 10),
                  AnimatedMascot(
                    imagePath: 'assets/quiz.png', // ★ 이미지 파일명 확인 필수!
                    width: 300,
                    height: 300,
                  ),
                  const SizedBox(height: 20),

                  // 진행 상황
                  Text(
                    '단계 ${currentStep + 1}  •  맞춘 문제: ${correctAnswersCount[currentStep] ?? 0} / ${quizData[currentStep].length}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // 문제 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      currentQuestion['question'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 선택지 버튼들
                  Column(
                    children: List.generate(
                        currentQuestion['options'].length, (index) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => answerQuestion(index),
                          child: Text(
                            currentQuestion['options'][index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}