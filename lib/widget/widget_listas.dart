import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';

class WidgetListas extends StatelessWidget {
  const WidgetListas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Listas',
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
              title: 'Academias',
              icon: Icons.location_city,
              route: Rotas.listaAcademias,
            ),
            _buildGridButton(
              context,
              title: 'Alunos',
              icon: Icons.person,
              route: Rotas.listaAlunos,
            ),
            _buildGridButton(
              context,
              title: 'Professores',
              icon: Icons.school,
              route: Rotas.listaProfessores,
            ),
            _buildGridButton(
              context,
              title: 'Objetivos',
              icon: Icons.flag,
              route: Rotas.listaObjetivos,
            ),
            _buildGridButton(
              context,
              title: 'Equipamentos',
              icon: Icons.build,
              route: Rotas.listaEquipamentos,
            ),
            _buildGridButton(
              context,
              title: 'Exercícios',
              icon: Icons.fitness_center,
              route: Rotas.listaExercicios,
            ),
            _buildGridButton(
              context,
              title: 'Treinos',
              icon: Icons.directions_run,
              route: Rotas.listaTreinos,
            ),
            _buildGridButton(
              context,
              title: 'Turmas',
              icon: Icons.group,
              route: Rotas.listaTurmas,
            ),
            _buildGridButton(
              context,
              title: 'Modalidades',
              icon: Icons.sports_gymnastics,
              route: Rotas.listaModalidades,
            ),
            _buildGridButton(
              context,
              title: 'Dietas',
              icon: Icons.food_bank,
              route: Rotas.listaDietas,
            ),
            _buildGridButton(
              context,
              title: 'Receitas',
              icon: Icons.restaurant_menu,
              route: Rotas.listaReceitas,
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
