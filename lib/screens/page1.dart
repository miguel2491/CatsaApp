import 'package:flutter/material.dart';
import 'package:catsa/core/app_color.dart';
import '../model/cotizador.dart';
import '../service/api.dart';
import './Cotizador/cotizador_detail.dart';
import './Cotizador/cotizacion.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('COTIZADOR'),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Acción al presionar el botón
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CotizacionF()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0F57), Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<Cotizador>>(
          future: fetchProductos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No hay cotizaciones disponibles',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final cotizador = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cotizador.length,
              itemBuilder: (context, index) {
                final p = cotizador[index];
                return Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      p.cliente.isNotEmpty ? p.cliente : 'Sin cliente',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      p.obra.isNotEmpty == true ? p.obra : 'Sin obra',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CotizadorDetail(cotizador: p),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
