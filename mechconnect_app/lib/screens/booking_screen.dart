import 'package:flutter/material.dart';
import '../models/mechanic.dart';
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final Mechanic mechanic;
  const BookingScreen({super.key, required this.mechanic});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final bikeController = TextEditingController();
  final problemController = TextEditingController();
  DateTime? selectedDate;
  String? selectedSlot;
  List<String> availableSlots = [];
  bool isLoadingSlots = false;
  bool isBooking = false;
  String errorMessage = '';

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedSlot = null;
        availableSlots = [];
      });
      await fetchSlots(picked);
    }
  }

  Future<void> fetchSlots(DateTime date) async {
    setState(() {
      isLoadingSlots = true;
      errorMessage = '';
    });
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final slots =
          await ApiService.getAvailableSlots(widget.mechanic.id, dateStr);
      setState(() => availableSlots = slots);
      if (slots.isEmpty) {
        setState(() => errorMessage = 'No open slots on this date — try another day');
      }
    } on ApiException catch (e) {
      setState(() => errorMessage = e.message);
    } catch (e) {
      setState(() => errorMessage = 'Could not fetch slots');
    } finally {
      setState(() => isLoadingSlots = false);
    }
  }

  Future<void> confirmBooking() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        bikeController.text.trim().isEmpty ||
        selectedDate == null ||
        selectedSlot == null) {
      setState(() => errorMessage = 'Please fill all fields and select a slot');
      return;
    }
    setState(() {
      isBooking = true;
      errorMessage = '';
    });
    try {
      final dateStr =
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
      final bookingTime = '${dateStr}T${selectedSlot!}';
      await ApiService.createBooking(
        mechanicId: widget.mechanic.id,
        customerName: nameController.text.trim(),
        customerPhone: phoneController.text.trim(),
        bikeModel: bikeController.text.trim(),
        bookingTime: bookingTime,
        problemDescription: problemController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Booking confirmed!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } on ApiException catch (e) {
      // FIX: this now shows the real backend reason — "Time slot already
      // booked", "Booking outside shop working hours", etc — instead of
      // the generic "Booking failed. Slot may be taken." guess it showed
      // before (which used to be the only message possible, since a real
      // 500 error carried no usable detail).
      setState(() => errorMessage = e.message);
    } catch (e) {
      setState(() => errorMessage = 'Could not connect to server');
    } finally {
      if (mounted) setState(() => isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book — ${widget.mechanic.name}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Your Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Phone Number', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: bikeController,
                decoration: const InputDecoration(
                    labelText: 'Bike Model', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: problemController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Problem Description',
                    border: OutlineInputBorder())),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(selectedDate == null
                  ? 'Pick a Date'
                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
            ),
            const SizedBox(height: 16),
            if (isLoadingSlots)
              const Center(child: CircularProgressIndicator())
            else if (availableSlots.isNotEmpty) ...[
              const Text('Available Slots',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableSlots.map((slot) {
                  final isSelected = slot == selectedSlot;
                  final label =
                      slot.length >= 5 ? slot.substring(0, 5) : slot;
                  return GestureDetector(
                    onTap: () => setState(() => selectedSlot = slot),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(label,
                          style: TextStyle(
                              color: isSelected ? Colors.white : Colors.orange,
                              fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isBooking ? null : confirmBooking,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: isBooking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Booking',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
