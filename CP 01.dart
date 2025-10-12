import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(
    const ProviderScope(
      child: CakeOrderingApp(),
    ),
  );
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class CakeOrderingApp extends StatelessWidget {
  const CakeOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrderCake',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.light,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==================== MODELS ====================
class Cake {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> flavors;
  final List<String> sizes;
  final String category;

  Cake({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.flavors,
    required this.sizes,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'flavors': flavors,
      'sizes': sizes,
      'category': category,
    };
  }

  factory Cake.fromMap(Map<String, dynamic> map) {
    return Cake(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      flavors: List<String>.from(map['flavors'] ?? []),
      sizes: List<String>.from(map['sizes'] ?? []),
      category: map['category'] ?? '',
    );
  }
}

class OrderItem {
  final String cakeId;
  final String cakeName;
  final String selectedFlavor;
  final String selectedSize;
  final int quantity;
  final double price;

  OrderItem({
    required this.cakeId,
    required this.cakeName,
    required this.selectedFlavor,
    required this.selectedSize,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'cakeId': cakeId,
      'cakeName': cakeName,
      'selectedFlavor': selectedFlavor,
      'selectedSize': selectedSize,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      cakeId: map['cakeId'] ?? '',
      cakeName: map['cakeName'] ?? '',
      selectedFlavor: map['selectedFlavor'] ?? '',
      selectedSize: map['selectedSize'] ?? '',
      quantity: map['quantity'] ?? 1,
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }
}

class Order {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userAddress,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      userAddress: map['userAddress'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromMap(item))
          .toList() ?? [],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.orderReceived,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}

enum OrderStatus {
  orderReceived,
  preparing,
  outForDelivery,
  orderDelivered,
}

// ==================== SERVICES ====================
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  static Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
      String? name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (name != null && credential.user != null) {
        await credential.user!.updateDisplayName(name);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cakes
  static Future<List<Cake>> getCakes() async {
    final snapshot = await _firestore.collection('cakes').get();
    return snapshot.docs.map((doc) => Cake.fromMap(doc.data())).toList();
  }

  static Stream<List<Cake>> getCakesStream() {
    return _firestore.collection('cakes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Cake.fromMap(doc.data())).toList();
    });
  }

  // Orders
  static Future<void> createOrder(Order order) async {
    await _firestore.collection('orders').doc(order.id).set(order.toMap());
  }

  static Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  static Stream<List<Order>> getOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Order.fromMap(doc.data())).toList();
    });
  }

  static Stream<List<Order>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Order.fromMap(doc.data())).toList();
    });
  }

  // Initialize sample data
  static Future<void> initializeSampleData() async {
    final cakes = [
      Cake(
        id: '1',
        name: 'Chocolate Brownie Cake',
        description: 'Rich chocolate brownie with vanilla ice cream',
        price: 1.75,
        imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400',
        flavors: ['Chocolate', 'Vanilla'],
        sizes: ['Small', 'Medium', 'Large'],
        category: 'Featured',
      ),
      Cake(
        id: '2',
        name: 'Strawberry Frosted Cake',
        description: 'Multi-layered chocolate cake with berry decoration',
        price: 1.70,
        imageUrl: 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=400',
        flavors: ['Strawberry', 'Chocolate'],
        sizes: ['Small', 'Medium', 'Large'],
        category: 'Featured',
      ),
      Cake(
        id: '3',
        name: 'Vanilla Delight',
        description: 'Classic vanilla cake with fresh berries',
        price: 1.50,
        imageUrl: 'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?w=400',
        flavors: ['Vanilla'],
        sizes: ['Small', 'Medium', 'Large'],
        category: 'Classic',
      ),
    ];

    for (final cake in cakes) {
      await _firestore.collection('cakes').doc(cake.id).set(cake.toMap());
    }
  }
}

// ==================== PROVIDERS ====================
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

final cakesProvider = StreamProvider<List<Cake>>((ref) {
  return DatabaseService.getCakesStream();
});

final ordersProvider = StreamProvider<List<Order>>((ref) {
  return DatabaseService.getOrders();
});

final userOrdersProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  return DatabaseService.getUserOrders(userId);
});

