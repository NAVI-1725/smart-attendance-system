// mobile_app\lib\features\auth\presentation\login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icon/app_icon.png',
                    width: 120,
                    height: 120,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'HKS Attendance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Hybrid Knowledge Security Attendance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 36),

                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            controller:
                                _emailController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Email',
                              prefixIcon:
                                  Icon(Icons.email_outlined),
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          TextField(
                            controller:
                                _passwordController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'Password',
                              prefixIcon:
                                  Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          SizedBox(
                            width:
                                double.infinity,
                            height: 50,
                            child: authState
                                    .isLoading
                                ? const Center(
                                    child:
                                        CircularProgressIndicator(),
                                  )
                                : ElevatedButton(
                                    onPressed:
                                        () {
                                      ref
                                          .read(
                                            authNotifierProvider
                                                .notifier,
                                          )
                                          .login(
                                            email:
                                                _emailController
                                                    .text,
                                            password:
                                                _passwordController
                                                    .text,
                                          );
                                    },
                                    child:
                                        const Text(
                                      'Login',
                                    ),
                                  ),
                          ),

                          if (authState.error !=
                              null) ...[
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              authState.error!,
                              textAlign:
                                  TextAlign.center,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.red,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  const Text(
                    'IIIT Raichur',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
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