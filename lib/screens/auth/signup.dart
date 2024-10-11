import 'package:admin/bloc/auth.dart';
import 'package:admin/constants.dart';
import 'package:admin/screens/auth/Login.dart';
import 'package:admin/screens/auth/components/alread_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SignupScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Signup successful!')),
            );
            Navigator.pushReplacementNamed(context, '/login');
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error.toString())),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Large screens (desktop/tablet)
              return Row(
                children: [
                  // Left Image
                  Expanded(
                    child: Container(
                      color: Colors.purple,
                      child: Center(
                        child: SvgPicture.asset("assets/icons/signup.svg"),
                      ),
                    ),
                  ),
                  // Right Form
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: _buildForm(context),
                    ),
                  ),
                ],
              );
            } else {
              // Small screens (mobile)
              return Center(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildForm(context),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text(
            "Sign Up",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: defaultPadding * 2),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Username'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: defaultPadding),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: defaultPadding),
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(labelText: 'First Name'),
          ),
          SizedBox(height: defaultPadding),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(labelText: 'Last Name'),
          ),
          SizedBox(height: defaultPadding),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: defaultPadding),
          TextFormField(
            controller: _password2Controller,
            decoration: InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<AuthBloc>().add(SignupEvent(
                      username: _usernameController.text,
                      email: _emailController.text,
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      password: _passwordController.text,
                      password2: _password2Controller.text,
                    ));
              }
            },
            child: Text('Signup'),
          ),
          SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              })
        ],
      ),
    );
  }


}
