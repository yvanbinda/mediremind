import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mediremind/data/models/drug_model.dart';
import 'package:mediremind/data/services/database_service.dart';
import 'package:mediremind/data/services/notification_service.dart';

class HomeController extends GetxController {
  // Observable list of drugs
  RxList<Drug> drugs = <Drug>[].obs;

  // Loading states
  RxBool isLoading = false.obs;
  RxBool isAddingDrug = false.obs;

  // Statistics
  RxInt totalDrugs = 0.obs;
  RxInt takenDrugs = 0.obs;

  // Database service instance
  final DatabaseService _databaseService = DatabaseService.instance;

  // Notification service instance
  final NotificationService _notificationService = NotificationService.instance;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  // Initialize services
  Future<void> _initializeServices() async {
    await _notificationService.initialize();
    await loadAllDrugs();
  }

  // Load all drugs from database
  Future<void> loadAllDrugs() async {
    try {
      isLoading.value = true;
      final loadedDrugs = await _databaseService.getAllDrugs();
      drugs.value = loadedDrugs;
      await updateStatistics();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load drugs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new drug
  Future<void> addDrug({
    required String name,
    required String dosage,
    required String hour,
    required String frequency,
  }) async {
    try {
      isAddingDrug.value = true;

      final newDrug = Drug(
        name: name,
        dosage: dosage,
        hour: hour,
        frequency: frequency,
      );

      final id = await _databaseService.addDrug(newDrug);

      if (id > 0) {
        newDrug.id = id; // Set the ID
        await _notificationService.scheduleDrugReminder(newDrug); // SCHEDULE NOTIFICATION
        await loadAllDrugs(); // Refresh the list
        Get.snackbar('Success', 'Drug added successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add drug: $e');
    } finally {
      isAddingDrug.value = false;
    }
  }

  // Update an existing drug
  Future<void> updateDrug(Drug drug) async {
    try {
      final rowsAffected = await _databaseService.updateDrug(drug);

      if (rowsAffected > 0) {
        await _notificationService.scheduleDrugReminder(drug); // RESCHEDULE NOTIFICATION
        await loadAllDrugs(); // Refresh the list
        Get.snackbar('Success', 'Drug updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update drug: $e');
    }
  }

  // Toggle drug taken status
  Future<void> toggleDrugStatus(int drugId) async {
    try {
      final rowsAffected = await _databaseService.toggleDrugStatus(drugId);

      if (rowsAffected > 0) {
        await loadAllDrugs(); // Refresh the list

        // Find the updated drug and show appropriate message
        final updatedDrug = drugs.firstWhere((drug) => drug.id == drugId);
        final status = updatedDrug.isTaken ? 'taken' : 'not taken';
        Get.snackbar('Status Updated', '${updatedDrug.name} marked as $status');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update drug status: $e');
    }
  }

  // Delete a drug
  Future<void> deleteDrug(int drugId) async {
    try {
      await _notificationService.cancelDrugNotifications(drugId); // CANCEL NOTIFICATION FIRST
      final rowsAffected = await _databaseService.deleteDrug(drugId);

      if (rowsAffected > 0) {
        await loadAllDrugs(); // Refresh the list
        Get.snackbar('Success', 'Drug deleted successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete drug: $e');
    }
  }

  // Delete all drugs with confirmation
  Future<void> deleteAllDrugs() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete all drugs?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _notificationService.cancelAllNotifications(); // CANCEL ALL NOTIFICATIONS
        final rowsAffected = await _databaseService.deleteAllDrugs();

        if (rowsAffected > 0) {
          await loadAllDrugs(); // Refresh the list
          Get.snackbar('Success', 'All drugs deleted successfully');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete all drugs: $e');
    }
  }

  // Reset all drugs status to not taken
  Future<void> resetAllDrugsStatus() async {
    try {
      final rowsAffected = await _databaseService.resetAllDrugsStatus();

      if (rowsAffected > 0) {
        await loadAllDrugs(); // Refresh the list
        Get.snackbar('Success', 'All drugs reset to not taken');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to reset drugs status: $e');
    }
  }

  // Test general notifications
  Future<void> testNotification() async {
    await _notificationService.showTestNotification();
  }

  // Test notification for a specific drug
  Future<void> testDrugNotification(Drug drug) async {
    try {
      // await _notificationService.showTestDrugNotification(drug);
      Get.snackbar(
        'Test Notification Sent',
        'Check your notification panel to see the test reminder for ${drug.name}',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.blueAccent.shade100,
        colorText: Colors.blue.shade800,
        icon: const Icon(Icons.notifications, color: Colors.orange),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send test notification: $e');
    }
  }

  // Get drugs filtered by taken status
  List<Drug> getDrugsByStatus(bool isTaken) {
    return drugs.where((drug) => drug.isTaken == isTaken).toList();
  }

  // Get taken drugs
  List<Drug> get takenDrugsList => getDrugsByStatus(true);

  // Get pending drugs (not taken)
  List<Drug> get pendingDrugsList => getDrugsByStatus(false);

  // Update statistics
  Future<void> updateStatistics() async {
    try {
      totalDrugs.value = await _databaseService.getDrugsCount();
      takenDrugs.value = await _databaseService.getTakenDrugsCount();
    } catch (e) {
      print('Error updating statistics: $e');
    }
  }

  // Get completion percentage
  double get completionPercentage {
    if (totalDrugs.value == 0) return 0.0;
    return (takenDrugs.value / totalDrugs.value) * 100;
  }

  // Check if all drugs are taken
  bool get allDrugsTaken => totalDrugs.value > 0 && takenDrugs.value == totalDrugs.value;

  // Get drugs for specific time/hour
  List<Drug> getDrugsForHour(String hour) {
    return drugs.where((drug) => drug.hour == hour).toList();
  }
}