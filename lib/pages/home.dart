import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/pages/navmenu.dart';
import 'package:myproject/pages/userprofile.dart';
import 'bottom_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required String username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
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
      bottomNavigationBar:
          const MyBottomNavigationBar(), // <-- เรียกใช้ Widget ใหม่ที่นี่
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.red[800],
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () {
            // โค้ดสำหรับนำทางไปยังหน้าโปรไฟล์
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LotteryUI(),
              ), // นำทางไป LotteryUI
            );
          },
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.red),
          ),
        ),
      ),
      title: Text(
        'โปรไฟล์',
        style: GoogleFonts.itim(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.red[800],
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Text(
        'วันนี้เฮงๆรวยๆ คุณ Tester',
        style: GoogleFonts.itim(fontSize: 24, color: Colors.white),
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
        child: Text(title, style: GoogleFonts.itim(color: Colors.white)),
      ),
    );
  }
}

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
          color: borderColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cardColor,
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
                      style: GoogleFonts.itim(
                        color: cardColor == Colors.red[800]
                            ? Colors.white
                            : Colors.grey[800],
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
                        style: GoogleFonts.itim(
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
                      style: GoogleFonts.itim(
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
                        style: GoogleFonts.itim(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'บาท',
                      style: GoogleFonts.itim(
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
