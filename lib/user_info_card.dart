import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_manager/edit_contacts.dart';
import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  UserCard({
    Key? key,
    required this.imageLink,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.id,
  });
  final String imageLink;
  final String firstName;
  final String lastName;
  final String phone;
  final String id;

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {

  void deleteContact(String id) async {
    await FirebaseFirestore.instance.collection('contacts').doc(id).delete();
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contact deleted.")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    late final firstName = widget.firstName.toString();
    late final lastName = widget.lastName.toString();
    late final phone = widget.phone.toString();
    late final imageLinks = widget.imageLink.toString();
    late final contactId = widget.id.toString();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert,),
            splashRadius: 20,
            splashColor: Colors.white70,
          )
        ],
      ),
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width*1,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  elevation: 20,
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Hero(
                        tag: contactId,
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: CircleAvatar(
                              minRadius: 40,
                              maxRadius: 60,
                              backgroundImage: NetworkImage(imageLinks),
                            ),
                          ),
                        ),
                      ),
                      const Divider(thickness: 5,),
                      const SizedBox(height: 20,),
                      Text('Name: $firstName $lastName',style:const TextStyle(fontSize: 20.0),),
                      const SizedBox(height: 20,),
                      Text('Mobile: $phone', style:const TextStyle(fontSize: 20.0),),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditContact(
                                imageLink: imageLinks,
                                firstName: firstName,
                                lastName: lastName,
                                phone:  phone,
                                id: contactId,
                              ),)),
                              icon: const Icon(Icons.edit, color: Colors.blue,),
                              splashRadius: 20,
                          ),
                          const SizedBox(width: 20,),
                          IconButton(
                              onPressed: ()=>deleteContact(contactId),
                              icon: const Icon(Icons.delete_rounded, color: Colors.blue,),
                              splashRadius: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
