import 'package:flutter/material.dart';
import 'utils.dart';

// Define a custom Form widget.
class NewCollectionForm extends StatefulWidget {
  const NewCollectionForm({super.key, required this.notifyParent});
  final Function() notifyParent;

  @override
  NewCollectionFormState createState() {
    return NewCollectionFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class NewCollectionFormState extends State<NewCollectionForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Material(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Enter collection name'),
            ),
            body: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: myController,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          String name = myController.text;
                          createDirectory(name);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Collection "$name" created')),
                          );
                          widget.notifyParent();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            )));
  }
}
