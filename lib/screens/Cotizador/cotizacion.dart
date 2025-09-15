import 'package:catsa/model/clientes.dart';
import 'package:catsa/model/cotizador.dart';
import 'package:catsa/model/extras.dart';
import 'package:catsa/model/extra_serv.dart';
import 'package:catsa/model/obras.dart';
import 'package:catsa/model/planta.dart';
import 'package:catsa/model/plantaInfo.dart';
import 'package:catsa/model/productoC.dart';
import 'package:catsa/service/api.dart' as api_service;
import 'package:catsa/widgets/accordeon.dart';
import 'package:catsa/widgets/accordeon_extra.dart';
import 'package:catsa/widgets/detalle_producto.dart';
import 'package:catsa/widgets/divisor.dart';
import 'package:catsa/widgets/dropdown.dart';
import 'package:catsa/widgets/drop_planta.dart';
import 'package:catsa/widgets/input_button.dart';
import 'package:flutter/material.dart';

class Cotizacion extends StatefulWidget {
  const Cotizacion({super.key});

  @override
  _CotizacionState createState() => _CotizacionState();
}

class _CotizacionState extends State<Cotizacion> {
  Planta? _selectedPlanta;
  List<Planta> _plantas = [];
  bool _isLoading = true;
  List<Clientes> _clientes = [];
  List<Obras> _obras = [];
  List<ProductoC> _productos = [];
  List<ProductoC> _productosSeleccionados = [];
  List<ProductoC> productos = [];
  List<ProductoC> productosPlanta = [];
  List<PlantaInfo> _plantaInfo = [];
  //----------------------------------------------------------------------------
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final TextEditingController _cotizacionController = TextEditingController();
  final TextEditingController _obraController = TextEditingController();
  final TextEditingController _noobraController = TextEditingController();
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _clienteSeleccionado = TextEditingController();
  final TextEditingController _obraSeleccionado = TextEditingController();
  final TextEditingController _productoSeleccionado = TextEditingController();

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

  List<Extras> extras = [];
  List<ExtraServ> extra_serv = [];
  List<ExtraServ> extra_serv_pro = [];
  //----------------------------------------------------------------------------
  Cotizador? _cotizacionResult;
  String? _clienteResult;
  String? _obraResult;
  DateTime? _fechaNacimiento;
  double _valorSlider = 5;
  bool _terminos_aceptados = false;
  double _fijos = 0.0;
  double _corpo = 0.0;
  double _mop = 0.0;
  double _diesel = 0.0;
  double _indirecto = 0.0;
  double _comision = 0.5;
  //------------------------------------------------------------------------------
  ExtraServ? extraSeleccionado;
  TextEditingController idExtraController = TextEditingController();
  TextEditingController costoController = TextEditingController();
  TextEditingController cantMinController = TextEditingController();
  //------------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadPlantas();
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
      final plantas = await api_service.fPlantas();
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

