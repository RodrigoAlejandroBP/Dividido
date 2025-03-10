import 'package:flutter/material.dart';

class GastosProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _detalles = [];

  List<Map<String, dynamic>> get detalles => _detalles;

  void agregarGasto(Map<String, dynamic> gasto) {
    _detalles.add({...gasto, 'subGastos': []});
    notifyListeners();
  }

  void agregarSubGasto(int index, Map<String, dynamic> subGasto) {
    _detalles[index]['subGastos'].add(subGasto);
    notifyListeners();
  }

  void eliminarGasto(int index) {
    _detalles.removeAt(index);
    notifyListeners();
  }
}
