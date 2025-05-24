class UserModel {
  final String nama;
  final String email;
  final String nomorTelepon;
  final String alamat;

  UserModel({
    required this.nama,
    required this.email,
    required this.nomorTelepon,
    required this.alamat,
  });

  factory UserModel.fromDocument(Map<String, dynamic> doc) {
    return UserModel(
      nama: doc['nama'] ?? '',
      email: doc['email'] ?? '',
      nomorTelepon: doc['nomor telepon'] ?? '',
      alamat: doc['alamat'] ?? '',
    );
  }
}
