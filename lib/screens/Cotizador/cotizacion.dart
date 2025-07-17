import 'package:catsa/model/cotizador.dart';
import 'package:catsa/model/planta.dart';
import 'package:catsa/model/producto.dart';
import 'package:catsa/model/productoC.dart';
import 'package:catsa/service/api.dart' as ApiService;
import 'package:catsa/widgets/accordeon.dart';
import 'package:catsa/widgets/detalle_producto.dart';
import 'package:catsa/widgets/divisor.dart';
import 'package:catsa/widgets/dropdown.dart';
import 'package:catsa/widgets/input_button.dart';
import 'package:catsa/widgets/producto_cotizado.dart';
import 'package:flutter/material.dart';
import 'package:catsa/core/app_color.dart';

class Cotizacion extends StatefulWidget {
  const Cotizacion({super.key});

  @override
  _CotizacionState createState() => _CotizacionState();
}

class _CotizacionState extends State<Cotizacion> {
  Planta? _selectedPlanta;
  List<Planta> _plantas = [];
  bool _isLoading = true;
  //----------------------------------------------------------------------------
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final TextEditingController _cotizacionController = TextEditingController();
  String? _selectedF;
  final List<String> _f = [
    'Base de Datos',
    'Llamada Catsa',
    'Referido',
    'Referido Interno',
    'Visita en Planta',
    'Visita en Obra',
    'WebSite CATSA',
  ];
  String? _selectedSeg;
  final List<String> _segmento = [
    'Vivienda',
    'Comercial',
    'Industrial',
    'Pavimentos',
    'Infraestructura',
  ];

  String? _selectedTC;
  final List<String> _tc = ['Constructor', 'Revendedor'];

  List<Producto> productos = [];

  final List<ProductoC> _todosLosProductos = [
    ProductoC(producto: 'Concreto premezclado', precio: 0),
    ProductoC(producto: 'Grava 3/4', precio: 0),
    ProductoC(producto: 'Arena fina', precio: 0),
    ProductoC(producto: 'Cemento Portland', precio: 0),
    ProductoC(producto: 'Concreto premezclado', precio: 0),
    ProductoC(producto: 'Grava 3/4', precio: 0),
    ProductoC(producto: 'Arena fina', precio: 0),
    ProductoC(producto: 'Cemento Portland', precio: 0),
    ProductoC(producto: 'Concreto premezclado', precio: 0),
    ProductoC(producto: 'Grava 3/4', precio: 0),
    ProductoC(producto: 'Arena fina', precio: 0),
    ProductoC(producto: 'Cemento Portland', precio: 0),
    ProductoC(producto: 'Concreto premezclado', precio: 0),
    ProductoC(producto: 'Grava 3/4', precio: 0),
    ProductoC(producto: 'Arena fina', precio: 0),
    ProductoC(producto: 'Cemento Portland', precio: 0),
  ]; // Lista original (API o local)
  List<ProductoC> _productosSeleccionados = [];

  //----------------------------------------------------------------------------
  Cotizador? _cotizacionResult;
  DateTime? _fechaNacimiento;
  double _valorSlider = 5;
  bool _terminosAceptados = false;

