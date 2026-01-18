import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:debtnote/db_helper.dart';

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key});

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final DbHelper _dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    // Set tanggal hari ini sebagai default
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  // Simpan data
  void _saveData() async {
    if (_descController.text.isEmpty || _valueController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Harap isi semua kolom!")));
      return;
    }

    await _dbHelper.insertBayar({
      'tanggal': _dateController.text,
      'keterangan': _descController.text,
      'nilai': int.parse(_valueController.text),
    });

    if (!mounted) return;
    Navigator.pop(context, true); // Kembali ke home dengan sinyal refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Pembayaran"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Tanggal
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Tanggal",
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 15),

            // Input Keterangan
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Keterangan (misal: Bayar Utang Budi)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Input Nilai
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Nilai (Rp)",
                border: OutlineInputBorder(),
                prefixText: "Rp ",
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saveData,
                child: const Text("SIMPAN", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
