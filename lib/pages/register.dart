import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ----- ตัวอย่าง Model (ตามของเดิม) -----
class CustomerRegisterPostResponse {
  final String fullname;
  final String phone;
  final String email;
  final String image;
  final String password;

  CustomerRegisterPostResponse({
    required this.fullname,
    required this.phone,
    required this.email,
    required this.image,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'fullname': fullname,
    'phone': phone,
    'email': email,
    'image': image,
    'password': password,
  };
}

String customerRegisterPostResponseToJson(CustomerRegisterPostResponse data) {
  return jsonEncode(data.toJson());
}

// ----- หน้าสมัครสมาชิก -----
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtl = TextEditingController();
  final emailCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  final confirmCtl = TextEditingController();
  final moneyCtl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  String errorText = '';

  void createID() {
    final moneyText = moneyCtl.text.trim();
    final money = double.tryParse(moneyText);
    log(nameCtl.text);
    log(emailCtl.text);
    log(passwordCtl.text);
    log(confirmCtl.text);
    log(moneyCtl.text);

    if (nameCtl.text.isEmpty ||
        emailCtl.text.isEmpty ||
        passwordCtl.text.isEmpty ||
        confirmCtl.text.isEmpty ||
        moneyCtl.text.isEmpty) {
      setState(() => errorText = 'กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }
    if (passwordCtl.text != confirmCtl.text) {
      setState(() => errorText = 'รหัสผ่านไม่ตรงกัน');
      return;
    }
    if (money == null) {
      setState(() => errorText = 'กรอกจำนวนเงินได้เฉพาะตัวเลข');
      return;
    }

    if (money < 0) {
      setState(() => errorText = 'กรอกจำนวนเงินห้ามติดลบ');
      return;
    }

    final payload = CustomerRegisterPostResponse(
      fullname: nameCtl.text,
      phone: '', // ไม่มีช่องใน UI ตัวอย่าง
      email: emailCtl.text,
      image:
          'http://202.28.34.197:8888/contents/4a00cead-afb3-45db-a37a-c8bebe08fe0d.png',
      password: passwordCtl.text,
    );

    log(customerRegisterPostResponseToJson(payload));
    setState(() => errorText = '');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFEAF7EA), // เขียวอ่อนสดใส
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            titlePadding: const EdgeInsets.only(top: 20),
            title: Column(
              children: const [
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50), // เขียวสำเร็จ
                  size: 60,
                ),
                SizedBox(height: 12),
                Text(
                  'สำเร็จ!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32), // เขียวเข้ม
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: const Text(
              'สมัครสมาชิกเรียบร้อยแล้ว!',
              style: TextStyle(fontSize: 16, color: Color(0xFF4B4B4B)),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C), // เขียวเข้ม
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด dialog
                  Navigator.of(context).pop(); // กลับหน้าก่อนหน้า
                },
                child: const Text(
                  'ตกลง',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    nameCtl.dispose();
    emailCtl.dispose();
    passwordCtl.dispose();
    confirmCtl.dispose();
    moneyCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // สีสำรองกรณีรูปยังไม่โหลด
      backgroundColor: const Color(0xFFF9F1F7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/image/bg2.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                child: SafeArea(
                  bottom: false,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),

                      // --- Header: ปุ่ม Back + หัวข้อ ---
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 46,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFA60000),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10), // มนซ้ายบน
                                  bottomRight: Radius.circular(10), // มนขวาล่าง
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 37,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'สมัครสมาชิก',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8C1E14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 60), // เว้นขวาเท่าปุ่ม back
                        ],
                      ),

                      const SizedBox(height: 25),

                      // --- Form (มี Padding ครอบ) ---
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _InputCard(
                              child: TextField(
                                controller: nameCtl,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _InputCard(
                              child: TextField(
                                controller: emailCtl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _InputCard(
                              child: TextField(
                                controller: passwordCtl,
                                obscureText: _obscure1,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.black54,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed:
                                        () => setState(
                                          () => _obscure1 = !_obscure1,
                                        ),
                                    icon: Icon(
                                      _obscure1
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _InputCard(
                              child: TextField(
                                controller: confirmCtl,
                                obscureText: _obscure2,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.black54,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed:
                                        () => setState(
                                          () => _obscure2 = !_obscure2,
                                        ),
                                    icon: Icon(
                                      _obscure2
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _InputCard(
                              child: TextField(
                                controller: moneyCtl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Money',
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            if (errorText.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 6, top: 4),
                                child: Text(
                                  errorText,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 52,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8E2217),
                                      Color(0xFFB12E23),
                                      Color(0xFFC53A2E),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x33000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed:
                                      createID, //เช็คว่ามีuserนี้ยังและอีเมลยัง
                                  child: Text(
                                    'Create Account',
                                    style: GoogleFonts.carterOne(
                                      fontSize: 32,
                                      color: Color(0xFFFFD04D),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----- การ์ดหุ้ม TextField
class _InputCard extends StatelessWidget {
  const _InputCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2), // เทาอ่อนในภาพ
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFA8A8A9), // สีขอบเทา
          width: 1.2, // ความหนาขอบ
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000), // เงาอ่อน
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: child,
    );
  }
}
