import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';

class ScriptSQLite {
  static const int _databaseVersion = 1; // Banco recriado

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
      nome TEXT NOT NULL,
      descricao TEXT,
      objetivo TEXT
    )
  ''';

  static const String _criarTabelaReceita = '''
    CREATE TABLE receita (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      ingredientes TEXT,
      modo_preparo TEXT,
      valor_nutricional TEXT
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
      nome TEXT NOT NULL
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
      aluno_nome TEXT,
      PRIMARY KEY (agendamento_id, aluno_id),
      FOREIGN KEY (agendamento_id) REFERENCES agendamento(id) ON DELETE CASCADE,
      FOREIGN KEY (aluno_id) REFERENCES aluno(id) ON DELETE CASCADE
    )
  ''';

  static const List<String> _insercoesAcademia = [
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Fit', 'Rua das Flores, 123', '(11) 1234-5678', 'São Paulo', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Power', 'Av. Central, 456', '(11) 2345-6789', 'São Paulo', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Top', 'Rua do Sol, 789', '(11) 3456-7890', 'São Paulo', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Energy', 'Rua da Lua, 101', '(11) 4567-8901', 'São Paulo', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Viva', 'Av. das Estrelas, 202', '(11) 5678-9012', 'São Paulo', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Move', 'Rua do Campo, 303', '(11) 6789-0123', 'São Paulo', 1)",
  ];

  static const List<String> _insercoesEquipamento = [
    "INSERT INTO equipamento (nome) VALUES ('Halteres')",
    "INSERT INTO equipamento (nome) VALUES ('Esteira')",
    "INSERT INTO equipamento (nome) VALUES ('Bicicleta Ergométrica')",
    "INSERT INTO equipamento (nome) VALUES ('Barra de Supino')",
    "INSERT INTO equipamento (nome) VALUES ('Máquina de Leg Press')",
    "INSERT INTO equipamento (nome) VALUES ('Corda de Pular')",
    "INSERT INTO equipamento (nome) VALUES ('Bola de Pilates')",
  ];

  static const List<String> _insercoesObjetivo = [
    "INSERT INTO objetivo (nome) VALUES ('Hipertrofia')",
    "INSERT INTO objetivo (nome) VALUES ('Emagrecimento')",
    "INSERT INTO objetivo (nome) VALUES ('Condicionamento Físico')",
    "INSERT INTO objetivo (nome) VALUES ('Resistência')",
    "INSERT INTO objetivo (nome) VALUES ('Saúde Geral')",
    "INSERT INTO objetivo (nome) VALUES ('Flexibilidade')",
    "INSERT INTO objetivo (nome) VALUES ('Força')",
  ];

  static const List<String> _insercoesExercicio = [
    "INSERT INTO exercicio (nome) VALUES ('Supino Reto')",
    "INSERT INTO exercicio (nome) VALUES ('Agachamento Livre')",
    "INSERT INTO exercicio (nome) VALUES ('Levantamento Terra')",
    "INSERT INTO exercicio (nome) VALUES ('Rosca Direta')",
    "INSERT INTO exercicio (nome) VALUES ('Abdominal Crunch')",
    "INSERT INTO exercicio (nome) VALUES ('Corrida na Esteira')",
    "INSERT INTO exercicio (nome) VALUES ('Prancha')",
  ];

  static const List<String> _insercoesExercicioEquipamento = [
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (1, 4)", // Supino Reto com Barra de Supino
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (2, 1)", // Agachamento Livre com Halteres
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (3, 1)", // Levantamento Terra com Halteres
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (4, 1)", // Rosca Direta com Halteres
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (5, 7)", // Abdominal Crunch com Bola de Pilates
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (6, 2)", // Corrida na Esteira com Esteira
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (7, 7)", // Prancha com Bola de Pilates
  ];

  static const List<String> _insercoesTreino = [
    "INSERT INTO treino (nome) VALUES ('Treino A - Peito e Tríceps')",
    "INSERT INTO treino (nome) VALUES ('Treino B - Costas e Bíceps')",
    "INSERT INTO treino (nome) VALUES ('Treino C - Pernas')",
    "INSERT INTO treino (nome) VALUES ('Treino D - Abdômen e Cardio')",
    "INSERT INTO treino (nome) VALUES ('Treino E - Corpo Inteiro')",
    "INSERT INTO treino (nome) VALUES ('Treino F - Funcional')",
    "INSERT INTO treino (nome) VALUES ('Treino G - Força')",
  ];

  static const List<String> _insercoesTreinoExercicio = [
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (1, 1)", // Treino A com Supino Reto
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (2, 4)", // Treino B com Rosca Direta
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (3, 2)", // Treino C com Agachamento Livre
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (4, 5)", // Treino D com Abdominal Crunch
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (5, 3)", // Treino E com Levantamento Terra
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (6, 6)", // Treino F com Corrida na Esteira
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (7, 7)", // Treino G com Prancha
  ];

  static const List<String> _insercoesAluno = [
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('João Silva', '(11) 91234-5678', 1)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Maria Oliveira', '(11) 92345-6789', 2)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Pedro Santos', '(11) 93456-7890', 3)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Ana Costa', '(11) 94567-8901', 4)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Lucas Pereira', '(11) 95678-9012', 5)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Clara Mendes', '(11) 96789-0123', 6)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Rafael Lima', '(11) 97890-1234', 7)",
  ];

  static const List<String> _insercoesAlunoObjetivo = [
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (1, 1)", // João Silva com Hipertrofia
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (2, 2)", // Maria Oliveira com Emagrecimento
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (3, 3)", // Pedro Santos com Condicionamento
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (4, 4)", // Ana Costa com Resistência
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (5, 5)", // Lucas Pereira com Saúde Geral
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (6, 6)", // Clara Mendes com Flexibilidade
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (7, 7)", // Rafael Lima com Força
  ];

  static const List<String> _insercoesModalidade = [
    "INSERT INTO modalidade (nome) VALUES ('Musculação')",
    "INSERT INTO modalidade (nome) VALUES ('Yoga')",
    "INSERT INTO modalidade (nome) VALUES ('Pilates')",
    "INSERT INTO modalidade (nome) VALUES ('Crossfit')",
    "INSERT INTO modalidade (nome) VALUES ('Funcional')",
    "INSERT INTO modalidade (nome) VALUES ('Zumba')",
    "INSERT INTO modalidade (nome) VALUES ('Spinning')",
  ];

  static const List<String> _insercoesProfessor = [
    "INSERT INTO professor (nome, telefone) VALUES ('Carlos Souza', '(11) 91234-5678')",
    "INSERT INTO professor (nome, telefone) VALUES ('Ana Lima', '(11) 92345-6789')",
    "INSERT INTO professor (nome, telefone) VALUES ('Bruno Costa', '(11) 93456-7890')",
    "INSERT INTO professor (nome, telefone) VALUES ('Felipe Almeida', '(11) 94567-8901')",
    "INSERT INTO professor (nome, telefone) VALUES ('Sofia Mendes', '(11) 95678-9012')",
    "INSERT INTO professor (nome, telefone) VALUES ('Ricardo Silva', '(11) 96789-0123')",
    "INSERT INTO professor (nome, telefone) VALUES ('Laura Ferreira', '(11) 97890-1234')",
  ];

  static const List<String> _insercoesProfessorModalidade = [
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (1, 1)", // Carlos Souza com Musculação
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (2, 2)", // Ana Lima com Yoga
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (3, 3)", // Bruno Costa com Pilates
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (4, 4)", // Felipe Almeida com Crossfit
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (5, 5)", // Sofia Mendes com Funcional
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (6, 6)", // Ricardo Silva com Zumba
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (7, 7)", // Laura Ferreira com Spinning
  ];

  static const List<String> _insercoesDieta = [
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Hipertrofia', 'Dieta para ganho de massa muscular', 'Hipertrofia')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Emagrecimento', 'Dieta para perda de peso', 'Emagrecimento')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Saúde', 'Dieta para saúde geral', 'Saúde Geral')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Resistência', 'Dieta para melhorar resistência', 'Resistência')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Flexibilidade', 'Dieta para flexibilidade', 'Flexibilidade')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Força', 'Dieta para ganho de força', 'Força')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Condicionamento', 'Dieta para condicionamento físico', 'Condicionamento Físico')",
  ];

  static const List<String> _insercoesReceita = [
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Frango Grelhado', 'Peito de frango, sal, pimenta', 'Grelhar o frango por 5 minutos de cada lado', '200 kcal')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Salada Verde', 'Alface, tomate, pepino, azeite', 'Misturar todos os ingredientes', '100 kcal')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Smoothie de Frutas', 'Banana, morango, iogurte', 'Bater no liquidificador', '150 kcal')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Omelete', 'Ovos, tomate, cebola', 'Bater os ovos e cozinhar com os legumes', '120 kcal')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Arroz Integral', 'Arroz integral, água, sal', 'Cozinhar por 30 minutos', '180 kcal')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Sopa de Legumes', 'Cenoura, abobrinha, batata', 'Cozinhar todos os ingredientes', '90 kcal')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Batata Doce Assada', 'Batata doce, azeite', 'Assar por 40 minutos', '130 kcal')",
  ];

  static const List<String> _insercoesReceitaDieta = [
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (1, 1)", // Frango Grelhado com Dieta Hipertrofia
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (2, 2)", // Salada Verde com Dieta Emagrecimento
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (3, 3)", // Smoothie de Frutas com Dieta Saúde
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (4, 4)", // Omelete com Dieta Resistência
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (5, 5)", // Arroz Integral com Dieta Flexibilidade
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (6, 6)", // Sopa de Legumes com Dieta Força
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (7, 7)", // Batata Doce Assada com Dieta Condicionamento
  ];

  static const List<String> _insercoesTurma = [
    "INSERT INTO turma (nome) VALUES ('Spinning')",
    "INSERT INTO turma (nome) VALUES ('Muay-Thai')",
    "INSERT INTO turma (nome) VALUES ('Natação-infantil')",
    "INSERT INTO turma (nome) VALUES ('Natação-adulto')",
    "INSERT INTO turma (nome) VALUES ('CrossFit')",
    "INSERT INTO turma (nome) VALUES ('Dança')",
    "INSERT INTO turma (nome) VALUES ('Musculação')",
  ];

  static const List<String> _insercoesTurmaProfessor = [
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (1, 1)", // Spinning com Carlos Souza
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (2, 2)", // Muay-Thai com Ana Lima
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (3, 3)", // Natação-infantil com Bruno Costa
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (4, 4)", // Turma D com Felipe Almeida
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (5, 5)", // CrossFit com Sofia Mendes
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (6, 6)", // Dança com Ricardo Silva
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (7, 7)", // Musculação com Laura Ferreira
  ];

  static const List<String> _insercoesTurmaAluno = [
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (1, 1)", // Spinning com João Silva
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (2, 2)", // Muay-Thai com Maria Oliveira
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (3, 3)", // Natação-infantil com Pedro Santos
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (4, 4)", // Turma D com Ana Costa
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (5, 5)", // CrossFit com Lucas Pereira
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (6, 6)", // Dança com Clara Mendes
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (7, 7)", // Musculação com Rafael Lima
  ];

  static const List<String> _insercoesAgendamento = [
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Segunda-feira', '08:00', '09:00', 1, 'Academia Fit', 1, 'Spinning', '1', 'João Silva')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Quarta-feira', '10:00', '11:00', 1, 'Academia Fit', 2, 'Muay-Thai', '2', 'Maria Oliveira')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Terça-feira', '18:00', '19:00', 2, 'Academia Power', 3, 'Natação-infantil', '3', 'Pedro Santos')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Quinta-feira', '07:00', '08:00', 3, 'Academia Top', 4, 'Natação-adulto', '4', 'Ana Costa')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Sexta-feira', '09:00', '10:00', 4, 'Academia Energy', 5, 'CrossFit', '5', 'Lucas Pereira')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Segunda-feira', '17:00', '18:00', 5, 'Academia Viva', 6, 'Dança', '6', 'Clara Mendes')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Quarta-feira', '19:00', '20:00', 6, 'Academia Move', 7, 'Musculação', '7', 'Rafael Lima')",
  ];

  static const List<String> _insercoesAgendamentoAluno = [
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (1, 1, 'João Silva')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (2, 2, 'Maria Oliveira')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (3, 3, 'Pedro Santos')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (4, 4, 'Ana Costa')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (5, 5, 'Lucas Pereira')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (6, 6, 'Clara Mendes')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (7, 7, 'Rafael Lima')",
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
}
