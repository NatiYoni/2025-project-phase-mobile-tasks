import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entity/authentication.dart';
import '../bloc/bloc/auth_bloc.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const SignUpForm(),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  String? _confirmValidator(String? v){
    if(v==null || v.trim().isEmpty) return 'Required';
    if(v.trim() != _passwordController.text.trim()) return 'Passwords do not match';
    return null;
  }

  void _onSignUpPressed() {
    if(!_formKey.currentState!.validate() || !_acceptedTerms) {
      if(!_acceptedTerms){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please accept the terms & policy')));
      }
      return;
    }
    context.read<AuthBloc>().add(
      SignUpEvent(
        Authentication(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ErrorState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is SignUpState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Account created successfully! Please sign in.'),
              ),
            );
          Navigator.pop(context);
        }
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent, width: 1.2),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'ECOM',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.blueAccent,
                            fontSize: 20,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _label('Name'),
                  _gap(8),
                  _input(_nameController, 'ex jon smith', validator: _required),
                  _gap(22),
                  _label('Email'),
                  _gap(8),
                  _input(_emailController, 'ex: jon.smith@email.com', keyboardType: TextInputType.emailAddress, validator: _emailValidator),
                  _gap(22),
                  _label('Password'),
                  _gap(8),
                  _input(_passwordController, '********', obscure: true, validator: _required),
                  _gap(22),
                  _label('Confirm password'),
                  _gap(8),
                  _input(_confirmPasswordController, '********', obscure: true, validator: _confirmValidator),
                  _gap(20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (v) => setState(()=> _acceptedTerms = v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black87, fontSize: 12),
                            children: const [
                              TextSpan(text: 'I understood the '),
                              TextSpan(text: 'terms & policy.', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  _gap(10),
                  SizedBox(
                    width: double.infinity,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is LoadingState) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ElevatedButton(
                          onPressed: _onSignUpPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4B4FFD),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: .8,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _gap(28),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Have an account? ',
                          style: TextStyle(color: Colors.black87),
                          children: [
                            TextSpan(text: 'SIGN IN', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _gap(20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---- helpers ----
Widget _gap(double h) => SizedBox(height: h);
Widget _label(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.w600));
InputDecoration _dec(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Colors.black38),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  filled: true,
  fillColor: const Color(0xFFF5F5F7),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none,
  ),
);
Widget _input(TextEditingController c, String hint,{bool obscure=false, TextInputType? keyboardType, String? Function(String?)? validator}){
  return TextFormField(
    controller: c,
    obscureText: obscure,
    keyboardType: keyboardType,
    validator: validator,
    decoration: _dec(hint),
  );
}

String? _required(String? v){ if(v==null || v.trim().isEmpty) return 'Required'; return null; }
String? _emailValidator(String? v){
  if(v==null || v.trim().isEmpty) return 'Required';
  if(!v.contains('@')) return 'Invalid email';
  return null;
}
