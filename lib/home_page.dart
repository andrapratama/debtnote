import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:debtnote/add_debt_page.dart';
import 'package:debtnote/add_payment_page.dart';
import 'package:debtnote/db_helper.dart';
import 'package:debtnote/screens/bayar_tab.dart';
import 'package:debtnote/screens/dashboard_tab.dart';
import 'package:debtnote/screens/utang_tab.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DbHelper _dbHelper = DbHelper();

  // State
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _utangList = [];
  List<Map<String, dynamic>> _bayarList = [];
  int _totalUtang = 0;
  int _totalBayar = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final utangData = await _dbHelper.getUtangList();
    final bayarData = await _dbHelper.getBayarList();

    int totalUtang =
        utangData.fold(0, (sum, item) => sum + (item['nilai'] as int));
    int totalBayar =
        bayarData.fold(0, (sum, item) => sum + (item['nilai'] as int));

    setState(() {
      _utangList = utangData;
      _bayarList = bayarData;
      _totalUtang = totalUtang;
      _totalBayar = totalBayar;
    });
  }

  String formatRupiah(int number) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(number);
  }

  void _deleteUtang(int id) async {
    await _dbHelper.deleteUtang(id);
    _refreshData();
  }

  void _deleteBayar(int id) async {
    await _dbHelper.deleteBayar(id);
    _refreshData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- LOGIKA EXPORT/IMPORT ---
  Future<void> _exportData() async {
    try {
      final utangData = await _dbHelper.getUtangList();
      final bayarData = await _dbHelper.getBayarList();

      if (utangData.isEmpty && bayarData.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak ada data untuk diekspor.")),
        );
        return;
      }

      Map<String, dynamic> backupData = {
        'utang': utangData,
        'bayar': bayarData,
      };

      String jsonString = jsonEncode(backupData);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/backup_catatan_utang.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Backup Data Catatan Utang');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gagal Ekspor: $e")));
    }
  }

  Future<void> _importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();

        if (!mounted) return;
        bool confirm = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Peringatan Impor"),
                content: const Text(
                  "Impor akan MENGHAPUS SEMUA data saat ini dan menggantinya dengan data dari file backup. Lanjutkan?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Batal"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("TIMPA DATA",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ) ??
            false;

        if (confirm) {
          await _dbHelper.deleteAllUtang();
          await _dbHelper.deleteAllBayar();

          // Logika baru untuk menangani format lama (List) dan baru (Map)
          final dynamic decodedJson = jsonDecode(content);

          if (decodedJson is Map<String, dynamic>) {
            // Format BARU: Map dengan kunci 'utang' dan 'bayar'
            if (decodedJson.containsKey('utang')) {
              List<dynamic> utangJson = decodedJson['utang'];
              for (var item in utangJson) {
                await _dbHelper.insertUtang({
                  'tanggal': item['tanggal'],
                  'keterangan': item['keterangan'],
                  'nilai': item['nilai'],
                });
              }
            }
            if (decodedJson.containsKey('bayar')) {
              List<dynamic> bayarJson = decodedJson['bayar'];
              for (var item in bayarJson) {
                await _dbHelper.insertBayar({
                  'tanggal': item['tanggal'],
                  'keterangan': item['keterangan'],
                  'nilai': item['nilai'],
                });
              }
            }
          } else if (decodedJson is List) {
            // Format LAMA: List berisi data utang saja
            for (var item in decodedJson) {
               await _dbHelper.insertUtang({
                'tanggal': item['tanggal'],
                'keterangan': item['keterangan'],
                'nilai': item['nilai'],
              });
            }
          }

          _refreshData();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data berhasil diimpor!")),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File rusak atau format salah!")),
      );
    }
  }

  // --- UI WIDGETS ---

  Widget _buildFloatingActionButton() {
    if (_selectedIndex == 0) {
      return Container(); // Tidak ada FAB di Dashboard
    }
    return FloatingActionButton(
      backgroundColor: _selectedIndex == 1 ? Colors.red : Colors.green,
      child: const Icon(Icons.add, color: Colors.white),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                _selectedIndex == 1 ? const AddDebtPage() : const AddPaymentPage(),
          ),
        );
        if (result == true) _refreshData();
      },
    );
  }

  Widget _buildTotalBar() {
    if (_selectedIndex == 0) {
      return Container(); // Tidak ada total bar di dashboard
    }

    String title = _selectedIndex == 1 ? "Total Utang" : "Total Pembayaran";
    int total = _selectedIndex == 1 ? _totalUtang : _totalBayar;
    Color color = _selectedIndex == 1 ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            formatRupiah(total),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardTab(
        totalUtang: _totalUtang,
        totalBayar: _totalBayar,
        onRefresh: _refreshData,
      ),
      UtangTab(
        utangList: _utangList,
        onDelete: _deleteUtang,
        onRefresh: _refreshData,
      ),
      BayarTab(
        bayarList: _bayarList,
        onDelete: _deleteBayar,
        onRefresh: _refreshData,
      ),
    ];

    final List<String> pageTitles = [
      "Dashboard",
      "Daftar Utang",
      "Daftar Pembayaran"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[_selectedIndex]),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') _exportData();
              if (value == 'import') _importData();
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.upload, color: Colors.teal),
                      SizedBox(width: 8),
                      Text("Backup (Export)"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.download, color: Colors.teal),
                      SizedBox(width: 8),
                      Text("Restore (Import)"),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTotalBar(),
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.arrow_upward),
                label: 'Utang',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.arrow_downward),
                label: 'Bayar',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.teal,
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }
}
