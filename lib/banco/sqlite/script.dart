import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';

class ScriptSQLite {
  static const int _databaseVersion = 2; // Incremented due to schema change

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
      FOREIGN KEY (exercicio_id) REFERENCES exercicio(id) ON DELETE CASCADE,
      FOREIGN KEY (equipamento_id) REFERENCES equipamento(id) ON DELETE CASCADE
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
      FOREIGN KEY (treino_id) REFERENCES treino(id) ON DELETE CASCADE,
      FOREIGN KEY (exercicio_id) REFERENCES exercicio(id) ON DELETE CASCADE
    )
  ''';

  static const String _criarTabelaAluno = '''
    CREATE TABLE aluno (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      telefone TEXT NOT NULL CHECK(length(telefone) <= 15),
      objetivo_principal_id INTEGER,
      FOREIGN KEY (objetivo_principal_id) REFERENCES objetivo(id) ON DELETE SET NULL
    )
  ''';

  static const String _criarTabelaAlunoObjetivo = '''
    CREATE TABLE aluno_objetivo (
      aluno_id INTEGER NOT NULL,
      objetivo_id INTEGER NOT NULL,
      PRIMARY KEY (aluno_id, objetivo_id),
      FOREIGN KEY (aluno_id) REFERENCES aluno(id) ON DELETE CASCADE,
      FOREIGN KEY (objetivo_id) REFERENCES objetivo(id) ON DELETE CASCADE
    )
  ''';

  static const String _criarTabelaModalidade = '''
    CREATE TABLE modalidade (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaProfessor = '''
    CREATE TABLE professor (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      telefone TEXT NOT NULL CHECK(length(telefone) <= 15)
    )
  ''';

  static const String _criarTabelaProfessorModalidade = '''
    CREATE TABLE professor_modalidade (
      professor_id INTEGER NOT NULL,
      modalidade_id INTEGER NOT NULL,
      PRIMARY KEY (professor_id, modalidade_id),
      FOREIGN KEY (professor_id) REFERENCES professor(id) ON DELETE CASCADE,
      FOREIGN KEY (modalidade_id) REFERENCES modalidade(id) ON DELETE CASCADE
    )
  ''';

  static const String _criarTabelaDieta = '''
    CREATE TABLE dieta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaReceita = '''
    CREATE TABLE receita (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaReceitaDieta = '''
    CREATE TABLE receita_dieta (
      receita_id INTEGER NOT NULL,
      dieta_id INTEGER NOT NULL,
      PRIMARY KEY (receita_id, dieta_id),
      FOREIGN KEY (receita_id) REFERENCES receita(id) ON DELETE CASCADE,
      FOREIGN KEY (dieta_id) REFERENCES dieta(id) ON DELETE CASCADE
    )
  ''';

  static const String _criarTabelaTurma = '''
    CREATE TABLE turma (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      horario_inicio TEXT NOT NULL,
      horario_fim TEXT NOT NULL,
      dia_semana TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaTurmaAluno = '''
    CREATE TABLE turma_aluno (
      turma_id INTEGER NOT NULL,
      aluno_id INTEGER NOT NULL,
      PRIMARY KEY (turma_id, aluno_id),
      FOREIGN KEY (turma_id) REFERENCES turma(id) ON DELETE CASCADE,
      FOREIGN KEY (aluno_id) REFERENCES aluno(id) ON DELETE CASCADE
    )
  ''';

  static const String _criarTabelaTurmaProfessor = '''
    CREATE TABLE turma_professor (
      turma_id INTEGER NOT NULL,
      professor_id INTEGER NOT NULL,
      PRIMARY KEY (turma_id, professor_id),
      FOREIGN KEY (turma_id) REFERENCES turma(id) ON DELETE CASCADE,
      FOREIGN KEY (professor_id) REFERENCES professor(id) ON DELETE CASCADE
    )
  ''';

  static const String _criarTabelaAgendamento = '''
    CREATE TABLE agendamento (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dia_semana TEXT NOT NULL,
      horario_inicio TEXT NOT NULL,
      horario_fim TEXT NOT NULL,
      academia_id INTEGER NOT NULL,
      academia_nome TEXT,
      turma_id INTEGER,
      turma_nome TEXT,
      alunos_ids TEXT,
      alunos_nomes TEXT,
      FOREIGN KEY (academia_id) REFERENCES academia(id) ON DELETE CASCADE,
      FOREIGN KEY (turma_id) REFERENCES turma(id) ON DELETE SET NULL
    )
  ''';

  static const String _criarTabelaAgendamentoAluno = '''
    CREATE TABLE agendamento_aluno (
      agendamento_id INTEGER NOT NULL,
      aluno_id INTEGER NOT NULL,
      aluno_nome TEXT NOT NULL,
      PRIMARY KEY (agendamento_id, aluno_id),
      FOREIGN KEY (agendamento_id) REFERENCES agendamento(id) ON DELETE CASCADE,
      FOREIGN KEY (aluno_id) REFERENCES aluno(id) ON DELETE CASCADE
    )
  ''';

  static const List<String> _insercoesAcademia = [
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Fit', 'Rua A, 123', '41999999999', 'Curitiba', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Power', 'Rua B, 456', '41988888888', 'Curitiba', 1)",
  ];

  static const List<String> _insercoesEquipamento = [
    "INSERT INTO equipamento (nome) VALUES ('Halteres')",
    "INSERT INTO equipamento (nome) VALUES ('Esteira')",
    "INSERT INTO equipamento (nome) VALUES ('Bicicleta Ergométrica')",
  ];

  static const List<String> _insercoesObjetivo = [
    "INSERT INTO objetivo (nome) VALUES ('Hipertrofia')",
    "INSERT INTO objetivo (nome) VALUES ('Emagrecimento')",
    "INSERT INTO objetivo (nome) VALUES ('Condicionamento Físico')",
  ];

  static const List<String> _insercoesExercicio = [
    "INSERT INTO exercicio (nome) VALUES ('Supino Reto')",
    "INSERT INTO exercicio (nome) VALUES ('Agachamento Livre')",
    "INSERT INTO exercicio (nome) VALUES ('Corrida')",
  ];

  static const List<String> _insercoesExercicioEquipamento = [
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (1, 1)",
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (3, 2)",
  ];

  static const List<String> _insercoesTreino = [
    "INSERT INTO treino (nome) VALUES ('Treino A')",
    "INSERT INTO treino (nome) VALUES ('Treino B')",
  ];

  static const List<String> _insercoesTreinoExercicio = [
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (1, 1)",
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (1, 2)",
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (2, 3)",
  ];

  static const List<String> _insercoesAluno = [
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('João Silva', '41977777777', 1)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Maria Oliveira', '41966666666', 2)",
  ];

  static const List<String> _insercoesAlunoObjetivo = [
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (1, 1)",
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (1, 3)",
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (2, 2)",
  ];

  static const List<String> _insercoesModalidade = [
    "INSERT INTO modalidade (nome) VALUES ('Musculação')",
    "INSERT INTO modalidade (nome) VALUES ('Aeróbico')",
  ];

  static const List<String> _insercoesProfessor = [
    "INSERT INTO professor (nome, telefone) VALUES ('Carlos Santos', '41955555555')",
    "INSERT INTO professor (nome, telefone) VALUES ('Ana Costa', '41944444444')",
  ];

  static const List<String> _insercoesProfessorModalidade = [
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (1, 1)",
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (2, 2)",
  ];

  static const List<String> _insercoesDieta = [
    "INSERT INTO dieta (nome) VALUES ('Dieta Hipercalórica')",
    "INSERT INTO dieta (nome) VALUES ('Dieta Low Carb')",
  ];

  static const List<String> _insercoesReceita = [
    "INSERT INTO receita (nome) VALUES ('Salada de Quinoa')",
    "INSERT INTO receita (nome) VALUES ('Shake de Proteína')",
  ];

  static const List<String> _insercoesReceitaDieta = [
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (1, 2)",
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (2, 1)",
  ];

  static const List<String> _insercoesTurma = [
    "INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana) VALUES ('Turma A', '08:00', '09:00', 'Segunda-feira')",
    "INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana) VALUES ('Turma B', '07:00', '08:00', 'Sexta-feira')",
  ];

  static const List<String> _insercoesTurmaProfessor = [
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (1, 1)",
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (2, 2)",
  ];

  static const List<String> _insercoesTurmaAluno = [
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (1, 1)",
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (2, 2)",
  ];

  static const List<String> _insercoesAgendamento = [
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Segunda-feira', '08:00', '09:00', 1, 'Academia Fit', 1, 'Turma A', '1', 'João Silva')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Quarta-feira', '10:00', '11:00', 1, 'Academia Fit', NULL, NULL, '1,2', 'João Silva,Maria Oliveira')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Sexta-feira', '07:00', '08:00', 2, 'Academia Power', 2, 'Turma B', NULL, NULL)",
  ];

  static const List<String> _insercoesAgendamentoAluno = [
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (1, 1, 'João Silva')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (2, 1, 'João Silva')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (2, 2, 'Maria Oliveira')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (3, 2, 'Maria Oliveira')",
  ];

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
    _criarTabelaProfessor,
    _criarTabelaProfessorModalidade,
    _criarTabelaDieta,
    _criarTabelaReceita,
    _criarTabelaReceitaDieta,
    _criarTabelaTurma,
    _criarTabelaTurmaAluno,
    _criarTabelaTurmaProfessor,
    _criarTabelaAgendamento,
    _criarTabelaAgendamentoAluno,
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
    _insercoesProfessor,
    _insercoesProfessorModalidade,
    _insercoesDieta,
    _insercoesReceita,
    _insercoesReceitaDieta,
    _insercoesTurma,
    _insercoesTurmaProfessor,
    _insercoesTurmaAluno,
    _insercoesAgendamento,
    _insercoesAgendamentoAluno,
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

  // Migration for version 2: Replace horario with horario_inicio and horario_fim
  static Future<void> migrateToVersion2(Database db) async {
    await db.execute('ALTER TABLE agendamento ADD COLUMN horario_inicio TEXT');
    await db.execute('ALTER TABLE agendamento ADD COLUMN horario_fim TEXT');
    await db.execute(
        'UPDATE agendamento SET horario_inicio = SUBSTR(horario, 1, 5), horario_fim = SUBSTR(horario, 7, 5)');
    await db.execute('ALTER TABLE agendamento DROP COLUMN horario');
    await db.execute('PRAGMA user_version = 2');
  }

  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2 && newVersion >= 2) {
      await migrateToVersion2(db);
    }
  }
}
