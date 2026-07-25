class ApiConstants {
  static const String baseUrl = "http://192.168.1.2:5000/api/v1";

  // Student
  static const studentRegister = "${baseUrl}/auth/student/register";
  static const studentLogin = "${baseUrl}/auth/student/login";
  static const studentProfile = "${baseUrl}/auth/student/profile";

  // Organiser
  static const organiserRegister = "${baseUrl}/auth/organiser/register";
  static const organiserLogin = "${baseUrl}/auth/organiser/login";
  static const organiserProfile = "${baseUrl}/auth/organiser/profile";

  // Clubs
  static const clubs = "/clubs";
}