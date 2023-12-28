import 'package:contacts_buddy/contact.dart';
import 'package:flutter/material.dart';
import 'package:contacts_buddy/database_helper.dart';
import 'package:logger/logger.dart';
import 'dart:ui';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class AppLogger {
  static final Logger _logger = Logger();

  static void init() {
    Logger.level = Level.debug;
  }

  static void logInfo(String message) {
    _logger.i(message);
  }

  static void logError(String message, [dynamic error]) {
    _logger.e(message, error: error);
  }
}


class _HomePageState extends State<HomePage> {
  bool searchError = false;  // Declare searchError here
  bool searching = false;
  int selectedIndex = -1; // Add this line
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<Contact> searchedContacts = [];
  List<Contact> contacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/Logo-Large-PNG.png',
          width: 170,
          height: 100,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.transparent, // Set the app bar background color to transparent
        actions: [
          IconButton(
            onPressed: () {
              _showSearchDialog();
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          if (searchedContacts.isEmpty && searchError)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.error,
                color: Colors.red,
              ),
            ),
          IconButton(
            onPressed: () {
              // Handle the cancel action
              _cancelSearch();
            },
            icon: const Icon(
              Icons.cancel,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/HD-wallpaper-oppo-f11pro-gray-mix-pattern-thumbnail.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (searchedContacts.isEmpty)
                Expanded(
                  child: contacts.isEmpty
                      ? Center(
                    child: Text(
                      searchError ? 'Error during search' : 'No Contact yet..',
                      style: const TextStyle(fontSize: 22),
                    ),
                  )
                      : ListView.builder(
                    key: UniqueKey(),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) => getRow(index),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    key: UniqueKey(),
                    itemCount: searchedContacts.length,
                    itemBuilder: (context, index) => getRow(index),
                  ),
                ),

              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 40),
                child: ElevatedButton(
                  onPressed: () {
                    _showAddContactForm();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Add Contact'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }







  Widget getRow(int index) {

    final List<Contact> currentContacts = searchedContacts.isEmpty ? contacts : searchedContacts;

    return Card(
      child: ListTile(
        onTap: () {
          // Calling the method to show contact details
          _showContactDetails(currentContacts[index]);
        },
        leading: CircleAvatar(
          backgroundColor: index % 2 == 0 ? Colors.deepPurpleAccent : Colors.purple,
          foregroundColor: Colors.white,
          child: Text(
            currentContacts[index].firstName[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Full Name: ${currentContacts[index].firstName} ${currentContacts[index].middleName} ${currentContacts[index].lastName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Contact: ${currentContacts[index].contact}'),
          ],
        ),
        trailing: SizedBox(
          width: 70,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  _showEditContactForm(index);
                },
                child: const Icon(Icons.edit),
              ),
              InkWell(
                onTap: () {
                  _deleteContact(index);
                },
                child: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }





  void _showAddContactForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Contact'),
          content: Container(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField('First Name', firstNameController),
                  _buildTextField('Middle Name', middleNameController),
                  _buildTextField('Last Name', lastNameController),
                  _buildTextField('Contact Number', contactController, keyboardType: TextInputType.number),
                  _buildTextField('Country', countryController),
                  _buildTextField('Age', ageController, keyboardType: TextInputType.number),
                  _buildTextField('Address', addressController),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Adjust this to your layout preference
              children: [
                ElevatedButton(
                  onPressed: () {
                    _addContact();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _clearFields(); // Call the function to clear all fields
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  void _showEditContactForm(int index) {
    firstNameController.text = contacts[index].firstName;
    middleNameController.text = contacts[index].middleName;
    lastNameController.text = contacts[index].lastName;
    countryController.text = contacts[index].country;
    ageController.text = contacts[index].age.toString();
    addressController.text = contacts[index].address;
    contactController.text = contacts[index].contact;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Contact'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('First Name', firstNameController),
                _buildTextField('Middle Name', middleNameController),
                _buildTextField('Last Name', lastNameController),
                _buildTextField('Contact Number', contactController, keyboardType: TextInputType.number),
                _buildTextField('Country', countryController),
                _buildTextField('Age', ageController, keyboardType: TextInputType.number),
                _buildTextField('Address', addressController),

              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _updateContact(index);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetching contacts from the database when the widget is created
    _fetchContacts();
  }

  // fetch contacts from the database
  void _fetchContacts() async {
    List<Contact> fetchedContacts = await DatabaseHelper.instance.getContacts();
    setState(() {
      contacts = fetchedContacts;
    });
  }


  void _addContact() async {
    String firstName = firstNameController.text.trim();
    String middleName = middleNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String contact = contactController.text.trim();

    // Check if either the first name, middle name, or last name is filled
    if (firstName.isNotEmpty || middleName.isNotEmpty || lastName.isNotEmpty) {
      if (contact.isNotEmpty) {
        setState(() {
          // Clear the text controllers
          firstNameController.text = '';
          middleNameController.text = '';
          lastNameController.text = '';
          countryController.text = ''; // Fix: Added countryController.text
          ageController.text = '';
          addressController.text = '';
          contactController.text = '';

          Contact newContact = Contact(
            id: null, // Set id to null when creating a new contact
            firstName: firstName,
            middleName: middleName,
            lastName: lastName,
            country: countryController.text, // Fix: Use countryController.text
            age: int.tryParse(ageController.text) ?? 0,
            address: addressController.text,
            contact: contact,
          );

          // Insert the contact into the database
          DatabaseHelper.instance.insertContact(newContact);

          // Log the contact information
          AppLogger.logInfo('Adding new contact: $newContact');

          // Update the UI with the new contact
          contacts.add(newContact);
        });
      } else {
        // Show an error message or handle the case where contact number is not provided
        // You can display a snackbar or showDialog to inform the user
        _showErrorMessage('Contact number is required.');
      }
    } else {
      // Show an error message or handle the case where none of the names is filled
      // You can display a snackbar or showDialog to inform the user
      _showErrorMessage('At least one of the names (First, Middle, Last) is required.');
    }
  }
  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void _updateContact(int index) async {
    String firstName = firstNameController.text.trim();
    String middleName = middleNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String country = countryController.text.trim();
    int age = int.tryParse(ageController.text.trim()) ?? 0;
    String address = addressController.text.trim();
    String contact = contactController.text.trim();

    try {
      // Create a Contact object with the updated information
      Contact updatedContact = Contact(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        country: country,
        age: age,
        address: address,
        contact: contact,
      );

      // Check if at least one field is not empty before updating
      if (firstName.isNotEmpty || lastName.isNotEmpty || contact.isNotEmpty) {
        // Update the non-empty fields of the contact in the database
        await DatabaseHelper.instance.updateContactPartial(updatedContact, contacts[index].id);

        // Log the updated contact information
        AppLogger.logInfo('Updating contact at index $index: $updatedContact');

        // Update the UI with the updated contact
        setState(() {
          contacts[index] = updatedContact;
          selectedIndex = -1;
        });
      } else {
        // Show an error message or handle the case where no fields are provided for update
      }
    } catch (e) {
      // Log any errors that occur during the update process
      AppLogger.logError('Error updating contact: $e');
    } finally {
      // Clear the text controllers
      firstNameController.clear();
      middleNameController.clear();
      lastNameController.clear();
      countryController.clear();
      ageController.clear();
      addressController.clear();
      contactController.clear();
    }
  }



  void _showSearchDialog() {
    setState(() {
      searchError = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Contacts'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Enter contact name...',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performSearch(searchController.text);
              },
              child: const Text('Search'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelSearch();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _performSearch(String contactName) async {
    try {
      setState(() {
        searching = true;
        searchError = false;
      });

      if (contactName.isNotEmpty) {
        List<Contact> results = await DatabaseHelper.instance.searchContacts(contactName);
        setState(() {
          searchedContacts = results;
          searchError = results.isEmpty;
        });

        // Showing a message based on whether contacts were found or not
        if (results.isNotEmpty) {
          _showSearchResultMessage('Contacts found!');
        } else {
          _showSearchResultMessage('No contacts found.');
        }
      }
    } catch (e) {
      AppLogger.logError('Error during search: $e');
      setState(() {
        searchError = true;
      });
    } finally {
      setState(() {
        searching = false;
      });
    }
  }

  void _showSearchResultMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Result'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void _cancelSearch() {
    // Clear the search controller
    searchController.clear();

    // Clear the search results
    setState(() {
      searchedContacts.clear();
      searchError = false; // Reset the search error status
    });
  }

  void _showContactDetails(Contact contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContactDetail('First Name', contact.firstName),
              _buildContactDetail('Middle Name', contact.middleName),
              _buildContactDetail('Last Name', contact.lastName),
              _buildContactDetail('Country', contact.country),
              _buildContactDetail('Age', contact.age.toString()),
              _buildContactDetail('Address', contact.address),
              _buildContactDetail('Contact Number', contact.contact),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _searchContact(String contactName) async {
    if (contactName.isNotEmpty) {
      List<Contact> searchResults = await DatabaseHelper.instance.searchContacts(contactName);

      setState(() {
        contacts = searchResults;
      });
    }
  }



  void _deleteContact(int index) async {
    try {
      if (contacts == null || index < 0 || index >= contacts.length) {
        _showErrorMessage('Invalid contact index');
        return;
      }

      int? contactId = contacts[index].id;

      if (contactId == null) {
        _showErrorMessage('Contact ID is null');
        return;
      }

      // Check if at least one field is not empty before deleting
      if (contacts[index].firstName.isNotEmpty ||
          contacts[index].lastName.isNotEmpty ||
          contacts[index].contact.isNotEmpty) {
        await DatabaseHelper.instance.deleteContact(contactId);

        setState(() {
          contacts.removeAt(index);
          selectedIndex = -1;
        });

        AppLogger.logInfo('Contact deleted successfully');
      } else {
        // Show an error message or handle the case where no fields are provided for deletion
        _showErrorMessage('At least one of the names (First, Last) or Contact Number is required.');
      }
    } catch (e) {
      AppLogger.logError('Error deleting contact: $e');
      _showErrorMessage('Error deleting contact');
    }
  }

  void _clearFields() {
    setState(() {
      firstNameController.text = '';
      middleNameController.text = '';
      lastNameController.text = '';
      countryController.text = '';
      ageController.text = '';
      addressController.text = '';
      contactController.text = '';
    });
  }

}