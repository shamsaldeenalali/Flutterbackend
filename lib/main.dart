import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'package:file_picker/file_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final auth = FirebaseAuth.instance;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/profile': (context) => ProfilePage(),
      },
      title: "My App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String? errorMessage = '';
  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Umm! $errorMessage.',
      style: TextStyle(
        color: Colors.red[400],
      ),
    );
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  FilePickerResult? _img;
  late var c;

  final DatabaseReference userdbref =
      FirebaseDatabase.instance.ref().child("users");
  Future<void> pickImage() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setState(() {
          _img = result;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> handleSignUp() async {
    final Reference refa = FirebaseStorage.instance
        .ref("profileimage/${DateTime.now().microsecondsSinceEpoch}.jpg");
    UploadTask ut = refa.putData(_img!.files.first.bytes!);
    String imagurl = await (await ut).ref.getDownloadURL();
    try {
      await Auth()
          .createWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .whenComplete(() {
        var user = {
          "email": emailController.text,
          "password": passwordController.text,
          "fullname": fullnameController.text,
          "mobile": mobileController.text,
          "profileimageurl": imagurl
        };
        print("User Added Success");
        var userid = Auth()._auth.currentUser!.uid;
        userdbref.child(userid).set(user);
        print("User Added Success to database");
        Navigator.pushNamed(context, "/profile");
      });
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _img == null
                  ? IconButton(
                      onPressed: () {
                        pickImage();
                      },
                      icon: Icon(Icons.person),
                    )
                  : IconButton(
                      onPressed: () {
                        pickImage();
                      },
                      icon: Image.memory(
                        _img!.files.first.bytes!,
                        scale: 0.3,
                        fit: BoxFit.cover, // or use other BoxFit values
                      ),
                    ),
              TextFormField(
                decoration: InputDecoration(
                    icon: Icon(Icons.email_outlined),
                    labelText: "Enter Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
                controller: emailController,
                // ... (other properties)
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: InputDecoration(
                    icon: Icon(Icons.password_outlined),
                    labelText: "Enter Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
                controller: passwordController,
                // ... (other properties)
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: "Enter full name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
                controller: fullnameController,
                // ... (other properties)
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: InputDecoration(
                    icon: Icon(Icons.mobile_friendly),
                    labelText: "Enter mobile number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
                controller: mobileController,
                // ... (other properties)
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Create a RegistrationData instance with the entered values

                    // Now you can use the registrationData object as needed
                    handleSignUp();
                  }
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignUp() {}
}

var photourl =
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFOZpN5bsHB6ouEALITGO2nJgMj-Re4PB6SQ&usqp=CAU";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? errorMessage = '';
  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Umm! $errorMessage.',
      style: TextStyle(
        color: Colors.red[400],
      ),
    );
  }

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], //
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Laptop Store"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(photourl),
              ),
              // Replace with your image path
              const SizedBox(height: 20.0),
              const Text('Welcome!', style: TextStyle(fontSize: 18.0)),
              TextFormField(
                controller: _controllerEmail,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _controllerPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                obscureText: true,
              ),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  // Implement your forget password logic
                },
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        'A password reset email has been sent to your email address.',
                      ),
                    ));
                  },
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Text('Forget Password', textAlign: TextAlign.left),
                  ),
                ),
              ),
              const SizedBox(
                height: 9,
              ),
              _errorMessage(),

              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _handleSignin();
                  }
                },
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignin() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      print("Logged in Successfully");
      Navigator.pushNamed(context, "/profile");
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }
}

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<dynamic, dynamic>? usermap;

  Future<void> fatchUserData() async {
    FirebaseService fbs = FirebaseService();
    Map<dynamic, dynamic>? um = await fbs.getUserData();
    if (um != null) {
      setState(() {
        usermap = um;
      });
    } else {
      print("user not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    fatchUserData();
    return Scaffold(
      backgroundColor: Colors.grey[100], //
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 16),
            usermap == null
                ? Text("user not found")
                : Text(
                    "Email: ${usermap!["email"]}",
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(255, 0, 8, 255)),
                  ),
            SizedBox(height: 16),
            Text(
              "fullname: ${usermap!["fullname"]}",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 0, 8, 255)),
            ),
            SizedBox(height: 16),
            Text(
              "mobile: ${usermap!["mobile"]}",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 0, 8, 255)),
            ),
            SizedBox(height: 16),
            IconButton(
              onPressed: () {},
              icon: Image(
                image: NetworkImage(
                  usermap!["profileimageurl"],
                ),
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return StoreHomeScreen();
                }));
              },
              child: Text('Go to home page'),
            ),

            //_signOutButton(),
          ],
        ),
      ),
    );
  }
}

