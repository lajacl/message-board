import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_board/home.dart';

// AuthGate shows Splash then routes to Login or Home depending on auth state.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() => _initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return SplashScreen();
    }
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }
        final user = snap.data;
        if (user == null) {
          return LoginPage();
        } else {
          return HomePage();
        }
      },
    );
  }
}

// Splash Screen widget
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.indigo,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.forum, size: 84, color: Colors.white),
              SizedBox(height: 12),
              Text(
                'Chatboards',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Message Boards for the New Age',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

void showSnack(BuildContext ctx, String s) =>
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(s)));

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text;
    if (email.isEmpty || pw.isEmpty) {
      showSnack(context, 'Email and password required');
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pw,
      );
    } on FirebaseAuthException catch (e) {
      showSnack(context, e.message ?? 'Login failed');
    } catch (e) {
      showSnack(context, 'Login error');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _goRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _pwCtrl,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _login,
                  icon: Icon(Icons.login),
                  label: Text(_loading ? 'Signing in...' : 'Sign in'),
                ),
                TextButton(
                  onPressed: _goRegister,
                  child: Text('Register a new account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Register Page
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  String _role = 'member';
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final mail = _email.text.trim();
      final pw = _pw.text.trim();
      final fn = _first.text.trim();
      final ln = _last.text.trim();

      setState(() => _loading = true);
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: mail,
          password: pw,
        );
        final user = cred.user!;
        final now = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'firstName': fn,
          'lastName': ln,
          'role': _role,
          'registeredAt': now,
          'email': mail,
        });
        showSnack(context, 'Registered successfully!');
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        showSnack(context, e.message ?? 'Registration error');
      } catch (e) {
        showSnack(context, 'Error registering');
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: _first,
                    decoration: InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _last,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Required";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Required";
                      }
                      if (!value.contains(RegExp(r'.+@.+\..+'))) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _pw,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password (min 6)'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Required";
                      }
                      if (value.trim().length < 6) {
                        return "Must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    items: ['member', 'moderator', 'admin']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => _role = v ?? 'member'),
                    decoration: InputDecoration(labelText: 'Role'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: Text(_loading ? 'Registering...' : 'Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
