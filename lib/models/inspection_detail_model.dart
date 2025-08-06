
import 'dart:ui';

import 'package:flutter/material.dart';

class InspectionDetailData {
  final InspectionDetail inspection;
  final InspectionSummaryDetail summary;
  final List<InspectionSection> sections;
  final String generatedAt;
  final String generatedBy;

  InspectionDetailData({
    required this.inspection,
    required this.summary,
    required this.sections,
    required this.generatedAt,
    required this.generatedBy,
  });

  factory InspectionDetailData.fromJson(Map<String, dynamic> json) {
    return InspectionDetailData(
      inspection: InspectionDetail.fromJson(json['inspection'] ?? {}),
      summary: InspectionSummaryDetail.fromJson(json['summary'] ?? {}),
      sections: (json['sections'] as List<dynamic>?)
          ?.map((section) => InspectionSection.fromJson(section))
          .toList() ??
          [],
      generatedAt: json['generatedAt'] ?? '',
      generatedBy: json['generatedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inspection': inspection.toJson(),
      'summary': summary.toJson(),
      'sections': sections.map((section) => section.toJson()).toList(),
      'generatedAt': generatedAt,
      'generatedBy': generatedBy,
    };
  }
}

class InspectionDetail {
  final String inspectionId;
  final String templateId;
  final String templateName;
  final InspectorDetail inspectorId;
  final String inspectionDate;
  final String startTime;
  final String overallStatus;
  final String location;
  final String weatherConditions;

  InspectionDetail({
    required this.inspectionId,
    required this.templateId,
    required this.templateName,
    required this.inspectorId,
    required this.inspectionDate,
    required this.startTime,
    required this.overallStatus,
    required this.location,
    required this.weatherConditions,
  });

  factory InspectionDetail.fromJson(Map<String, dynamic> json) {
    return InspectionDetail(
      inspectionId: json['inspectionId'] ?? '',
      templateId: json['templateId'] ?? '',
      templateName: json['templateName'] ?? '',
      inspectorId: InspectorDetail.fromJson(json['inspectorId'] ?? {}),
      inspectionDate: json['inspectionDate'] ?? '',
      startTime: json['startTime'] ?? '',
      overallStatus: json['overallStatus'] ?? '',
      location: json['location'] ?? '',
      weatherConditions: json['weatherConditions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inspectionId': inspectionId,
      'templateId': templateId,
      'templateName': templateName,
      'inspectorId': inspectorId.toJson(),
      'inspectionDate': inspectionDate,
      'startTime': startTime,
      'overallStatus': overallStatus,
      'location': location,
      'weatherConditions': weatherConditions,
    };
  }
}

class InspectorDetail {
  final String id;
  final String name;
  final String email;

  InspectorDetail({
    required this.id,
    required this.name,
    required this.email,
  });

