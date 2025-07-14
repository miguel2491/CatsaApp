import 'dart:convert';
import 'package:catsa/model/cotizador.dart';
import 'package:catsa/model/producto.dart';
import 'package:catsa/service/api.dart' as ApiService;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/dropdown_planta.dart';
import '../../widgets/input_button.dart';
import '../../widgets/detail.dart';
import '../../widgets/date_picker.dart';
import '../../widgets/time_picker.dart';
import '../../widgets/divisor.dart';
import '../../widgets/time_duration.dart';
import '../../widgets/comentarios.dart';
import '../../screens/Pedidos/pedidos.dart';
import 'package:http/http.dart' as http;
import '../../model/planta.dart';

class PedidoForm extends StatefulWidget {
  const PedidoForm({super.key});

  @override
  State<PedidoForm> createState() => _PedidoFormState();
}

class _PedidoFormState extends State<PedidoForm> {
  Planta? _selectedPlanta; // Variable para almacenar la planta seleccionada
  //String? _selectedPlantaNombre;
  List<Planta> _plantas = [];
  //List<String> _plantasNombres = [];
  bool _isLoading = true;

  String? _selectedFP; // Variable para almacenar la planta seleccionada
  final List<String> _fp = ['Crédito', 'Contado', 'Débito'];

  List<Producto> _productos = [];
  Producto? _productoSeleccionado;

  final TextEditingController _cotizacionController = TextEditingController();
  final TextEditingController _pedidoController = TextEditingController();
  DateTime? _fechaEntrega;
  TimeOfDay? _horaLlegada;
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final _tiempoRecorridoController = TextEditingController();
  final _tiempoDescargaController = TextEditingController();
  final _frecEnvioController = TextEditingController();
  final _comentariosController = TextEditingController();
  Cotizador? _cotizacionResult;
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
  void initState() {
    super.initState();
    _loadPlantas();
  }

  @override
  void dispose() {
    _cotizacionController.dispose();
    _cantidadController.dispose();
    _pedidoController.dispose();
    super.dispose();
  }

  Future<void> _loadPlantas() async {
    try {
      final plantas = await ApiService.fPlantas();
      setState(() {
        _plantas = plantas; // ✅ Asigna la lista completa de objetos
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProductos(String idc) async {
    setState(() => _isLoading = true);
    try {
      final productos = await ApiService.fProducto(idc);
      setState(() {
        _productos = productos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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
            DropdownButton<Planta>(
              value: _selectedPlanta,
              hint: Text('Selecciona una planta'),
              isExpanded: true, // 👈 esto también ayuda si el texto es largo
              items: _plantas.map((planta) {
                return DropdownMenuItem<Planta>(
                  value: planta,
                  child: Text(planta.nombre),
                );
              }).toList(),
              onChanged: (planta) {
                setState(() {
                  _selectedPlanta = planta;
                  print('✅ Seleccionada: ${planta?.nombre} (${planta?.id})');
                });
              },
            ),
            InputWithIconButton(
              label: 'Pedido',
              controller: _pedidoController,
              icon: Icons.search,
              onPressed: () {
                // print('Buscando: ${_cotizacionController.text}');
              },
            ),
            InputWithIconButton(
              label: 'Cotización',
              controller: _cotizacionController,
              icon: Icons.search,
              onPressed: () async {
                if (_cotizacionController.text.isNotEmpty) {
                  try {
                    final resultado = await ApiService.fCotizacion(
                      _cotizacionController.text,
                    );
                    if (resultado.isNotEmpty) {
                      final cot = resultado.first;
                      final plantaSeleccionada = _plantas.firstWhere(
                        (p) => p.id == cot.planta,
                        orElse: () => Planta(id: '', nombre: ''),
                      );
                      setState(() {
                        _cotizacionResult = cot;
                        _selectedPlanta = plantaSeleccionada;
                      });

                      _loadProductos(_cotizacionController.text);
                      print('🔄 Cargando ...');
                      print(_cotizacionResult);
                    } else {
                      // Maneja caso de resultado vacío
                      print('No se encontró cotización');
                    }
                  } catch (e) {
                    print('Error al obtener cotización: $e');
                  }
                }
              },
            ),
            DetailTile(
              label: 'Cliente',
              value:
                  '${_cotizacionResult?.noCliente ?? ''} ${_cotizacionResult?.cliente ?? ''}',
            ),
            DetailTile(
              label: 'Obra',
              value:
                  '${_cotizacionResult?.noObra ?? ''} ${_cotizacionResult?.obra ?? ''}',
            ),
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
            DropdownButton<Producto>(
              value: _productoSeleccionado,
              hint: Text('Selecciona un producto'),
              items: _productos.map((producto) {
                return DropdownMenuItem<Producto>(
                  value: producto,
                  child: Text(
                    producto.producto,
                  ), // 👈 Asegúrate que `producto.producto` no esté vacío
                );
              }).toList(),
              onChanged: (producto) {
                setState(() {
                  _productoSeleccionado = producto;
                  _precioController.text =
                      producto?.precio.toStringAsFixed(2) ?? '';
                  print('🟢 Seleccionado: ${producto?.producto}');
                  print('🟢 Precio: ${producto?.precio}');
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _precioController,
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
            // Dropdown(
            //   label: 'Elemento a Colar',
            //   selectedValue: '',
            //   items: ['a', 'b', 'c'],
            //   onChanged: (newValue) {
            //     // setState(() {
            //     //   _selectedPro = newValue;
            //     // });
            //   },
            // ),
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
            // Dropdown(
            //   label: 'Tipo Bomba',
            //   selectedValue: '',
            //   items: ['a', 'b'],
            //   onChanged: (newValue) {
            //     // setState(() {
            //     //   _selectedPro = newValue;
            //     // });
            //   },
            // ),
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
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Subtotal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              enabled: false,
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
                //print('Nuevo tiempo ingresado: $val');
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
            ElevatedButton(
              onPressed: () {
                print('¡Botón presionado!');
              },
              child: Text('Guardar'),
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
        // _selectedFP == null ||
        // _selectedPro == null ||
        // cotizacion.isEmpty ||
        _fechaEntrega == null ||
        // _horaLlegada == null ||
        cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    } else {
      showDialog(
        context: context,
        barrierDismissible: false, // Para evitar que el usuario lo cierre antes
        builder: (context) {
          // Inicia el temporizador apenas se construya el modal
          Future.delayed(const Duration(seconds: 3), () {
            // Cerrar el diálogo actual y redirigir
            Navigator.of(context)
              ..pop() // Cierra el AlertDialog
              ..pushReplacement(
                MaterialPageRoute(builder: (_) => const Pedidos()),
              );
          });

          return AlertDialog(
            title: const Text('Pedido Registrado'),
            content: Text('El pedido fue guardado exitosamente.\n'),
          );
        },
      );
    }

    final fechaStr = DateFormat('yyyy-MM-dd').format(_fechaEntrega!);
    final horaStr = _horaLlegada!.format(context);

    final pedidoData = {
      "planta": _selectedPlanta,
      "formaPago": _selectedFP,
      "producto": '_selectedPro',
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
                    // _selectedPro = null;
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
