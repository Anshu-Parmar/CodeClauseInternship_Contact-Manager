import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_manager/theme/theme.dart';
import 'package:contact_manager/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditContact extends StatefulWidget {
  const EditContact({
    Key? key,
    required this.imageLink,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.id,
  }): super(key: key);
  final String imageLink;
  final String firstName;
  final String lastName;
  final String phone;
  final String id;

  @override
  State<EditContact> createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController phoneController;
  late final String imageLinks;

  void editContact() async{
    if(_formKey.currentState!.validate()){
      try{
        await FirebaseFirestore.instance.collection('contacts').doc(widget.id).update({
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "phone": phoneController.text.trim(),
          "imageLink" : imageLinks,
        });
        if(mounted){Navigator.pop(context);}
      }on FirebaseException{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to edit contacts!!')));
      }
    }
  }

  @override
  void initState() {
    firstNameController = TextEditingController(
      text: widget.firstName
    );
    lastNameController = TextEditingController(
        text: widget.lastName
    );
    phoneController = TextEditingController(
        text: widget.phone
    );
    imageLinks = widget.imageLink.toString();
    super.initState();
  }

  Uint8List? _image;
  void selectedImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  void dispose() {
    // firstNameController.dispose();
    // lastNameController.dispose();
    // phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Edit Contact",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  elevation: 20,
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              imageLinks != null
                                  ? Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: CircleAvatar(
                                    minRadius: 40,
                                    maxRadius: 60,
                                    backgroundImage: NetworkImage(imageLinks),
                                  ),
                                ),
                              )
                                  : const Padding(
                                padding: EdgeInsets.all(15.0),
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    minRadius: 40,
                                    maxRadius: 60,
                                    // img!=null? img :
                                    backgroundImage: NetworkImage(
                                        'https://w7.pngwing.com/pngs/205/731/png-transparent-default-avatar.png'),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -10,
                                left: 80,
                                child: IconButton(
                                  onPressed: selectedImage,
                                  icon: const Icon(Icons.add_a_photo),
                                  splashRadius: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            controller: firstNameController,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter first name";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: "First Name",
                              contentPadding: inputPadding,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            controller: lastNameController,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a last name";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: "Last Name",
                              contentPadding: inputPadding,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            controller: phoneController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a phone number";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: "Phone",
                              contentPadding: inputPadding,
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: ElevatedButton.icon(
                                  onPressed: () => editContact(),
                                  icon: const Icon(Icons.edit_square),
                                  label: const Text("Edit Contact"),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
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
