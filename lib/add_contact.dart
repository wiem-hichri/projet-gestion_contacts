import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class AddContactPage extends StatefulWidget {
  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  String contactName = '';
  String contactTelephone = '';
  String contactEmail = '';
  String contactEntreprise = '';
  String contactPoste = '';
  String contactAdresse = '';
  String contactDateCreation = '';
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    contactDateCreation = DateTime.now().toIso8601String();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> addContact() async {
    var url = Uri.parse("http://192.168.118.157/gestion_contacts/add_contact.php");
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['nom'] = contactName;
      request.fields['telephone'] = contactTelephone;
      request.fields['email'] = contactEmail;
      request.fields['entreprise'] = contactEntreprise;
      request.fields['poste'] = contactPoste;
      request.fields['adresse'] = contactAdresse;
      request.fields['date_creation'] = contactDateCreation;

      if (selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('image', selectedImage!.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var data = json.decode(responseData.body);

        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Contact ajouté avec succès")),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Erreur lors de l'ajout de contact")),
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
        backgroundColor: Colors.blue,
        title: Text("Créer un contact"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                    child: selectedImage == null
                        ? Icon(Icons.person, size: 50, color: Colors.blue)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Nom de contact",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onChanged: (value) => contactName = value,
                  validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un nom' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Téléphone",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onChanged: (value) => contactTelephone = value,
                  validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un téléphone' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onChanged: (value) => contactEmail = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Entreprise",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onChanged: (value) => contactEntreprise = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Poste",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onChanged: (value) => contactPoste = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Adresse",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  onChanged: (value) => contactAdresse = value,
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        addContact();
                      }
                    },
                    child: Text("Ajouter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
