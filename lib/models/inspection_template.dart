class InspectionTemplate {
  final String id;
  final String templateId;
  final String templateName;
  final String vesselType;
  final List<InspectionSection> sections;
  final String version;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  InspectionTemplate({
    required this.id,
    required this.templateId,
    required this.templateName,
    required this.vesselType,
    required this.sections,
    required this.version,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InspectionTemplate.fromJson(Map<String, dynamic> json) {
    return InspectionTemplate(
      id: json['_id'] ?? '',
      templateId: json['templateId'] ?? '',
      templateName: json['templateName'] ?? '',
      vesselType: json['vesselType'] ?? '',
      sections: (json['sections'] as List<dynamic>?)
          ?.map((section) => InspectionSection.fromJson(section))
          .toList() ?? [],
      version: json['version'] ?? '',
      isActive: json['isActive'] ?? false,
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'templateId': templateId,
      'templateName': templateName,
      'vesselType': vesselType,
      'sections': sections.map((section) => section.toJson()).toList(),
      'version': version,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class InspectionSection {
  final String sectionId;
  final String sectionName;
  final List<InspectionQuestion> questions;
  final int order;
  final String id;

  InspectionSection({
    required this.sectionId,
    required this.sectionName,
    required this.questions,
    required this.order,
    required this.id,
  });

  factory InspectionSection.fromJson(Map<String, dynamic> json) {
    return InspectionSection(
      sectionId: json['sectionId'] ?? '',
      sectionName: json['sectionName'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
          ?.map((question) => InspectionQuestion.fromJson(question))
          .toList() ?? [],
      order: json['order'] ?? 0,
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'sectionName': sectionName,
      'questions': questions.map((question) => question.toJson()).toList(),
      'order': order,
      '_id': id,
    };
  }
}

class InspectionQuestion {
  final String questionId;
  final String questionText;
  final String questionType;
  final bool required;
  final List<String> options;
  final String id;

  InspectionQuestion({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.required,
    required this.options,
    required this.id,
  });

  factory InspectionQuestion.fromJson(Map<String, dynamic> json) {
    return InspectionQuestion(
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      questionType: json['questionType'] ?? '',
      required: json['required'] ?? false,
      options: (json['options'] as List<dynamic>?)
          ?.map((option) => option.toString())
          .toList() ?? [],
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'questionType': questionType,
      'required': required,
      'options': options,
      '_id': id,
    };
  }
}

class ApiResponse<T> {
  final int statusCode;
  final T data;
  final String message;
  final bool error;

  ApiResponse({
    required this.statusCode,
    required this.data,
    required this.message,
    required this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      statusCode: json['statusCode'] ?? 0,
      data: fromJsonT(json['data']),
      message: json['message'] ?? '',
      error: json['error'] ?? false,
    );
  }
}