  factory InspectorDetail.fromJson(Map<String, dynamic> json) {
    return InspectorDetail(
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

class InspectionSummaryDetail {
  final int totalSections;
  final int completedSections;
  final int totalQuestions;
  final int answeredQuestions;
  final int satisfiedQuestions;
  final int unsatisfiedQuestions;
  final int questionsWithComments;
  final int questionsWithFiles;

  InspectionSummaryDetail({
    required this.totalSections,
    required this.completedSections,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.satisfiedQuestions,
    required this.unsatisfiedQuestions,
    required this.questionsWithComments,
    required this.questionsWithFiles,
  });

  factory InspectionSummaryDetail.fromJson(Map<String, dynamic> json) {
    return InspectionSummaryDetail(
      totalSections: json['totalSections'] ?? 0,
      completedSections: json['completedSections'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      answeredQuestions: json['answeredQuestions'] ?? 0,
      satisfiedQuestions: json['satisfiedQuestions'] ?? 0,
      unsatisfiedQuestions: json['unsatisfiedQuestions'] ?? 0,
      questionsWithComments: json['questionsWithComments'] ?? 0,
      questionsWithFiles: json['questionsWithFiles'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSections': totalSections,
      'completedSections': completedSections,
      'totalQuestions': totalQuestions,
      'answeredQuestions': answeredQuestions,
      'satisfiedQuestions': satisfiedQuestions,
      'unsatisfiedQuestions': unsatisfiedQuestions,
      'questionsWithComments': questionsWithComments,
      'questionsWithFiles': questionsWithFiles,
    };
  }
}

class InspectionSection {
  final String sectionId;
  final String sectionName;
  final int order;
  final String status;
  final String? completedAt;
  final SectionStatistics statistics;
  final List<QuestionAnswer> answers;

  InspectionSection({
    required this.sectionId,
    required this.sectionName,
    required this.order,
    required this.status,
    this.completedAt,
    required this.statistics,
    required this.answers,
  });

  factory InspectionSection.fromJson(Map<String, dynamic> json) {
    return InspectionSection(
      sectionId: json['sectionId'] ?? '',
      sectionName: json['sectionName'] ?? '',
      order: json['order'] ?? 0,
      status: json['status'] ?? '',
      completedAt: json['completedAt'],
      statistics: SectionStatistics.fromJson(json['statistics'] ?? {}),
      answers: (json['answers'] as List<dynamic>?)
          ?.map((answer) => QuestionAnswer.fromJson(answer))
          .toList() ??
          [],
    );
  }

  // get status color
  Map<String, Color> _getStatusColors() {
    switch (status.toLowerCase()) {
      case 'in-progress':
      case 'pending':
        return {
          'background': Colors.orange.shade100,
          'border': Colors.orange.shade400,
        };
      case 'not started':
        return {
          'background': Colors.grey.shade100,
          'border': Colors.grey.shade500,
        };
      case 'completed':
        return {
          'background': Colors.green.shade100,
          'border': Colors.green.shade600,
        };
      default:
        return {
          'background': Colors.grey.shade100,
          'border': Colors.grey.shade400,
        };
    }
  }

  // get status background color
  Color getStatusBackgroundColor() {
    return _getStatusColors()['background'] ?? Colors.grey.shade100;
  }

  // get status border color
  Color getStatusBorderColor() {
    return _getStatusColors()['border'] ?? Colors.grey.shade400;
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'sectionName': sectionName,
      'order': order,
      'status': status,
      'completedAt': completedAt,
      'statistics': statistics.toJson(),
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

class SectionStatistics {
  final int totalQuestions;
  final int answeredQuestions;
  final int satisfiedQuestions;
  final int unsatisfiedQuestions;
  final int notApplicableQuestions;
  final int questionsWithComments;
  final int questionsWithFiles;

  SectionStatistics({
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.satisfiedQuestions,
    required this.unsatisfiedQuestions,
    required this.notApplicableQuestions,
    required this.questionsWithComments,
    required this.questionsWithFiles,
  });

  factory SectionStatistics.fromJson(Map<String, dynamic> json) {
    return SectionStatistics(
      totalQuestions: json['totalQuestions'] ?? 0,
      answeredQuestions: json['answeredQuestions'] ?? 0,
      satisfiedQuestions: json['satisfiedQuestions'] ?? 0,
      unsatisfiedQuestions: json['unsatisfiedQuestions'] ?? 0,
      notApplicableQuestions: json['notApplicableQuestions'] ?? 0,
      questionsWithComments: json['questionsWithComments'] ?? 0,
      questionsWithFiles: json['questionsWithFiles'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'answeredQuestions': answeredQuestions,
      'satisfiedQuestions': satisfiedQuestions,
      'unsatisfiedQuestions': unsatisfiedQuestions,
      'notApplicableQuestions': notApplicableQuestions,
      'questionsWithComments': questionsWithComments,
      'questionsWithFiles': questionsWithFiles,
    };
  }
}

class QuestionAnswer {
  final String questionId;
  final String questionText;
  final bool required;
  final String satisfied;
  final String comments;
  final List<FileUpload> fileUploads;
  final String timestamp;
  final String inspectorId;

  QuestionAnswer({
    required this.questionId,
    required this.questionText,
    required this.required,
    required this.satisfied,
    required this.comments,
    required this.fileUploads,
    required this.timestamp,
    required this.inspectorId,
  });

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      required: json['required'] ?? false,
      satisfied: json['satisfied'] ?? '',
      comments: json['comments'] ?? '',
      fileUploads: (json['fileUploads'] as List<dynamic>?)
          ?.map((file) => FileUpload.fromJson(file))
          .toList() ??
          [],
      timestamp: json['timestamp'] ?? '',
      inspectorId: json['inspectorId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'required': required,
      'satisfied': satisfied,
      'comments': comments,
      'fileUploads': fileUploads.map((file) => file.toJson()).toList(),
      'timestamp': timestamp,
      'inspectorId': inspectorId,
    };
  }
}

class FileUpload {
  final String? id;
  final String? filename;
  final String? originalName;
  final String? mimetype;
  final int? size;
  final String? url;
  final String? uploadedAt;

  FileUpload({
    this.id,
    this.filename,
    this.originalName,
    this.mimetype,
    this.size,
    this.url,
    this.uploadedAt,
  });

  factory FileUpload.fromJson(Map<String, dynamic> json) {
    return FileUpload(
      id: json['id'],
      filename: json['filename'],
      originalName: json['originalName'],
      mimetype: json['mimetype'],
      size: json['size'],
      url: json['url'],
      uploadedAt: json['uploadedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'originalName': originalName,
      'mimetype': mimetype,
      'size': size,
      'url': url,
      'uploadedAt': uploadedAt,
    };
  }
}
