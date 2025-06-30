import 'package:catsa/model/planta.dart';
import 'package:flutter/material.dart';
import 'package:catsa/core/app_color.dart';

class Cotizacion extends StatefulWidget {
  const Cotizacion({super.key});

  @override
  _CotizacionState createState() => _CotizacionState();
}

class _CotizacionState extends State<Cotizacion> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _fechaNacimiento;
  double _valorSlider = 5;
  bool _terminosAceptados = false;
  // En tu estado
  final List<Planta> _plantas = [
    Planta('PUE1', 'PUEBLA'),
    Planta('TLX1', 'TLAXCALA'),
    Planta('MEX1', 'MÉXICO'),
  ];
  Planta? _selectedPlanta;
  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1900),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotización'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0F57), Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                    print(
                      'Planta seleccionada: ${newValue?.id} - ${newValue?.nombre}',
                    );
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor selecciona una planta';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo de email con validación
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo de contraseña
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Selector de fecha
                InkWell(
                  onTap: () => _seleccionarFecha(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _fechaNacimiento != null
                          ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                          : 'Seleccionar fecha',
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nivel de satisfacción:'),
                    Slider(
                      value: _valorSlider,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: _valorSlider.round().toString(),
                      onChanged: (value) =>
                          setState(() => _valorSlider = value),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _terminosAceptados,
                      onChanged: (value) =>
                          setState(() => _terminosAceptados = value ?? false),
                    ),
                    const Expanded(
                      child: Text('Acepto los términos y condiciones'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

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
