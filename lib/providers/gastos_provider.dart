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
      'fecha': gasto['fecha'] ?? DateTime.now(), // Fecha por defecto: hoy
      'etiquetas': gasto['etiquetas'] ?? [], // Lista de etiquetas, por defecto vacía
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
    _gastos[gastoIndex]['subGastos'].add(subGasto);
    _gastos[gastoIndex] = {..._gastos[gastoIndex], 'subGastos': List<Map<String, dynamic>>.from(_gastos[gastoIndex]['subGastos'])};
    notifyListeners();
  }

  void eliminarSubGasto(int gastoIndex, int subGastoIndex) {
    _gastos[gastoIndex]['subGastos'].removeAt(subGastoIndex);
    _gastos[gastoIndex] = {..._gastos[gastoIndex], 'subGastos': List<Map<String, dynamic>>.from(_gastos[gastoIndex]['subGastos'])};
    notifyListeners();
  }

  void editarSubGasto(int gastoIndex, int subGastoIndex, Map<String, dynamic> subGastoEditado) {
    _gastos[gastoIndex]['subGastos'][subGastoIndex] = subGastoEditado;
    _gastos[gastoIndex] = {..._gastos[gastoIndex], 'subGastos': List<Map<String, dynamic>>.from(_gastos[gastoIndex]['subGastos'])};
    notifyListeners();
  }

  void agregarResponsable(String responsable) {
    _responsables.add(responsable);
    notifyListeners();
  }
}