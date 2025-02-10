class Feedback {
  final String feedbackId;
  final String type;
  final String title;
  final String content;
  final String contact;
  final bool wantResponse;
    final String userId;

  Feedback({
        required this.feedbackId,
    required this.type,
    required this.title,
    required this.content,
    required this.contact,
        required this.userId,
    required this.wantResponse,
  });

  Map<String, dynamic> toJson() {
    return {
      'feedbackId':feedbackId,
      'type': type,
      'title': title,
      'content': content,
      'contact': contact,
      'wantResponse': wantResponse,
      'userId':userId,
    };
  }
}
