import 'package:flutter/material.dart';
import '../../../../../repositories/clinic_repository.dart';

class AdminSpecialtyScreen  extends StatefulWidget {
   AdminSpecialtyScreen ({super.key});

  @override
  State<AdminSpecialtyScreen> createState() => _AdminSpecialtyScreenState();
}

class _AdminSpecialtyScreenState extends State<AdminSpecialtyScreen> {
  final ClinicRepository _repository = ClinicRepository.getInstance();
  List<String> _specialties = [];
  bool _isLoading = true;
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadSpecialties();
  }
  Future<void> _loadSpecialties() async {
    final list = await _repository.getSpecialties();
    if (mounted) {
      setState(() {
        _specialties = list;
        _isLoading = false;
      });
    }
  }
  void _addSpecialty() async {
    if (_controller.text.isEmpty) return;

    await _repository.addSpecialty(_controller.text.trim());
    _controller.clear();
    Navigator.pop(context);
    _loadSpecialties();

    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Specialty Added!"), backgroundColor: Colors.blue),
      );
    }
  }
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Specialty"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
              labelText: "Specialty Name",
              hintText: "e.g. Dermatology",
              border: OutlineInputBorder()
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: _addSpecialty, child: const Text("Add")),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("Manage Specialties",
            style: TextStyle(fontSize: 30, color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _specialties.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.medical_services, color: Colors.blue, size: 20),
              ),
              title: Text(
                _specialties[index],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}