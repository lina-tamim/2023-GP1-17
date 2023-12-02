 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:techxcel11/Models/CalendarModel.dart';
import 'package:techxcel11/Models/ReusedElements.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _currentIndex = 0;
  List<Color> _colorCollection = <Color>[];

  @override
  void initState() {
    super.initState();
    _initializeEventColor();
  }

 void _initializeEventColor() {
  _colorCollection.add(const Color(0xFF0F8644));
  _colorCollection.add(const Color(0xFF881FA9));
  _colorCollection.add(const Color(0xFF3F51B5));
  _colorCollection.add(const Color(0xFFD32F2F));
  _colorCollection.add(const Color(0xFF009688));
  _colorCollection.add(const Color(0xFF795548));
  _colorCollection.add(const Color(0xFFC2185B));
  _colorCollection.add(const Color(0xFF8BC34A));
  _colorCollection.add(const Color(0xFF607D8B));
}

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final DateTime lastDayOfMonth = DateTime(now.year, now.month + 30);
    return Scaffold(
      drawer: const NavBarUser(),
      appBar: buildAppBar('Calendar'),
      body: Padding(
        padding: const EdgeInsets.all(13),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              FutureBuilder<List<EventModel>>(
                future: _getEvents(firstDayOfMonth, lastDayOfMonth),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final events = snapshot.data!;
                    return Column(
                      children: [
                        // Calendar section

                        Container(
                          height: 390, // Set your desired height here
                          child: SfCalendar(
                            view: CalendarView.month,
                            initialDisplayDate: firstDayOfMonth,
                            minDate: firstDayOfMonth,
                            maxDate: lastDayOfMonth,
                            showNavigationArrow: true,
                            onSelectionChanged: _onSelectionChanged,
                            headerStyle: CalendarHeaderStyle(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              backgroundColor: Color.fromARGB(255, 14, 1, 65),
                            ),
                            backgroundColor: Colors.transparent,
                            dataSource: _getCalendarDataSource(events),
                            appointmentBuilder: (
                              BuildContext context,
                              CalendarAppointmentDetails details,
                            ) {
                              return Container();
                            },
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        // Display information about events for the selected day
                        Container(
                          padding: const EdgeInsets.all(3),
                          child: _buildSelectedDayEvents(events),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error retrieving events');
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSelectedDayEvents(List<EventModel> events) {
    final selectedDayEvents = _getSelectedDayEvents(events);
 


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: selectedDayEvents.map((event) {
        

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Location: ${event.location == '' ? 'Online' : event.location}',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Start Date: ${DateFormat.yMd().format(event.startDate)}',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'End Date: ${DateFormat.yMd().format(event.endDate)}',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      deleteEvent(event);
                    },
                    child: Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<EventModel> _getSelectedDayEvents(List<EventModel> events) {
    final selectedDate = _selectedDate ?? DateTime.now();

    return events.where((event) {
      return event.startDate.isBefore(selectedDate) &&
              event.endDate.isAfter(selectedDate) ||
          (event.startDate.year == selectedDate.year &&
              event.startDate.month == selectedDate.month &&
              event.startDate.day == selectedDate.day) ||
          (event.endDate.year == selectedDate.year &&
              event.endDate.month == selectedDate.month &&
              event.endDate.day == selectedDate.day);
    }).toList();
  }

  void deleteEvent(EventModel event) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('loggedInEmail') ?? '';
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Calendar')
              .where('my_id', isEqualTo: email)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs[0].id;
        await FirebaseFirestore.instance
            .collection('Calendar')
            .doc(docId)
            .delete();
        setState(() {
          // Update the UI or reload the events after deletion
        });
      }
    } catch (e) {
    }
  }

  void _onSelectionChanged(CalendarSelectionDetails details) {
    final selectedEvent = details.date;
    if (selectedEvent != null) {
      final selectedDayEvents = _getSelectedDayEvents(_selectedDayEvents);
      setState(() {
        _selectedDate = selectedEvent;
        _selectedDayEvents = selectedDayEvents;
      });
    }
  }

  DateTime? _selectedDate;
  List<EventModel> _selectedDayEvents = [];

  Future<List<EventModel>> _getEvents(
      DateTime startDate, DateTime endDate) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('loggedInEmail') ?? '';
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Calendar')
              .where('my_id', isEqualTo: email)
              .get();
      final List<EventModel> events = snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data();

        return EventModel(
          title: data['title'],
          startDate: DateTime.parse(data['startDate']),
          endDate: DateTime.parse(data['endDate']),
          location: data['location'],
          docId: data['docId'],
        );
      }).toList();

      return events;
    } catch (e) {
      return [];
    }
  }

  List<Appointment> _getAppointments(List<EventModel> events) {
    return events.map((event) {
      final int index = events.indexOf(event);
      final Color color = _colorCollection[index % _colorCollection.length];
      return Appointment(
        startTime: event.startDate,
        endTime: event.endDate,
        subject: event.title,
        notes: event.location,
        color: color,
      );
    }).toList();
  }

  DataSource _getCalendarDataSource(List<EventModel> events) {
    final List<Appointment> appointments = _getAppointments(events);
    return DataSource(appointments);
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    final appointment = appointments?[index];
    return appointment?.startTime ?? DateTime.now();
  }

  @override
  DateTime getEndTime(int index) {
    final appointment = appointments?[index];
    return appointment?.endTime ?? DateTime.now();
  }

  @override
  String getSubject(int index) {
    final appointment = appointments?[index];
    return appointment?.subject ?? '';
  }

  @override
  String getNotes(int index) {
    final appointment = appointments?[index];
    return appointment?.notes ?? '';
  }

  @override
  Color getColor(int index) {
    final appointment = appointments?[index];
    return appointment?.color ?? Colors.blue;
  }
}
 