// ==================== AUTH WRAPPER ====================
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // Check if user is admin
          if (user.email == 'admin@ordercake.com') {
            return const AdminPanel();
          } else {
            return const UserHomeScreen();
          }
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

// ==================== AUTH SCREENS ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Title
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'OrderCake',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Cake Image
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Colors.pink),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.pink),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.pink, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.pink),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.pink,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.pink),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.pink, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register button
                ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // OR divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Google Sign In button
                ElevatedButton.icon(
                  onPressed: () {
                    // Google Sign In implementation would go here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Sign In coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                  label: const Text(
                    'Sign in with Google',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person, color: Colors.pink),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Colors.pink),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.pink),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.pink,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.pink),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.pink,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== USER SCREENS ====================
class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  String _selectedCategory = 'All Flavors';
  final List<String> _categories = ['All Flavors', 'Vanilla', 'Chocolate', 'Strawberry'];

  @override
  void initState() {
    super.initState();
    // Initialize sample data
    DatabaseService.initializeSampleData();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final cakesAsync = ref.watch(cakesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        title: Text('Hi ${user?.displayName ?? 'User'}'),
        actions: [
          IconButton(
            onPressed: () => _showDrawer(context),
            icon: const Icon(Icons.menu),
          ),
          IconButton(
            onPressed: () {
              // Navigate to cart
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: Column(
        children: [
          // Greeting
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'What would you like to eat?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Category filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.pink[100],
                    checkmarkColor: Colors.pink,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Featured products
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Products',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ],
            ),
          ),

          // Cakes list
          Expanded(
            child: cakesAsync.when(
              data: (cakes) {
                final filteredCakes = _selectedCategory == 'All Flavors'
                    ? cakes
                    : cakes.where((cake) => 
                        cake.flavors.any((flavor) => 
                          flavor.toLowerCase().contains(_selectedCategory.toLowerCase())
                        )
                      ).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCakes.length,
                  itemBuilder: (context, index) {
                    final cake = filteredCakes[index];
                    return CakeCard(cake: cake);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading cakes: $error'),
              ),
            ),
          ),

          // Categories section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore from categories',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CategoryCard(
                        title: 'New this week',
                        color: Colors.pink[100]!,
                        imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=200',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CategoryCard(
                        title: 'Best Seller',
                        color: Colors.green[100]!,
                        imageUrl: 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=200',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const UserDrawer(),
    );
  }
}

class CakeCard extends StatelessWidget {
  final Cake cake;

  const CakeCard({super.key, required this.cake});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Cake image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(cake.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Cake details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cake.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cake.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${cake.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Add button
            FloatingActionButton.small(
              onPressed: () => _showCakeDetails(context, cake),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showCakeDetails(BuildContext context, Cake cake) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CakeDetailsSheet(cake: cake),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final String imageUrl;

  const CategoryCard({
    super.key,
    required this.title,
    required this.color,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CakeDetailsSheet extends StatefulWidget {
  final Cake cake;

  const CakeDetailsSheet({super.key, required this.cake});

  @override
  State<CakeDetailsSheet> createState() => _CakeDetailsSheetState();
}

class _CakeDetailsSheetState extends State<CakeDetailsSheet> {
  String _selectedFlavor = '';
  String _selectedSize = '';
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedFlavor = widget.cake.flavors.first;
    _selectedSize = widget.cake.sizes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cake image
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(widget.cake.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cake name and price
          Text(
            widget.cake.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${widget.cake.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 16),

          // Flavor selection
          Text(
            'Select Flavor:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.cake.flavors.map((flavor) {
              return ChoiceChip(
                label: Text(flavor),
                selected: _selectedFlavor == flavor,
                onSelected: (selected) {
                  setState(() {
                    _selectedFlavor = flavor;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Size selection
          Text(
            'Select Size:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.cake.sizes.map((size) {
              return ChoiceChip(
                label: Text(size),
                selected: _selectedSize == size,
                onSelected: (selected) {
                  setState(() {
                    _selectedSize = size;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Quantity selector
          Row(
            children: [
              Text(
                'Quantity:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _quantity > 1 ? () {
                  setState(() {
                    _quantity--;
                  });
                } : null,
                icon: const Icon(Icons.remove),
              ),
              Text(
                '$_quantity',
                style: const TextStyle(fontSize: 18),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _quantity++;
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Add to cart button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Add to cart logic
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to cart!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add to Cart - \$${(_quantity * widget.cake.price).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserDrawer extends ConsumerWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.pink[100],
                child: Text(
                  user?.displayName?.isNotEmpty == true 
                      ? user!.displayName![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Menu items
          ListTile(
            leading: const Icon(Icons.shopping_bag, color: Colors.pink),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserOrdersScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.pink),
            title: const Text('Cart'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to cart
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.pink),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to profile
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class UserOrdersScreen extends ConsumerWidget {
  const UserOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final ordersAsync = ref.watch(userOrdersProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start ordering some delicious cakes!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading orders: $error'),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(order.status)),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Items: ${order.items.length}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Ordered on: ${DateFormat('MMM dd, yyyy').format(order.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.orderReceived:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.orange;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.orderDelivered:
        return Colors.green;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.orderReceived:
        return 'Order Received';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.orderDelivered:
        return 'Delivered';
    }
  }
}

// ==================== ADMIN SCREENS ====================
class AdminPanel extends ConsumerWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return AdminOrderCard(order: order);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading orders: $error'),
        ),
      ),
    );
  }
}

class AdminOrderCard extends StatelessWidget {
  final Order order;

  const AdminOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[100]!, Colors.pink[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Id:',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          order.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Status:',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _getStatusText(order.status),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Progress indicator
                      Row(
                        children: [
                          _buildProgressStep(OrderStatus.orderReceived, order.status),
                          const SizedBox(width: 4),
                          _buildProgressStep(OrderStatus.preparing, order.status),
                          const SizedBox(width: 4),
                          _buildProgressStep(OrderStatus.outForDelivery, order.status),
                          const SizedBox(width: 4),
                          _buildProgressStep(OrderStatus.orderDelivered, order.status),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showOrderDetails(context, order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateOrderStatus(context, order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update Status'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(OrderStatus step, OrderStatus currentStatus) {
    final stepIndex = OrderStatus.values.indexOf(step);
    final currentIndex = OrderStatus.values.indexOf(currentStatus);
    final isCompleted = stepIndex <= currentIndex;
    
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.white,
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.orderReceived:
        return 'Order Received';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for delivery';
      case OrderStatus.orderDelivered:
        return 'Order Delivered';
    }
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(order: order),
    );
  }

  void _updateOrderStatus(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => UpdateStatusDialog(order: order),
    );
  }
}

class OrderDetailsDialog extends StatelessWidget {
  final Order order;

  const OrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Number: ${order.id}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Order status
            Text(
              'Order Status:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...OrderStatus.values.map((status) {
              final isCompleted = OrderStatus.values.indexOf(status) <= 
                  OrderStatus.values.indexOf(order.status);
              return Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isCompleted ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(_getStatusText(status)),
                ],
              );
            }).toList(),

            const SizedBox(height: 16),

            // Order items
            Text(
              'Orders:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...order.items.map((item) {
              return Text('• ${item.cakeName} (${item.selectedSize}) - Qty: ${item.quantity}');
            }).toList(),

            const SizedBox(height: 16),

            // Customer info
            Text(
              'Customer Number:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(order.userPhone),
            const SizedBox(height: 8),
            Text(
              'Customer Address:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(order.userAddress),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.pink,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.orderReceived:
        return 'Order Received';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.orderDelivered:
        return 'Order Delivered';
    }
  }
}

class UpdateStatusDialog extends StatefulWidget {
  final Order order;

  const UpdateStatusDialog({super.key, required this.order});

  @override
  State<UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  OrderStatus _selectedStatus = OrderStatus.orderReceived;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Update Order Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Order: ${widget.order.id}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<OrderStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Select Status',
                border: OutlineInputBorder(),
              ),
              items: OrderStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await DatabaseService.updateOrderStatus(
                        widget.order.id,
                        _selectedStatus,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order status updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.orderReceived:
        return 'Order Received';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.orderDelivered:
        return 'Order Delivered';
    }
  }
}
