import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/lotto_service.dart';

class SearchLottoPage extends StatefulWidget {
  const SearchLottoPage({
    super.key,
    required this.username,
    required this.userId,
  });

  final String username;
  final String userId;

  @override
  State<SearchLottoPage> createState() => _SearchLottoPageState();
}

class _SearchLottoPageState extends State<SearchLottoPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  List<LottoItem> _results = [];

  Future<void> _doSearch() async {
    if (!_formKey.currentState!.validate()) return;
    final q = _controller.text.trim();
    setState(() => _loading = true);
    try {
      final items = await LottoService.search(
        q,
      ); // ไม่กรองสถานะ; ถ้าจะกรอง ส่ง status: 'sell' หรือ 'sold'
      setState(() => _results = items);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ค้นหาล้มเหลว: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _doRandom() async {
    setState(() => _loading = true);
    try {
      final item = await LottoService.random(
        sellOnly: false,
      ); // true = สุ่มเฉพาะที่ยังขาย
      setState(() {
        _results = item == null ? [] : [item];
        _controller.text = item?.lottoNumber ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('สุ่มล้มเหลว: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _clear() {
    _controller.clear();
    setState(() => _results = []);
  }

  @override
  Widget build(BuildContext context) {
    const redHeader = Color(0xFFAD0101);
    const goldBorder = Color(0xFFE3BB66);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ค้นหาลอตเตอรี่',
          style: GoogleFonts.itim(fontWeight: FontWeight.w700),
        ),
        backgroundColor: redHeader,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                maxLength: 6,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'กรอกเลข 1–6 หลัก (2-3 จะเช็คตัวท้าย)',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'กรอกเลขก่อน';
                  if (!RegExp(r'^\d{1,6}$').hasMatch(t))
                    return 'ต้องเป็นตัวเลข 1–6 หลัก';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _doSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redHeader,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: goldBorder, width: 2),
                    ),
                    icon: const Icon(Icons.search),
                    label: Text(
                      'ค้นหา',
                      style: GoogleFonts.itim(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _doRandom,
                    icon: const Icon(Icons.casino),
                    label: Text(
                      'สุ่มจากฐานข้อมูล',
                      style: GoogleFonts.itim(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loading ? null : _clear,
                  icon: const Icon(Icons.clear),
                  tooltip: 'ล้าง',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        'ไม่มีผลลัพธ์',
                        style: GoogleFonts.itim(fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final it = _results[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: goldBorder, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 4,
                                offset: Offset(0, 1),
                                color: Colors.black12,
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: redHeader,
                              foregroundColor: Colors.white,
                              child: Text(
                                '${it.lottoId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              'เลข: ${it.lottoNumber}',
                              style: GoogleFonts.itim(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              'สถานะ: ${it.status}    ราคา: ${it.price.toStringAsFixed(2)}',
                              style: GoogleFonts.itim(fontSize: 14),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
