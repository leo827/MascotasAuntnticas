import 'Cita.dart';

class CitasManager {
  static List<Cita> citas = [];

  static void agendarCita(Cita cita) {
    citas.add(cita);
  }

  static List<Cita> obtenerCitas() {
    return List.from(citas);
  }

  static void agregarCita(Cita nuevaCita) {
    citas.add(nuevaCita);
  }

  static void eliminarCita(Cita cita) {
    citas.remove(cita);
  }
}
