import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app/firebase_options.dart'; // Adjust this import to your actual file


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Malicious Therapist Access Test', () {
    setUpAll(() async {
      // Initialize Firebase and point to emulator
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      // Firebase Auth Emulator
      FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
    });

    test('Therapist should NOT be able to read patient entries', () async {
      final firestore = FirebaseFirestore.instance;

      // Seed patient
      await firestore.collection('users').doc('patient123').set({
        'uid': 'patient123',
        'role': 'patient',
        'email': 'patient@example.com',
      });

      // Seed journal entry (owned by patient)
      await firestore.collection('entries').add({
        'uid': 'patient123',
        'text': 'This is a sensitive entry',
        'classification': 'depression',
        'timestamp': Timestamp.now(),
      });

      // Seed malicious therapist
      await firestore.collection('users').doc('therapist999').set({
        'uid': 'therapist999',
        'role': 'therapist',
        'email': 'malicious@example.com',
      });

      bool accessDenied = false;

      try {
        // Therapist tries to fetch entries for a patient (unauthorized access)
        final snapshot = await firestore
            .collection('entries')
            .where('uid', isEqualTo: 'patient123')
            .get();

        if (snapshot.docs.isEmpty) {
          accessDenied = true; // No entries returned
        } else {
          // If entries are returned, check if they're encrypted or accessible
          for (var doc in snapshot.docs) {
            final text = doc.data()['text'];
            print("Retrieved entry text: $text");
            if (text == 'This is a sensitive entry') {
              accessDenied = false; // Attack succeeded, not expected
            }
          }
        }
      } catch (e) {
        print("Firestore access failed: $e");
        accessDenied = true; // Exception = access denied
      }

      expect(accessDenied, isTrue,
          reason: 'Malicious therapist should not have access to patient entries');
    });
  });
}
