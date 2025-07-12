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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List _employee = [];
  List _filteredEmployee = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    _searchController.addListener(() {
      filterList(_searchController.text);
    });
  }

  void fetchData() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("https://669b3f09276e45187d34eb4e.mockapi.io/api/v1/employee"),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _employee = List<Map<String, dynamic>>.from(json.decode(response.body));
          _filteredEmployee = _employee;
          _isLoading = false;
        });
      } else {
        Get.snackbar("Error", "Failed to load data");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
      setState(() => _isLoading = false);
    }
  }

  void filterList(String query) {
    final result = _employee.where((emp) {
      final name = emp['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() => _filteredEmployee = result);
  }

  void _postData() async {
    final name = _nameController.text.trim();
    final position = _positionController.text.trim();
    final dept = _deptController.text.trim();

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
      Get.snackbar("Success", "Employee added");
      _nameController.clear();
      _positionController.clear();
      _deptController.clear();
      fetchData();
    } else {
      Get.snackbar("Error", "Failed to store data");
    }
  }

  void showAddEmployeeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Add New Employee",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.work_outline),
                    labelText: "Job Position",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Job Position is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _deptController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.apartment),
                    labelText: "Department",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Department is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        _postData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Add Employee",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showEmployeeDialog(Map<String, dynamic> emp) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueGrey,
                  child: Text(
                    (emp['name'] ?? 'N/A')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  emp['name'] ?? 'N/A',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  emp['position'] ?? 'No Position',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.apartment,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        emp['department'] ?? 'No Department',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: () => Get.back(),
                )
              ],
            ),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredEmployee.isEmpty
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
                                onTap: () => showEmployeeDialog(employee),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
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
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddEmployeeSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