  //------------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadPlantas();
    productos = [
      Producto(
        producto: 'C300N',
        cantidad: 5.0,
        m3Bomba: 1.0,
        bomba: 500,
        mop: 120,
        precio: 1500,
        flagVoBo: true,
        autoriza: 1,
        comentario: 'Prueba',
        flg: false,
        flagImprimir: true,
        mb: 5.5,
      ),
    ];
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  void _enviarFormulario() {
    if (_formKey.currentState!.validate() && _terminosAceptados) {
      // Procesar los datos del formulario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Formulario enviado: ${_nombreController.text}'),
        ),
      );
    } else if (!_terminosAceptados) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
        ),
      );
    }
  }

  void _mostrarSelectorDeProductos() async {
    final List<Producto> seleccionados = await showDialog(
      context: context,
      builder: (context) {
        Set<String> seleccionTemp = _productosSeleccionados
            .map((p) => p.producto)
            .toSet();
        return AlertDialog(
          title: const Text('Selecciona productos'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: _todosLosProductos.map((producto) {
                final isSelected = seleccionTemp.contains(producto.producto);
                return CheckboxListTile(
                  title: Text(producto.producto),
                  value: isSelected,
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        print(producto.producto);
                        seleccionTemp.add(producto.producto);
                      } else {
                        seleccionTemp.remove(producto.producto);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context, _productosSeleccionados),
            ),
            ElevatedButton(
              child: const Text('Aceptar'),
              onPressed: () {
                final seleccionFinal = _todosLosProductos
                    .where((p) => seleccionTemp.contains(p.producto))
                    .toList();
                Navigator.pop(context, seleccionFinal);
              },
            ),
          ],
        );
      },
    );

    setState(() {
      _productosSeleccionados = seleccionados.cast<ProductoC>();
    });
  }

  void _mostrarExtras() async {
    String selectedDropdown = 'Tipo A';
    String inputValue = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona Extra'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // importante para evitar overflow
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Extra",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),

                    DropdownButtonFormField<String>(
                      value: selectedDropdown,
                      items: const [
                        DropdownMenuItem(
                          value: 'Tipo A',
                          child: Text('Tipo A'),
                        ),
                        DropdownMenuItem(
                          value: 'Tipo B',
                          child: Text('Tipo B'),
                        ),
                        DropdownMenuItem(
                          value: 'Tipo C',
                          child: Text('Tipo C'),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedDropdown = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tipo de extra',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      initialValue: inputValue,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setStateDialog(() {
                          inputValue = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Text("ALGO AQU IVA "),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                print('Tipo seleccionado: $selectedDropdown');
                print('Cantidad ingresada: $inputValue');
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotización'),
        backgroundColor: const Color(0xFF0D0F57),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _enviarFormulario();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<Planta>(
                  value: _selectedPlanta,
                  decoration: const InputDecoration(
                    labelText: 'Planta',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.factory),
                  ),
                  hint: const Text('Selecciona una planta'),
                  items: _plantas.map((Planta planta) {
                    return DropdownMenuItem<Planta>(
                      value: planta,
                      child: Text(planta.nombre),
                    );
                  }).toList(),
                  onChanged: (Planta? newValue) {
                    setState(() {
                      _selectedPlanta = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor selecciona una planta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
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
                        } else {
                          // Maneja caso de resultado vacío
                          //print('No se encontró cotización');
                        }
                      } catch (e) {
                        //print('Error al obtener cotización: $e');
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
                InputWithIconButton(
                  label: 'Cliente',
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
                        } else {
                          // Maneja caso de resultado vacío
                          //print('No se encontró cotización');
                        }
                      } catch (e) {
                        //print('Error al obtener cotización: $e');
                      }
                    }
                  },
                ),
                Text('Cliente seleccionado'),
                const SizedBox(height: 0),
                InputWithIconButton(
                  label: 'Obra',
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
                        } else {
                          // Maneja caso de resultado vacío
                          //print('No se encontró cotización');
                        }
                      } catch (e) {
                        //print('Error al obtener cotización: $e');
                      }
                    }
                  },
                ),
                Text('Obra seleccionado'),
                const SizedBox(height: 20),
                Dropdown(
                  label: 'Fuente',
                  selectedValue: _selectedF,
                  items: _f,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedF = newValue;
                    });
                  },
                ),
                const SizedBox(height: 3),
                Dropdown(
                  label: 'Segmento',
                  selectedValue: _selectedSeg,
                  items: _segmento,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSeg = newValue;
                    });
                  },
                ),
                const SizedBox(height: 3),
                Dropdown(
                  label: 'Tipo de Cliente',
                  selectedValue: _selectedTC,
                  items: _tc,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTC = newValue;
                    });
                  },
                ),
                CenteredDivider(title: 'PRODUCTO'),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar productos'),
                  onPressed: _mostrarSelectorDeProductos,
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap:
                      true, // Se adapta al contenido, no se expande infinito
                  physics:
                      const NeverScrollableScrollPhysics(), // Evita scroll propio
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return ProductoAccordion(
                      producto: producto,
                      onDetallePressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetalleProductoWidget(producto: producto),
                          ),
                        );
                      },
                    );
                  },
                ),
                ListView.builder(
                  shrinkWrap:
                      true, // Se adapta al contenido, no se expande infinito
                  physics:
                      const NeverScrollableScrollPhysics(), // Evita scroll propio
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return ProductoAccordion(
                      producto: producto,
                      onDetallePressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetalleProductoWidget(producto: producto),
                          ),
                        );
                      },
                    );
                  },
                ),
                CenteredDivider(title: 'EXTRAS'),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Extras'),
                  onPressed: _mostrarExtras,
                ),

                // Botón de enviar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _enviarFormulario,
                  child: const Text('ENVIAR FORMULARIO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
