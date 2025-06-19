import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mediremind/core/app/constants.dart';
import 'package:mediremind/features/app/controllers/homeController.dart';
import 'package:mediremind/features/drugs/presentation/pages/add_Drug.dart';
import 'package:mediremind/features/drugs/presentation/widgets/DrugCard.dart';
import 'package:mediremind/features/drugs/presentation/widgets/statistics_Card.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomePage extends StatelessWidget {
  final HomeController homeController = Get.find();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Constants.colorPrimary,
        foregroundColor: Colors.white,
        title: Text(
          "MediRemind",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (String value) {
              switch (value) {
                case 'reset_all':
                  homeController.resetAllDrugsStatus();
                  break;
                case 'delete_all':
                  homeController.deleteAllDrugs();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'reset_all',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Reset All Status'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete All Drugs'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (homeController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: homeController.loadAllDrugs,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Card
                StatisticsCard(),

                // Quick Actions
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          'Pending',
                          homeController.pendingDrugsList.length.toString(),
                          Icons.schedule,
                          Colors.orange,
                              () => _showDrugsByStatus(false),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          'Completed',
                          homeController.takenDrugsList.length.toString(),
                          Icons.done_all,
                          Colors.green,
                              () => _showDrugsByStatus(true),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Section Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Drugs",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                // Drug List
                if (homeController.drugs.isEmpty)
                  _buildEmptyState()
                else
                  ...homeController.drugs.map((drug) => Drugcard(drug: drug)).toList(),

                SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() =>  AddDrug()),
        backgroundColor: Constants.colorPrimary,
        child:  Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  Widget _buildQuickActionCard(String title, String count, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin:  EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            Icons.medication_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
           SizedBox(height: 16),
          Text(
            'No drugs added yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first drug',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDrugsByStatus(bool isTaken) {
    final drugs = homeController.getDrugsByStatus(isTaken);
    final title = isTaken ? 'Completed Drugs' : 'Pending Drugs';

    Get.bottomSheet(
      Container(
        decoration:  BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin:  EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: drugs.length,
                itemBuilder: (context, index) => Drugcard(drug: drugs[index])),
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


}