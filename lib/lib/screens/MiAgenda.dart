import 'package:flutter/material.dart';
import 'package:spamascotas/lib/utils/Event.dart';
import 'package:spamascotas/lib/utils/EventDatabase.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class MiAgenda extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<MiAgenda> {
  late List<Event> allEvents;
  late Map<DateTime, List<Event>> eventsMap;

  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  TextEditingController _eventController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _celularController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allEvents = [];
    eventsMap = {};
    loadAllEvents();
  }

  Future<void> loadAllEvents() async {
    final events = await EventDatabase.instance.getAllEvents();
    setState(() {
      allEvents = events;
      eventsMap = _groupEventsByDate(events);
    });
  }

  Map<DateTime, List<Event>> _groupEventsByDate(List<Event> events) {
    Map<DateTime, List<Event>> map = {};
    for (var event in events) {
      DateTime date = event.date;
      if (map[date] == null) {
        map[date] = [event];
      } else {
        map[date]!.add(event);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis citas"),
        centerTitle: true,
        automaticallyImplyLeading: false, // Esto quita la flecha de retroceso
        actions: [
          IconButton(
            onPressed: () => _showCreateEventDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'es_ES',
            focusedDay: selectedDay,
            firstDay: DateTime(1990),
            lastDay: DateTime(2050),
            calendarFormat: format,
            onFormatChanged: (CalendarFormat _format) {
              setState(() {
                format = _format;
              });
            },
            startingDayOfWeek: StartingDayOfWeek.sunday,
            daysOfWeekVisible: true,
            eventLoader: (date) {
              return eventsMap[date] ?? [];
            },
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.purpleAccent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5.0),
              ),
              formatButtonTextStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
            onDaySelected: (DateTime selectDay, DateTime focusDay) {
              setState(() {
                selectedDay = selectDay;
                focusedDay = focusDay;
              });
            },
            selectedDayPredicate: (DateTime date) {
              return isSameDay(selectedDay, date);
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: eventsMap[selectedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                Event event = eventsMap[selectedDay]![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.pets),
                      title: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(event.description),
                      onTap: () => _showEventDetailsDialog(context, event),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Crear Cita",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: _eventController,
                label: 'Título',
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _descriptionController,
                label: 'Descripción',
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre',
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _celularController,
                label: 'Celular',
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancelar",
              style: TextStyle(
                color: Colors.red, // Cambia el color del texto del botón
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _createEvent(context),
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _createEvent(BuildContext context) {
    if (_eventController.text.isNotEmpty) {
      final event = Event(
        title: _eventController.text,
        description: _descriptionController.text,
        date: selectedDay,
        nombre: _nombreController.text,
        celular: _celularController.text,
      );
      EventDatabase.instance.createEvent(event).then((_) {
        setState(() {
          if (eventsMap[selectedDay] != null) {
            eventsMap[selectedDay]!.add(event);
          } else {
            eventsMap[selectedDay] = [event];
          }
        });
      });
    }
    Navigator.pop(context);
    _eventController.clear();
    _descriptionController.clear();
    _nombreController.clear();
    _celularController.clear();
  }

  void _showEventDetailsDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Detalles de la Cita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Colors.blue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título: ${event.title}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Descripción: ${event.description}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Nombre: ${event.nombre}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Celular: ${event.celular}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Fecha: ${event.date.day}/${event.date.month}/${event.date.year}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _launchWhatsApp(event.celular),
                  child: const Text(
                    'WhatsApp',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.green,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _callNumber(event.celular),
                  child: const Text(
                    'Llamar',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchWhatsApp(String phoneNumber) async {
    String url = "https://wa.me/$phoneNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir WhatsApp.';
    }
  }

  void _callNumber(String phoneNumber) {
    FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
}
