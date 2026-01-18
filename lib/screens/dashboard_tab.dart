import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardTab extends StatelessWidget {
  final int totalUtang;
  final int totalBayar;
  final Function onRefresh;

  const DashboardTab({
    super.key,
    required this.totalUtang,
    required this.totalBayar,
    required this.onRefresh,
  });

  String formatRupiah(int number) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    // Jika angka negatif, format secara manual
    if (number < 0) {
      return '-${currencyFormatter.format(number.abs())}';
    }
    return currencyFormatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final int sisaUtang = totalUtang - totalBayar;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSummaryCard(
                title: "SISA UTANG",
                amount: sisaUtang,
                color: sisaUtang > 0 ? Colors.orange : Colors.teal,
                isLarge: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: "TOTAL UTANG",
                      amount: totalUtang,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildSummaryCard(
                      title: "TOTAL DIBAYAR",
                      amount: totalBayar,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              const Icon(Icons.swipe_down, size: 30, color: Colors.grey),
              const Text("Tarik ke bawah untuk refresh", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int amount,
    required Color color,
    bool isLarge = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: isLarge ? const EdgeInsets.all(25.0) : const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isLarge ? 18 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formatRupiah(amount),
              style: TextStyle(
                fontSize: isLarge ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
