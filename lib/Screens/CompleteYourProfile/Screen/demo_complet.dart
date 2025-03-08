import 'package:flutter/material.dart';

class GenderDropdownForm extends StatefulWidget {
  const GenderDropdownForm({super.key});

  @override
  State<GenderDropdownForm> createState() => _GenderDropdownFormState();
}

class _GenderDropdownFormState extends State<GenderDropdownForm> {
  String? _selectedGender;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gender Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: <String>['Male', 'Female', 'Other', 'Prefer not to say']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: "Gender",
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, process the selected gender
                    print('Selected Gender: $_selectedGender');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Gender selected: $_selectedGender')),
                    );
                    // You can perform further actions here, like saving to a database
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
