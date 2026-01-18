import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BayarTab extends StatelessWidget {
  final List<Map<String, dynamic>> bayarList;
  final Function(int) onDelete;
  final Function onRefresh;

  const BayarTab({
    super.key,
    required this.bayarList,
    required this.onDelete,
    required this.onRefresh,
  });

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Data"),
          content: const Text("Yakin ingin menghapus?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(id);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String formatRupiah(int number) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return bayarList.isEmpty
        ? const Center(child: Text("Belum ada data pembayaran."))
        : RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 90),
              itemCount: bayarList.length,
              itemBuilder: (context, index) {
                final item = bayarList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: InkWell(
                    onLongPress: () => _showDeleteConfirmation(context, item['id']),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(
                          Icons.arrow_downward,
                          color: Colors.green,
                        ),
                      ),
                      title: Text(
                        item['keterangan'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item['tanggal']),
                      trailing: Text(
                        formatRupiah(item['nilai']),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
