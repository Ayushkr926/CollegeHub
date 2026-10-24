class ApiConstants {
  static const String baseUrl = "http://192.168.1.3:5000/api/v1";

  // Auth & profiles
  static const String authStudentRegister = "$baseUrl/auth/student/register";
  static const String authOrganiserRegister = "$baseUrl/auth/organiser/register";
  static const String authLogin = "$baseUrl/auth/login";
  static const String authOrganisers = "$baseUrl/auth/organisers";
  static const String authOrganisersAll = "$baseUrl/auth/organisers/all";
  static const String authProfile = "$baseUrl/auth/profile";
  static const String authMe = "$baseUrl/auth/me";
  static const String authStudentProfile = "$baseUrl/auth/student/profile";
  static const String authOrganiserProfile = "$baseUrl/auth/organiser/profile";

  // Legacy compatibility aliases
  static const String studentRegister = authStudentRegister;
  static const String organiserRegister = authOrganiserRegister;
  static const String studentLogin = authLogin;
  static const String organiserLogin = "$baseUrl/auth/organiser/login";
  static const String studentProfile = authStudentProfile;
  static const String organiserProfile = authOrganiserProfile;

  // Clubs
  static const String clubs = "$baseUrl/clubs";

  // Events
  static const String events = "$baseUrl/events";
  static const String myEventRegistrations = "$baseUrl/events/registrations/me";

  // Notices
  static const String notices = "$baseUrl/notices";

  // Analytics
  static const String analyticsDashboard = "$baseUrl/analytics/dashboard";
  static const String analyticsCategory = "$baseUrl/analytics/category";
  static const String analyticsPublisher = "$baseUrl/analytics/publisher";
  static const String analyticsMonthly = "$baseUrl/analytics/monthly";
  static const String analyticsViews = "$baseUrl/analytics/views";
  static const String analyticsReadRate = "$baseUrl/analytics/read-rate";
  static const String analyticsEngagement = "$baseUrl/analytics/engagement";
}