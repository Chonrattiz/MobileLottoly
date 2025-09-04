import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSection('เลขเด็ดงวดนี้', Colors.red[800]!, [
              _LotteryCard(
                title: 'ชุดที่ 33',
                number: '4 2 3 1 4 7',
                price: '80',
                accentColor: const Color(0xFFB5934E),
              ),
              _LotteryCard(
                title: 'ชุดที่ 52',
                number: '4 2 3 1 4 7',
                price: '80',
                accentColor: const Color(0xFFB5934E),
              ),
              _LotteryCard(
                title: 'ชุดที่ 99',
                number: '4 2 3 1 4 7',
                price: '80',
                accentColor: const Color(0xFFB5934E),
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection('เลขมงคล', Colors.orange[800]!, [
              _LotteryCard2(
                title: 'ชุดที่ 40',
                number: '4 7 5 1 2 7',
                price: '80',
                accentColor: const Color(0xFFE2B45A),
                cardColor: const Color.fromARGB(255, 60, 91, 40),
              ),
              _LotteryCard2(
                title: 'ชุดที่ 1',
                number: '7 3 4 4 7 6',
                price: '80',
                accentColor: const Color(0xFFE2B45A),
              ),
            ]),
            const SizedBox(height: 50),
          ],
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
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(Icons.notifications, color: Colors.white),
        ),
      ],
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

class _LotteryCard extends StatelessWidget {
  final String title;
  final String number;
  final String price;
  final Color accentColor;
  final bool showCartIcon;
  final Color cardColor;

  const _LotteryCard({
    required this.title,
    required this.number,
    required this.price,
    required this.accentColor,
    this.showCartIcon = true,
    this.cardColor = const Color.fromARGB(255, 229, 216, 75),
  });

  @override
  Widget build(BuildContext context) {
    const Color goldBorderColor = Color(0xFFFFD700);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: goldBorderColor, width: 6.0),
        ),
        child: Card(
          margin: const EdgeInsets.all(0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: Colors.red[800],
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
                      style: const TextStyle(
                        color: Colors.white,
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
                    const Text('ราคา', style: TextStyle(color: Colors.white)),
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
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('บาท', style: TextStyle(color: Colors.white)),
                    if (showCartIcon)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: accentColor,
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

class _LotteryCard2 extends StatelessWidget {
  final String title;
  final String number;
  final String price;
  final Color accentColor;
  final bool showCartIcon;
  final Color cardColor;

  const _LotteryCard2({
    required this.title,
    required this.number,
    required this.price,
    required this.accentColor,
    this.showCartIcon = true,
    this.cardColor = const Color.fromARGB(255, 229, 216, 75),
  });

  @override
  Widget build(BuildContext context) {
    const Color goldBorderColor = Color(0xFFFFD700);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color.fromARGB(255, 252, 184, 35),
            width: 6.0,
          ),
        ),
        child: Card(
          margin: const EdgeInsets.all(0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: const Color.fromARGB(255, 253, 214, 108),
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
                      style: const TextStyle(
                        color: Colors.white,
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
                    const Text('ราคา', style: TextStyle(color: Colors.white)),
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
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('บาท', style: TextStyle(color: Colors.white)),
                    if (showCartIcon)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: accentColor,
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
