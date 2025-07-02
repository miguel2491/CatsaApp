import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/dropdown_Planta.dart';
import '../../widgets/InputButton.dart';
import '../../widgets/detail.dart';
import '../../widgets/DatePicker.dart';
import '../../widgets/TimePicker.dart';
import '../../widgets/Divisor.dart';
import '../../widgets/TimeDuration.dart';
import '../../widgets/Comentarios.dart';
import '../../widgets/FilePickerField.dart';
import 'package:http/http.dart' as http;

class PedidoForm extends StatefulWidget {
  const PedidoForm({super.key});

  @override
  State<PedidoForm> createState() => _PedidoFormState();
}

class _PedidoFormState extends State<PedidoForm> {
  String? _selectedPlanta; // Variable para almacenar la planta seleccionada
  final List<String> _plantas = [
    'Planta 1',
    'Planta 2',
    'Planta 3',
    'Planta 4',
  ];
  String? _selectedFP; // Variable para almacenar la planta seleccionada
  final List<String> _fp = ['Crédito', 'Contado', 'Débito'];
  String? _selectedPro; // Variable para almacenar la planta seleccionada
  final List<String> _pro = ['C250N2014D00', 'C100N2010D00', 'C250N2010B00'];
  final TextEditingController _cotizacionController = TextEditingController();
  DateTime? _fechaEntrega;
  TimeOfDay? _horaLlegada;
  final TextEditingController _cantidadController = TextEditingController();
  final _tiempoRecorridoController = TextEditingController();
  final _tiempoDescargaController = TextEditingController();
  final _frecEnvioController = TextEditingController();
  final _comentariosController = TextEditingController();
  XFile? _archivoAdjunto;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'), // Para español
    );
    if (picked != null && picked != _fechaEntrega) {
      setState(() {
        _fechaEntrega = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaLlegada ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _horaLlegada) {
      setState(() {
        _horaLlegada = picked;
      });
    }
  }

  @override
  void dispose() {
    _cotizacionController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Pedido'),
        backgroundColor: const Color(0xFF0D0F57),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _guardarPedido();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Dropdown(
              label: 'Planta',
              selectedValue: _selectedPlanta,
              items: _plantas,
              onChanged: (newValue) {
                setState(() {
                  _selectedPlanta = newValue;
                });
              },
            ),
            InputWithIconButton(
              label: 'Cotización',
              controller: _cotizacionController,
              icon: Icons.search,
              onPressed: () {
                print('Buscando: ${_cotizacionController.text}');
              },
            ),
            DetailTile(label: 'Cliente', value: ''),
            DetailTile(label: 'Obra', value: ''),
            DetailTile(label: 'Teléfono', value: ''),
            Dropdown(
              label: 'Forma de Pago',
              selectedValue: _selectedFP,
              items: _fp,
              onChanged: (newValue) {
                setState(() {
                  _selectedFP = newValue;
                });
              },
            ),
            const SizedBox(height: 12),
            CenteredDivider(title: 'Caracteristicas del Producto'),
            const SizedBox(height: 12),
            Dropdown(
              label: 'Producto',
              selectedValue: _selectedPro,
              items: _pro,
              onChanged: (newValue) {
                setState(() {
                  _selectedPro = newValue;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Precio Concreto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Precio Extra',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Dropdown(
              label: 'Elemento a Colar',
              selectedValue: _selectedPro,
              items: _pro,
              onChanged: (newValue) {
                setState(() {
                  _selectedPro = newValue;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Metros (m³)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Dropdown(
              label: 'Tipo Bomba',
              selectedValue: _selectedPlanta,
              items: _plantas,
              onChanged: (newValue) {
                setState(() {
                  _selectedPlanta = newValue;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Precio Bombeo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Subtotal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Total',
                border: OutlineInputBorder(),
              ),
            ),
            CenteredDivider(title: 'Datos del Pedido'),
            const SizedBox(height: 12),
            DatePickerTile(
              label: 'Fecha de entrega',
              date: _fechaEntrega,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 12),
            TimePickerTile(
              label: 'Hora Llegada',
              time: _horaLlegada,
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'M3 Viaje',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TimeInputField(
              label: 'Tiempo de recorrido',
              controller: _tiempoRecorridoController,
              onChanged: (val) {
                print('Nuevo tiempo ingresado: $val');
              },
            ),
            const SizedBox(height: 12),
            TimeInputField(
              label: 'Tiempo de Descarga',
              controller: _tiempoDescargaController,
              onChanged: (val) {
                print('Nuevo tiempo Descarga: $val');
              },
            ),
            const SizedBox(height: 12),
            TimeInputField(
              label: 'Frecuencia de Envío',
              controller: _frecEnvioController,
              onChanged: (val) {
                print('Frecuencia de Envio: $val');
              },
            ),
            const SizedBox(height: 12),
            TextAreaField(
              label: 'Observaciones',
              controller: _comentariosController,
              hintText: 'Escribe tus observaciones aquí...',
            ),
            TextField(
              controller: _comentariosController,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Recibe en Obra',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilePickerField(
              label: 'Adjuntar archivo (PDF o imagen)',
              onFilePicked: (file) {
                setState(() {
                  _archivoAdjunto = file;
                });
                print('Archivo: ${file?.name}');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _guardarPedido() async {
    final cotizacion = _cotizacionController.text;
    final cantidad = double.tryParse(_cantidadController.text) ?? 0.0;

    if (_selectedPlanta == null ||
        _selectedFP == null ||
        _selectedPro == null ||
        cotizacion.isEmpty ||
        _fechaEntrega == null ||
        _horaLlegada == null ||
        cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final fechaStr = DateFormat('yyyy-MM-dd').format(_fechaEntrega!);
    final horaStr = _horaLlegada!.format(context);

    final pedidoData = {
      "planta": _selectedPlanta,
      "formaPago": _selectedFP,
      "producto": _selectedPro,
      "cotizacion": cotizacion,
      "cantidad": cantidad,
      "fechaEntrega": fechaStr,
      "horaLlegada": horaStr,
    };

    try {
      final url = Uri.parse(
        'http://apicatsa.catsaconcretos.mx:2543/api/Pedidos/Create',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pedidoData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Mostramos la ventana emergente de éxito
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Pedido Registrado'),
            content: Text(
              'El pedido fue guardado exitosamente.\n'
              'ID Pedido: ${responseData['idPedido'] ?? 'desconocido'}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Limpiar formulario
                  _cotizacionController.clear();
                  _cantidadController.clear();
                  setState(() {
                    _selectedPlanta = null;
                    _selectedFP = null;
                    _selectedPro = null;
                    _fechaEntrega = null;
                    _horaLlegada = null;
                  });

                  Navigator.of(context)
                    ..pop() // Cierra el diálogo
                    ..pop(); // Regresa a pantalla anterior
                },
                child: const Text('Hecho'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
