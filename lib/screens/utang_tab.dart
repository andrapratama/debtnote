import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UtangTab extends StatelessWidget {
  final List<Map<String, dynamic>> utangList;
  final Function(int) onDelete;
  final Function onRefresh;

  const UtangTab({
    super.key,
    required this.utangList,
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
    return utangList.isEmpty
        ? const Center(child: Text("Belum ada data utang."))
        : RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 90),
              itemCount: utangList.length,
              itemBuilder: (context, index) {
                final item = utangList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: InkWell(
                    onLongPress: () => _showDeleteConfirmation(context, item['id']),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.red,
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
                          color: Colors.red,
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
