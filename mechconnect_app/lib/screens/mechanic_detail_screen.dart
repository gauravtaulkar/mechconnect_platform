import 'package:flutter/material.dart';
import '../models/mechanic.dart';
import 'booking_screen.dart';

class MechanicDetailScreen extends StatelessWidget {
  final Mechanic mechanic;
  const MechanicDetailScreen({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mechanic.shopName),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mechanic.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _row(Icons.store, mechanic.shopName),
            _row(Icons.location_city, mechanic.city),
            _row(Icons.map, mechanic.street),
            _row(Icons.phone, mechanic.phone),
            _row(Icons.build, mechanic.expertise),
            _row(Icons.work, '${mechanic.experience} years experience'),
            _row(Icons.access_time,
                'Open: ${mechanic.openingTime} — Close: ${mechanic.closingTime}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: mechanic.available ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(mechanic.available ? 'Available' : 'Not Available',
                  style: const TextStyle(color: Colors.white)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: mechanic.available
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                BookingScreen(mechanic: mechanic)))
                    : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Book Now',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