  Future<void> _loadClientes() async {
    try {
      final clientes = await api_service.fClientes(_selectedPlanta?.id);
      setState(() {
        _clientes = clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadObras() async {
    try {
      final obras = await api_service.fObras(_selectedPlanta?.id);
      setState(() {
        _obras = obras;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProductos() async {
    try {
      final productos = await api_service.fProductosPlanta(_selectedPlanta?.id);
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

  Future<void> _loadCostoPlanta() async {
    try {
      final resultado = await api_service.fCostoPlanta(_selectedPlanta?.id);
      if (resultado != null) {
        // for (var producto in resultado.productos) {
        //   print('📦 Producto: ${producto.producto}');
        // }
        // for (var costo in resultado.costos) {
        //   print('💰 CPC: ${costo.cpc} 📆 Fecha: ${costo.fecha}');
        // }
        if (resultado.costos.isNotEmpty) {
          _loadInfoPlanta(
            _selectedPlanta?.id,
            resultado.costos[0].fecha,
            resultado.costos[0].cpc,
          );
          _fnComision(null);
        }
        setState(() {
          if (resultado.productos.isNotEmpty) {
            productosPlanta = resultado.productos;
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInfoPlanta(p, f, c) async {
    try {
      final infoPla = await api_service.fInfoPlanta(p, f, c);
      print("📦 ResultSet[0]: ${infoPla[0]}");
      print("📦 ResultSet[1]: ${infoPla[1]}");
      setState(() {
        final plantaData = infoPla[0][0];
        _fijos = plantaData["FIJOS"];
        _corpo = plantaData["CORPORATIVO"];
        _mop = plantaData["MOP"];
        _diesel = plantaData["DISEL"];
        _indirecto = _fijos + _corpo + _diesel;
        //extra_serv = [ExtraServ.fromJson(infoPla[1] as Map<String, dynamic>)];
        extra_serv = infoPla[1]
            .where((e) => (e['Nivel'] ?? 0) == 0) // 👈 filtra Motivo = 0
            .map((e) => ExtraServ.fromJson(e))
            .toList();
        extra_serv_pro = infoPla[1]
            .where((e) => (e['Nivel'] ?? 0) != 0) // 👈 filtra Motivo = 0
            .map((e) => ExtraServ.fromJson(e))
            .toList();
        print("✅ Extra_serv cargado: ${extra_serv.length} items");
        for (var e in extra_serv) {
          print(
            " -> ${e.IdExtra} | ${e.Descripcion} | ${e.Nivel} | ${e.Costo} | ${e.CantMin} ",
          );
        }
      });
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _fnComision(obra) async {
    final resultado = await api_service.fVolumenComision(
      _selectedPlanta?.id,
      obra,
    );
    if (resultado != null && resultado.volumen.isNotEmpty) {
      final p3min = resultado.volumen.first.p3min;
      setState(() {
        _comision = p3min;
      });
    } else {
      print('⚠️ No hay resultados');
    }
  }

  void _enviarFormulario() {
    if (_formKey.currentState!.validate() && _terminos_aceptados) {
      // Procesar los datos del formulario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Formulario enviado: ${_nombreController.text}'),
        ),
      );
    } else if (!_terminos_aceptados) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
        ),
      );
    }
  }

  void _mostrarSelectorDeProductos() async {
    final seleccionados = await showModalBottomSheet<List<ProductoC>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        List<ProductoC> productosFiltrados = [..._productos];
        List<String> seleccionTemp = _productosSeleccionados
            .map((p) => p.producto)
            .toList(); // Para mantener consistencia

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar producto',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        productosFiltrados = _productos
                            .where(
                              (p) => p.producto.toLowerCase().contains(
                                value.toLowerCase(),
                              ),
                            )
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: ListView(
                      children: productosFiltrados.map((producto) {
                        final isSelected = seleccionTemp.contains(
                          producto.producto,
                        );
                        return CheckboxListTile(
                          title: Text(producto.producto),
                          value: isSelected,
                          onChanged: (bool? checked) {
                            setModalState(() {
                              if (checked == true) {
                                seleccionTemp.add(producto.producto);
                                final productoSel = producto.producto;
                                final seleccionFinal = _productos
                                    .where(
                                      (p) => seleccionTemp.contains(p.producto),
                                    )
                                    .toList();
                                Navigator.pop(context, seleccionFinal);
                              } else {
                                seleccionTemp.remove(producto.producto);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (seleccionados != null) {
      setState(() {
        _productosSeleccionados = seleccionados;
      });
    }
    if (seleccionados != null) {
      setState(() {
        _productosSeleccionados = seleccionados;
      });
    }
  }

  void _mostrarExtras() async {
    String selectedDropdown = 'Tipo A';
    String inputValue = '';
    print('🩻 $extra_serv');
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Costos Extras'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value:
                          selectedDropdown.isNotEmpty &&
                              extra_serv.any(
                                (e) => e.IdExtra.toString() == selectedDropdown,
                              )
                          ? selectedDropdown
                          : null,
                      items: extra_serv.map((extraServ) {
                        return DropdownMenuItem<String>(
                          value: extraServ.IdExtra.toString(),
                          child: Text(
                            extraServ.Descripcion,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ), // 👈 lo que ve el usuario
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedDropdown = value ?? "";
                          extraSeleccionado = extra_serv.firstWhere(
                            (e) => e.IdExtra.toString() == selectedDropdown,
                            orElse: () => ExtraServ(
                              IdExtra: 0,
                              Costo: 0,
                              Descripcion: '',
                              CantMin: 0,
                              Nivel: 0,
                              Tipo: 0,
                              Unidad: '',
                              Observaciones: '',
                            ),
                          );
                          // actualizar el TextFormField con CantMin
                          cantMinController.text =
                              extraSeleccionado?.CantMin.toString() ?? '';
                          costoController.text =
                              extraSeleccionado?.Costo.toString() ?? '';
                          print(
                            "🎯 Seleccionado: ${extraSeleccionado?.IdExtra}",
                          );
                          print("💰 Costo: ${extraSeleccionado?.Costo}");
                          print("🧱 CantMin: ${extraSeleccionado?.CantMin}");
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Concepto',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: cantMinController,
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
                    Text("Costo: ${costoController.text}"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: costoController,
                            decoration: const InputDecoration(
                              labelText: 'Precio',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                final nuevoExtra = Extras(
                  concepto: selectedDropdown,
                  cantidad: 5,
                  descripcion: "-",
                );
                setState(() {
                  extras.add(nuevoExtra);
                });
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
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
            icon: const Icon(Icons.add),
            onPressed: () {
              _enviarFormulario();
            },
          ),
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
                const SizedBox(height: 10),
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
                      _loadClientes();
                      _loadObras();
                      _loadProductos();
                      _loadCostoPlanta();
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
                        final resultado = await api_service.fCotizacion(
                          _cotizacionController.text,
                        );
                        if (resultado.isNotEmpty) {
                          final cot = resultado.first;
                          final plantaSeleccionada = _plantas.firstWhere(
                            (p) => p.id == cot.planta,
                            orElse: () => Planta(id: '', nombre: ''),
                          );
                          print('☠️💀☠️ $cot');
                          setState(() {
                            _cotizacionResult = cot;
                            _clienteController.text = cot.cliente;
                            _obraController.text = cot.obra;
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
                  controller: _clienteController,
                  icon: Icons.search,
                  onPressed: () async {
                    final Clientes? clienteSeleccionado =
                        await showDialog<Clientes>(
                          context: context,
                          builder: (context) {
                            String filtro = '';
                            List<Clientes> filtrados = _clientes;

                            return StatefulBuilder(
                              builder: (context, setStateDialog) {
                                return AlertDialog(
                                  title: const Text('Buscar Cliente'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        decoration: const InputDecoration(
                                          hintText: 'Buscar...',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          setStateDialog(() {
                                            filtro = value;
                                            filtrados = _clientes
                                                .where(
                                                  (c) => c.nombre
                                                      .toLowerCase()
                                                      .contains(
                                                        filtro.toLowerCase(),
                                                      ),
                                                )
                                                .toList();
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 200,
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                          itemCount: filtrados.length,
                                          itemBuilder: (context, index) {
                                            final cliente = filtrados[index];
                                            return ListTile(
                                              title: Text(cliente.nombre),
                                              onTap: () => Navigator.pop(
                                                context,
                                                cliente,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cerrar'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );

                    if (clienteSeleccionado != null) {
                      setState(() {
                        _clienteController.text = clienteSeleccionado.nombre;
                        //_clienteSeleccionado.text = clienteSeleccionado.toString(); // opcional
                      });
                    }
                  },
                ),
                Text('Cliente seleccionado:'),
                const SizedBox(height: 0),
                InputWithIconButton(
                  label: 'Obra',
                  controller: _obraController,
                  icon: Icons.search,
                  onPressed: () async {
                    final Obras? obraSeleccionada = await showDialog<Obras>(
                      context: context,
                      builder: (context) {
                        String filtro = '';
                        List<Obras> filtrados = _obras;
                        return StatefulBuilder(
                          builder: (context, setStateDialog) {
                            return AlertDialog(
                              title: const Text('Buscar Obra'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Buscar...',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      setStateDialog(() {
                                        filtro = value;
                                        filtrados = _obras
                                            .where(
                                              (c) =>
                                                  c.obra.toLowerCase().contains(
                                                    filtro.toLowerCase(),
                                                  ),
                                            )
                                            .toList();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 200,
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                      itemCount: filtrados.length,
                                      itemBuilder: (context, index) {
                                        final obras = filtrados[index];
                                        return ListTile(
                                          title: Text(obras.obra),
                                          onTap: () =>
                                              Navigator.pop(context, obras),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cerrar'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );

                    if (obraSeleccionada != null) {
                      setState(() {
                        _fnComision(obraSeleccionada.no_obra);
                        _obraController.text = obraSeleccionada.obra;
                        _noobraController.text = obraSeleccionada.no_obra;
                      });
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
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 600, // Máximo deseado
                  ),
                  child: ListView.builder(
                    shrinkWrap:
                        true, // Se adapta al contenido, no se expande infinito
                    physics:
                        const NeverScrollableScrollPhysics(), // Evita scroll propio
                    itemCount: _productosSeleccionados.length,
                    itemBuilder: (context, index) {
                      final producto = _productosSeleccionados[index];
                      final encontrado = _productosSeleccionados.firstWhere(
                        (p) => p.producto == producto.producto,
                        // ignore: cast_from_null_always_fails
                        orElse: () => null as ProductoC,
                      );
                      final isSelected = _productosSeleccionados.any(
                        (p) => p.producto == producto.producto,
                      );
                      return ProductoAccordion(
                        producto: encontrado,
                        mbminimo: _indirecto,
                        mop: _mop,
                        comision: _comision,
                        isSelected: isSelected,
                        onToggleSeleccion: () {
                          setState(() {
                            if (isSelected) {
                              _productosSeleccionados.removeWhere(
                                (p) => p.producto == producto.producto,
                              );
                            } else {
                              _productosSeleccionados.add(producto);
                            }
                          });
                        },
                        onDetallePressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetalleProductoWidget(producto: producto),
                            ),
                          );
                        },
                        onEliminar: () {
                          setState(() {
                            _productosSeleccionados.removeWhere(
                              (p) => p.producto == producto.producto,
                            );
                          });
                        },
                        onExtraSer: () {},
                      );
                    },
                  ),
                ),
                CenteredDivider(title: 'EXTRA SERVICIO'),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Extras'),
                  onPressed: _mostrarExtras,
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
                    itemCount: extras.length,
                    itemBuilder: (context, index) {
                      final extra = extras[index];
                      return ExtraAccordion(
                        extra: extra,
                        onDetallePressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) =>
                          //         DetalleProductoWidget(producto: extra),
                          //   ),
                          // );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: _enviarFormulario,
            child: const Text('ENVIAR FORMULARIO'),
          ),
        ),
      ),
    );
  }
}
