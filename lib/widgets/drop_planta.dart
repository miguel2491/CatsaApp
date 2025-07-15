import 'package:flutter/material.dart';
import '../model/planta.dart';

// Widget reutilizable
class PlantaDropdown extends StatelessWidget {
  final List<Planta> plantas;
  final Planta? selectedPlanta;
  final ValueChanged<Planta?> onChanged;
  final String hintText;

  const PlantaDropdown({
    Key? key,
    required this.plantas,
    required this.selectedPlanta,
    required this.onChanged,
    this.hintText = 'Selecciona una planta',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Planta>(
          value: selectedPlanta,
          hint: Text(hintText, style: TextStyle(color: Colors.grey.shade600)),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
          style: TextStyle(color: Colors.black, fontSize: 16),
          items: plantas.map((planta) {
            return DropdownMenuItem<Planta>(
              value: planta,
              child: Text(planta.nombre),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
