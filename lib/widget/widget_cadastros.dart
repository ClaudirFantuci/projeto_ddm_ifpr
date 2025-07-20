import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';

class WidgetCadastros extends StatelessWidget {
  const WidgetCadastros({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Cadastros',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            _buildGridButton(
              context,
              title: 'Cadastrar Academia',
              icon: Icons.location_city,
              route: Rotas.cadastroAcademias,
            ),
            _buildGridButton(
              context,
              title: 'Cadastrar Aluno',
              icon: Icons.person,
              route: Rotas.cadastroAlunos,
            ),
            _buildGridButton(
              context,
              title: 'Cadastrar Objetivo',
              icon: Icons.flag,
              route: Rotas.cadastroObjetivos,
            ),
            _buildGridButton(
              context,
              title: 'Cadastrar Equipamento',
              icon: Icons.build,
              route: Rotas.cadastroEquipamento,
            ),
            _buildGridButton(
              context,
              title: 'Cadastrar Exercício',
              icon: Icons.fitness_center,
              route: Rotas.cadastroExercicios,
            ),
            _buildGridButton(
              context,
              title: 'Cadastrar Treino',
              icon: Icons.directions_run,
              route: Rotas.cadastroTreinos,
            ),
            _buildGridButton(
              context,
              title: 'Cadastrar Agendamento',
              icon: Icons.schedule,
              route: Rotas.agendamento,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(BuildContext context,
      {required String title, required IconData icon, required String route}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16),
      ),
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.amber, size: 40),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.amber, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
