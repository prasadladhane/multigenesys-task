import 'package:get/get.dart';

class EmployeeController extends GetxController {
  RxMap<String, dynamic> selectedEmployee = <String, dynamic>{}.obs;

  void setEmployee(Map<String, dynamic> emp) {
    selectedEmployee.value = emp;
  }
}
