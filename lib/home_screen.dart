import 'package:flutter/material.dart';
import 'add_contact.dart';
import 'profile_page.dart';
import 'edit_contact.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> contactList = [];
  List<dynamic> filteredContacts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchContacts();
    searchController.addListener(() {
      filterContacts();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void logout() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> fetchContacts() async {
    var url = Uri.parse("http://192.168.118.157/gestion_contacts/get_contacts.php");
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> contacts = data['contacts'];

        setState(() {
          contactList = contacts;
          filteredContacts = contacts;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la récupération des contacts")),
        );
      }
    } catch (e) {
      print("Erreur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur réseau")),
      );
    }
  }

  void filterContacts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredContacts = contactList.where((contact) {
        String name = contact['nom']?.toLowerCase() ?? '';
        String email = contact['email']?.toLowerCase() ?? '';
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  Future<void> deleteContact(int contactId) async {
    var url = Uri.parse("http://192.168.118.157/gestion_contacts/delete_contact.php");
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': contactId}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Contact supprimé avec succès")),
          );
          fetchContacts();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Échec de la suppression")),
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
      title: const Text("Liste des contacts"),
      backgroundColor: Colors.blue,
    ),
    endDrawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Menu",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profil"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Paramètres"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Déconnexion"),
            onTap: () {
              Navigator.pop(context);
              logout();
            },
          ),
        ],
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un contact...',
              prefixIcon: Icon(Icons.search, size: 20),
              contentPadding: EdgeInsets.symmetric(vertical: 9, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: filteredContacts.isEmpty
              ? Center(child: Text("Aucun contact trouvé"))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.75, 
                  ),
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    var item = filteredContacts[index];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Détails du contact"),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Nom : ${item['nom'] ?? 'Non disponible'}"),
                                  Text("Email : ${item['email'] ?? 'Non disponible'}"),
                                  Text("Téléphone : ${item['telephone'] ?? 'Non disponible'}"),
                                  Text("Entreprise : ${item['entreprise'] ?? 'Non disponible'}"),
                                  Text("Poste : ${item['poste'] ?? 'Non disponible'}"),
                                  Text("Adresse : ${item['adresse'] ?? 'Non disponible'}"),
                                  Text("Date de création : ${item['date_creation'] ?? 'Non disponible'}"),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Fermer"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: item['image_path'] != null && item['image_path']!.isNotEmpty
                                    ? (item['image_path']!.startsWith('uploads/')
                                        ? Image.network(
                                            'http://192.168.118.157/gestion_contacts/' +
                                                item['image_path']!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(item['image_path']!),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ))
                                    : Icon(Icons.person, size: 80, color: Colors.blue),
                              ),
                              SizedBox(height: 10),
                              Text(
                                item['nom'] ?? 'Sans nom',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 5),
                              Text(
                                item['email'] ?? 'Non disponible',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditContactPage(contact: item),
                                        ),
                                      ).then((_) {
                                        fetchContacts();
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text("Confirmation"),
                                          content: Text(
                                              "Voulez-vous vraiment supprimer ce contact ?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Annuler"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteContact(item['id']);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Supprimer"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddContactPage()),
        ).then((_) {
          fetchContacts();
        });
      },
      child: Icon(Icons.add),
      backgroundColor: Colors.blue,
    ),
  );
}
}