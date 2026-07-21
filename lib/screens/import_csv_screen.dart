import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../models/expense.dart';
import '../db/database_helper.dart';

class ImportCsvScreen extends StatefulWidget {
  const ImportCsvScreen({super.key});

  @override
  State<ImportCsvScreen> createState() => _ImportCsvScreenState();
}

class _ImportCsvScreenState extends State<ImportCsvScreen> {
  List<List<dynamic>>? _rows;
  List<String> _headers = [];

  String? _titleCol;
  String? _amountCol;
  String? _categoryCol;
  String? _dateCol;
  String _defaultCurrency = 'USD';
  String _defaultCategory = 'Imported';

  bool _importing = false;
  String? _resultMessage;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final content = utf8.decode(result.files.single.bytes!);
    final parsed = const CsvToListConverter().convert(content, eol: '\n');

    if (parsed.isEmpty) {
      setState(() => _resultMessage = 'File appears to be empty.');
      return;
    }

    setState(() {
      _headers = parsed.first.map((h) => h.toString()).toList();
      _rows = parsed.skip(1).toList();
      _resultMessage = null;
      // Best-effort auto-guess based on common header names
      _titleCol = _guessColumn(['title', 'description', 'name', 'memo']);
      _amountCol = _guessColumn(['amount', 'value', 'debit', 'total']);
      _categoryCol = _guessColumn(['category', 'type']);
      _dateCol = _guessColumn(['date', 'transaction date']);
    });
  }

  String? _guessColumn(List<String> candidates) {
    for (final h in _headers) {
      final lower = h.toLowerCase().trim();
      if (candidates.contains(lower)) return h;
    }
    return null;
  }

  DateTime? _parseDate(String raw) {
    final direct = DateTime.tryParse(raw);
    if (direct != null) return direct;

    // Try common alternate formats: dd/MM/yyyy, MM/dd/yyyy, dd-MM-yyyy
    final parts = raw.split(RegExp(r'[/-]'));
    if (parts.length == 3) {
      final a = int.tryParse(parts[0]);
      final b = int.tryParse(parts[1]);
      final c = int.tryParse(parts[2]);
      if (a != null && b != null && c != null) {
        // Assume dd/MM/yyyy if first part > 12
        if (a > 12) {
          return DateTime.tryParse('$c-${b.toString().padLeft(2, '0')}-${a.toString().padLeft(2, '0')}');
        }
        // Otherwise assume MM/dd/yyyy
        return DateTime.tryParse('$c-${a.toString().padLeft(2, '0')}-${b.toString().padLeft(2, '0')}');
      }
    }
    return null;
  }

  Future<void> _import() async {
    if (_rows == null || _titleCol == null || _amountCol == null) {
      setState(() => _resultMessage = 'Please map at least Title and Amount columns.');
      return;
    }

    setState(() => _importing = true);

    final titleIdx = _headers.indexOf(_titleCol!);
    final amountIdx = _headers.indexOf(_amountCol!);
    final categoryIdx = _categoryCol != null ? _headers.indexOf(_categoryCol!) : -1;
    final dateIdx = _dateCol != null ? _headers.indexOf(_dateCol!) : -1;

    final List<Expense> toImport = [];
    int skipped = 0;

    for (final row in _rows!) {
      try {
        final title = row[titleIdx].toString().trim();
        final amountRaw = row[amountIdx].toString().replaceAll(',', '').trim();
        final amount = double.tryParse(amountRaw);

        if (title.isEmpty || amount == null) {
          skipped++;
          continue;
        }

        final category = categoryIdx >= 0 && categoryIdx < row.length
            ? row[categoryIdx].toString().trim()
            : _defaultCategory;

        DateTime date = DateTime.now();
        if (dateIdx >= 0 && dateIdx < row.length) {
          final parsedDate = _parseDate(row[dateIdx].toString().trim());
          if (parsedDate != null) date = parsedDate;
        }

        toImport.add(Expense(
          title: title,
          amount: amount.abs(),
          category: category.isEmpty ? _defaultCategory : category,
          currency: _defaultCurrency,
          date: date,
        ));
      } catch (_) {
        skipped++;
      }
    }

    final count = await DatabaseHelper.instance.insertExpenses(toImport);

    setState(() {
      _importing = false;
      _resultMessage = 'Imported $count expenses. Skipped $skipped rows.';
    });
  }

  Widget _columnDropdown(String label, String? value, ValueChanged<String?> onChanged, {bool required = false}) {
    return DropdownButtonFormField<String>(
      value: value,
      items: [
        if (!required) const DropdownMenuItem(value: null, child: Text('None')),
        ..._headers.map((h) => DropdownMenuItem(value: h, child: Text(h))),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import CSV')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Choose CSV File'),
            ),
            const SizedBox(height: 16),
            if (_headers.isNotEmpty) ...[
              Text('Map columns (${_rows!.length} rows found)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _columnDropdown('Title column *', _titleCol, (v) => setState(() => _titleCol = v), required: true),
              const SizedBox(height: 8),
              _columnDropdown('Amount column *', _amountCol, (v) => setState(() => _amountCol = v), required: true),
              const SizedBox(height: 8),
              _columnDropdown('Category column (optional)', _categoryCol, (v) => setState(() => _categoryCol = v)),
              const SizedBox(height: 8),
              _columnDropdown('Date column (optional)', _dateCol, (v) => setState(() => _dateCol = v)),
              const SizedBox(height: 16),
              _importing
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _import,
                      child: const Text('Import Expenses'),
                    ),
            ],
            if (_resultMessage != null) ...[
              const SizedBox(height: 16),
              Text(_resultMessage!, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }
}
