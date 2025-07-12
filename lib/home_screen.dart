import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();

  List _employee = [].obs;
  List _filteredEmployee = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    _searchController.addListener(() {
      filterList(_searchController.text);
    });
  }

  void fetchData() async {
    final response = await http.get(
      Uri.parse("https://669b3f09276e45187d34eb4e.mockapi.io/api/v1/employee"),
    );

    if (response.statusCode == 200) {
      setState(() {
        _employee =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        _filteredEmployee = _employee;
      });
    } else {
      Get.snackbar("Error", "Failed to load data from server");
    }
  }

  void filterList(String query) {
    final result = _employee.where((emp) {
      final name = emp['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredEmployee = result;
    });
  }

  void _postData() async {
    final name = _nameController.text.trim();
    final position = _positionController.text.trim();
    final dept = _deptController.text.trim();

    if (name.isEmpty || position.isEmpty || dept.isEmpty) {
      Get.snackbar("Validation", "All fields are required");
      return;
    }

    final response = await http.post(
      Uri.parse("https://669b3f09276e45187d34eb4e.mockapi.io/api/v1/employee"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "position": position,
        "department": dept,
      }),
    );

    if (response.statusCode == 201) {
      Get.snackbar("Success", "Employee added successfully");
      Navigator.of(context).pop();
      _nameController.clear();
      _positionController.clear();
      _deptController.clear();
      fetchData();
    } else {
      Get.snackbar("Error", "Failed to store data on server");
    }
  }

  void showMyBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add New Employee",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 25),
              SizedBox(
                height: 56,
                width: MediaQuery.of(context).size.width,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    labelText: "Full Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 56,
                width: MediaQuery.of(context).size.width,
                child: TextField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.work_outline),
                    labelText: "Job Position",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 56,
                width: MediaQuery.of(context).size.width,
                child: TextField(
                  controller: _deptController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.apartment),
                    labelText: "Department",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: _postData,
                  child: Container(
                    height: 56,
                    width: 200,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Text(
                      "Add Employee",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee List"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search Employees...",
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredEmployee.isEmpty
                  ? const Center(child: Text("No employees found"))
                  : ListView.builder(
                      itemCount: _filteredEmployee.length,
                      itemBuilder: (context, index) {
                        final employee = _filteredEmployee[index];
                        final name = employee['name'] ?? 'N/A';
                        final position = employee['position'] ?? 'N/A';
                        final dept = employee['department'] ?? 'N/A';
                        final avatar = employee['avatar'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.blueGrey,
                              backgroundImage: avatar != null && avatar != ""
                                  ? NetworkImage(avatar)
                                  : null,
                              child: (avatar == null || avatar == "")
                                  ? Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    )
                                  : null,
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(position,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text(dept,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            trailing: const Icon(Icons.keyboard_arrow_right),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showMyBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
