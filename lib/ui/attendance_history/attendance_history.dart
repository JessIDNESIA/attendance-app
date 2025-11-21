import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  // === TEMA ORANGE PROFESIONAL ===
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color lightBg = Color(0xFFFFFAF5);

  final CollectionReference dataCollection =
      FirebaseFirestore.instance.collection('attendance');

  // === FUNGSI EDIT DATA ===
  void _editData(
    String docId,
    String currentName,
    String currentAddress,
    String currentDescription,
    String currentDatetime,
  ) {
    final nameController = TextEditingController(text: currentName);
    final addressController = TextEditingController(text: currentAddress);
    final descController = TextEditingController(text: currentDescription);
    final datetimeController = TextEditingController(text: currentDatetime);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Attendance Data", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 12),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address", prefixIcon: Icon(Icons.location_on))),
              const SizedBox(height: 12),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Description", prefixIcon: Icon(Icons.note))),
              const SizedBox(height: 12),
              TextField(controller: datetimeController, decoration: const InputDecoration(labelText: "Datetime", prefixIcon: Icon(Icons.access_time))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
            onPressed: () async {
              await dataCollection.doc(docId).update({
                'name': nameController.text.trim(),
                'address': addressController.text.trim(),
                'description': descController.text.trim(),
                'datetime': datetimeController.text.trim(),
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // === FUNGSI DELETE DATA ===
  void _deleteData(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
        title: const Text("Delete Data?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await dataCollection.doc(docId).delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: primaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          "Attendance History Menu",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dataCollection.orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: primaryOrange));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No attendance history yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              final docId = data.id;
              final name = data['name'] ?? '-';
              final address = data['address'] ?? '-';
              final description = data['description'] ?? '-';
              final datetime = data['datetime'] ?? '-';

              return Card(
                elevation: 8,
                shadowColor: primaryOrange.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)].withOpacity(0.8),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryOrange)),
                            const SizedBox(height: 6),
                            Text("Location: $address", style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            Text("Status: $description", style: TextStyle(
                              fontSize: 14,
                              color: description == "Attend"
                                  ? Colors.green
                                  : description == "Late"
                                      ? Colors.orange[700]
                                      : Colors.red,
                            )),
                            Text("Time: $datetime", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ),

                      // Action Buttons
                      Column(
                        children: [
                          // Ikon Edit → WARNA HITAM
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.black),
                            onPressed: () => _editData(docId, name, address, description, datetime),
                          ),
                          // Ikon Delete tetap merah
                          IconButton(
                            icon: const Icon(Icons.delete_rounded, color: Colors.red),
                            onPressed: () => _deleteData(docId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}