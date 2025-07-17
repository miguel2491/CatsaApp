import 'dart:convert';
import 'package:catsa/model/cotizador.dart';
import 'package:catsa/model/pedido.dart';
import 'package:catsa/model/producto.dart';
import 'package:catsa/service/api.dart' as ApiService;
import 'package:catsa/widgets/drop_planta.dart';
import 'package:catsa/widgets/drop_producto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/dropdown.dart';
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
  String estado = "N";

  Planta? _selectedPlanta;
  List<Planta> _plantas = [];
  bool _isLoading = true;

  String? _selectedFP;
  final List<String> _fp = ['Crédito', 'Contado', 'Anticipo'];

  String? _selectedTB;
  final List<String> _tb = [
    'Bomba Pluma',
    'Bomba Estacionaria',
    'Bomba Pluma Ext.',
    'Bomba Estacionaria Ext.',
  ];

  String? _selectedElemento;
  List<String> _elemento = [];

  List<Producto> _productos = [];
  Producto? _productoSeleccionado;

  final TextEditingController _precioConcretoController =
      TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioExtraController = TextEditingController();
  final TextEditingController _precioBombaController = TextEditingController();
  final TextEditingController _subtotalController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  final TextEditingController _m3viajeController = TextEditingController();
  final _tiempoRecorridoController = TextEditingController();
  final _tiempoDescargaController = TextEditingController();
  final _frecEnvioController = TextEditingController();
  final _comentariosController = TextEditingController();
  final _recibeController = TextEditingController();

  final TextEditingController _cotizacionController = TextEditingController();
  final TextEditingController _pedidoController = TextEditingController();
  DateTime? _fechaEntrega;
  TimeOfDay? _horaLlegada;

  Cotizador? _cotizacionResult;
  Pedido? _pedidoResult;

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
    _loadElementos();
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
        _plantas = plantas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProductos(String idc) async {
    setState(() {
      _isLoading = true;
      _productos = [];
      _productoSeleccionado = null; // 🔁 Resetea la selección anterior
    });
    setState(() => _isLoading = true);

    try {
      final productos = await ApiService.fProducto(idc);
      setState(() {
        _productos = productos;
        if (_productos.isNotEmpty) {
          //_productoSeleccionado = _productos.first;
          _precioConcretoController.text = '0.00';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadElementos() async {
    final elementos = await ApiService.fElemento(); // espera el Future
    setState(() {
      _elemento = elementos;
    });
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
            PlantaDropdown(
              plantas: _plantas,
              selectedPlanta: _selectedPlanta,
              onChanged: (planta) {
                setState(() {
                  _selectedPlanta = planta;
                });
              },
            ),
            const SizedBox(height: 12),
            InputWithIconButton(
              label: 'Pedido',
              controller: _pedidoController,
              icon: Icons.search,
              onPressed: () async {
                if (_pedidoController.text.isNotEmpty) {
                  try {
                    final resultado = await ApiService.fPedido(
                      _pedidoController.text,
                    );
                    if (resultado.isNotEmpty) {
                      final ped = resultado.first;
                      final plantaSeleccionada = _plantas.firstWhere(
                        (p) => p.id == ped.Planta,
                        orElse: () => Planta(id: '', nombre: ''),
                      );
                      setState(() {
                        estado = "A";
                        _pedidoResult = ped;
                        _selectedPlanta = plantaSeleccionada;
                        if (_fp.contains(ped.Pago)) {
                          _selectedFP = ped.Pago;
                        } else {
                          _selectedFP = null;
                        }
                        if (_tb.contains(ped.Bomba)) {
                          _selectedTB = ped.Bomba;
                        } else {
                          _selectedTB = null;
                        }
                        setState(() {
                          _selectedElemento = (ped.Elemento.trim().isNotEmpty)
                              ? ped.Elemento.trim()
                              : 'ALERON';
                        });
                        _precioConcretoController.text =
                            ped.PrecioProducto.toString();
                        _precioExtraController.text =
                            ped.PrecioExtra.toString();
                        _cantidadController.text = ped.Cantidad.toString();
                        _m3viajeController.text = ped.M3Viaje.toString();
                        _precioBombaController.text =
                            ped.PrecioBomba.toString();
                        _tiempoRecorridoController.text =
                            ped.TRecorrido.toString();
                        _tiempoDescargaController.text =
                            ped.TDescarga.toString();
                        _frecEnvioController.text = ped.Espaciado.toString();
                        _comentariosController.text =
                            ped.Observaciones.toString();
                        _recibeController.text = ped.Asesor.toString();
                        final fechaFormateada = DateFormat(
                          'yyyy-MM-dd',
                        ).format(_pedidoResult!.FechaHoraPedido);
                        _fechaEntrega = _pedidoResult?.FechaHoraPedido;
                        _horaLlegada = TimeOfDay.fromDateTime(
                          _pedidoResult!.FechaHoraPedido,
                        );
                        _recibeController.text = _pedidoResult!.Recibe
                            .toString();
                        final subtotal = ApiService.calcularSubtotalPed(
                          ped.PrecioProducto,
                          ped.PrecioBomba,
                          ped.Cantidad,
                          ped.PrecioExtra,
                        );
                        final total = ApiService.calcularTotalPed(subtotal);
                        _subtotalController.text = subtotal.toString();
                        _totalController.text = total.toString();
                        final tiempoR = ApiService.calcularTiempo(
                          ped.TRecorrido,
                        );
                        final tiempoD = ApiService.calcularTiempo(
                          ped.TDescarga,
                        );
                        final tiempoE = ApiService.calcularTiempo(
                          ped.Espaciado,
                        );
                        _tiempoRecorridoController.text = tiempoR;
                        _tiempoDescargaController.text = tiempoD;
                        _frecEnvioController.text = tiempoE;
                      });
                      if (ped.IdCotizacion == 0) {
                        setState(() => _isLoading = true);
                        final productoManual = Producto(
                          producto: ped.Producto,
                          cantidad: ped.Cantidad,
                          m3Bomba:
                              0, // Si es un objeto, asegúrate de tener la clase bien modelada
                          bomba: 0,
                          mop: 0,
                          precio: ped.PrecioProducto,
                          flagVoBo: true,
                          autoriza: 0,
                          comentario: '-',
                          flg: true,
                          flagImprimir: true,
                          mb: 0,
                        );
                        setState(() {
                          _productos = [productoManual];
                          _productoSeleccionado = productoManual;
                        });
                        _isLoading = false;
                      } else {
                        _loadProductos(ped.IdCotizacion.toString());
                      }
                      _cotizacionController.text = _pedidoResult!.IdCotizacion
                          .toString();
                    }
                  } catch (e) {
                    print('Error al obtener pedido: $e');
                  }
                }
              },
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            DetailTile(
              label: 'Cliente',
              value:
                  '${_pedidoResult?.NoCliente ?? _cotizacionResult?.noCliente ?? ''} ${_pedidoResult?.Nombre ?? _cotizacionResult?.cliente ?? ''}',
            ),
            const SizedBox(height: 12),
            DetailTile(
              label: 'Obra',
              value:
                  '${_pedidoResult?.NoObra ?? _cotizacionResult?.noObra ?? ''} ${_pedidoResult?.Obra ?? _cotizacionResult?.obra ?? ''}',
            ),
            const SizedBox(height: 12),
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
            ProductoDropdown(
              producto: _productos,
              selectedProducto: _productoSeleccionado,
              onChanged: (producto) {
                setState(() {
                  _productoSeleccionado = producto;
                  _precioConcretoController.text =
                      producto?.precio.toStringAsFixed(2) ?? '';
                });
              },
            ),
            Text(
              'Producto seleccionado: ${_productoSeleccionado?.producto ?? 'Ninguno'}',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _precioConcretoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Precio Concreto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _precioExtraController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Precio Extra',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Dropdown(
              label: 'Elemento a colar',
              selectedValue: _selectedElemento,
              items: _elemento,
              onChanged: (newValue) {
                setState(() {
                  _selectedElemento = newValue;
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
              selectedValue: _selectedTB,
              items: _tb,
              onChanged: (newValue) {
                setState(() {
                  _selectedTB = newValue;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _precioBombaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Precio Bombeo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subtotalController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Subtotal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _totalController,
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
              controller: _m3viajeController,
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
            const SizedBox(height: 12),
            TextField(
              controller: _recibeController,
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
    print("☠️ $estado");
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
