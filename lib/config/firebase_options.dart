import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'AIzaSyC7j6TD3DWXq-gf_NE4r72JoK1wSRmPkU4',
        authDomain: 'sawit-iot.firebaseapp.com',
        databaseURL:
            'https://sawit-iot-default-rtdb.asia-southeast1.firebasedatabase.app',
        projectId: 'sawit-iot',
        storageBucket: 'sawit-iot.firebasestorage.app',
        messagingSenderId: '1048979702405',
        appId: '1:1048979702405:web:74d2affa71ba6cd4c45fec',
      );
}
