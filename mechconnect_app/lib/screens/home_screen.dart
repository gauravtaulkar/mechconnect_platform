import 'package:flutter/material.dart';
import '../models/mechanic.dart';
import '../services/api_service.dart';
import 'mechanic_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // controller for the city search field
  final cityController = TextEditingController();

  // list of mechanics returned from backend
  List<Mechanic> mechanics = [];

  bool isLoading = false;
  String errorMessage = '';

  // called when user taps search button
  Future<void> searchMechanics() async {
    if (cityController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
      mechanics = []; // clear previous results
    });

    try {
      final result = await ApiService.getMechanicsByCity(
        cityController.text.trim(),
      );
      setState(() => mechanics = result);

      if (mechanics.isEmpty) {
        setState(() => errorMessage = 'No mechanics found in this city');
      }
    } catch (e) {
      setState(() => errorMessage = 'Could not connect to server');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MechConnect'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        // my bookings button in top right
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              // we will add my bookings screen later
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // search bar + button in a row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'Search by city',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    // search when user presses enter
                    onSubmitted: (_) => searchMechanics(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : searchMechanics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // error message
            if (errorMessage.isNotEmpty)
              Text(errorMessage,
                  style: const TextStyle(color: Colors.red)),

            // mechanics list
            Expanded(
              child: ListView.builder(
                // how many items in list
                itemCount: mechanics.length,
                itemBuilder: (context, index) {
                  final mechanic = mechanics[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      // mechanic name + shop name
                      title: Text(
                        mechanic.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          '${mechanic.shopName}\n${mechanic.city} — ${mechanic.expertise}'),
                      isThreeLine: true,
                      // green dot if available, red if not
                      trailing: Icon(
                        Icons.circle,
                        color: mechanic.available
                            ? Colors.green
                            : Colors.red,
                        size: 14,
                      ),
                      // tap to go to mechanic detail
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MechanicDetailScreen(mechanic: mechanic),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}