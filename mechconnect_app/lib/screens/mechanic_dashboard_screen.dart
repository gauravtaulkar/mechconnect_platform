import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/mechanic.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'mechanic_profile_screen.dart';

// NEW SCREEN — this whole side of the app was missing. The backend already
// supported a mechanic viewing/updating their own bookings
// (GET /api/bookings/mechanic/me, PUT /api/bookings/{id}/status), but there
// was no screen calling either. A booking could be created by a customer and
// then sit as "PENDING" forever with no way for the mechanic to confirm or
// cancel it.
class MechanicDashboardScreen extends StatefulWidget {
  const MechanicDashboardScreen({super.key});

  @override
  State<MechanicDashboardScreen> createState() =>
      _MechanicDashboardScreenState();
}

class _MechanicDashboardScreenState extends State<MechanicDashboardScreen> {
  Mechanic? profile;
  List<Booking> bookings = [];
  bool isLoading = true;
  String errorMessage = '';
  Set<int> updatingIds = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final myProfile = await ApiService.getMyMechanicProfile();
      setState(() => profile = myProfile);
      if (myProfile != null) {
        final myBookings = await ApiService.getMyShopBookings();
        setState(() => bookings = myBookings);
      }
    } on ApiException catch (e) {
      setState(() => errorMessage = e.message);
    } catch (e) {
      setState(() => errorMessage = 'Could not connect to server');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> setStatus(Booking booking, String status) async {
    setState(() => updatingIds.add(booking.id));
    try {
      await ApiService.updateBookingStatus(booking.id, status);
      await load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update booking')));
    } finally {
      if (mounted) setState(() => updatingIds.remove(booking.id));
    }
  }

  Future<void> editProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => MechanicProfileScreen(existing: profile)),
    );
    if (updated == true) load();
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

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (profile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Shop',
              onPressed: editProfile,
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: load,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : profile == null
                ? _noProfileView()
                : _dashboardView(),
      ),
    );
  }

  Widget _noProfileView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.storefront, size: 64, color: Colors.orange),
        const SizedBox(height: 16),
        const Text(
          "You haven't set up your shop yet",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Customers can only find and book you once your shop profile is filled in.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: editProfile,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('Set Up Shop Profile',
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _dashboardView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.store, color: Colors.orange),
            title: Text(profile!.shopName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${profile!.city} — ${profile!.expertise}'),
            trailing: Icon(Icons.circle,
                color: profile!.available ? Colors.green : Colors.red,
                size: 14),
          ),
        ),
        const SizedBox(height: 16),
        Text('Bookings (${bookings.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        if (errorMessage.isNotEmpty)
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
        if (bookings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
                child: Text('No bookings yet', style: TextStyle(color: Colors.grey))),
          ),
        ...bookings.map((booking) {
          final isUpdating = updatingIds.contains(booking.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${booking.customerName} — ${booking.bikeModel}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor(booking.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          booking.status,
                          style: TextStyle(
                              color: statusColor(booking.status),
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(booking.bookingTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('Phone: ${booking.customerPhone}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (booking.problemDescription.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(booking.problemDescription,
                          style: const TextStyle(fontSize: 13)),
                    ),
                  if (booking.status.toUpperCase() == 'PENDING') ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isUpdating
                                ? null
                                : () => setStatus(booking, 'CANCELLED'),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isUpdating
                                ? null
                                : () => setStatus(booking, 'CONFIRMED'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: isUpdating
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Confirm',
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ] else if (booking.status.toUpperCase() == 'CONFIRMED') ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isUpdating
                            ? null
                            : () => setStatus(booking, 'COMPLETED'),
                        child: isUpdating
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Mark Completed'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
