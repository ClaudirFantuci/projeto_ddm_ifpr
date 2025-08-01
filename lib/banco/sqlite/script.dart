import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';

class ScriptSQLite {
  static const int _databaseVersion = 1;

  static const String _criarTabelaAcademia = '''
    CREATE TABLE academia (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      endereco TEXT NOT NULL,
      telefone_contato TEXT NOT NULL CHECK(length(telefone_contato) <= 15),
      cidade TEXT NOT NULL,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaEquipamento = '''
    CREATE TABLE equipamento (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaObjetivo = '''
    CREATE TABLE objetivo (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaExercicio = '''
    CREATE TABLE exercicio (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaExercicioEquipamento = '''
    CREATE TABLE exercicio_equipamento (
      exercicio_id INTEGER NOT NULL,
      equipamento_id INTEGER NOT NULL,
      PRIMARY KEY (exercicio_id, equipamento_id),
      FOREIGN KEY (exercicio_id) REFERENCES exercicio(id),
      FOREIGN KEY (equipamento_id) REFERENCES equipamento(id)
    )
  ''';

  static const String _criarTabelaTreino = '''
    CREATE TABLE treino (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaTreinoExercicio = '''
    CREATE TABLE treino_exercicio (
      treino_id INTEGER NOT NULL,
      exercicio_id INTEGER NOT NULL,
      PRIMARY KEY (treino_id, exercicio_id),
      FOREIGN KEY (treino_id) REFERENCES treino(id),
      FOREIGN KEY (exercicio_id) REFERENCES exercicio(id)
    )
  ''';

  static const String _criarTabelaAluno = '''
    CREATE TABLE aluno (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      telefone TEXT NOT NULL,
      objetivo_principal_id INTEGER,
      FOREIGN KEY (objetivo_principal_id) REFERENCES objetivo(id)
    )
  ''';

  static const String _criarTabelaAlunoObjetivo = '''
    CREATE TABLE aluno_objetivo (
      aluno_id INTEGER NOT NULL,
      objetivo_id INTEGER NOT NULL,
      PRIMARY KEY (aluno_id, objetivo_id),
      FOREIGN KEY (aluno_id) REFERENCES aluno(id),
      FOREIGN KEY (objetivo_id) REFERENCES objetivo(id)
    )
  ''';

  static const String _criarTabelaModalidade = '''
    CREATE TABLE modalidade (
      id TEXT PRIMARY KEY,
      nome TEXT NOT NULL
    )
  ''';

  static const List<String> comandosCriarTabelas = [
    _criarTabelaAcademia,
    _criarTabelaEquipamento,
    _criarTabelaObjetivo,
    _criarTabelaExercicio,
    _criarTabelaExercicioEquipamento,
    _criarTabelaTreino,
    _criarTabelaTreinoExercicio,
    _criarTabelaAluno,
    _criarTabelaAlunoObjetivo,
    _criarTabelaModalidade,
  ];

  static const List<String> _insercoesAcademia = [
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('FitLife', 'Rua Principal, 123', '(44) 99999-1234', 'Paranavaí', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('PowerGym', 'Av. Central, 456', '(44) 98888-5678', 'Maringá', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Vida Saudável', 'Rua das Flores, 789', '(44) 97777-9012', 'Cianorte', 0)",
  ];

  static const List<String> _insercoesEquipamento = [
    "INSERT INTO equipamento (nome) VALUES ('Halteres')",
    "INSERT INTO equipamento (nome) VALUES ('Barra Olímpica')",
    "INSERT INTO equipamento (nome) VALUES ('Máquina de Smith')",
    "INSERT INTO equipamento (nome) VALUES ('Cabo de Aço')",
    "INSERT INTO equipamento (nome) VALUES ('Banco Ajustável')",
    "INSERT INTO equipamento (nome) VALUES ('Kettlebell')",
    "INSERT INTO equipamento (nome) VALUES ('Leg Press')",
    "INSERT INTO equipamento (nome) VALUES ('Esteira')",
  ];

  static const List<String> _insercoesObjetivo = [
    "INSERT INTO objetivo (nome) VALUES ('Perder peso')",
    "INSERT INTO objetivo (nome) VALUES ('Ganhar massa muscular')",
    "INSERT INTO objetivo (nome) VALUES ('Melhorar condicionamento físico')",
    "INSERT INTO objetivo (nome) VALUES ('Aumentar flexibilidade')",
    "INSERT INTO objetivo (nome) VALUES ('Reduzir estresse')",
  ];

  static const List<String> _insercoesExercicio = [
    "INSERT INTO exercicio (nome) VALUES ('Supino Reto')",
    "INSERT INTO exercicio (nome) VALUES ('Agachamento Livre')",
    "INSERT INTO exercicio (nome) VALUES ('Rosca Direta')",
    "INSERT INTO exercicio (nome) VALUES ('Leg Press 45°')",
    "INSERT INTO exercicio (nome) VALUES ('Puxada na Polia')",
  ];

  static const List<String> _insercoesExercicioEquipamento = [
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (1, 5)", // Supino Reto: Banco Ajustável
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (1, 1)", // Supino Reto: Halteres
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (2, 2)", // Agachamento Livre: Barra Olímpica
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (3, 1)", // Rosca Direta: Halteres
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (3, 6)", // Rosca Direta: Kettlebell
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (4, 7)", // Leg Press 45°: Leg Press
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (5, 4)", // Puxada na Polia: Cabo de Aço
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (5, 1)", // Puxada na Polia: Halteres
  ];

  static const List<String> _insercoesTreino = [
    "INSERT INTO treino (nome) VALUES ('Treino de Peito')",
    "INSERT INTO treino (nome) VALUES ('Treino de Pernas')",
    "INSERT INTO treino (nome) VALUES ('Treino de Braços')",
    "INSERT INTO treino (nome) VALUES ('Treino Full Body')",
    "INSERT INTO treino (nome) VALUES ('Treino de Costas')",
  ];

  static const List<String> _insercoesTreinoExercicio = [
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (1, 1)",
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (2, 2)",
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (2, 4)",
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (3, 3)",
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (4, 1)",
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (4, 2)",
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (4, 3)",
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (5, 5)",
  ];

  static const List<String> _insercoesAluno = [
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('João Silva', '(44) 99999-1111', 1)", // Objetivo: Perder peso
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Maria Oliveira', '(44) 99999-2222', 2)", // Objetivo: Ganhar massa muscular
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Carlos Santos', '(44) 99999-3333', 3)", // Objetivo: Melhorar condicionamento físico
  ];

  static const List<String> _insercoesAlunoObjetivo = [
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (1, 2)", // João Silva: Ganhar massa muscular
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (1, 3)", // João Silva: Melhorar condicionamento físico
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (2, 1)", // Maria Oliveira: Perder peso
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (2, 4)", // Maria Oliveira: Aumentar flexibilidade
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (3, 5)", // Carlos Santos: Reduzir estresse
  ];

  static const List<String> _insercoesModalidade = [
    "INSERT INTO modalidade (id, nome) VALUES ('1', 'Musculação')",
    "INSERT INTO modalidade (id, nome) VALUES ('2', 'Yoga')",
    "INSERT INTO modalidade (id, nome) VALUES ('3', 'Pilates')",
    "INSERT INTO modalidade (id, nome) VALUES ('4', 'Treinamento Funcional')",
    "INSERT INTO modalidade (id, nome) VALUES ('5', 'Spinning')",
  ];

  static const List<List<String>> comandosInsercoes = [
    _insercoesAcademia,
    _insercoesEquipamento,
    _insercoesObjetivo,
    _insercoesExercicio,
    _insercoesExercicioEquipamento,
    _insercoesTreino,
    _insercoesTreinoExercicio,
    _insercoesAluno,
    _insercoesAlunoObjetivo,
    _insercoesModalidade,
  ];

  Future<void> criarTabelas(Database db) async {
    for (var comando in comandosCriarTabelas) {
      await db.execute(comando);
    }
    await db.execute('PRAGMA user_version = $_databaseVersion');
  }

  Future<void> inserirDadosIniciais(Database db) async {
    for (var listaInsercoes in comandosInsercoes) {
      for (var comando in listaInsercoes) {
        await db.execute(comando);
      }
    }
  }
}
