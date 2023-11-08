import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class VehicleRecord {
  final String vehicleType;
  final String licensePlate;
  final double speed;
  final DateTime timestamp;

  VehicleRecord({
    required this.vehicleType,
    required this.licensePlate,
    required this.speed,
    required this.timestamp,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  List<VehicleRecord> vehicleRecords = []; // Your list of vehicle records

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });

    // Initialize your list of vehicle records here, e.g., by fetching data from Firebase.
    // Example: vehicleRecords = fetchVehicleRecordsFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speed Trap History"),
      ),
      body: Column(
        children: [
          if (_user != null) ...[
            _userInfo(),
            Expanded(child: _vehicleHistoryList()),
            _signOutButton(),
          ] else ...[
            _googleSignInButton(),
          ],
        ],
      ),
    );
  }

  Widget _googleSignInButton() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: SignInButton(
              Buttons.google,
              text: "Sign up with Google",
              onPressed: _handleGoogleSignIn,
            ),
          ),
          if (_user != null)
            TextButton(
              onPressed: () async {
                await _auth.signOut();
                setState(() {
                  _user = null; // Clear the user object
                  vehicleRecords.clear(); // Clear the vehicle history
                });
                _handleGoogleSignIn(); // Initiate the sign-in process again
              },
              child: Text("Switch Account"),
            ),
        ],
      ),
    );
  }

  Widget _userInfo() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(_user!.photoURL!),
              ),
            ),
          ),
          Text(_user!.email!),
          Text(_user!.displayName ?? ""),
        ],
      ),
    );
  }

  Widget _signOutButton() {
    return Center(
      child: MaterialButton(
        color: Colors.red,
        child: const Text("Sign Out"),
        onPressed: () async {
          await _auth.signOut();
          setState(() {
            _user = null; // Clear the user object
          });
        },
      ),
    );
  }

  Widget _vehicleHistoryList() {
    if (vehicleRecords.isEmpty) {
      // Display a message when there are no vehicle records.
      return Center(
        child: Text("No vehicle records available."),
      );
    }

    return ListView.builder(
      itemCount: vehicleRecords.length,
      itemBuilder: (context, index) {
        final record = vehicleRecords[index];
        return ListTile(
          title: Text('Type: ${record.vehicleType}'),
          subtitle: Text(
              'License Plate: ${record.licensePlate}\nSpeed: ${record.speed} mph\nTimestamp: ${record.timestamp}'),
          leading:
              Icon(Icons.directions_car), // You can choose an appropriate icon
          // You can add more customization to the ListTile as needed
        );
      },
    );
  }

  void _handleGoogleSignIn() {
    try {
      GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();
      _auth.signInWithProvider(_googleAuthProvider);
    } catch (error) {
      print(error);
    }
  }
}
