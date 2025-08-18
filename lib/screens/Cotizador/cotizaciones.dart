import 'package:catsa/model/planta.dart';
import 'package:catsa/service/api.dart' as ApiService;
import 'package:catsa/widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:catsa/core/app_color.dart';
import 'package:intl/intl.dart';
import '../../model/cotizador.dart';
import '../../service/api.dart';
import 'cotizador_detail.dart';

class Cotizaciones extends StatefulWidget {
  const Cotizaciones({super.key});
  @override
  State<Cotizaciones> createState() => _CotizacionState();
}

class _CotizacionState extends State<Cotizaciones> {
  String? _selectedPlanta; // Variable para almacenar la planta seleccionada
  String? _selectedPlantaNombre;
  List<Planta> _plantas = [];
  List<String> _plantasNombres = [];
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _loading = false;
  bool _isLoading = true;
  List<Cotizador> _cotizaciones = [];

  @override
  void initState() {
    super.initState();
    _loadPlantas();
  }

  Future<void> _loadPlantas() async {
    try {
      final plantas = await ApiService.fPlantas();
      setState(() {
        _plantas = plantas;
        _plantasNombres = plantas.map((p) => p.nombre).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
        _ffCotizaciones();
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
        _ffCotizaciones();
      }
    }
  }

  void _ffCotizaciones() async {
    if (_selectedPlanta == null ||
        _selectedStartDate == null ||
        _selectedEndDate == null) {
      setState(() => _cotizaciones = []);
      return;
    }

    setState(() => _loading = true);

    try {
      final cotizaciones = await fCotizaciones(
        planta: _selectedPlanta!,
        fechaInicio: _selectedStartDate!,
        fechaFin: _selectedEndDate!, // o ajusta si quieres rango
      );

      setState(() {
        _cotizaciones = cotizaciones;
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
                MaterialPageRoute(builder: (_) => Cotizaciones()),
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
                  Dropdown(
                    label: 'Planta',
                    selectedValue: _selectedPlantaNombre,
                    items: _plantasNombres,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPlantaNombre = newValue;
                        final plantaSeleccionada = _plantas.firstWhere(
                          (p) => p.nombre == newValue,
                          orElse: () => Planta(id: '', nombre: ''),
                        );
                        _selectedPlanta = plantaSeleccionada.id;
                      });
                    },
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
    if (_loading && _cotizaciones.isEmpty) {
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

    if (_cotizaciones.isEmpty) {
      return const Center(
        child: Text(
          'No hay pedidos con los filtros seleccionados',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cotizaciones.length,
      itemBuilder: (context, index) {
        final p = _cotizaciones[index];
        return Card(
          color: Colors.white10,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              '${p.idCotizacion != 0 ? p.idCotizacion : 'Sin Pedido'}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${p.noObra} - ${p.obra}\n${p.planta} - ${p.cliente}',
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => Cotizaciones(id: p)),
              // );
            },
          ),
        );
      },
    );
  }
}
