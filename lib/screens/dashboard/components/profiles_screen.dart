import 'dart:math';

import 'package:admin/bloc/profile.dart';
import 'package:admin/models/user.dart';
import 'package:admin/responsive.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constants.dart';

class ProfilesScreen extends StatefulWidget {
  @override
  _ProfilesScreenState createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfilesEvent());
  }

  void _showCreateUserDialog(BuildContext context) {
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    // Error message variables
    String firstNameError = '';
    String lastNameError = '';
    String emailError = '';
    String usernameError = '';
    String passwordError = '';

    // Email validation regex
    final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    // Function to validate fields
    bool _validateFields() {
      bool isValid = true;

      // Validate first name
      if (firstNameController.text.isEmpty) {
        firstNameError = 'First name is required';
        isValid = false;
      } else {
        firstNameError = '';
      }

      if (lastNameController.text.isEmpty) {
        lastNameError = 'Last name is required';
        isValid = false;
      } else {
        lastNameError = '';
      }

      if (emailController.text.isEmpty) {
        emailError = 'Email is required';
        isValid = false;
      } else if (!emailRegExp.hasMatch(emailController.text)) {
        emailError = 'Invalid email format';
        isValid = false;
      } else {
        emailError = '';
      }

      if (usernameController.text.isEmpty) {
        usernameError = 'Username is required';
        isValid = false;
      } else {
        usernameError = '';
      }

      if (passwordController.text.isEmpty) {
        passwordError = 'Password is required';
        isValid = false;
      } else if (passwordController.text.length < 6) {
        passwordError = 'Password must be at least 6 characters long';
        isValid = false;
      } else {
        passwordError = '';
      }

      return isValid;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Create New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    hintText: 'First Name',
                    errorText:
                        firstNameError.isNotEmpty ? firstNameError : null,
                  ),
                ),
                SizedBox(height: defaultPadding),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    hintText: 'Last Name',
                    errorText: lastNameError.isNotEmpty ? lastNameError : null,
                  ),
                ),
                SizedBox(height: defaultPadding),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    errorText: emailError.isNotEmpty ? emailError : null,
                  ),
                ),
                SizedBox(height: defaultPadding),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    errorText: usernameError.isNotEmpty ? usernameError : null,
                  ),
                ),
                SizedBox(height: defaultPadding),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    errorText: passwordError.isNotEmpty ? passwordError : null,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate form fields
                if (_validateFields()) {
                  // Dispatch the CreateProfileEvent to the ProfileBloc
                  context.read<ProfileBloc>().add(CreateProfileEvent(
                        username: usernameController.text,
                        email: emailController.text,
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        password: passwordController.text,
                      ));
                  context.read<ProfileBloc>().add(LoadProfilesEvent());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Created User: ${firstNameController.text}')),
                  );

                  // Close the dialog
                  Navigator.pop(context);
                } else {
                  // Trigger a UI update to show error messages
                  setState(() {});
                }
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
      return Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Users",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // ElevatedButton(
                //   onPressed: () => _showCreateUserDialog(context),
                //   child: Text('Add New'),
                // ),
                TextButton.icon(
                  onPressed: () => _showCreateUserDialog(context),
                    icon: Icon(Icons.add),
                    label: Text("Add New"),
                )

              ],
            ),
            if (state is ProfileLoaded)
              SizedBox(
                width: double.infinity,
                child: DataTable(
                  columnSpacing: defaultPadding,
                  // minWidth: 600,
                  columns: [
                    DataColumn(
                      label: Text("First Name"),
                    ),
                    DataColumn(
                      label: Text("Last Name"),
                    ),
                    DataColumn(
                      label: Text("Username"),
                    ),
                    DataColumn(
                      label: Text("Email"),
                    ),
                    DataColumn(
                      label: Text('Actions'), // Column for edit/delete buttons
                    ),
                  ],
                  rows: List.generate(
                    state.profiles.length,
                    (index) => userDataRow(state.profiles[index], context),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

DataRow userDataRow(User user, BuildContext context) {
  void _showEditDialog(BuildContext context, User user) {
    String updatedFirstName = user.firstName;
    String updatedLastName = user.lastName;
    String updatedEmail = user.email;
    String updatedUsername = user.username;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => updatedFirstName = value,
              decoration: InputDecoration(hintText: 'First Name'),
              controller: TextEditingController(text: user.firstName),
            ),
            SizedBox(height: defaultPadding),
            TextField(
              onChanged: (value) => updatedLastName = value,
              decoration: InputDecoration(hintText: 'Last Name'),
              controller: TextEditingController(text: user.lastName),
            ),
            SizedBox(height: defaultPadding),
            TextField(
              onChanged: (value) => updatedEmail = value,
              decoration: InputDecoration(hintText: 'Email'),
              controller: TextEditingController(text: user.email),
            ),
            SizedBox(height: defaultPadding),
            TextField(
              onChanged: (value) => updatedUsername = value,
              decoration: InputDecoration(hintText: 'Username'),
              controller: TextEditingController(text: user.username),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Check if fields are updated before making the API call
              if (updatedFirstName.isNotEmpty &&
                  updatedLastName.isNotEmpty &&
                  updatedEmail.isNotEmpty &&
                  updatedUsername.isNotEmpty) {
                // context.read<ProfileBloc>().add(DeleteProfileEvent(user.id));
                // context.read<ProfileBloc>().add(LoadProfilesEvent());
                context.read<ProfileBloc>().add(UpdateProfileEvent(
                      userId: user.id,
                      updatedData: {
                        'first_name': updatedFirstName,
                        'last_name': updatedLastName,
                        'email': updatedEmail,
                        'username': updatedUsername,
                      },
                    ));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('USer successful!')),
              );
              context.read<ProfileBloc>().add(LoadProfilesEvent());

              // Close the dialog
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text(
            'Are you sure you want to delete "${user.firstName} ${user.lastName}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(DeleteProfileEvent(user.id));
              context.read<ProfileBloc>().add(LoadProfilesEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted Use: ${user.firstName}')),
              );
              print('Deleted Use: ${user.firstName}');
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            CircleWithLetter(name: user.firstName),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(user.firstName),
            ),
          ],
        ),
      ),
      DataCell(Text(user.lastName)),
      DataCell(Text(user.username)),
      DataCell(Text(user.email)),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, user),
              iconSize: 18,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, user),
              iconSize: 18,
            ),
          ],
        ),
      ),
    ],
  );
}

class CircleWithLetter extends StatelessWidget {
  final String name;
  final Color textColor;

  const CircleWithLetter({
    Key? key,
    required this.name,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '';
    final randomColor = Color.fromARGB(255, Random.secure().nextInt(256),
        Random.secure().nextInt(256), Random.secure().nextInt(256));

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: randomColor,
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
