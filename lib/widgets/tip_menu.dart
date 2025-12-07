import 'package:flutter/material.dart';

class TipMenu extends StatelessWidget {
  const TipMenu({super.key});

  void _showTipPopup(BuildContext context, String title) {
    String tip = "";

    switch (title) {
      case "플라스틱":
        tip = """
♻️ 플라스틱 분리배출 TIP
1. 내용물을 깨끗이 비워주세요. 음식물이나 음료가 남아있으면 재활용이 어렵습니다.
2. 라벨은 제거하고, 뚜껑은 따로 분리해주세요.
3. 일회용 컵, 빨대, 비닐류와 혼합되지 않도록 주의합니다.
4. PET병(투명 생수병)은 찌그러뜨려 부피를 줄이면 수거 효율이 높습니다.
5. 플라스틱 종류별 분리배출 규정이 다르니, 가능하면 분류표 확인! 📝
""";
        break;

      case "종이류":
        tip = """
📄 **종이류 분리배출 TIP**
1. 오염되지 않은 종이만 배출하세요. (음식물, 기름 묻은 종이는 NO!)
2. 신문, 잡지, 책은 스프링, 클립, 비닐커버 제거 후 펼쳐서 배출
3. 골판지 상자는 찢어서 부피를 줄이면 수거 효율 UP 📦
4. 색연필, 스티커, 접착제 등으로 오염된 부분은 잘라서 일반쓰레기로
5. 깨끗하고 말린 종이만 배출하면 재활용 품질이 좋아집니다 ✅
""";
        break;

      case "유리병":
        tip = """
🍶 **유리병 분리배출 TIP**
1. 내용물을 비우고 깨끗이 헹궈주세요. 음식물 잔여물 제거 필수!
2. 병뚜껑은 금속으로 분리, 라벨 제거
3. 깨진 유리는 신문지로 감싸 안전하게 배출 📰
4. 색깔별로 분리: 투명, 갈색, 녹색 → 재활용 효율 증가
5. 유리병은 재활용률이 높으니 꼼꼼히 세척하면 환경 보호에 큰 도움이 됩니다 🌍
""";
        break;

      case "캔류":
        tip = """
🥫 **캔류 분리배출 TIP**
1. 음료, 음식 캔은 내용물 비우고 간단히 헹구기
2. 라벨은 제거하고, 뚜껑은 캔과 분리
3. 알루미늄, 철 캔 구분 가능하면 분리 배출
4. 캔을 눌러 부피 줄이면 수거 효율 UP
5. 캔류는 재활용률이 매우 높으니 깨끗하게 배출하는 것이 중요합니다 ✅
""";
        break;

      case "비닐":
        tip = """
🛍️ **비닐류 분리배출 TIP**
1. 쇼핑백, 포장 비닐은 깨끗하게 비우고 이물질 제거
2. 스티커, 테이프, 음식물 오염된 비닐은 일반쓰레기로
3. 분리배출용 비닐봉투에 모아서 배출
4. 비닐류는 재활용 과정에서 혼합되면 품질 저하 ⚠️
5. 가능한 한 재사용하고, 재활용 규정을 확인하세요!
""";
        break;

      default:
        tip = "이 제품은 분리배출 팁이 아직 없습니다.";
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("$title 분리배출 팁"),
          content: SingleChildScrollView(child: Text(tip)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("닫기"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        children: [
          tipCard(context, "플라스틱", Icons.recycling),
          tipCard(context, "종이류", Icons.menu_book),
          tipCard(context, "유리병", Icons.local_drink),
          tipCard(context, "캔류", Icons.local_cafe),
          tipCard(context, "비닐", Icons.shopping_bag),
        ],
      ),
    );
  }

  Widget tipCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () => _showTipPopup(context, title),
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.grey.shade300,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.green),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
