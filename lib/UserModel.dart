
 
class UserModel {
  final String userName;
  final String userType;
  final String attendancePreference; 
  final String country;
  final String state;
  final String city;
  final String email;
  final String password;
  final String GithubLink;
  final List<String> interests;
  final List<String> skills;

  UserModel({
    required this.userName,
    required this.userType,
    required this.attendancePreference,
    required this.country,
    required this.state,
    required this.city,
    required this.email,
    required this.password,
    required this.GithubLink,
    required this.interests,
    required this.skills,
  });

  

toJson(){
    return {
      'userName': userName,
      'userType': userType,
      'attendancePreference': attendancePreference,
      'country': country,
      'state': state,
      'city': city,
      'email': email,
      'password': password,
      'GithubLink': GithubLink,
      'interests': interests,
      'skills': skills,
    };
  }




}

