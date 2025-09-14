import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:test_t1/register.dart';
import 'package:test_t1/admim/search_lotto.dart';
import 'package:test_t1/admim/AdminMain.dart'; // ✅ นำทางไปหน้าแอดมิน

// ✅ utility baseUrl (ถ้าไม่อยากใช้ก็แก้ Uri.parse(...) กลับเป็น 10.0.2.2 ได้)
class Env {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void register(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Future<void> login(BuildContext context) async {
    if (_emailCtrl.text.isEmpty || !_emailCtrl.text.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกอีเมลที่ถูกต้อง')));
      return;
    }

    if (_passwordCtrl.text.isEmpty || _passwordCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัว')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      "email": _emailCtrl.text.trim(),
      "password": _passwordCtrl.text,
    };

    try {
      final response = await http
          .post(
            Uri.parse('${Env.baseUrl}/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if ((responseData['status'] ?? '').toString().toLowerCase() ==
            'success') {
          // โครงสร้างตาม backend:
          // {
          //   status, message,
          //   user: { user_id, username, email, role, wallet }
          // }
          final user = (responseData['user'] as Map?) ?? {};
          final username = (user['username'] ?? 'ผู้ใช้').toString();
          final userId = (user['user_id'] ?? user['id'] ?? '').toString();
          final role = (user['role'] ?? '').toString().toLowerCase();

          if (userId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login สำเร็จ แต่ไม่ได้รับ User ID จาก Server'),
              ),
            );
            setState(() => _isLoading = false);
            return;
          }

          // ✅ นำทางตาม role
          if (role == 'admin') {
            // ใน LoginPage เมื่อ role == 'admin'
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AdminMain(
                  username: username,
                  userId: userId,
                  role: role, // 'admin'
                ),
              ),
            );
          } else {
            // member หรือค่าอื่น → หน้าใช้งานทั่วไป
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SearchLottoPage(username: username, userId: userId),
              ),
            );
          }
        } else {
          final msg = responseData['message'] ?? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ (${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F1F7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/image/bg2.png"),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        Image.asset(
                          'assets/image/logo.png',
                          height: 400,
                          fit: BoxFit.contain,
                        ),
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
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
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
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3AB0A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _isLoading ? null : () => login(context),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: GoogleFonts.carterOne(
                                      fontSize: 32,
                                      color: const Color(0xFFB51823),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'คุณยังไม่มีบัญชีใช่ไหม ',
                              style: GoogleFonts.inter(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            TextButton(
                              onPressed: () => register(context),
                              child: Text(
                                'สมัครสมาชิก',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF057CE4),
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xFF057CE4),
                                  decorationThickness: 1.5,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
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

class _InputCard extends StatelessWidget {
  const _InputCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA8A8A9), width: 2.0),
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
