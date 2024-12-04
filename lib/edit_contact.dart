import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditContactPage extends StatefulWidget {
  final Map<String, dynamic> contact;

  EditContactPage({required this.contact});

  @override
  _EditContactPageState createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController creationDateController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    nameController.text = widget.contact['nom'];
    emailController.text = widget.contact['email'];
    phoneController.text = widget.contact['telephone'];
    companyController.text = widget.contact['entreprise'];
    positionController.text = widget.contact['poste'];
    addressController.text = widget.contact['adresse'];
    creationDateController.text = widget.contact['date_creation'] ?? 'Non spécifiée'; 
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    positionController.dispose();
    addressController.dispose();
    creationDateController.dispose(); 
    super.dispose();
  }

  Future<void> updateContact() async {
    var url = Uri.parse("http://192.168.118.157/gestion_contacts/edit_contact.php");

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': widget.contact['id'],
          'nom': nameController.text,
          'email': emailController.text,
          'telephone': phoneController.text,
          'entreprise': companyController.text,
          'poste': positionController.text,
          'adresse': addressController.text,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Contact mis à jour avec succès")),
          );
          Navigator.pop(context); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Échec de la mise à jour")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur serveur")),
        );
      }
    } catch (e) {
      print("Erreur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur réseau")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier le contact"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Téléphone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: companyController,
                decoration: InputDecoration(labelText: 'Entreprise'),
              ),
              TextFormField(
                controller: positionController,
                decoration: InputDecoration(labelText: 'Poste'),
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Adresse'),
              ),
              TextFormField(
                controller: creationDateController,
                decoration: InputDecoration(labelText: 'Date de création'),
                enabled: false, 
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    updateContact();
                  }
                },
                child: Text("Mettre à jour le contact"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
