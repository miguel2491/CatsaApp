import 'package:catsa/core/app_color.dart';
import 'package:catsa/model/planta.dart';
import 'package:catsa/service/api.dart' as api_service;
import 'package:catsa/service/api.dart' as ApiService;
import 'package:catsa/widgets/dropdown.dart';
import 'package:catsa/widgets/w_online.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/pedido_online.dart';

class PedidoOnline extends StatefulWidget {
  const PedidoOnline({super.key});

  @override
  _PedidoOnlineState createState() => _PedidoOnlineState();
}

class _PedidoOnlineState extends State<PedidoOnline> {
  List<Online> p_online = [];
  String? _selectedPlanta; // Variable para almacenar la planta seleccionada
  String? _selectedPlantaNombre;
  List<Planta> _plantas = [];
  List<String> _plantasNombres = [];
  List<Online> _pedidos = [];

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isLoading = true;
  bool _loading = false;
  //------------------------------------------------------
  Future<void> _loadPedidos() async {
    try {
      final pedidos = await api_service.fPOnline('', '');
      setState(() {
        p_online = pedidos;
      });
    } catch (e) {
      print('Error al cargar pedidos: $e');
    }
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

  void _onPlantaSelected(String? planta) {
    setState(() => _selectedPlanta = planta);
    if (_selectedStartDate != null && _selectedEndDate != null) {
      _fetchFilteredPedidos();
    }
  }

  void _fetchFilteredPedidos() async {
    if (_selectedPlanta == null || _selectedStartDate == null) {
      setState(() => _pedidos = []);
      return;
    }

    setState(() => _loading = true);
    print('⚽ $_selectedPlanta 🎃 $_selectedStartDate');
    try {
      final pedidos = await api_service.fPOnline(
        _selectedPlanta!,
        _selectedStartDate!,
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

  @override
  void initState() {
    super.initState();
    _loadPedidos();
    _loadPlantas();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos en Línea'),
        backgroundColor: const Color(0xFF0D0F57),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              children: [
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
                      _fetchFilteredPedidos();
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
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
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 400, // Máximo deseado
                  ),
                  child: ListView.builder(
                    shrinkWrap:
                        true, // Se adapta al contenido, no se expande infinito
                    physics:
                        const NeverScrollableScrollPhysics(), // Evita scroll propio
                    itemCount: _pedidos.length,
                    itemBuilder: (context, index) {
                      final ponline = _pedidos[index];
                      return OnlineAccordion(
                        extra: ponline,
                        onDetallePressed: () {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