class FirebaseService {
  final DatabaseReference userref =
      FirebaseDatabase.instance.ref().child("users");
  Future<Map<dynamic, dynamic>?> getUserData() async {
    try {
      if (Auth()._auth.currentUser != null) {
        var userid = Auth()._auth.currentUser!.uid;
        DatabaseEvent event = await userref.child(userid).once();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> mapsnapshot = event.snapshot.value as dynamic;
          return mapsnapshot as Map<dynamic, dynamic>;
        } else {
          print("current user is null");
        }
      } else {
        print("current user is not avilable");
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

class Product {
  final String name;
  final double price;
  final String imageUrl; // Include image URL for the product

  Product({required this.name, required this.price, required this.imageUrl});
}

class Cart {
  List<Product> cartItems = [];

  void addToCart(Product product) {
    cartItems.add(product);
  }
}

class StoreHomeScreen extends StatelessWidget {
  final List<Product> products = [
    Product(
        name: 'Laptop',
        price: 999.99,
        imageUrl:
            'https://th.bing.com/th/id/OIP.NGsxebyVpOePw47hT9635gHaFj?w=277&h=207&c=7&r=0&o=5&pid=1.7'), // Replace with actual image URLs
    Product(
        name:
            'ASUS TUF 15.6" Full HD Gaming Laptop AMD Ryzen 7 R7-3750H GeForce ',
        price: 799.99,
        imageUrl:
            'https://th.bing.com/th/id/OIP.1x4X_CwBhqEcd0z1Dj3UOgHaHa?w=188&h=188&c=7&r=0&o=5&pid=1.7'),
    Product(
        name: 'Asus Rog Zephyrus G14 14 Laptop - Amd Ryzen 7 - 8gb Memory',
        price: 999.99,
        imageUrl:
            'https://th.bing.com/th/id/OIP.Nxv6PGEp23Mft0rPlaj_FgHaFq?w=246&h=188&c=7&r=0&o=5&pid=1.7'),

    Product(
        name: 'Asus VivoBook 15 15.6" 1920x1080 Laptop - AMD Ryzen 7 - 12GB',
        price: 549.99,
        imageUrl:
            'https://th.bing.com/th/id/OIP.mm19yeiV46PtZC9VfV352wHaFj?w=251&h=188&c=7&r=0&o=5&pid=1.7'),
    Product(
        name: ' ASUS GA502DU Ryzen 7 GTX 1660 Ti Gaming Laptop',
        price: 649.99,
        imageUrl:
            'https://th.bing.com/th/id/OIP.tip-A11eyObcS7UYyBOcjAHaHa?w=188&h=188&c=7&r=0&o=5&pid=1.7'),

    Product(
        name:
            'Best Buy: ASUS 15.6" Laptop AMD Ryzen 7 16GB Memory NVIDIA GeForce RTX 3050',
        price: 1199.99,
        imageUrl:
            'https://th.bing.com/th/id/OIP.PkDlXfytDmT2YNNzS8gnZgHaGg?w=214&h=188&c=7&r=0&o=5&pid=1.7'),
  ];

  final Cart cart = Cart();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Computers Store'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(
              products[index].imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            title: Text(products[index].name),
            subtitle: Text('\$${products[index].price.toStringAsFixed(2)}'),
            trailing: ElevatedButton(
              onPressed: () {
                cart.addToCart(products[index]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartPage(cart: cart),
                  ),
                );
              },
              child: Text('Add to Cart'),
            ),
          );
        },
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final Cart cart;

  CartPage({required this.cart});

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0.0;

    // Calculate total price of products in the cart
    cart.cartItems.forEach((product) {
      totalPrice += product.price;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.cartItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(
                    cart.cartItems[index].imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(cart.cartItems[index].name),
                  subtitle: Text(
                    '\$${cart.cartItems[index].price.toStringAsFixed(2)}',
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement the place order action here
              // This could involve finalizing the order or navigating to a checkout page
              // For example:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaceOrderPage(totalPrice: totalPrice),
                ),
              );
            },
            child: Text('Place Order'),
          ),
        ],
      ),
    );
  }
}

class PlaceOrderPage extends StatelessWidget {
  final double totalPrice;

  PlaceOrderPage({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Payment Details', // Add your payment details UI here
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            // Add payment-related widgets/forms/buttons here
            // Example: TextFields for credit card info, payment methods, etc.
            ElevatedButton(
              onPressed: () {
                // Implement the payment process here
                // For example, confirm the payment and navigate to a success page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentSuccessPage(totalPrice: totalPrice),
                  ),
                );
              },
              child: Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentSuccessPage extends StatelessWidget {
  final double totalPrice;

  PaymentSuccessPage({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Success'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Total Payment: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement action for further options after successful payment
                // For example, navigate to a home screen or order details page
                Navigator.popUntil(
                  context,
                  ModalRoute.withName(Navigator.defaultRouteName),
                ); // Return to the initial route (home screen)
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
