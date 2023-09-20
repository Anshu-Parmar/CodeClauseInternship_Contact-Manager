import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_manager/theme/theme.dart';
import 'package:contact_manager/utils/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Uint8List? _image;
  void selectedImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void addContacts() async {
    Future<String> uploadImageToStorage(String childName, Uint8List file) async {
      Reference ref = _storage.ref().child(childName);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    }
    if (_formKey.currentState!.validate()) {
      try {
        if(_image == null){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload a photo!!!")));
        }
        String imageUrl = await uploadImageToStorage('profileImage', _image!);
        await FirebaseFirestore.instance.collection("contacts").add({
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "phone": phoneController.text.trim(),
          "imageLink" : imageUrl,
        });
        if (mounted) {
          Navigator.pop(context);
        }else{
          CircularProgressIndicator.adaptive();
        }
      } on FirebaseException {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to add contacts")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill all fields")));
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "New Contact",
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
                              _image != null
                                  ? Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: CircleAvatar(
                                          minRadius: 40,
                                          maxRadius: 60,
                                          backgroundImage: MemoryImage(_image!),
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
                                  onPressed: () => addContacts(),
                                  icon: const Icon(Icons.add_call),
                                  label: const Text("Add Contact"),
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
