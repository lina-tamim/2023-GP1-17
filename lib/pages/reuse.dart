import 'package:flutter/material.dart';

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller, bool modifiable) {
  Color boxColor = modifiable
      ? Color.fromARGB(255, 200, 176, 185).withOpacity(0.3)
      : Color.fromARGB(255, 165, 165, 165);

  return TextField(
    enabled: modifiable,
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: const Color.fromARGB(255, 43, 3, 101),
    style: TextStyle(
      color: const Color.fromARGB(255, 1, 9, 111).withOpacity(0.9),
      fontSize: 14,
    ),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 63, 12, 118)),
      labelText: text,
      labelStyle: const TextStyle(
        color: Colors.black54,
      ),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: const Color.fromARGB(255, 228, 228, 228).withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        //borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

Widget NavBarAdmin() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero, // top
      children: [
        UserAccountsDrawerHeader(
          // +++++++++++++modify

          accountName: Text('Lina-tamim'),
          accountEmail: Text('Linatamim@hotmail.com'),
          currentAccountPicture: CircleAvatar(
            child: ClipOval(
              child: Image.network(
                'https://img.freepik.com/free-icon/user_318-563642.jpg',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 218, 200, 255), // if img not show up
            image: DecorationImage(
              image: NetworkImage(
                  'https://4kwallpapers.com/images/walls/thumbs_2t/7898.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // profile
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Profile'),
          onTap: () => null, // change it to page name +++++++++++++++++
        ),

        // about us - contact us
        ListTile(
          leading: Icon(Icons.groups_2_rounded),
          title: Text('About Us'),
          onTap: () => null, // change it to page name +++++++++++++++++
        ),
        /*logout
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
          onTap: () => null, // change it to page name +++++++++++++++++
        ), */ //logout will be from user profile
      ],
    ),
  );
}

Widget NavBarUser() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero, // top
      children: [
        UserAccountsDrawerHeader(
          // +++++++++++++modify

          accountName: Text('Lina-tamim'),
          accountEmail: Text('Linatamim@hotmail.com'),
          currentAccountPicture: CircleAvatar(
            child: ClipOval(
              child: Image.network(
                'https://img.freepik.com/free-icon/user_318-563642.jpg',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 218, 200, 255), // if img not show up
            image: DecorationImage(
              image: NetworkImage(
                  'https://4kwallpapers.com/images/walls/thumbs_2t/7898.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // profile
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Profile'),
          onTap: () => null, // change it to page name +++++++++++++++++
        ),
        Divider(),
        // my Post
        ListTile(
          leading: Icon(Icons.post_add),
          title: Text('My Post'),
          onTap: () => null, // change it to page name +++++++++++++++++
        ),
        Divider(),

        // Bookmarke
        ListTile(
          leading: Icon(Icons.bookmark),
          title: Text('Bookmarke'),
          onTap: () => null, // change it to page name +++++++++++++++++
        ),
        Divider(),

        // calendar
        ListTile(
          leading: Icon(Icons.calendar_month),
          title: Text('Calendar'),
          onTap: () => null, // change it to page name +++++++++++++++++
        ),

        // about us - contact us
        ListTile(
          leading: Icon(Icons.groups_2_rounded),
          title: Text('About Us'),
          onTap: () => null, // change it to page name +++++++++++++++++
        ),
        //logout
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
          onTap: () => null, // change it to page name +++++++++++++++++
        ),
      ],
    ),
  );
}

AppBar buildAppBar(String titleText) {
  return AppBar(
    iconTheme: IconThemeData(color: const Color.fromARGB(255, 255, 255, 255)),
    backgroundColor: Color.fromRGBO(37, 6, 81, 0.898),
    toolbarHeight: 100, // Adjust the height of the AppBar
    elevation: 0, // Adjust the position of the AppBar
    shape: ContinuousRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(130),
        bottomRight: Radius.circular(130),
      ),
    ),
    title: Text(
      titleText,
      style: TextStyle(
        fontSize: 18, // Adjust the font size
        fontFamily: "Poppins",
        color: Colors.white,
      ),
    ),
  );
}
