enum RequestStatus { pending, accepted, declined }

class Request {
  final String id;
  final String name;
  final String branch;
  final int year;
  final String image;
  final String timeago;
  RequestStatus status;

  Request({
    required this.id,
    required this.name,
    required this.branch,
    required this.year,
    this.image = 'assets/images/onboarding.jpg',
    this.timeago = '1h ago',
    this.status = RequestStatus.pending,
  });
}