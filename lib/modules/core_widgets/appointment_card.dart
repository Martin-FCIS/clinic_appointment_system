import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDoctorView;
  final bool isAdmin; // عشان نعرف إننا أدمن
  final Function(String)? onStatusChange;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.item,
    required this.isDoctorView,
    this.isAdmin = false,
    this.onStatusChange,
    this.onCancel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Data Parsing
    String status = item['status'] ?? 'pending';
    bool isPending = status == 'pending';
    Color statusColor = _getStatusColor(status);

    // الأسماء والتخصص
    String titleName; // الاسم الكبير
    Widget? subtitleWidget; // السطر اللي تحته (دكتور/تخصص)

    if (isDoctorView) {
      // --- حالة الدكتور أو الأدمن ---
      titleName = item['patientName'] ?? 'Unknown Patient';

      if (isAdmin) {
        // ✅ للأدمن: نعرض "اسم الدكتور - التخصص" مع أيقونة
        String doctorName = item['doctorName'] ?? 'Unknown';
        String specialty = item['specialty'] ?? 'General';

        subtitleWidget = Row(
          children: [
            const Icon(Icons.medical_services, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              "Dr. $doctorName • $specialty", // دمجنا الاسم والتخصص
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500),
            ),
          ],
        );
      } else {
        // للدكتور العادي: مش محتاج subtitle
        subtitleWidget = null;
      }
    } else {
      // --- حالة المريض ---
      // المريض بيشوف اسم الدكتور والتخصص
      titleName = "Dr. ${item['doctorName'] ?? 'Unknown'}";
      subtitleWidget = Text(
        item['specialty'] ?? 'General',
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      );
    }

    // الفلوس والدفع
    String priceText = "${item['price'] ?? 0} EGP";
    String paymentMethod = item['paymentMethod'] ?? 'Cash';
    IconData paymentIcon =
    paymentMethod == 'Credit Card' ? Icons.credit_card : Icons.money;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // الشريط الملون
                Container(width: 6, color: statusColor),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade50,
                                  radius: 22,
                                  child: Text(
                                    titleName.isNotEmpty
                                        ? titleName[0].toUpperCase()
                                        : "?",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(titleName,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    // هنا بنعرض الـ Widget اللي جهزناها فوق
                                    if (subtitleWidget != null) subtitleWidget,
                                  ],
                                ),
                              ],
                            ),
                            _buildStatusBadge(status, statusColor),
                          ],
                        ),

                        // ✅ شلنا الـ Divider وحطينا مسافة بس
                        const SizedBox(height: 20),

                        // --- Date & Time ---
                        Row(
                          children: [
                            _buildIconText(Icons.calendar_today_outlined,
                                item['date'] ?? 'No Date'),
                            const SizedBox(width: 15),
                            _buildIconText(
                                Icons.access_time,
                                _formatAppointmentRange(
                                    item['time'] ?? '00:00', context)),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // --- Price & Payment ---
                        Row(
                          children: [
                            // السعر يظهر للمريض "أو" للأدمن
                            if (!isDoctorView || isAdmin) ...[
                              _buildIconText(
                                  Icons.monetization_on_outlined, priceText),
                              const SizedBox(width: 15),
                            ],

                            // الدفع يظهر للكل
                            _buildIconText(paymentIcon, "Payment: $paymentMethod"),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // --- Action Buttons ---
                        // أزرار الأدمن أو الدكتور
                        if ((isDoctorView || isAdmin) && isPending)
                          Row(
                            children: [
                              Expanded(
                                  child: _actionButton("Decline", Colors.red,
                                          () => onStatusChange?.call('cancelled'))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _actionButton("Accept", Colors.green,
                                          () => onStatusChange?.call('approved'),
                                      isFilled: true)),
                            ],
                          ),

                        // زرار الإلغاء (للمريض فقط)
                        if (!isDoctorView &&
                            !isAdmin &&
                            status != 'cancelled' &&
                            status != 'completed')
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: onCancel,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.red.shade200)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cancel_outlined,
                                        size: 16, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text("Cancel Booking",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onTap,
      {bool isFilled = false}) {
    return isFilled
        ? ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8))),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    )
        : OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8))),
      child: Text(text),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.grey;
      default: return Colors.orange;
    }
  }

  String _formatAppointmentRange(String startTime, BuildContext context) {
    try {
      final parts = startTime.split(':');
      final start =
      TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      final startInMinutes = start.hour * 60 + start.minute;
      final endInMinutes = startInMinutes + 15;
      final end =
      TimeOfDay(hour: endInMinutes ~/ 60, minute: endInMinutes % 60);
      return "${start.format(context)} - ${end.format(context)}";
    } catch (e) {
      return startTime;
    }
  }
}