import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/bg4.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              // ใช้ _LotteryCard คลาสเดียว
              _buildSection(
                'เลขเด็ดงวดนี้',
                const Color.fromARGB(216, 198, 161, 40)!,
                [
                  _LotteryCard(
                    title: 'ชุดที่ 33',
                    number: '4 2 3 1 4 7',
                    price: '80',
                    cardColor: Colors.red[800]!,
                    borderColor: const Color.fromARGB(255, 254, 229, 4),
                    cartColor: const Color.fromARGB(255, 254, 229, 4),
                  ),
                  _LotteryCard(
                    title: 'ชุดที่ 52',
                    number: '4 2 3 1 4 7',
                    price: '80',
                    cardColor: Colors.red[800]!,
                    borderColor: const Color.fromARGB(255, 254, 229, 4),
                    cartColor: const Color.fromARGB(255, 254, 229, 4),
                  ),
                  _LotteryCard(
                    title: 'ชุดที่ 99',
                    number: '4 2 3 1 4 7',
                    price: '80',
                    cardColor: Colors.red[800]!,
                    borderColor: const Color.fromARGB(255, 254, 229, 4),
                    cartColor: const Color.fromARGB(255, 254, 229, 4),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // ใช้ _LotteryCard คลาสเดียวสำหรับส่วนที่ 2
              _buildSection('เลขมงคล', const Color.fromARGB(255, 255, 4, 4)!, [
                _LotteryCard(
                  title: 'ชุดที่ 40',
                  number: '4 7 5 1 2 7',
                  price: '80',
                  cardColor: const Color.fromARGB(255, 253, 214, 108),
                  borderColor: const Color.fromARGB(255, 252, 184, 35),
                  cartColor: const Color.fromARGB(255, 230, 32, 10),
                ),
                _LotteryCard(
                  title: 'ชุดที่ 1',
                  number: '7 3 4 4 7 6',
                  price: '80',
                  cardColor: const Color.fromARGB(255, 253, 214, 108),
                  borderColor: const Color.fromARGB(255, 252, 184, 35),
                  cartColor: const Color.fromARGB(255, 230, 32, 10),
                ),
              ]),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.red[800],
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.red),
        ),
      ),
      title: const Text(
        'โปรไฟล์',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      // actions: const [
      //   Padding(
      //     padding: EdgeInsets.only(right: 16.0),
      //     child: Icon(Icons.notifications, color: Colors.white),
      //   ),
      // ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.red[800],
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: const Text(
        'วันนี้เฮงๆรวยๆ คุณ Tester',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSection(String title, Color headerColor, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, color: headerColor),
        ...cards,
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.red[800],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.account_balance_wallet,
              label: 'กระเป๋า',
              color: Colors.green,
            ),
            _buildNavItem(
              icon: Icons.verified,
              label: 'ตรวจรางวัล',
              color: Colors.blue,
            ),
            _buildNavItem(
              icon: Icons.search,
              label: 'ค้นหาเลข',
              color: Colors.brown,
            ),
            _buildNavItem(
              icon: Icons.shopping_cart,
              label: 'ตะกร้า',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 0,
        right: 16.0,
        top: 8.0,
        bottom: 16.0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(9.0),
            bottomRight: Radius.circular(9.0),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// รวม _LotteryCard และ _LotteryCard2
class _LotteryCard extends StatelessWidget {
  final String title;
  final String number;
  final String price;
  final Color cardColor;
  final Color borderColor;
  final Color cartColor;
  final bool showCartIcon;

  const _LotteryCard({
    required this.title,
    required this.number,
    required this.price,
    required this.cardColor,
    required this.borderColor,
    required this.cartColor,
    this.showCartIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: borderColor, // ใช้ borderColor เป็นสีขอบ
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          margin: const EdgeInsets.all(
            6,
          ), // ทำให้เกิดช่องว่างระหว่างขอบกับเนื้อหา
          decoration: BoxDecoration(
            color: cardColor, // ใช้ cardColor เป็นสีพื้นหลังการ์ด
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: cardColor == Colors.red[800]
                            ? Colors.white
                            : Colors.grey[800], // ปรับสีตัวอักษรตามสีพื้นหลัง
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        number,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'ราคา',
                      style: TextStyle(
                        color: cardColor == Colors.red[800]
                            ? Colors.white
                            : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        price,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'บาท',
                      style: TextStyle(
                        color: cardColor == Colors.red[800]
                            ? Colors.white
                            : Colors.grey[800],
                      ),
                    ),
                    if (showCartIcon)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: cartColor,
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
