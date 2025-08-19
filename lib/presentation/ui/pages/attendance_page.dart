import 'package:epkl/data/models/attendance.dart';
import 'package:epkl/presentation/providers/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AttendanceListPage extends ConsumerStatefulWidget {
  const AttendanceListPage({super.key});

  @override
  ConsumerState<AttendanceListPage> createState() => _AttendanceListPageState();
}

class _AttendanceListPageState extends ConsumerState<AttendanceListPage> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final filter = DateFilter(start: _startDate, end: _endDate);
    // Kita tidak perlu await di sini, karena onRefresh akan menunggunya
    ref.read(attendanceNotifierProvider.notifier).fetchAttendance(filter);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: Column(
        children: [
          // --- Filter Tanggal ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('d MMM yyyy').format(_startDate)),
                    onPressed: () => _selectDate(context, true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('s/d'),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('d MMM yyyy').format(_endDate)),
                    onPressed: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // --- Daftar Absensi ---
          Expanded(
            child: RefreshIndicator(
              color: Colors.white,
              onRefresh: _fetchData,
              child: attendanceState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (attendances) {
                  if (attendances.isEmpty) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: const Center(
                              child: Text(
                                'Tidak ada data absensi pada rentang tanggal ini.',
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return ListView.builder(
                    itemCount: attendances.length,
                    itemBuilder: (context, index) {
                      final attendance = attendances[index];
                      return AttendanceCard(attendance: attendance);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk menampilkan satu item absensi agar lebih rapi
class AttendanceCard extends StatelessWidget {
  final Attendance attendance;
  const AttendanceCard({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat(
                'EEEE, d MMMM yyyy',
                'id_ID',
              ).format(DateTime.parse(attendance.date)),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeInfo(
                  'Check In',
                  attendance.checkInTime,
                  Icons.login,
                  Colors.green,
                ),
                _buildTimeInfo(
                  'Check Out',
                  attendance.checkOutTime,
                  Icons.logout,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8), // Beri sedikit jarak antara ikon dan teks
        Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri untuk teks
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              time,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
