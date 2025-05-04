String getBesokTanggal() {
  final besok = DateTime.now().add(Duration(days: 1));
  return "${besok.day}/${besok.month}/${besok.year}";
}

String getHariBesok() {
  final besok = DateTime.now().add(Duration(days: 1));
  const hari = [
    'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];
  return hari[besok.weekday % 7];
}
