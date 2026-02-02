import 'package:flutter/material.dart';

import '../features/clients/ui/clients_screen.dart';
import '../features/services/ui/services_screen.dart';
import '../features/budgets/ui/budgets_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget card({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return Card(
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: cs.onPrimaryContainer),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MEI Organizador'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          card(
            icon: Icons.people_outline,
            title: 'Clientes',
            subtitle: 'Cadastrar e gerenciar clientes',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientsScreen()),
              );
            },
          ),

          card(
            icon: Icons.work_outline,
            title: 'Serviços',
            subtitle: 'Serviços prestados',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicesScreen()),
              );
            },
          ),

          card(
            icon: Icons.request_quote_outlined,
            title: 'Orçamentos',
            subtitle: 'Criar, gerar PDF e compartilhar',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BudgetsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
