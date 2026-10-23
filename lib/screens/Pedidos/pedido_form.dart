import 'dart:convert';
import 'dart:math' as console;
import 'package:catsa/model/cotizador.dart';
import 'package:catsa/model/pedido.dart';
import 'package:catsa/model/producto.dart';
import 'package:catsa/service/api.dart' as ApiService;
import 'package:catsa/service/offline_sync.dart' as ApiLocal;
import 'package:catsa/service/utils.dart' as utils;
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class PedidoForm extends StatefulWidget {
  const PedidoForm({super.key});

  @override
  State<PedidoForm> createState() => _PedidoFormState();
}

class _PedidoFormState extends State<PedidoForm> {
  String estado = "N";
  String _lat = "0.0";
  String _lon = "0.0";

  Planta? _selectedPlanta;
  List<Planta> _plantas = [];
  bool _isLoading = true;
  bool _isVisibleForm = false;
  bool mostrarBoton = false;
  bool _hPBomba = false;

  String? _selectedFP;
  final List<String> _fp = ['Crédito', 'Contado', 'Anticipo'];

  String? _selectedTB;
  final List<String> _tb = [
    '-',
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
  final TextEditingController _descripcionProductoController =
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

  final FocusNode _cantidadFocus = FocusNode();
  final FocusNode _pExtraFocus = FocusNode();
  final FocusNode _pBombaFocus = FocusNode();
  final FocusNode _m3ViajeFocus = FocusNode();
  final FocusNode _vForm = FocusNode();

  //Helpers
  bool _isEmpty(TextEditingController c) => c.text.trim().isEmpty;

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega ?? today,
      firstDate: today, // ⛔ no deja elegir fechas pasadas
      lastDate: DateTime(2100),
    );
    if (picked != null && picked.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes seleccionar una fecha pasada')),
      );
      return;
    } else if (picked != null) {
      setState(() {
        _fechaEntrega = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();

    final TimeOfDay initialTime =
        _horaLlegada ??
        (_fechaEntrega != null && _esHoy(_fechaEntrega!)
            ? _sumarHoras(now, 2)
            : now);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime, //_horaLlegada ?? TimeOfDay.now(),
    );

    if (picked == null) return;

    // ✅ Validación SOLO si es hoy
    if (_fechaEntrega != null && _esHoy(_fechaEntrega!)) {
      final DateTime nowDateTime = DateTime.now();
      final DateTime pickedDateTime = DateTime(
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        picked.hour,
        picked.minute,
      );

      final DateTime limite = nowDateTime.add(const Duration(hours: 2));

      if (pickedDateTime.isBefore(limite)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La hora debe ser al menos 2 horas después de la actual',
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      _horaLlegada = picked;
    });
  }

  bool _esHoy(DateTime fecha) {
    final DateTime now = DateTime.now();
    return fecha.year == now.year &&
        fecha.month == now.month &&
        fecha.day == now.day;
  }

  TimeOfDay _sumarHoras(TimeOfDay time, int horas) {
    final int totalMin = time.hour * 60 + time.minute + horas * 60;
    return TimeOfDay(hour: (totalMin ~/ 60) % 24, minute: totalMin % 60);
  }

  @override
  void initState() {
    super.initState();
    _obtenerLatLon();
    _loadPlantas();
    _loadElementos();
    _cantidadFocus.addListener(() {
      if (!_cantidadFocus.hasFocus) {
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
    _m3ViajeFocus.addListener(() {
      if (!_m3ViajeFocus.hasFocus) {
        _cM3Viaje();
      }
    });
    _vForm.addListener(() {
      validarYGuardar();
    });
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
      final plantas = await ApiService.getPlantas();
      setState(() {
        _plantas = plantas;
        _isLoading = false;
      });
    } catch (e, s) {
      print('❌ ERROR getPlantas: $e');
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
          _productoSeleccionado = _productos.first;
          print("💀 $_productoSeleccionado");
          _precioConcretoController.text =
              _productoSeleccionado?.precio.toStringAsFixed(2) ?? '';
          _descripcionProductoController.text =
              _productoSeleccionado?.descripcion ?? '';
          _cantidadController.text =
              _productoSeleccionado?.cantidad.toStringAsFixed(2) ?? '';
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

  Future<void> _getInfoCot(String? planta) async {
    try {
      final coti = await ApiService.fPlantas();
      print('☠️ $planta R= ${coti.toString()}');
    } catch (e) {
      print('$e');
    }
  }

  Future<void> savePedido() async {}

  void _calcularTotal() {
    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
    final precioC = double.tryParse(_precioConcretoController.text) ?? 0;
    final subtotal = cantidad * precioC;
    final iva = subtotal * 0.16;
    final total = subtotal + iva;
    print('Calculando con $cantidad');
    // aquí tu lógica
    _subtotalController.text = subtotal.toStringAsFixed(2);
    _totalController.text = total.toStringAsFixed(2);
  }

  void _cTotalExtra() {
    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
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
    _subtotalController.text = auxstF.toStringAsFixed(2);
    final auxT = auxstF * 0.16;
    final totalF = auxstF + auxT;
    _totalController.text = totalF.toStringAsFixed(2);
  }

  void _cTotalBomba() {
    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
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
    _subtotalController.text = auxST.toStringAsFixed(2);
    final auxT = auxST * 0.16;
    final totalF = auxST + auxT;
    _totalController.text = totalF.toStringAsFixed(2);
  }

  void _cM3Viaje() {
    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
    final cantidadViaje = double.tryParse(_m3viajeController.text) ?? 0;

    if (cantidad < cantidadViaje) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cantidad por viaje no puede ser mayor'),
        ),
      );
      mostrarBoton = false;
      return;
    } else {
      mostrarBoton = true;
    }
  }

  Future<Position?> obtenerUbicacion() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. ¿Servicio activo?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error('Activa la ubicación del dispositivo');
      return null;
    }

    // 2. Permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error('Permiso de ubicación denegado');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error('Permiso de ubicación bloqueado permanentemente');
      return null;
    }

    // 3. Obtener posición
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _obtenerLatLon() async {
    final position = await obtenerUbicacion();
    if (position == null) return;

    final lat = position.latitude;
    final lon = position.longitude;
    setState(() {
      _lat = lat.toString();
      _lon = lon.toString();
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
          if (mostrarBoton)
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
            InputWithIconButton(
              label: 'Cotización',
              controller: _cotizacionController,
              icon: Icons.search,
              onPressed: () async {
                if (_cotizacionController.text.isNotEmpty) {
                  try {
                    final int idCotizacion =
                        int.tryParse(_cotizacionController.text) ?? 0;
                    final resultado = await ApiService.fCotizacion(
                      idCotizacion,
                    );
                    final List<Cotizador> cotizaciones =
                        resultado['cotizacion'];
                    final List<Producto> productos = resultado['producto'];
                    if (resultado.isNotEmpty) {
                      final cot = cotizaciones.first;
                      print("👻 $cot");
                      if (cot.noObra != "" && cot.noObra.trim().isNotEmpty) {
                        _isVisibleForm = false;
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('AVISO'),
                            content: Text(
                              'LA COTIZACION NO CUENTA CON OBRA o CLIENTE AUN, NO VALIDA',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => {
                                  _isVisibleForm = true,
                                }, //Navigator.pop(context),
                                child: Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                        _cotizacionController.text = '';
                        setState(() {
                          _isVisibleForm = false;
                        });
                      }
                      final plantaSeleccionada = _plantas.firstWhere(
                        (p) => p.id == cot.planta,
                        orElse: () => Planta(id: '', planta: ''),
                      );
                      setState(() {
                        _cotizacionResult = cot;
                        _selectedPlanta = plantaSeleccionada;
                        _isVisibleForm = true;
                      });
                      _loadProductos(_cotizacionController.text);
                    } else {
                      // Maneja caso de resultado vacío
                      print('No se encontró cotización');
                    }
                  } catch (e) {
                    print('Error al obtener cotización: $e');
                  }
                } else {
                  setState(() {
                    _isVisibleForm = false;
                  });
                }
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
                        orElse: () => Planta(id: '', planta: ''),
                      );
                      setState(() {
                        estado = "A";
                        _pedidoResult = ped;
                        _selectedPlanta = plantaSeleccionada;
                        print(ped);
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
                          descripcion: ped.Descripcion,
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
            if (_isVisibleForm) ...[
              PlantaDropdown(
                plantas: _plantas,
                selectedPlanta: _selectedPlanta,
                onChanged: (planta) {
                  setState(() {
                    _selectedPlanta = planta;
                  });
                  _getInfoCot(planta?.planta);
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
              DetailTile(
                label: 'Dirección',
                value:
                    '${_cotizacionResult?.direccion ?? _cotizacionResult?.direccion ?? ''} ',
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
                    _descripcionProductoController.text =
                        producto?.descripcion ?? '';
                    _cantidadController.text =
                        producto?.cantidad.toStringAsFixed(2) ?? '';
                  });
                },
              ),
              const SizedBox(height: 12),
              DetailTile(
                label: 'Descripción',
                value: _descripcionProductoController.text.isNotEmpty
                    ? _descripcionProductoController.text
                    : 'Sin descripción',
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
                controller: _cantidadController,
                focusNode: _cantidadFocus,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Metros (m³)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _precioExtraController,
                focusNode: _pExtraFocus,
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
              Dropdown(
                label: 'Tipo Bomba',
                selectedValue: _selectedTB,
                items: _tb,
                onChanged: (newValue) {
                  setState(() {
                    _selectedTB = newValue;
                    if (newValue == '-') {
                      _hPBomba = false;
                      _precioBombaController.text = '0';
                    } else {
                      _hPBomba = true;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _precioBombaController,
                focusNode: _pBombaFocus,
                enabled: _hPBomba,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Precio Bombeo',
                  border: OutlineInputBorder(),
                  filled: !_hPBomba,
                  fillColor: Colors.grey.shade200,
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
                focusNode: _m3ViajeFocus,
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
                  //validarYGuardar();
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
                focusNode: _vForm,
                decoration: InputDecoration(
                  labelText: 'Recibe en Obra',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (mostrarBoton)
                ElevatedButton(
                  onPressed: () {
                    _guardarPedido();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D0F57), // color del botón
                    foregroundColor: Colors.white, // color del texto / iconos
                  ),
                  child: Text('Guardar'),
                ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  void validarYGuardar() {
    if (!validarForm()) {
      setState(() => mostrarBoton = false);
      return;
    }

    setState(() => mostrarBoton = true);
    //_guardarPedido();
  }

  bool validarForm() {
    if (_selectedPlanta == null) {
      _error('Selecciona una planta');
      return false;
    }

    if (_cotizacionController.text.trim().isEmpty) {
      _error('La cotización es obligatoria');
      return false;
    }

    if (_selectedFP == null) {
      _error('Selecciona la forma de pago');
      return false;
    }

    if (_precioConcretoController.text.trim().isEmpty) {
      _error('El precio del concreto es obligatorio');
      return false;
    }

    if (_cantidadController.text.trim().isEmpty) {
      _error('La cantidad es obligatoria');
      return false;
    }

    if (_selectedElemento == null) {
      _error('Selecciona el elemento');
      return false;
    }

    if (_m3viajeController.text.trim().isEmpty) {
      _error('Los m³ por viaje son obligatorios');
      return false;
    }

    if (_tiempoRecorridoController.text.trim().isEmpty) {
      _error('El tiempo de recorrido es obligatorio');
      return false;
    }

    if (_tiempoDescargaController.text.trim().isEmpty) {
      _error('El tiempo de descarga es obligatorio');
      return false;
    }

    if (_frecEnvioController.text.trim().isEmpty) {
      _error('La frecuencia de envío es obligatoria');
      return false;
    }

    if (_fechaEntrega == null) {
      _error('Selecciona la fecha de entrega');
      return false;
    }

    if (_horaLlegada == null) {
      _error('Selecciona la hora de llegada');
      return false;
    }

    // 🔥 Validación avanzada: fecha + hora válida
    final DateTime fechaHora = DateTime(
      _fechaEntrega!.year,
      _fechaEntrega!.month,
      _fechaEntrega!.day,
      _horaLlegada!.hour,
      _horaLlegada!.minute,
    );

    if (!fechaHora.isAfter(DateTime.now())) {
      _error('La fecha y hora deben ser futuras');
      return false;
    }

    return true;
  }

  void _guardarPedido() async {
    final prefs = await SharedPreferences.getInstance();
    final userApp = prefs.getString('userApp');
    final nPlanta = _selectedPlanta?.planta ?? '';
    final plantaEnvio = _selectedPlanta?.id ?? '';
    final prod = _productoSeleccionado?.producto ?? '';
    final fechaStr = DateFormat('yyyy-MM-dd').format(_fechaEntrega!);
    final horaStr = _horaLlegada!.format(context);
    final tRecorridoSeg = timeToSeconds(_tiempoRecorridoController.text);
    final tFrecuenciaSeg = timeToSeconds(_frecEnvioController.text);
    final tDescargaSeg = timeToSeconds(_tiempoDescargaController.text);

    final pedidoData = {
      "planta": plantaEnvio,
      "noobra": _pedidoResult?.NoObra ?? _cotizacionResult?.noObra ?? '',
      "producto": prod,
      "precioProducto": _precioConcretoController.text,
      "cantidad": _cantidadController.text,
      "codBomba": _selectedTB ?? "",
      "precioBomba": valueOrZero(_precioBombaController),
      "fechaHoraPedido": "$fechaStr $horaStr",
      "tRecorrido": tRecorridoSeg.toString(),
      "m3Viaje": _m3viajeController.text,
      "espaciado": tFrecuenciaSeg.toString(),
      "usuarioCreo": userApp,
      "tDescarga": tDescargaSeg.toString(),
      "hrSalida": "$fechaStr $horaStr",
      "precioExtra": valueOrZero(_precioExtraController),
      "observaciones": _comentariosController.text,
      "idPedido": valueOrZero(_pedidoController),
      "recibe": _recibeController.text,
      "elemento": _selectedElemento,
      "pago": _selectedFP,
      "UTM": "$_lat,$_lon",
      "plantaEnvio": plantaEnvio,
      "archivos": 1,
      "tiempoReal": "-",
      "distancia": "-",
      "idCotizacion": _cotizacionController.text,
      "statusEliminado": 0,
      "enviado": 0,
    };
    print(pedidoData);

    try {
      final int id = await ApiLocal.OfflineSync().insertPedido(pedidoData);

      debugPrint('✅ Pedido guardado con ID: $id');

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
    } catch (e) {
      debugPrint('❌ Error al guardar pedido: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el pedido')),
      );
    }
  }

  String valueOrZero(TextEditingController c) {
    return c.text.trim().isEmpty ? "0" : c.text.trim();
  }

  int timeToSeconds(String time) {
    if (time.trim().isEmpty) return 0;

    final parts = time.split(':');
    if (parts.length != 2) return 0;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;

    return (hours * 3600) + (minutes * 60);
  }
}
