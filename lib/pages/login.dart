// lib/pages/login_page.dart

import 'package:app_oracel999/pages/home.dart';
import 'package:app_oracel999/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Imports ที่สะอาดและเป็นระเบียบ ---
import '../api/api_service.dart';
import '../model/request/login_request.dart';
import '../model/response/login_response.dart';

import 'package:app_oracel999/admim/AdminMain.dart';
import '../model/response/user_response.dart';  // ✅ import User class


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _apiService = ApiService();

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // --- ฟังก์ชัน Login---
  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty) {
      _showError('กรุณากรอกอีเมลที่ถูกต้อง');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final request = LoginRequest(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      final User user = await _apiService.login(request);



      if (user.role.toLowerCase() == 'admin') {
        // ✅ ถ้า role เป็น admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => AdminMain(
                  username: user.username,
                  userId: user.userId,
                  role: user.role,
                ),
          ),
        );
      } else {
        // ✅ ถ้า role เป็น user/member ปกติ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => HomeScreen(username: user.username, userId: user.userId),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // โค้ดส่วน UI ทั้งหมดสามารถใช้ของเดิมได้เลย
    // แค่เปลี่ยน onPressed ของปุ่ม Login ให้เรียกใช้ฟังก์ชัน _login()
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
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Image.asset('assets/image/logo.png', height: 400),
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
                                onPressed:
                                    () => setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
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
                            ),
                            onPressed: _isLoading ? null : _login,
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
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
                              style: GoogleFonts.inter(fontSize: 18),
                            ),
                            TextButton(
                              onPressed: _goToRegister,
                              child: Text(
                                'สมัครสมาชิก',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF057CE4),
                                  decoration: TextDecoration.underline,
                                  fontSize: 20,
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
            ),
          );
        },
      ),
    );
  }
}

// Widget _InputCard ไม่ต้องแก้ไข
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
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
