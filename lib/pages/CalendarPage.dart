//Full code, m s
//GP discussion
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:techxcel11/models/calendar.dart';
import 'package:techxcel11/pages/reuse.dart';
import 'package:intl/intl.dart';
//EDIT +CALNDER COMMIT

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _currentIndex = 0;
  List<Color> _colorCollection = <Color>[];
//retrive from calender db
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeEventColor();
  }

  void _initializeEventColor() {
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF881FA9));
    /*_colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF0F8644));*/
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: FutureBuilder<List<EventModel>>(
                future: _getEvents(firstDayOfMonth, lastDayOfMonth),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final events = snapshot.data!;
                    return SfCalendar(
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
                        backgroundColor: Colors.purple.shade100,
                      ),
                      monthViewSettings: MonthViewSettings(
                          showAgenda: true,
                          agendaStyle: AgendaStyle(
                            backgroundColor: Colors.grey.shade100,
                            appointmentTextStyle: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.black),
                            dateTextStyle: TextStyle(
                                fontStyle: FontStyle.normal,
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: Colors.black),
                            dayTextStyle: TextStyle(
                                fontStyle: FontStyle.normal,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
                          )),
                      dataSource: _getCalendarDataSource(events),
                      appointmentBuilder: (BuildContext context,
                          CalendarAppointmentDetails details) {
                        final List<Appointment> appointments =
                            details.appointments.toList().cast<Appointment>();

// Adjust the height as needed or use Expanded to fill available space
                        return ListView.builder(
                          itemCount: appointments.length,
                          shrinkWrap: false,
//physics: NeverScrollableScrollPhysics(), // Disable scrolling
                          itemBuilder: (BuildContext context, int index) {
                            final Appointment appointment = appointments[index];
                            final EventModel event = EventModel(
                              title: appointment.subject,
                              location: appointment.location ?? 'riyadh',
                              startDate: appointment.startTime,
                              endDate: appointment.endTime,
                            );
                            return Card(
                              child: ListTile(
                                dense: true,
                                title: Expanded(
                                  child: Text(event.title),
                                ),
                                trailing: ElevatedButton(
                                  autofocus: true,
                                  onPressed: () {
                                    print("@@@@ YOU PRESSED DELETE");
                                    deleteEvent(appointment);
                                  },
                                  child: Text("delete"),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error retrieving events');
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
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

  void deleteEvent(Appointment event) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('loggedInEmail') ?? '';
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Calendar')
              .where('my_id', isEqualTo: email)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final docIdd = snapshot.docs[0].id;
        await FirebaseFirestore.instance
            .collection('Calendar')
            .doc(docIdd)
            .delete();
        setState(() {
          // Update the UI or reload the events after deletion
        });
      }
    } catch (e) {
      // Handle error
      print('********Error deleting event: $e');
    }
  }

  void _onSelectionChanged(CalendarSelectionDetails details) {
    final selectedEvent = details.date;
    if (selectedEvent != null) {
      // You can now access the selected event and perform any desired actions
      print("*******$selectedEvent");
    }
  }

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
      print('*******Retrieved ${snapshot.docs.length} events');
      final List<EventModel> events = snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data();

        return EventModel(
          title: data['title'],
          startDate: DateTime.parse(data['start_date']),
          endDate: DateTime.parse(data['end_date']),
          location: data['location'],
          docId: data['docId'],
          //background:data['color'],
        );
      }).toList();

      return events;
    } catch (e) {
// Handle error
      print('Error retrieving events: $e');
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

  _DataSource _getCalendarDataSource(List<EventModel> events) {
    final List<Appointment> appointments = _getAppointments(events);
    return _DataSource(appointments);
  }
}

mixin data {}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
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
