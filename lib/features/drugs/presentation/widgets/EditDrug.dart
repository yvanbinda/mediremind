import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mediremind/core/app/constants.dart';
import 'package:mediremind/data/models/drug_model.dart';
import 'package:mediremind/features/app/controllers/homeController.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EditDrugForm extends StatefulWidget {
  final Drug drug;

  const EditDrugForm({super.key, required this.drug});

  @override
  State<EditDrugForm> createState() => _EditDrugFormState();
}

class _EditDrugFormState extends State<EditDrugForm> {
  final _formKey = GlobalKey<FormState>();
  final HomeController homeController = Get.find();

  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _hourController;
  late TextEditingController _frequencyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.drug.name);
    _dosageController = TextEditingController(text: widget.drug.dosage);
    _hourController = TextEditingController(text: widget.drug.hour);
    _frequencyController = TextEditingController(text: widget.drug.frequency);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _hourController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Constants.colorPrimary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit Drug',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),

             SizedBox(height: 24),

            // Form Fields
            _buildTextField(
              controller: _nameController,
              label: 'Drug Name',
              icon: Icons.medication,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter drug name';
                }
                return null;
              },
            ),

             SizedBox(height: 16),

            _buildTextField(
              controller: _dosageController,
              label: 'Dosage',
              icon: Icons.medication_liquid,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter dosage';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            _buildTextField(
              controller: _hourController,
              label: 'Time',
              icon: Icons.access_time,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter time';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            _buildTextField(
              controller: _frequencyController,
              label: 'Frequency',
              icon: Icons.repeat,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter frequency';
                }
                return null;
              },
            ),

            SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                 SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateDrug,
                    child: const Text('Update'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.colorPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Constants.colorPrimary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Constants.colorPrimary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _updateDrug() {
    if (_formKey.currentState!.validate()) {
      final updatedDrug = Drug(
        id: widget.drug.id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        hour: _hourController.text.trim(),
        frequency: _frequencyController.text.trim(),
        isTaken: widget.drug.isTaken,
      );

      homeController.updateDrug(updatedDrug);
      Get.back();
      Get.snackbar(
        'Success',
        'Drug updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}