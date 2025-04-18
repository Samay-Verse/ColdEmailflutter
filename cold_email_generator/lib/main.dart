import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ColdEmailApp());
}

class ColdEmailApp extends StatelessWidget {
  const ColdEmailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cold Email Generator',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const EmailFormPage(),
    );
  }
}

class EmailFormPage extends StatefulWidget {
  const EmailFormPage({super.key});

  @override
  _EmailFormPageState createState() => _EmailFormPageState();
}

class _EmailFormPageState extends State<EmailFormPage> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final companyCtrl = TextEditingController();
  final roleCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final urlCtrl = TextEditingController();

  String generatedEmail = '';
  bool loading = false;

  Future<void> generateEmail() async {
    setState(() => loading = true);

    final data = {
      'name': nameCtrl.text,
      'company': companyCtrl.text,
      'role': roleCtrl.text,
      'experience': experienceCtrl.text,
      'url': urlCtrl.text,
    };

    try {
      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2:5000/generate-email'), // Use 10.0.2.2 for Android emulator
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(
            () => generatedEmail = result['email'] ?? 'No email returned.');
      } else {
        setState(() => generatedEmail = 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => generatedEmail = 'Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    companyCtrl.dispose();
    roleCtrl.dispose();
    experienceCtrl.dispose();
    urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cold Email Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInput(nameCtrl, 'Your Name'),
              _buildInput(companyCtrl, 'Company Name'),
              _buildInput(roleCtrl, 'Your Role'),
              _buildInput(experienceCtrl, 'Your Experience'),
              _buildInput(urlCtrl, 'Job URL'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : generateEmail,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Generate Email'),
              ),
              const SizedBox(height: 20),
              if (generatedEmail.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Generated Email:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(generatedEmail),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
