import 'package:flutter/material.dart';

// , aparte cuando lo mantengo presionado se elimina, en ves de eliminarse deberia permitirme editarlo llevandome a la misma pestaña de editar como la q tiene

class GastosProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _gastos = [];
  List<String> _responsables = [];

  List<Map<String, dynamic>> get gastos => _gastos;
  List<String> get responsables => _responsables;

  void agregarGasto(Map<String, dynamic> gasto) {
    _gastos.add({...gasto, 'subGastos': []});
    notifyListeners();
  }

  void editarGasto(int index, Map<String, dynamic> gastoEditado) {
    _gastos[index] = {
      ...gastoEditado,
      'subGastos': List<Map<String, dynamic>>.from(_gastos[index]['subGastos'])
    };
    notifyListeners();
  }

  void eliminarGasto(int index) {
    _gastos.removeAt(index);
    notifyListeners();
  }

  void agregarSubGasto(int gastoIndex, Map<String, dynamic> subGasto) {
    _gastos[gastoIndex]['subGastos'].add(subGasto);
    _gastos[gastoIndex] = {
      ..._gastos[gastoIndex],
      'subGastos': List<Map<String, dynamic>>.from(_gastos[gastoIndex]['subGastos'])
    };
    notifyListeners();
  }

  void eliminarSubGasto(int gastoIndex, int subGastoIndex) {
    _gastos[gastoIndex]['subGastos'].removeAt(subGastoIndex);
    _gastos[gastoIndex] = {
      ..._gastos[gastoIndex],
      'subGastos': List<Map<String, dynamic>>.from(_gastos[gastoIndex]['subGastos'])
    };
    notifyListeners();
  }

  void agregarResponsable(String responsable) {
    _responsables.add(responsable);
    notifyListeners();
  }
}
