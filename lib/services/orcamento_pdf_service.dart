import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/orcamento.dart'; // ajuste o caminho

class OrcamentoPdfService {
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _data = DateFormat('dd/MM/yyyy');

  Future<File> gerarPdf({
    required Orcamento orc,
    required String nomeEmpresa,
    String? cnpj,
    String? telefoneEmpresa,
    String? enderecoEmpresa,
    String? observacoes,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (_) => [
          _cabecalho(
            nomeEmpresa: nomeEmpresa,
            cnpj: cnpj,
            telefoneEmpresa: telefoneEmpresa,
            enderecoEmpresa: enderecoEmpresa,
          ),
          pw.SizedBox(height: 16),
          _blocoOrcamento(orc),
          pw.SizedBox(height: 16),
          _tabelaItens(orc),
          pw.SizedBox(height: 16),
          _totais(orc),
          if (observacoes != null && observacoes.trim().isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _observacoes(observacoes),
          ],
          pw.SizedBox(height: 24),
          _rodapeAssinatura(),
        ],
      ),
    );

    final bytes = await doc.save();

    final dir = await getApplicationDocumentsDirectory();
    final safeNome = _sanitizeFileName('orcamento_${orc.id}_${_data.format(orc.data)}.pdf');
    final file = File('${dir.path}/$safeNome');

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  pw.Widget _cabecalho({
    required String nomeEmpresa,
    String? cnpj,
    String? telefoneEmpresa,
    String? enderecoEmpresa,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  nomeEmpresa,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                if (cnpj != null && cnpj.trim().isNotEmpty)
                  pw.Text('CNPJ/CPF: $cnpj'),
                if (telefoneEmpresa != null && telefoneEmpresa.trim().isNotEmpty)
                  pw.Text('Telefone: $telefoneEmpresa'),
                if (enderecoEmpresa != null && enderecoEmpresa.trim().isNotEmpty)
                  pw.Text('Endereço: $enderecoEmpresa'),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'ORÇAMENTO',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _blocoOrcamento(Orcamento orc) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Nº: ${orc.id}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Data: ${_data.format(orc.data)}'),
            ],
          ),
          if (orc.validade != null) pw.Text('Validade: ${_data.format(orc.validade!)}'),
          pw.SizedBox(height: 8),
          pw.Text('Cliente: ${orc.clienteNome}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (orc.clienteDocumento != null && orc.clienteDocumento!.trim().isNotEmpty)
            pw.Text('Documento: ${orc.clienteDocumento}'),
          if (orc.clienteTelefone != null && orc.clienteTelefone!.trim().isNotEmpty)
            pw.Text('Telefone: ${orc.clienteTelefone}'),
        ],
      ),
    );
  }

  pw.Widget _tabelaItens(Orcamento orc) {
    final headers = ['Descrição', 'Qtd', 'Vlr. Unit.', 'Total'];

    final rows = orc.itens.map((i) {
      final total = i.qtd * i.valorUnit;
      return [
        i.descricao,
        i.qtd.toStringAsFixed(_dec(i.qtd)),
        _moeda.format(i.valorUnit),
        _moeda.format(total),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      columnWidths: {
        0: const pw.FlexColumnWidth(3.5),
        1: const pw.FlexColumnWidth(1.0),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.2),
      },
    );
  }

  pw.Widget _totais(Orcamento orc) {
    pw.Widget linha(String label, String value, {bool bold = false}) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
          pw.Text(value, style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
        ],
      );
    }

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.ConstrainedBox(
        constraints: const pw.BoxConstraints(maxWidth: 260),
        child: pw.Column(
          children: [
            linha('Subtotal', _moeda.format(orc.subtotal)),
            if (orc.desconto > 0) linha('Desconto', '- ${_moeda.format(orc.desconto)}'),
            if ((orc.taxa ?? 0) > 0) linha('Taxa', _moeda.format(orc.taxa)),
            pw.Divider(),
            linha('Total', _moeda.format(orc.total), bold: true),
          ],
        ),
      ),
    );
  }

  pw.Widget _observacoes(String obs) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Observações', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(obs),
        ],
      ),
    );
  }

  pw.Widget _rodapeAssinatura() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 24),
        pw.Row(
          children: [
            pw.Expanded(child: pw.Divider()),
            pw.SizedBox(width: 12),
            pw.Text('Assinatura'),
            pw.SizedBox(width: 12),
            pw.Expanded(child: pw.Divider()),
          ],
        ),
      ],
    );
  }

  int _dec(double v) => (v % 1 == 0) ? 0 : 2;

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').replaceAll(' ', '_');
  }
}
