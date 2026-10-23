import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:catsa/model/pedido.dart';
import '../../model/pedido.dart';
import '../../widgets/date_picker.dart';
import '../../widgets/time_picker.dart';
import '../../widgets/time_duration.dart';
import '../../widgets/comentarios.dart';

class PedidoDetail extends StatefulWidget {
  final Pedido pedido;

  const PedidoDetail({super.key, required this.pedido});

  @override
  State<PedidoDetail> createState() => _PedidoDetailState();
}

class _PedidoDetailState extends State<PedidoDetail> {
  DateTime? _fechaEntrega;
  TimeOfDay? _horaLlegada;
  bool _hPBomba = false;

  late TextEditingController _precioConcretoController;
  late TextEditingController _precioExtraController;
  late TextEditingController _precioBombaController;
  late TextEditingController _cantidadM3Controller;
  late TextEditingController _m3ViajeController;
  final TextEditingController _subtotalController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  final _tiempoRecorridoController = TextEditingController();
  final _comentariosController = TextEditingController();

  final FocusNode _cantidadFocus = FocusNode();
  final FocusNode _precioFocus = FocusNode();
  final FocusNode _pExtraFocus = FocusNode();
  final FocusNode _pBombaFocus = FocusNode();
  @override
  void initState() {
    super.initState();

    _precioConcretoController = TextEditingController(
      text: widget.pedido.PrecioProducto.toStringAsFixed(2),
    );

    _precioExtraController = TextEditingController();
    _precioBombaController = TextEditingController();
    _cantidadM3Controller = TextEditingController(
      text: widget.pedido.Cantidad.toStringAsFixed(2),
    );
    _tiempoRecorridoController.text = widget.pedido.TRecorrido.toString();
    _m3ViajeController = TextEditingController(
      text: widget.pedido.M3Viaje.toStringAsFixed(2),
    );
    _calcularTotal();
    _cantidadFocus.addListener(() {
      if (!_cantidadFocus.hasFocus) {
        _calcularTotal();
      }
    });
    _precioFocus.addListener(() {
      if (!_precioFocus.hasFocus) {
        _calcularTotal();
      }
    });
    _pExtraFocus.addListener(() {
      if (!_pExtraFocus.hasFocus) {
        _cTotalExtra();
      }
    });
    _pBombaFocus.addListener(() {
      if (!_pBombaFocus.hasFocus && _hPBomba) {
        _cTotalBomba();
      }
    });
  }

