import 'package:flutter/material.dart';
import '../models/mechanic.dart';
import '../services/api_service.dart';

// NEW SCREEN — this did not exist before. The backend already had
// POST /api/mechanics (and now the safer POST /api/mechanics/me) to create
// a shop profile, but there was no UI for a mechanic to ever use it. Without
// this screen, a MECHANIC-role account could log in but could never appear
// in anyone's city search, because no Mechanic row ever got created for them.
class MechanicProfileScreen extends StatefulWidget {
  final Mechanic? existing;
  const MechanicProfileScreen({super.key, this.existing});

  @override
  State<MechanicProfileScreen> createState() => _MechanicProfileScreenState();
}

class _MechanicProfileScreenState extends State<MechanicProfileScreen> {
  late final nameController =
      TextEditingController(text: widget.existing?.name ?? '');
  late final shopNameController =
      TextEditingController(text: widget.existing?.shopName ?? '');
  late final cityController =
      TextEditingController(text: widget.existing?.city ?? '');
  late final streetController =
      TextEditingController(text: widget.existing?.street ?? '');
  late final phoneController =
      TextEditingController(text: widget.existing?.phone ?? '');
  late final experienceController = TextEditingController(
      text: widget.existing?.experience.toString() ?? '');
  late final expertiseController =
      TextEditingController(text: widget.existing?.expertise ?? '');

  late bool available = widget.existing?.available ?? true;
  late TimeOfDay openingTime = _parseTime(widget.existing?.openingTime) ??
      const TimeOfDay(hour: 9, minute: 0);
  late TimeOfDay closingTime = _parseTime(widget.existing?.closingTime) ??
      const TimeOfDay(hour: 18, minute: 0);

  bool isSaving = false;
  String errorMessage = '';

  static TimeOfDay? _parseTime(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> pickTime(bool isOpening) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? openingTime : closingTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          openingTime = picked;
        } else {
          closingTime = picked;
        }
      });
    }
  }

  Future<void> save() async {
    if (nameController.text.trim().isEmpty ||
        shopNameController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Name, shop name, city and phone are required');
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = '';
    });

    try {
      await ApiService.saveMyMechanicProfile(
        name: nameController.text.trim(),
        shopName: shopNameController.text.trim(),
        city: cityController.text.trim(),
        street: streetController.text.trim(),
        latitude: 0,
        longitude: 0,
        phone: phoneController.text.trim(),
        experience: int.tryParse(experienceController.text.trim()) ?? 0,
        expertise: expertiseController.text.trim(),
        available: available,
        openingTime: _formatTime(openingTime),
        closingTime: _formatTime(closingTime),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Shop profile saved'), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => errorMessage = e.message);
    } catch (e) {
      setState(() => errorMessage = 'Could not connect to server');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Set Up Your Shop' : 'Edit Shop'),
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
                controller: shopNameController,
                decoration: const InputDecoration(
                    labelText: 'Shop Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: cityController,
                decoration: const InputDecoration(
                    labelText: 'City', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: streetController,
                decoration: const InputDecoration(
                    labelText: 'Street / Address', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Phone', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Years of experience',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: expertiseController,
                decoration: const InputDecoration(
                    labelText: 'Expertise (e.g. Engine, Electrical)',
                    border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => pickTime(true),
                    icon: const Icon(Icons.access_time),
                    label: Text('Opens ${_formatTime(openingTime).substring(0, 5)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => pickTime(false),
                    icon: const Icon(Icons.access_time_filled),
                    label: Text('Closes ${_formatTime(closingTime).substring(0, 5)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Currently accepting bookings'),
              value: available,
              activeColor: Colors.orange,
              onChanged: (v) => setState(() => available = v),
            ),
            const SizedBox(height: 8),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : save,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save Shop Profile',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
