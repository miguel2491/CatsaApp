import 'package:catsa/db/database_helper.dart';
import 'package:catsa/model/pedido.dart';
import 'package:catsa/model/pedidoDB.dart';
import 'package:catsa/model/planta.dart';
import 'package:catsa/service/api.dart' as api_service;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:catsa/service/api.dart' as ApiService;
import 'package:catsa/service/offline_sync.dart' as ApiLocal;
import 'package:catsa/screens/Pedidos/pedido_detail.dart';
import 'package:catsa/screens/Pedidos/pedido_form.dart';
import 'package:catsa/widgets/drop_planta.dart';
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
  Planta? _selectedPlanta;
  List<Planta> _plantas = [];
  bool _isLoading = true;

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  List<Pedidodb> _pedidos = [];
  List<Pedido> _pedidosAll = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPlantas();
    readPedidosL();
    //ApiLocal.OfflineSync().sincronizar();
  }

  //------------------------ Parametros ----------------------------------------
  Future<void> _loadPlantas() async {
    try {
      final plantas = await api_service.getPlantas();
      setState(() {
        _plantas = plantas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pickStartDate() async {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: lastDayOfMonth,
    );

    if (picked != null) {
      setState(() => _selectedStartDate = picked);
      if (_selectedEndDate != null && _selectedPlanta != null) {
        //_fetchFilteredPedidos();
      }
    }
  }

  void _pickEndDate() async {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? (_selectedStartDate ?? DateTime.now()),
      firstDate: _selectedStartDate ?? DateTime(2020),
      lastDate: lastDayOfMonth,
    );

    if (picked != null) {
      setState(() => _selectedEndDate = picked);
      if (_selectedStartDate != null && _selectedPlanta != null) {
        //_fetchFilteredPedidos();
      }
    }
  }

  //------------------------ Principales --------------------------------------
  void _fetchFilteredPedidos(planta) async {
    if (_selectedPlanta == null ||
        _selectedStartDate == null ||
        _selectedEndDate == null) {
      setState(() => _pedidos = []);
      return;
    }

    setState(() => _loading = true);
    try {
      final pedidos = await fetchPedido(
        planta: planta, //_selectedPlanta!,
        fechaInicio: _selectedStartDate!,
        fechaFin: _selectedEndDate!, // o ajusta si quieres rango
      );
      //final result = pedidos.map((e) => Pedido.fromJson(e)).toList();

      setState(() {
        _pedidosAll = pedidos;
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

  void _insertPedido() async {
    await ApiLocal.OfflineSync().insertPedido({
      "nocliente": "123",
      "cliente": "Juan Pérez",
      "fechaCreacion": DateTime.now().toIso8601String(),
      "enviado": 0,
    });
  }

  //------------------------ Eventos -------------------------------------------
  void _onPlantaSelected(String? planta) {
    if (_selectedStartDate != null && _selectedEndDate != null) {
      _fetchFilteredPedidos(planta);
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

  void readPedidosL() async {
    final prefs = await SharedPreferences.getInstance();
    final edoCon = prefs.getString('coneccion');
    if (edoCon == 'SI') {
      final db = await DatabaseHelper.instance.database;
      final pendientes = await db.query(
        "pedidos",
        where: "enviado = ?",
        whereArgs: [0],
      );
      for (final pedido in pendientes) {
        final ok = await ApiService.comprobarPedPend(pedido);

        if (ok) {
          await db.update(
            "pedidos",
            {"enviado": 1},
            where: "id = ?",
            whereArgs: [pedido['id']],
          );
        }
      }

      // final pedidos = await fetchPedido(
      //   planta: "", //_selectedPlanta!,
      //   fechaInicio: _selectedStartDate!,
      //   fechaFin: _selectedEndDate!, // o ajusta si quieres rango
      // );

      // for (final pedido in pedidos) {
      //   debugPrint('Pedido: $pedido');
      // }
    } else {
      final List<Map<String, dynamic>> pedidos = await ApiLocal.OfflineSync()
          .getPedidosL();

      for (final pedido in pedidos) {
        debugPrint('Pedido: $pedido');
      }
    }
  }

  Future<void> _confirmarYActualizar({
    required String titulo,
    required String mensaje,
    required int idPedido,
    required String tipo,
    required int respuesta,
    required void Function() onSuccessUI,
  }) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );

    if (confirmado != true) return;

    // 🔄 Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ok = await ApiService.autorizarPedido(idPedido, tipo, respuesta);

      Navigator.pop(context); // cerrar loading

      if (ok) {
        setState(onSuccessUI);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Estado actualizado correctamente"),
            backgroundColor: Colors.green,
          ),
        );
        _fetchFilteredPedidos(_selectedPlanta?.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ No se pudo actualizar"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  //----------------------------------------------------------------------------
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
                  PlantaDropdown(
                    plantas: _plantas,
                    selectedPlanta: _selectedPlanta,
                    onChanged: (planta) {
                      setState(() {
                        _selectedPlanta = planta;
                      });
                      _onPlantaSelected(planta?.id);
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

    if (_pedidosAll.isEmpty) {
      return const Center(
        child: Text(
          'No hay pedidos con los filtros seleccionados',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pedidosAll.length,
      itemBuilder: (context, index) {
        final p = _pedidosAll[index];
        return Card(
          color: Colors.white10,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              '${p.IdPedido != 0 ? p.IdPedido : 'Sin Pedido'}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${p.Asesor} \n ${p.NoCliente} ${p.Nombre} \n ${p.NoObra} ${p.Obra} \n ${p.FechaHoraPedido} \n ${p.Cantidad.toStringAsFixed(2)} m³',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primer círculo (Programar)
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    _confirmarYActualizar(
                      titulo: "Cambiar Visto Bueno",
                      mensaje: p.activo == 1
                          ? "¿Deseas desactivar el Programado?"
                          : "¿Deseas activar el Programado?",
                      idPedido: p.IdPedido,
                      tipo: "PR",
                      respuesta: p.activo == 1 ? 0 : 1,
                      onSuccessUI: () {
                        //p.activo = p.activo == 1 ? 0 : 1;
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: p.activo == 1 ? Colors.blue : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      p.activo == 1 ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    _confirmarYActualizar(
                      titulo: "Cambiar Visto Bueno",
                      mensaje: p.VistoBueno == 1
                          ? "¿Deseas desactivar el Visto Bueno?"
                          : "¿Deseas activar el Visto Bueno?",
                      idPedido: p.IdPedido,
                      tipo: "VB",
                      respuesta: p.VistoBueno == 1 ? 0 : 1,
                      onSuccessUI: () {
                        //p.VistoBueno = p.VistoBueno == 1 ? 0 : 1;
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: p.VistoBueno == 1 ? Colors.blue : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      p.VistoBueno == 1 ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
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
