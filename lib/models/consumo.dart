class Consumo {
  String data;
  double quantidadeEmMl;
  double pesoAtualKg;

  Consumo({
    required this.data,
    required this.quantidadeEmMl,
    required this.pesoAtualKg,
  });

  String toCSV() {
    return '$data;$quantidadeEmMl;$pesoAtualKg';
  }

  factory Consumo.fromCSV(String csv) {
    List<String> partes = csv.split(';');

    return Consumo(
      data: partes[0],
      quantidadeEmMl: double.parse(partes[1]),
      pesoAtualKg: double.parse(partes[2]),
    );
  }
}