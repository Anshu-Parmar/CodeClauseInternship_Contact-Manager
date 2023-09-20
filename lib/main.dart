import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_manager/add_contact.dart';
import 'package:contact_manager/theme/theme.dart';
import 'package:contact_manager/user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Contacts",
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final contactsCollection =
      FirebaseFirestore.instance.collection('contacts').snapshots();

  Uri dialNumber = Uri(scheme: 'tel', path: '91');
  callNumber() async => await launchUrl(dialNumber);
  directCall(String phone) async => await FlutterPhoneDirectCaller.callNumber(phone);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contacts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
            splashRadius: 20,
            splashColor: Colors.white70,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddContact(),
            )),
        child: const Icon(
          Icons.dialpad,
          color: Colors.blue,
          size: 25.0,
        ),
      ),
      body: StreamBuilder(
          stream: contactsCollection,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
              if (documents.isEmpty) {
                return const Center(
                    child: Text(
                  "No contact",
                ));
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      //controller: searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        labelText: "Search",
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final contact = documents[index].data() as Map<String, dynamic>;
                          final contactId = documents[index].id;
                          final String imageLinks = contact['imageLink'];
                          final String firstName = contact['firstName'];
                          final String lastName = contact['lastName'];
                          final String phone = contact['phone'];
                          return ListTile(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserCard(
                                    imageLink: imageLinks,
                                    firstName: firstName,
                                    lastName: lastName,
                                    phone: phone,
                                    id: contactId,
                                  ),
                                )),
                            title: Row(
                              children: [
                                Text( "$firstName $lastName",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              phone,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: SizedBox(
                              width: 70,
                              child: IconButton(
                                onPressed: () => directCall(phone),
                                icon: const Icon(
                                  Icons.phone,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                              ),
                            ),
                            leading: Hero(
                              tag: contactId,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircleAvatar(
                                    minRadius: 25,
                                    maxRadius: 35,
                                    backgroundImage: NetworkImage(imageLinks),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return const Text('Error has occured!!!');
            }
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }),
    );
  }

// Widget callDialPad() {
//   return Container();
// }
}
