class ReceitaDTO {
  String? id;
  String nome;
  List<String> ingredientes;
  String? modoPreparo;
  Map<String, double>? valorNutricional;
  List<String> dietasIds;
  List<String>? dietasNomes;

  ReceitaDTO({
    this.id,
    required this.nome,
    required this.ingredientes,
    this.modoPreparo,
    this.valorNutricional,
    required this.dietasIds,
    this.dietasNomes,
  });
}
