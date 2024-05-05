class Event {
  final int? id;
  late final String title;
  late final String description;
  final DateTime date;
  late final String nombre; // Nuevo campo nombre
  late final String celular; // Nuevo campo celular

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.nombre,
    required this.celular,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'nombre': nombre, // Agregar nombre al mapa
      'celular': celular, // Agregar celular al mapa
    };
  }

  Event copy({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? nombre,
    String? celular,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      nombre: nombre ?? this.nombre, // Copiar nombre
      celular: celular ?? this.celular, // Copiar celular
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, title: $title, description: $description, date: $date, nombre: $nombre, celular: $celular}';
  }
}
