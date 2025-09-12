// lib/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Imports ที่สะอาดและเป็นระเบียบ ---
import '../api/api_service.dart';
import '../model/request/register_request.dart';

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
  final _apiService = ApiService(); // สร้าง Instance ของ ApiService

  bool _obscure1 = true;
  bool _obscure2 = true;
  String _errorText = '';
  bool _isLoading = false;

  @override
  void dispose() {
    nameCtl.dispose();
    emailCtl.dispose();
    passwordCtl.dispose();
    confirmCtl.dispose();
    moneyCtl.dispose();
    super.dispose();
  }

  // --- ฟังก์ชันสมัครสมาชิกที่สั้น, สะอาด, และอ่านง่าย ---
  Future<void> _createAccount() async {
    // --- 1. ตรวจสอบข้อมูลในฟอร์ม (Validation) ---
    final money = double.tryParse(moneyCtl.text.trim());
    if (nameCtl.text.isEmpty ||
        emailCtl.text.isEmpty ||
        passwordCtl.text.isEmpty ||
        confirmCtl.text.isEmpty ||
        moneyCtl.text.isEmpty) {
      setState(() => _errorText = 'กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }
    if (passwordCtl.text != confirmCtl.text) {
      setState(() => _errorText = 'รหัสผ่านไม่ตรงกัน');
      return;
    }
    if (money == null || money < 0) {
      setState(() => _errorText = 'กรุณากรอกจำนวนเงินให้ถูกต้อง');
      return;
    }
    setState(() {
      _errorText = '';
      _isLoading = true;
    });

    // --- 2. เรียกใช้ API ผ่าน Service ---
    try {
      final request = RegisterRequest(
        username: nameCtl.text.trim(),
        email: emailCtl.text.trim(),
        password: passwordCtl.text,
        wallet: money,
      );
      await _apiService.register(request);

      // --- 3. ถ้าสำเร็จ: แสดง Dialog และกลับไปหน้า Login ---
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.replaceFirst('Exception: ', ''))),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('สำเร็จ!'),
            content: const Text('สมัครสมาชิกเรียบร้อยแล้ว!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ปิด Dialog
                  Navigator.of(context).pop(); // กลับไปหน้า Login
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // โค้ดส่วน UI ทั้งหมดสามารถใช้ของเดิมได้เลย
    // แค่เปลี่ยน onPressed ของปุ่มให้เรียกใช้ฟังก์ชัน _createAccount()
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
                    image: AssetImage('assets/image/bg2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 46,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFFA60000),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 37,
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
                          const SizedBox(width: 60),
                        ],
                      ),
                      const SizedBox(height: 25),
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
                                  prefixIcon: Icon(Icons.person),
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
                                  prefixIcon: Icon(Icons.email),
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
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    onPressed:
                                        () => setState(
                                          () => _obscure1 = !_obscure1,
                                        ),
                                    icon: Icon(
                                      _obscure1
                                          ? Icons.visibility
                                          : Icons.visibility_off,
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
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    onPressed:
                                        () => setState(
                                          () => _obscure2 = !_obscure2,
                                        ),
                                    icon: Icon(
                                      _obscure2
                                          ? Icons.visibility
                                          : Icons.visibility_off,
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
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            if (_errorText.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Text(
                                  _errorText,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB12E23),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _createAccount,
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : Text(
                                          'Create Account',
                                          style: GoogleFonts.carterOne(
                                            fontSize: 32,
                                            color: const Color(0xFFFFD04D),
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

// Widget _InputCard ไม่ต้องแก้ไข
class _InputCard extends StatelessWidget {
  const _InputCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA8A8A9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
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
