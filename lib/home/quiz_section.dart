import 'package:flutter/material.dart';

// 홈 화면에서 보여지는 퀴즈 버튼
class QuizSection extends StatelessWidget {
  const QuizSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 버튼 누르면 새 페이지로 이동
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
          boxShadow: [BoxShadow(color: Colors.orange.shade100, blurRadius: 6, offset: const Offset(0,4))],
        ),
        child: Row(
          children: [
            const Icon(Icons.quiz, color: Colors.orange, size: 40),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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

// 새 창으로 열리는 퀴즈 페이지
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentStep = 0;
  int currentQuestionIndex = 0;
  Map<int, int> correctAnswersCount = {};

// 분리수거/환경 퀴즈 50문제 (10단계, 단계별 5문제)
  final List<List<Map<String, dynamic>>> quizData = [
    // 1단계 (중학생 수준, 5문제)
    [
      {
        'question': '플라스틱 병을 버릴 때 가장 먼저 해야 하는 일은?',
        'options': ['뚜껑을 닫는다', '내용물을 비운다', '라벨을 제거한다', '그냥 버린다'],
        'answer': 1,
        'explanation': '재활용 효율을 위해 플라스틱 병은 내용물을 비우고 배출해야 합니다.'
      },
      {
        'question': '종이컵은 어떤 통에 넣어야 할까요?',
        'options': ['플라스틱', '종이', '유리', '음식물'],
        'answer': 1,
        'explanation': '종이컵은 종이류로 분리배출해야 합니다.'
      },
      {
        'question': '유리병을 버릴 때 주의할 점은?',
        'options': ['뚜껑 제거', '깨끗하게 세척', '색깔별 구분', '모두 해당'],
        'answer': 3,
        'explanation': '유리병은 뚜껑 제거, 세척, 색깔별 구분 후 배출해야 합니다.'
      },
      {
        'question': '음식물 쓰레기는 어느 통에 넣어야 할까요?',
        'options': ['플라스틱', '종이', '유리', '음식물'],
        'answer': 3,
        'explanation': '음식물 쓰레기는 음식물 전용 통에 버립니다.'
      },
      {
        'question': '페트병 뚜껑은 어떻게 처리해야 할까요?',
        'options': ['뚜껑과 함께 버린다', '뚜껑 제거 후 버린다', '종이 통에 넣는다', '버리지 않는다'],
        'answer': 1,
        'explanation': '뚜껑은 제거하고 병만 배출해야 재활용 효율이 높습니다.'
      },
    ],

    // 2단계 (중학생 수준, 5문제)
    [
      {
        'question': '종이박스에 음식물이 묻어 있다면 어떻게 해야 할까요?',
        'options': ['그냥 버린다', '오염된 부분 제거 후 종이 통에 버린다', '플라스틱 통에 넣는다', '재사용만 한다'],
        'answer': 1,
        'explanation': '오염된 부분을 제거하고 종이류로 배출하면 재활용이 가능합니다.'
      },
      {
        'question': '캔류를 버리기 전 처리해야 하는 일은?',
        'options': ['내용물을 비운다', '라벨 제거', '압착', '모두 해당'],
        'answer': 3,
        'explanation': '캔류는 내용물을 비우고, 라벨 제거 후 압착하여 배출해야 합니다.'
      },
      {
        'question': '플라스틱과 종이를 동시에 섞어 버리면 발생하는 문제는?',
        'options': ['재활용 불가', '환경 오염', '자원 낭비', '모두 해당'],
        'answer': 3,
        'explanation': '혼합 배출 시 재활용이 어려워 환경 오염과 자원 낭비가 발생합니다.'
      },
      {
        'question': '유리병 색깔을 구분하는 이유는?',
        'options': ['재활용 효율 향상', '미관상 보기 좋음', '안전 문제', '모두 해당'],
        'answer': 0,
        'explanation': '유리병 색깔별 분류는 재활용 효율을 높이기 위함입니다.'
      },
      {
        'question': '일반 비닐봉투는 어느 통에 버려야 할까요?',
        'options': ['플라스틱', '종이', '음식물', '재활용 불가'],
        'answer': 3,
        'explanation': '일반 비닐봉투는 재활용이 어렵기 때문에 쓰레기 통에 버립니다.'
      },
    ],

    // 3단계 (고등학생 수준, 5문제)
    [
      {
        'question': 'PET병 라벨은 왜 제거해야 할까요?',
        'options': ['재활용 과정 방해', '색 혼합 방지', '화학적 처리 필요', '모두 해당'],
        'answer': 3,
        'explanation': '라벨 제거는 재활용 과정에서 문제를 방지하고 효율을 높이기 위해 필요합니다.'
      },
      {
        'question': '재활용 플라스틱을 분류하는 기준이 아닌 것은?',
        'options': ['재질 종류', '색상', '브랜드', '용도'],
        'answer': 2,
        'explanation': '브랜드는 재활용 분류 기준이 되지 않습니다.'
      },
      {
        'question': '종이류를 재활용할 때 가장 큰 문제는 무엇인가요?',
        'options': ['오염', '습기', '크기', '색상'],
        'answer': 0,
        'explanation': '오염된 종이는 재활용이 어렵습니다.'
      },
      {
        'question': '캔류를 재활용할 때 압착하는 이유는?',
        'options': ['부피 축소', '재활용 효율', '운반 비용 절감', '모두 해당'],
        'answer': 3,
        'explanation': '캔을 압착하면 부피가 줄고 운반 효율과 재활용 효율이 모두 향상됩니다.'
      },
      {
        'question': '재활용 플라스틱의 화학적 변형을 방지하는 방법은?',
        'options': ['혼합 배출 금지', '고온 세척', '색상 혼합', '압착'],
        'answer': 0,
        'explanation': '재질별 분리 배출을 통해 화학적 변형을 방지합니다.'
      },
    ],

    // 4단계 (고등학생 수준, 5문제)
    [
      {
        'question': '유리병 재활용 과정에서 깨진 유리가 문제되는 이유는?',
        'options': ['기계 손상', '재활용 효율 저하', '안전 문제', '모두 해당'],
        'answer': 3,
        'explanation': '깨진 유리는 기계 손상, 효율 저하, 안전 문제를 모두 유발합니다.'
      },
      {
        'question': '재활용 종이류에서 코팅된 종이는 어떻게 분류되나요?',
        'options': ['플라스틱', '종이', '유리', '재활용 불가'],
        'answer': 0,
        'explanation': '코팅 종이는 재활용 플라스틱으로 분류됩니다.'
      },
      {
        'question': '페트병 재활용 시 색상별 분류가 중요한 이유는?',
        'options': ['제품 색상 유지', '재활용 과정 효율', '소재 혼합 방지', '모두 해당'],
        'answer': 3,
        'explanation': '색상별 분류는 제품 품질과 재활용 효율을 위해 필요합니다.'
      },
      {
        'question': '캔류 재활용 시 남은 음식물 문제는?',
        'options': ['부패', '악취', '재활용 불가', '모두 해당'],
        'answer': 3,
        'explanation': '음식물이 남아 있으면 부패, 악취, 재활용 불가 문제가 발생합니다.'
      },
      {
        'question': '재활용 과정에서 플라스틱을 세척하는 이유는?',
        'options': ['오염 제거', '냄새 제거', '재활용 효율 향상', '모두 해당'],
        'answer': 3,
        'explanation': '세척을 통해 오염과 냄새를 제거하고 재활용 효율을 높입니다.'
      },
    ],

    // 5단계 (성인 수준, 5문제)
    [
      {
        'question': '일회용 플라스틱 사용 제한 정책이 효과적인 이유는?',
        'options': ['폐기물 감소', '재활용 비용 절감', '환경오염 감소', '모두 해당'],
        'answer': 3,
        'explanation': '정책은 폐기물, 비용, 환경오염 모두 감소에 기여합니다.'
      },
      {
        'question': '재활용 플라스틱 혼합 배출 시 발생하는 화학적 문제는?',
        'options': ['물성 변화', '재활용 불가', '환경 오염', '모두 해당'],
        'answer': 3,
        'explanation': '혼합 배출 시 플라스틱의 물성 변화와 재활용 불가, 환경 오염이 발생합니다.'
      },
      {
        'question': '종이류 재활용 과정에서 첨가되는 화학약품의 주 목적은?',
        'options': ['오염 제거', '색상 보존', '섬유 재생', '모두 해당'],
        'answer': 3,
        'explanation': '화학약품은 오염 제거, 색상 보존, 섬유 재생을 위해 사용됩니다.'
      },
      {
        'question': '유리병 재활용 과정에서 색상 혼합 시 문제점은?',
        'options': ['제품 품질 저하', '재활용 효율 감소', '폐기 증가', '모두 해당'],
        'answer': 3,
        'explanation': '색상 혼합은 제품 품질 저하와 재활용 효율 감소, 폐기 증가를 초래합니다.'
      },
      {
        'question': '재활용 쓰레기 운반 비용 절감 방법으로 적절한 것은?',
        'options': ['압축', '재질별 분리', '대형 수거 차량 사용', '모두 해당'],
        'answer': 3,
        'explanation': '압축, 분리, 대형 차량 모두 운반 비용 절감에 기여합니다.'
      },
    ],

    // 6~10단계도 성인 난이도, 정책/환경 영향/재활용 효율/국제 사례 등 심화 문제로 구성
    [
      // 6단계
      {
        'question': 'EU에서 플라스틱 세금이 도입된 주된 이유는?',
        'options': ['재활용 장려', '플라스틱 사용 억제', '환경 오염 감소', '모두 해당'],
        'answer': 3,
        'explanation': '세금은 재활용 장려, 사용 억제, 환경 오염 감소 모두 목적입니다.'
      },
      {
        'question': '폐전자제품 처리 시 주의해야 하는 중금속은?',
        'options': ['납', '수은', '카드뮴', '모두 해당'],
        'answer': 3,
        'explanation': '폐전자제품에는 납, 수은, 카드뮴 등 여러 중금속이 포함되어 있습니다.'
      },
      {
        'question': '재활용 과정에서 플라스틱 라벨 제거를 자동화하면 장점은?',
        'options': ['효율 증가', '인건비 감소', '제품 품질 유지', '모두 해당'],
        'answer': 3,
        'explanation': '자동화하면 효율, 비용, 품질 모두 개선됩니다.'
      },
      {
        'question': '혼합 재활용품을 분리하는 첨단 기술은?',
        'options': ['X-ray 분류', '센서 기반 AI 분류', '물리적 회전식 분류', '모두 해당'],
        'answer': 3,
        'explanation': '혼합 재활용품 분리는 여러 첨단 기술을 통해 진행됩니다.'
      },
      {
        'question': '재활용 산업에서 재활용율을 낮추는 요인은?',
        'options': ['오염', '혼합 배출', '정책 미비', '모두 해당'],
        'answer': 3,
        'explanation': '오염, 혼합 배출, 정책 미비 모두 재활용율 감소 원인입니다.'
      },
    ],

    // 7단계
    [
      {
        'question': '분리배출 기준이 지역별로 다른 이유는?',
        'options': ['재활용 시설 차이', '지자체 정책 차이', '인구 밀도 차이', '모두 해당'],
        'answer': 3,
        'explanation': '지역별 재활용 시설, 정책, 인구 밀도 차이 때문에 기준이 다릅니다.'
      },
      {
        'question': '플라스틱 폐기물 소각 시 발생하는 환경 문제는?',
        'options': ['이산화탄소 증가', '다이옥신 발생', '대기오염', '모두 해당'],
        'answer': 3,
        'explanation': '소각 시 CO2 증가, 다이옥신 발생, 대기오염 등 문제가 발생합니다.'
      },
      {
        'question': 'PET병 재활용률이 낮은 이유로 적절한 것은?',
        'options': ['오염', '수거율 부족', '재활용 시설 제한', '모두 해당'],
        'answer': 3,
        'explanation': '오염, 수거율 부족, 재활용 시설 제한 모두 영향 줍니다.'
      },
      {
        'question': '재활용 과정에서 폐기물의 에너지 회수 장점은?',
        'options': ['재활용 불가 재료 활용', '에너지 비용 절감', '환경 영향 감소', '모두 해당'],
        'answer': 3,
        'explanation': '에너지 회수를 통해 활용 불가 재료 활용, 비용 절감, 환경 영향 감소가 가능합니다.'
      },
      {
        'question': '재활용 정책 평가 시 가장 중요한 지표는?',
        'options': ['수거율', '재활용율', '환경 영향', '모두 해당'],
        'answer': 3,
        'explanation': '수거율, 재활용율, 환경 영향 모두 정책 평가에 중요합니다.'
      },
    ],

    // 8단계
    [
      {
        'question': '폐유리병을 다른 유리와 혼합하면 발생하는 문제는?',
        'options': ['제품 강도 저하', '재활용 공정 문제', '폐기물 증가', '모두 해당'],
        'answer': 3,
        'explanation': '혼합 시 제품 강도 저하, 재활용 문제, 폐기물 증가가 발생합니다.'
      },
      {
        'question': '친환경 포장재로 재활용률이 낮은 이유는?',
        'options': ['재질 복합', '오염', '소각 처리', '모두 해당'],
        'answer': 3,
        'explanation': '재질이 복합되거나 오염되면 재활용이 어렵고 소각 처리되는 경우도 있습니다.'
      },
      {
        'question': '유리 재활용 과정에서 색상 분류 실패 시 문제점은?',
        'options': ['신제품 품질 저하', '폐기물 증가', '재활용 효율 감소', '모두 해당'],
        'answer': 3,
        'explanation': '품질 저하, 폐기물 증가, 효율 감소 문제가 발생합니다.'
      },
      {
        'question': '재활용 산업에서 인공지능을 활용하는 목적은?',
        'options': ['분류 정확도 향상', '비용 절감', '처리 속도 향상', '모두 해당'],
        'answer': 3,
        'explanation': 'AI를 활용하면 분류 정확도, 비용, 처리 속도 모두 개선됩니다.'
      },
      {
        'question': '플라스틱 재활용 과정에서 PVC 혼입 문제는?',
        'options': ['재활용 불가', '화학적 변형', '제품 품질 저하', '모두 해당'],
        'answer': 3,
        'explanation': 'PVC 혼입 시 재활용 불가, 화학적 변형, 제품 품질 저하 문제가 발생합니다.'
      },
    ],

    // 9단계
    [
      {
        'question': '재활용 산업에서 ‘다운사이클링’ 의미는?',
        'options': ['원료 가치 유지', '가치 하락 재활용', '재활용 불가', '환경 오염'],
        'answer': 1,
        'explanation': '다운사이클링은 재활용 과정에서 원래 재료보다 가치가 낮아지는 것을 의미합니다.'
      },
      {
        'question': '재활용 산업에서 플라스틱 물성 변화를 막는 방법은?',
        'options': ['재질 분리', '색상 분리', '온도 관리', '모두 해당'],
        'answer': 3,
        'explanation': '재질·색상 분리, 온도 관리 등을 통해 물성 변화를 방지합니다.'
      },
      {
        'question': '유리 재활용 시 최종 제품 품질 저하 요인이 아닌 것은?',
        'options': ['색상 혼합', '이물 혼입', '압축 과정', '재활용 공정 오류'],
        'answer': 2,
        'explanation': '압축 과정은 유리 재활용 품질에 큰 영향을 주지 않습니다.'
      },
      {
        'question': '재활용 정책 평가에서 ‘EPR(생산자 책임 재활용)’의 목적은?',
        'options': ['생산자에게 재활용 비용 부담', '소비자 부담 완화', '재활용율 향상', '모두 해당'],
        'answer': 3,
        'explanation': 'EPR은 생산자가 재활용 비용 부담을 통해 재활용율을 높이는 제도입니다.'
      },
      {
        'question': '재활용 공정에서 자동화 장비 도입의 장점이 아닌 것은?',
        'options': ['분류 효율 향상', '인건비 절감', '재활용 품질 저하', '처리 속도 증가'],
        'answer': 2,
        'explanation': '자동화 장비는 품질을 저하시킬 이유가 없습니다.'
      },
    ],

    // 10단계
    [
      {
        'question': '재활용 산업에서 PVC 플라스틱 혼입을 막는 최선의 방법은?',
        'options': ['재질별 배출 강화', '수거 후 수동 분류', '혼합 배출 허용', '화학적 처리'],
        'answer': 0,
        'explanation': '재질별 배출을 강화하면 PVC 혼입을 예방할 수 있습니다.'
      },
      {
        'question': '재활용품 수거율을 높이는 가장 효과적인 방법은?',
        'options': ['정책 강화', '소비자 교육', '수거 인프라 개선', '모두 해당'],
        'answer': 3,
        'explanation': '정책, 교육, 인프라 개선 모두 수거율 향상에 기여합니다.'
      },
      {
        'question': '재활용 과정에서 화학적 혼합으로 인해 발생하는 문제는?',
        'options': ['재활용 불가', '제품 품질 저하', '환경 오염', '모두 해당'],
        'answer': 3,
        'explanation': '화학적 혼합은 재활용 불가, 품질 저하, 환경 오염 문제를 모두 유발합니다.'
      },
      {
        'question': '재활용 산업에서 "업사이클링"의 의미는?',
        'options': ['원료 가치 유지', '가치 상승 재활용', '재활용 불가', '폐기물 증가'],
        'answer': 1,
        'explanation': '업사이클링은 재활용 과정에서 원래 재료보다 가치가 높아지는 것을 의미합니다.'
      },
      {
        'question': '세계적으로 플라스틱 폐기물 문제를 해결하는 가장 효과적인 정책은?',
        'options': ['재활용 장려', '일회용 제한', '해양 쓰레기 수거', '모두 해당'],
        'answer': 3,
        'explanation': '모두의 정책이 복합적으로 시행되어야 플라스틱 폐기물 문제를 완화할 수 있습니다.'
      },
    ],
  ];


  void answerQuestion(int selectedIndex) {
    bool isCorrect =
        selectedIndex == quizData[currentStep][currentQuestionIndex]['answer'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white, // 피드백 창 배경 흰색
        title: Text(
          isCorrect ? '정답입니다!' : '틀렸습니다!',
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
                  correctAnswersCount[currentStep] =
                      (correctAnswersCount[currentStep] ?? 0) + 1;
                }
                if (currentQuestionIndex <
                    quizData[currentStep].length - 1) {
                  currentQuestionIndex++;
                } else {
                  currentQuestionIndex = 0;
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
      backgroundColor: Colors.white, // 전체 배경 흰색으로 통일
      appBar: AppBar(
        title: const Text("환경 퀴즈"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // 단계 선택 버튼
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white, // 문제 영역과 같은 색
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: quizData.length,
              itemBuilder: (context, step) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentStep == step
                          ? Colors.green
                          : Colors.grey.shade300,
                      foregroundColor:
                      currentStep == step ? Colors.white : Colors.black87,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 이미지 (크기 축소)
                  Image.asset(
                    'assets/quiz.png',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  // 단계 진행
                  Text(
                    '단계 ${currentStep + 1}  ${correctAnswersCount[currentStep] ?? 0}/${quizData[currentStep].length}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  // 문제 텍스트
                  Text(
                    currentQuestion['question'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // 선택지 버튼
                  Column(
                    children: List.generate(
                        currentQuestion['options'].length, (index) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // 버튼 흰색
                            foregroundColor: Colors.black87, // 텍스트 검정
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => answerQuestion(index),
                          child: Text(currentQuestion['options'][index]),
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