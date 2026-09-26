import 'package:flutter/material.dart';
import '../models/mechanic.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'mechanic_detail_screen.dart';
import 'my_bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final cityController = TextEditingController();
  List<Mechanic> mechanics = [];
  bool isLoading = false;
  bool hasSearched = false;
  String errorMessage = '';

  Future<void> searchMechanics() async {
    if (cityController.text.trim().isEmpty) return;
    setState(() {
      isLoading = true;
      hasSearched = true;
      errorMessage = '';
      mechanics = [];
    });
    try {
      final result = await ApiService.getMechanicsByCity(cityController.text.trim());
      setState(() => mechanics = result);
      if (mechanics.isEmpty) {
        setState(() => errorMessage = 'No mechanics found in this city yet');
      }
    } on ApiException catch (e) {
      setState(() => errorMessage = e.message);
    } catch (e) {
      setState(() => errorMessage =
          'Could not connect to server. Check the address in app_config.dart.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MechConnect'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Bookings',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen())),
          ),
          // FIX: there was no logout anywhere in the app before.
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                        labelText: 'Search by city',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city)),
                    onSubmitted: (_) => searchMechanics(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : searchMechanics,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16)),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(errorMessage,
                    style: const TextStyle(color: Colors.red)),
              ),
            // FIX: before, an empty result list and "haven't searched yet"
            // looked identical (just an empty screen). Now there's an
            // explicit hint the first time the screen is shown.
            if (!hasSearched && !isLoading)
              const Expanded(
                child: Center(
                  child: Text(
                    'Type a city above and tap search to find a mechanic near you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: mechanics.length,
                  itemBuilder: (context, index) {
                    final mechanic = mechanics[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(mechanic.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${mechanic.shopName}\n${mechanic.city} — ${mechanic.expertise}'),
                        isThreeLine: true,
                        trailing: Icon(Icons.circle,
                            color: mechanic.available
                                ? Colors.green
                                : Colors.red,
                            size: 14),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    MechanicDetailScreen(mechanic: mechanic))),
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
