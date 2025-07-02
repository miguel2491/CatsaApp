import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

class FilePickerField extends StatefulWidget {
  final String label;
  final void Function(XFile?) onFilePicked;

  const FilePickerField({
    super.key,
    required this.label,
    required this.onFilePicked,
  });

  @override
  State<FilePickerField> createState() => _FilePickerFieldState();
}

class _FilePickerFieldState extends State<FilePickerField> {
  XFile? _selectedFile;

  Future<void> _pickFile() async {
    const allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

    final typeGroup = XTypeGroup(
      label: 'Documentos permitidos',
      extensions: allowedExtensions,
    );

    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      setState(() {
        _selectedFile = file;
      });
      widget.onFilePicked(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(widget.label),
        subtitle: Text(_selectedFile?.name ?? 'Ningún archivo seleccionado'),
        trailing: IconButton(
          icon: const Icon(Icons.attach_file),
          onPressed: _pickFile,
        ),
      ),
    );
  }
}
