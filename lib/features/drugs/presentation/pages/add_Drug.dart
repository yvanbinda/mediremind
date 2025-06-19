import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mediremind/features/app/controllers/homeController.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AddDrug extends StatefulWidget {
  const AddDrug({super.key});

  @override
  State<AddDrug> createState() => _AddDrugState();
}

class _AddDrugState extends State<AddDrug> {
  final _formKey = GlobalKey<FormState>();
  final HomeController _homeController = Get.find<HomeController>();

  // Text editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();

  // Selected values
  String? _selectedHour;
  String? _selectedFrequency;

  // Predefined options
  final List<String> _hours = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'
  ];

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'Every 2 hours',
    'Every 4 hours',
    'Every 6 hours',
    'Every 8 hours',
    'Every 12 hours',
    'As needed',
    'Weekly',
    'Monthly'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await _homeController.addDrug(
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        hour: _selectedHour!,
        frequency: _selectedFrequency!,
      );

      // Navigate back if successful
      if (!_homeController.isAddingDrug.value) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Drug'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  SizedBox(height: 4.h),

                  // Drug Name Field
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Drug Name',
                        hintText: 'e.g., Aspirin, Paracetamol',
                        prefixIcon: Icon(Icons.local_pharmacy, color: Colors.blue.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the drug name';
                        }
                        if (value.trim().length < 2) {
                          return 'Drug name must be at least 2 characters';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Dosage Field
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _dosageController,
                      decoration: InputDecoration(
                        labelText: 'Dosage',
                        hintText: 'e.g., 500mg,',
                        prefixIcon: Icon(Icons.scatter_plot, color: Colors.blue.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the dosage';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Hour Selection
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedHour,
                      decoration: InputDecoration(
                        labelText: 'Time to Take',
                        prefixIcon: Icon(Icons.access_time, color: Colors.blue.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _hours.map((String hour) {
                        return DropdownMenuItem<String>(
                          value: hour,
                          child: Text(hour),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedHour = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Frequency Selection
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedFrequency,
                      decoration: InputDecoration(
                        labelText: 'Frequency',
                        prefixIcon: Icon(Icons.repeat, color: Colors.blue.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _frequencies.map((String frequency) {
                        return DropdownMenuItem<String>(
                          value: frequency,
                          child: Text(frequency),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFrequency = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a frequency';
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Submit Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => OutlinedButton(
                        onPressed: _homeController.isAddingDrug.value ? null : _submitForm,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          side: BorderSide.none,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white
                          ),
                        ),
                      ),
                      ),

                      SizedBox(width: 10.w),
                      // Cancel Button
                      OutlinedButton(
                        onPressed: _homeController.isAddingDrug.value ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}