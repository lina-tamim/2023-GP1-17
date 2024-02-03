import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportedAccount extends StatefulWidget {
  const ReportedAccount({Key? key}) : super(key: key);
  @override
  State<ReportedAccount> createState() => _ReportedAccountState();
}

int _currentIndex = 0;
bool showSearchBar = false;
final searchController = TextEditingController();

class _ReportedAccountState extends State<ReportedAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Color.fromRGBO(37, 6, 81, 0.898),
        ),
        toolbarHeight: 100,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Backgrounds/bg11.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 0),
                  const Text(
                    'Reported Accounts',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Poppins",
                      color: Color.fromRGBO(37, 6, 81, 0.898),
                    ),
                  ),
                  const SizedBox(width: 100),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        showSearchBar = !showSearchBar;
                      });
                    },
                    icon: Icon(showSearchBar ? Icons.search_off : Icons.search),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              if (showSearchBar)
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                    ),
                    isDense: true,
                  ),
                  onChanged: (text) {
                    setState(() {});
                    // Handle search input changes
                  },
                ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TeXel',
                style: GoogleFonts.orbitron(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Image.asset('assets/Backgrounds/XlogoSmall.png'),
              const SizedBox(height: 30),
              Text(
                'Coming soon !',
                style: TextStyle(
                  fontFamily: 'AutofillHints.familyName',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 