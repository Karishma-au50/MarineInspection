class InspectionListResponse {
  final List<InspectionModelData> inspections;
  final InspectionSummary summary;

  InspectionListResponse({
    required this.inspections,
    required this.summary,
  });

  factory InspectionListResponse.fromJson(Map<String, dynamic> json) {
    return InspectionListResponse(
      inspections: (json['inspections'] as List<dynamic>?)
          ?.map((inspection) => InspectionModelData.fromJson(inspection))
          .toList() ??
          [],
      summary: InspectionSummary.fromJson(json['summary'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inspections': inspections.map((inspection) => inspection.toJson()).toList(),
      'summary': summary.toJson(),
    };
  }
}

class InspectionModelData {
  final String id;
  final String inspectionId;
  final String templateId;
  final String templateName;
  final Inspector inspectorId;
  final String inspectionDate;
  final String startTime;
  final String overallStatus;

  InspectionModelData({
    required this.id,
    required this.inspectionId,
    required this.templateId,
    required this.templateName,
    required this.inspectorId,
    required this.inspectionDate,
    required this.startTime,
    required this.overallStatus,
  });

  factory InspectionModelData.fromJson(Map<String, dynamic> json) {
    return InspectionModelData(
      id: json['_id'] ?? '',
      inspectionId: json['inspectionId'] ?? '',
      templateId: json['templateId'] ?? '',
      templateName: json['templateName'] ?? '',
      inspectorId: Inspector.fromJson(json['inspectorId'] ?? {}),
      inspectionDate: json['inspectionDate'] ?? '',
      startTime: json['startTime'] ?? '',
      overallStatus: json['overallStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'inspectionId': inspectionId,
      'templateId': templateId,
      'templateName': templateName,
      'inspectorId': inspectorId.toJson(),
      'inspectionDate': inspectionDate,
      'startTime': startTime,
      'overallStatus': overallStatus,
    };
  }

  // Helper methods for status checking
  bool get isCompleted => overallStatus.toLowerCase() == 'completed';
  bool get isPending => overallStatus.toLowerCase() == 'pending';
  bool get isInProgress => overallStatus.toLowerCase() == 'in-progress';

  // Helper method to get status color
  String get statusDisplayText {
    switch (overallStatus.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'in-progress':
        return 'In Progress';
      default:
        return overallStatus;
    }
  }
}

class Inspector {
  final String id;
  final String name;
  final String email;

  Inspector({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Inspector.fromJson(Map<String, dynamic> json) {
    return Inspector(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
    };
  }
}

class InspectionSummary {
  final int completed;
  final int pending;
  final int total;

  InspectionSummary({
    required this.completed,
    required this.pending,
    required this.total,
  });

  factory InspectionSummary.fromJson(Map<String, dynamic> json) {
    return InspectionSummary(
      completed: json['completed'] ?? 0,
      pending: json['pending'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      'pending': pending,
      'total': total,
    };
  }

  // Helper methods for percentage calculations
  double get completedPercentage => total > 0 ? (completed / total) * 100 : 0.0;
  double get pendingPercentage => total > 0 ? (pending / total) * 100 : 0.0;
  int get inProgress => total - completed - pending;
  double get inProgressPercentage => total > 0 ? (inProgress / total) * 100 : 0.0;
}
