import 'package:flutter/material.dart';
import '../models/mechanic.dart';
import 'booking_screen.dart';

class MechanicDetailScreen extends StatelessWidget {
  // mechanic object passed from home screen when user taps a card
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // mechanic name
            Text(
              mechanic.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // detail rows
            _detailRow(Icons.store, mechanic.shopName),
            _detailRow(Icons.location_city, mechanic.city),
            _detailRow(Icons.map, mechanic.street),
            _detailRow(Icons.phone, mechanic.phone),
            _detailRow(Icons.build, mechanic.expertise),
            _detailRow(Icons.work, '${mechanic.experience} years experience'),
            _detailRow(Icons.access_time,
                'Open: ${mechanic.openingTime} — Close: ${mechanic.closingTime}'),

            const SizedBox(height: 8),

            // availability badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: mechanic.available ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                mechanic.available ? 'Available' : 'Not Available',
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const Spacer(), // pushes button to bottom

            // book now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: mechanic.available
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingScreen(mechanic: mechanic),
                          ),
                        )
                    : null, // disabled if mechanic not available
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // reusable row widget — icon + text
  // this is a helper method, not a full widget
  Widget _detailRow(IconData icon, String text) {
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