import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MaterialApp(
    home: BlocProvider(
      create: (context) => FormBloc(),
      child: MyForm(),
    ),
  ));
}

class FormBloc extends Cubit<Map<String, String>> {
  FormBloc() : super({});

  void updateField(String field, String value) {
    emit(state..[field] = value);
  }
}

class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MyFormFields(),
      ),
    );
  }
}

class MyFormFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormBloc, Map<String, String>>(
      builder: (context, state) {
        return Column(
          children: [
            _buildTextField(context, 'First Name', 'firstName'),
            _buildTextField(context, 'Middle Name', 'middleName'),
            _buildTextField(context, 'Last Name', 'lastName'),
            _buildTextField(context, 'Country', 'country'),
            _buildTextField(context, 'Age', 'age'),
            _buildTextField(context, 'Address', 'address'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle the submit logic here
                context.read<FormBloc>().state.forEach((key, value) {
                  print('$key: $value');
                });
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context, String label, String field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        onChanged: (value) {
          context.read<FormBloc>().updateField(field, value);
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
