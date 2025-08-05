class ReceitaDTO {
  String? id;
  String nome;
  List<String> ingredientes;
  String? modoPreparo;
  Map<String, double>? valorNutricional;
  String? dietaId; 
  List<String>? dietasNomes;

  ReceitaDTO({
    this.id,
    required this.nome,
    required this.ingredientes,
    this.modoPreparo,
    this.valorNutricional,
    this.dietaId,
    this.dietasNomes,
  });
}
