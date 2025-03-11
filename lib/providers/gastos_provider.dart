import 'package:flutter/material.dart';

class GastosProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _gastos = [];
  List<String> _responsables = [];

  List<Map<String, dynamic>> get gastos => _gastos;
  List<String> get responsables => _responsables;

  void agregarGasto(Map<String, dynamic> gasto) {
    _gastos.add({
      ...gasto,
      'subGastos': [],
      'fecha': gasto['fecha'] ?? DateTime.now(),
      'etiquetas': gasto['etiquetas'] ?? [],
    });
    notifyListeners();
  }

  void editarGasto(int index, Map<String, dynamic> gastoEditado) {
    _gastos[index] = {
      ...gastoEditado,
      'subGastos': List<Map<String, dynamic>>.from(_gastos[index]['subGastos']),
      'fecha': gastoEditado['fecha'] ?? _gastos[index]['fecha'],
      'etiquetas': gastoEditado['etiquetas'] ?? _gastos[index]['etiquetas'],
    };
    notifyListeners();
  }

  void eliminarGasto(int index) {
    _gastos.removeAt(index);
    notifyListeners();
  }

  void agregarSubGasto(int gastoIndex, Map<String, dynamic> subGasto) {
    _gastos[gastoIndex]['subGastos'].add({
      ...subGasto,
      'esIndividual': subGasto['esIndividual'] ?? false, // Por defecto no individual
    });
    notifyListeners();
  }

  void eliminarSubGasto(int gastoIndex, int subGastoIndex) {
    _gastos[gastoIndex]['subGastos'].removeAt(subGastoIndex);
    notifyListeners();
  }

  void editarSubGasto(int gastoIndex, int subGastoIndex, Map<String, dynamic> subGastoEditado) {
    _gastos[gastoIndex]['subGastos'][subGastoIndex] = {
      ...subGastoEditado,
      'esIndividual': subGastoEditado['esIndividual'] ?? _gastos[gastoIndex]['subGastos'][subGastoIndex]['esIndividual'] ?? false,
    };
    notifyListeners();
  }

  void agregarResponsable(String responsable) {
    _responsables.add(responsable);
    notifyListeners();
  }

  Map<String, double> calcularTotalPorResponsable(Map<String, dynamic> gasto) {
    Set<String> responsables = {gasto['responsable'] as String};
    double totalPrecio = double.parse(gasto['precio'].toString());
    double totalGastoComun = totalPrecio;
    Map<String, double> gastosIndividuales = {};

    gastosIndividuales[gasto['responsable'] as String] = 0.0;

    final subGastos = (gasto['subGastos'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    for (var subGasto in subGastos) {
      String responsableSubGasto = subGasto['responsable'] as String;
      double precio = double.parse(subGasto['precio'].toString());
      bool esIndividual = subGasto['esIndividual'] as bool? ?? false;

      responsables.add(responsableSubGasto);

      if (esIndividual) {
        gastosIndividuales[responsableSubGasto] = (gastosIndividuales[responsableSubGasto] ?? 0) + precio;
        totalGastoComun -= precio;
      } else {
        double precioPorResponsable = precio / responsables.length;
        for (var responsable in responsables) {
          gastosIndividuales[responsable] = (gastosIndividuales[responsable] ?? 0) + precioPorResponsable;
        }
        totalGastoComun -= precio;
      }
    }

    double gastoComunPorPersona = (responsables.isNotEmpty && totalGastoComun > 0) ? totalGastoComun / responsables.length : 0.0;
    Map<String, double> totalPorResponsable = {};
    for (var responsable in responsables) {
      totalPorResponsable[responsable] = (gastosIndividuales[responsable] ?? 0) + gastoComunPorPersona;
    }

    return totalPorResponsable;
  }
}