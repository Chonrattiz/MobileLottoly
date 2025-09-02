import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_oracel999/pages/register.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  void login(BuildContext context) {
    final data = {"phone": "0817399999", "password": "1111"};
    log(jsonEncode(data));
    // TODO: call API ของคุณ
  }

  void register(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // สีเผื่อกรณีรูปยังไม่โหลด
      backgroundColor: const Color(0xFFF9F1F7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              // ให้ความสูงขั้นต่ำเท่าหน้าจอ และยืดตามความสูงของคอนเทนต์
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                // พื้นหลังแบบภาพ (จะคลุมเต็มพื้นที่เสมอ)
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/image/bg2.png"),
                    fit: BoxFit.cover, // ครอบให้เต็มพื้นที่
                    alignment: Alignment.center, // ครอบตรงกลาง
                  ),
                ),
                child: SafeArea(
                  bottom: false, // ให้พื้นหลังต่อถึงขอบล่าง
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),

                        // โลโก้
                        Image.asset(
                          'assets/image/logo.png',
                          height: 400,
                          fit: BoxFit.contain,
                        ),

                        // Email
                        _InputCard(
                          child: TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password + show/hide
                        _InputCard(
                          child: TextField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              border: InputBorder.none,
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.black54,
                              ),
                              suffixIcon: IconButton(
                                onPressed:
                                    () => setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ปุ่ม Login 
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFF3AB0A,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () => login(context),
                            child: Text(
                              'Login',
                              style: GoogleFonts.carterOne(
                                fontSize: 32,
                                color: Color(0xFFB51823), // แดงเข้ม
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // สมัครสมาชิก 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'คุณยังไม่มีบัญชีใช่ไหม ',
                              style: GoogleFonts.inter(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => register(context),
                              child: Text(
                                'สมัครสมาชิก',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF057CE4),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF057CE4),
                                  decorationThickness: 1.5,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Spacer ดันให้คอนเทนต์ไม่ชิดล่างเกินไป (ถ้าต้องการ)
                        const SizedBox(height: 12),
                      ],
                    ),
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

/// การ์ดครอบ TextField
class _InputCard extends StatelessWidget {
  const _InputCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFA8A8A9), // สีขอบ
          width: 2.0, // ความหนาของขอบ (ค่า default = 1.0)
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: child,
    );
  }
}