  @override
  void dispose() {
    _precioConcretoController.dispose();
    _precioExtraController.dispose();
    _precioBombaController.dispose();
    _cantidadM3Controller.dispose();
    _m3ViajeController.dispose();
    _subtotalController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _fechaEntrega = picked);
    }
  }

  Future<void> _selectTime() async {
    final now = TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: _horaLlegada ?? now,
    );

    if (picked != null) {
      setState(() => _horaLlegada = picked);
    }
  }

  void _calcularTotal() {
    final cantidad = double.tryParse(_cantidadM3Controller.text) ?? 0;
    final precioC = double.tryParse(_precioConcretoController.text) ?? 0;
    final subtotal = cantidad * precioC;
    final iva = subtotal * 0.16;
    final total = subtotal + iva;
    // aquí tu lógica
    setState(() {
      _subtotalController.text = subtotal.toStringAsFixed(2);
      _totalController.text = total.toStringAsFixed(2);
    });
  }

  void _cTotalExtra() {
    final cantidad = double.tryParse(_cantidadM3Controller.text) ?? 0;
    final precioC = double.tryParse(_precioConcretoController.text) ?? 0;
    final _pBomba = double.tryParse(_precioBombaController.text) ?? 0;
    final _pExtra = double.tryParse(_precioExtraController.text) ?? 0;
    final auxST;
    final auxstF;
    if (_pBomba == 0) {
      auxST = cantidad * precioC;
      auxstF = auxST + _pExtra + _pBomba;
    } else {
      auxST = cantidad * (precioC + _pBomba);
      auxstF = auxST + _pExtra;
    }
    final auxT = auxstF * 0.16;
    final totalF = auxstF + auxT;
    setState(() {
      _subtotalController.text = auxstF.toStringAsFixed(2);
      _totalController.text = totalF.toStringAsFixed(2);
    });
  }

  void _cTotalBomba() {
    final cantidad = double.tryParse(_cantidadM3Controller.text) ?? 0;
    final precioC = double.tryParse(_precioConcretoController.text) ?? 0;
    final _pBomba = double.tryParse(_precioBombaController.text) ?? 0;
    final _pExtra = double.tryParse(_precioExtraController.text) ?? 0;
    final auxSTF;
    final auxST;
    if (_pBomba == 0) {
      auxSTF = cantidad * precioC;
      auxST = auxSTF + _pExtra + _pBomba;
    } else {
      auxSTF = cantidad * (precioC + _pExtra);
      auxST = auxSTF + _pBomba;
    }
    final auxT = auxST * 0.16;
    final totalF = auxST + auxT;
    setState(() {
      _subtotalController.text = auxST.toStringAsFixed(2);
      _totalController.text = totalF.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle Pedido # ${pedido.IdPedido}'),
        backgroundColor: const Color(0xFF0D0F57),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildDetail('No. Pedido', pedido.IdPedido.toString()),
            _buildDetail('Cliente', '${pedido.NoCliente} ${pedido.Nombre}'),
            _buildDetail('Obra', '${pedido.NoObra} ${pedido.Obra}'),
            _buildDetail('Forma Pago', pedido.Pago),
            _buildDetail('Asesor', pedido.Asesor),
            _buildDetail('Producto', pedido.Producto),
            const SizedBox(height: 20),
            _buildInput(
              _cantidadM3Controller,
              'Cantidad M3',
              focusNode: _cantidadFocus,
            ),
            const SizedBox(height: 20),
            _buildInput(
              _precioConcretoController,
              'Precio Concreto',
              focusNode: _precioFocus,
            ),
            _buildInput(
              _precioExtraController,
              'Precio Extra',
              focusNode: _pExtraFocus,
            ),
            _buildInput(
              _precioBombaController,
              'Precio Bomba',
              focusNode: _pBombaFocus,
            ),
            const SizedBox(height: 20),
            _buildDetail('SubTotal', _subtotalController.text),
            _buildDetail('Total', _totalController.text),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Fecha de entrega'),
              subtitle: Text(
                _fechaEntrega == null
                    ? 'Seleccionar fecha'
                    : '${_fechaEntrega!.day}/${_fechaEntrega!.month}/${_fechaEntrega!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            ListTile(
              title: const Text('Hora de llegada'),
              subtitle: Text(
                _horaLlegada == null
                    ? 'Seleccionar hora'
                    : _horaLlegada!.format(context),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
            _buildInput(_m3ViajeController, 'M3 Viaje'),
            const SizedBox(height: 20),
            TimeInputField(
              label: 'Tiempo de recorrido',
              controller: _tiempoRecorridoController,
              onChanged: (val) {
                //print('Nuevo tiempo ingresado: $val');
              },
            ),
            TimeInputField(
              label: 'Tiempo de Descarga',
              controller: _tiempoRecorridoController,
              onChanged: (val) {
                //print('Nuevo tiempo ingresado: $val');
              },
            ),
            TimeInputField(
              label: 'Frecuencia de envío',
              controller: _tiempoRecorridoController,
              onChanged: (val) {
                //print('Nuevo tiempo ingresado: $val');
              },
            ),
            const SizedBox(height: 12),
            TextAreaField(
              label: 'Observaciones',
              controller: _comentariosController,
              hintText: 'Escribe tus observaciones aquí...',
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _guardarCambios();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D0F57), // color del botón
                foregroundColor: Colors.white, // color del texto / iconos
              ),
              child: const Text("Modificar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isNotEmpty ? value : 'Sin información'),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _guardarCambios() {
    final double cantidadO = widget.pedido.Cantidad;
    final double precioCO = widget.pedido.PrecioProducto;
    final double precioEO = widget.pedido.PrecioExtra;
    final double precioBO = widget.pedido.PrecioBomba;

    final double cantidadM =
        double.tryParse(_cantidadM3Controller.text.trim()) ?? 0;
    final double precioCM =
        double.tryParse(_precioConcretoController.text.trim()) ?? 0;
    final double precioEM =
        double.tryParse(_precioExtraController.text.trim()) ?? 0;
    final double precioBM =
        double.tryParse(_precioBombaController.text.trim()) ?? 0;
    final double m3viaje = double.tryParse(_m3ViajeController.text.trim()) ?? 0;

    if (cantidadM < cantidadO) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La cantidad M3 no puede ser menor a la cantidad original',
          ),
        ),
      );
      _cantidadM3Controller.text = cantidadO.toString();
      return;
    }
    if (precioCO < precioCM) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El precio no puede ser menor al precio original'),
        ),
      );
      _precioConcretoController.text = precioCO.toString();
      return;
    }
    if (precioEO < precioEM) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El precio Extra no puede ser menor al precio extra original',
          ),
        ),
      );
      _precioExtraController.text = precioEO.toString();
      return;
    }
    if (precioBO < precioBM) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El precio bomba no puede ser menor al precio bomba original',
          ),
        ),
      );
      _precioBombaController.text = precioBO.toString();
      return;
    }
    if (cantidadM < m3viaje) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los M3 Viaje no puede ser mayor a la cantidad'),
        ),
      );
      _m3ViajeController.text = cantidadM.toString();
      return;
    }
    print("Fecha: $_fechaEntrega");
    print("Hora: $_horaLlegada");
  }
}
