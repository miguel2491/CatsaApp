import 'package:catsa/model/pedido.dart';
import 'package:catsa/screens/Pedidos/pedido_detail.dart';
import 'package:catsa/screens/Pedidos/pedido_form.dart';
import 'package:catsa/service/api.dart';
import 'package:flutter/material.dart';
import 'package:catsa/core/app_color.dart';
import 'package:intl/intl.dart';

class Pedidos extends StatefulWidget {
  const Pedidos({super.key});

  @override
  State<Pedidos> createState() => _PedidosState();
}

class _PedidosState extends State<Pedidos> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedPlanta;
  final List<String> _plantasDisponibles = [
    'TLX1',
    'MEX1',
    'PUE1',
  ]; // cambia según tus datos
  List<Pedido> _pedidos = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    //_fetchFilteredPedidos(); // carga inicial
  }

  void _fetchFilteredPedidos() async {
    if (_selectedPlanta == null ||
        _selectedStartDate == null ||
        _selectedEndDate == null) {
      setState(() => _pedidos = []);
      return;
    }

    setState(() => _loading = true);

    try {
      final pedidos = await fetchPedido(
        planta: _selectedPlanta!,
        fechaInicio: _selectedStartDate!,
        fechaFin: _selectedEndDate!, // o ajusta si quieres rango
      );

      setState(() {
        _pedidos = pedidos;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar pedidos: ${e.toString()}')),
      );
    }
  }

  void _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _selectedStartDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedStartDate = picked);
      if (_selectedEndDate != null && _selectedPlanta != null) {
        _fetchFilteredPedidos();
      }
    }
  }

  void _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? (_selectedStartDate ?? DateTime.now()),
      firstDate: _selectedStartDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedEndDate = picked);
      if (_selectedStartDate != null && _selectedPlanta != null) {
        _fetchFilteredPedidos();
      }
    }
  }

  void _onPlantaSelected(String? planta) {
    setState(() => _selectedPlanta = planta);
    if (_selectedStartDate != null && _selectedEndDate != null) {
      _fetchFilteredPedidos();
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
      _selectedPlanta = null;
      _pedidos = [];
    });
    //_fetchFilteredPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
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
                MaterialPageRoute(builder: (_) => PedidoForm()),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _selectedStartDate != null
                                ? 'Inicio: ${DateFormat('yyyy-MM-dd').format(_selectedStartDate!)}'
                                : 'Fecha inicial',
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: _pickStartDate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _selectedEndDate != null
                                ? 'Fin: ${DateFormat('yyyy-MM-dd').format(_selectedEndDate!)}'
                                : 'Fecha final',
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: _pickEndDate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedPlanta,
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    hint: const Text('Planta'),
                    items: _plantasDisponibles.map((planta) {
                      return DropdownMenuItem(
                        value: planta,
                        child: Text(planta),
                      );
                    }).toList(),
                    onChanged: _onPlantaSelected,
                  ),
                ],
              ),
            ),
            if (_loading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
              ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading && _pedidos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedPlanta == null ||
        _selectedStartDate == null ||
        _selectedEndDate == null) {
      return const Center(
        child: Text(
          'Seleccione planta y rango de fechas para filtrar',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    if (_pedidos.isEmpty) {
      return const Center(
        child: Text(
          'No hay pedidos con los filtros seleccionados',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pedidos.length,
      itemBuilder: (context, index) {
        final p = _pedidos[index];
        return Card(
          color: Colors.white10,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              '${p.IdPedido != 0 ? p.IdPedido : 'Sin Pedido'}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${p.NoObra} - ${p.Obra}\n${p.Producto} - ${p.Cantidad.toStringAsFixed(2)} m³',
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PedidoDetail(pedido: p)),
              );
            },
          ),
        );
      },
    );
  }
}
