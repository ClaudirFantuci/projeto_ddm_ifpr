
## Visão Geral

O projeto é um aplicativo móvel desenvolvido como projeto da disciplina de Desenvolvimento para Dispositivos Móveis no IFPR Campus Paranavaí. O objetivo do aplicativo é auxiliar personal trainers no gerenciamento de seus alunos e aulas ao longo da semana, proporcionando uma ferramenta prática para organizar academias, equipamentos, exercícios, treinos e agendamentos.

O aplicativo foi construído utilizando **Flutter** e **sqflite** para gerenciamento de banco de dados local, oferecendo uma interface amigável e funcionalidades essenciais para o controle eficiente das atividades de treinamento.

## Objetivo

O projeto visa facilitar a rotina de personal trainers, permitindo:
- Cadastro e gerenciamento de academias, equipamentos, exercícios e treinos.
- Organização de agendamentos de aulas para os alunos.
- Visualização e edição de informações em uma interface intuitiva e consistente.

## Funcionalidades

- **Gerenciamento de Academias**:
  - Cadastro e edição de academias com informações como nome, endereço, telefone e cidade.
  - Listagem de academias com opções para editar ou excluir.
- **Gerenciamento de Equipamentos**:
  - Cadastro e edição de equipamentos de musculação (ex.: Halteres, Barra Olímpica).
  - Listagem com opções de edição e exclusão, com confirmação para exclusão.
- **Gerenciamento de Exercícios**:
  - Cadastro de exercícios com nome e equipamento associado (via dropdown).
  - Integração futura com banco de dados para equipamentos.
- **Gerenciamento de Treinos e Agendamentos**:
  - Cadastro de treinos e agendamentos (em desenvolvimento).
  - Planejamento de aulas semanais para alunos.
- **Observação**: Outras funcionalidades serão adicionadas.

## Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento da interface do aplicativo.
- **sqflite**: Banco de dados SQLite para armazenamento local de dados.
- **Dart**: Linguagem de programação para lógica do aplicativo.
- **Material Design**: Componentes visuais para uma interface amigável.
- 
## Pré-requisitos

- **Flutter SDK**: Versão 3.32.0.
- **Dart**: Incluído com o Flutter.
- **Dispositivo/Emulador**: Android ou iOS para testes.
- **IDE**: Recomenda-se Visual Studio Code ou Android Studio.
  
##Executando o projeto
### Clone o projeto
git clone https://github.com/ClaudirFantuci/projeto_ddm_ifpr.git
cd projeto_ddm_ifpr

### Instale as dependências
flutter pub get

### Execute
flutter run
