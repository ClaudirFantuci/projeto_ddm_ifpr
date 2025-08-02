class ProfessorDTO {
  String? id;
  String nome;
  String telefone;
  List<String> ModalidadesIds;
  List<String>? ModalidadesNomes;

  ProfessorDTO({
    this.id,
    required this.nome,
    required this.telefone,
    required this.ModalidadesIds,
    this.ModalidadesNomes,
  });
}
