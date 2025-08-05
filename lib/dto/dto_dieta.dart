class DietaDTO {
  String? id;
  String nome;
  String? descricao;
  String? objetivo;
  List<String> receitasIds;
  List<String>? receitasNomes;

  DietaDTO({
    this.id,
    required this.nome,
    this.descricao,
    this.objetivo,
    required this.receitasIds,
    this.receitasNomes,
  });
}
