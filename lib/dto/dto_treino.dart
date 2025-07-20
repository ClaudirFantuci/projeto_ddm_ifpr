class DTOTreino {
  String? id;
  String nome;
  List<String> exerciciosIds;
  List<String>? exerciciosNomes;

  DTOTreino({
    this.id,
    required this.nome,
    required this.exerciciosIds,
    this.exerciciosNomes,
  });
}
