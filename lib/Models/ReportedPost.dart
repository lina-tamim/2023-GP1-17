class ReportedPost {
  String? reportType;
  String? reason;
  String? reportDate;
  String? reportedItemId;
  String? status;
  String? docId;
  String? postedDate;
  String? userId;
  Map<String, dynamic>? data;

  ReportedPost({
    this.reportType,
    this.reason,
    this.reportDate,
    this.postedDate,
    this.reportedItemId,
    this.status,
    this.docId,
    this.data,
    this.userId,
  });

  ReportedPost.fromJson(Map<String, dynamic> json, String this.docId)
      : reportType = json['reportType'],
        reason = json['reason'],
        reportDate = json['reportDate'].toString(),
        postedDate = json['postedDate'].toString(),
        reportedItemId = json['reportedItemId'],
        userId = json['reportedUserId'],
        status = json['status'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'reportType': reportType,
      'reason': reason,
      'reportDate': reportDate,
      'postedDate': postedDate,
      'reportedItemId': reportedItemId,
      'status': status,
      'reportedUserId': userId,
    };
    return data;
  }
}
