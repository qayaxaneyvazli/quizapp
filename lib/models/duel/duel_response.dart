class DuelResponse {
  final String message;
  final bool isBot;
  final DuelOpponent opponent;
  final DuelData duel;

  DuelResponse({
    required this.message,
    required this.isBot,
    required this.opponent,
    required this.duel,
  });

  factory DuelResponse.fromJson(Map<String, dynamic> json) {
    return DuelResponse(
      message: json['message'] ?? '',
      isBot: json['is_bot'] ?? false,
      opponent: DuelOpponent.fromJson(json['opponent'] ?? {}),
      duel: DuelData.fromJson(json['duel'] ?? {}),
    );
  }
}

class DuelOpponent {
  final int id;
  final String name;
  final String avatarUrl;

  DuelOpponent({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  factory DuelOpponent.fromJson(Map<String, dynamic> json) {
    return DuelOpponent(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }
}

class DuelData {
  final int id;
  final int player1Id;
  final int? player2Id;
  final String startedAt;
  final String updatedAt;
  final String createdAt;
  final List<DuelQuestionData> duelQuestions;

  DuelData({
    required this.id,
    required this.player1Id,
    this.player2Id,
    required this.startedAt,
    required this.updatedAt,
    required this.createdAt,
    required this.duelQuestions,
  });

  factory DuelData.fromJson(Map<String, dynamic> json) {
    return DuelData(
      id: json['id'] ?? 0,
      player1Id: json['player1_id'] ?? 0,
      player2Id: json['player2_id'],
      startedAt: json['started_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      duelQuestions: (json['duel_questions'] as List<dynamic>?)
              ?.map((q) => DuelQuestionData.fromJson(q))
              .toList() ??
          [],
    );
  }
}

class DuelQuestionData {
  final int id;
  final int duelId;
  final int questionId;
  final int orderNumber;
  final String createdAt;
  final String updatedAt;
  final QuestionData question;

  DuelQuestionData({
    required this.id,
    required this.duelId,
    required this.questionId,
    required this.orderNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.question,
  });

  factory DuelQuestionData.fromJson(Map<String, dynamic> json) {
    return DuelQuestionData(
      id: json['id'] ?? 0,
      duelId: json['duel_id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      orderNumber: json['order_number'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      question: QuestionData.fromJson(json['question'] ?? {}),
    );
  }
}

class QuestionData {
  final int id;
  final int categoryId;
  final String type;
  final String? image;
  final int level;
  final int? createdBy;
  final String createdAt;
  final String updatedAt;
  final int levelId;
  final List<QuestionTranslation> translations;
  final List<QuestionOption> options;

  QuestionData({
    required this.id,
    required this.categoryId,
    required this.type,
    this.image,
    required this.level,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.levelId,
    required this.translations,
    required this.options,
  });

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      type: json['type'] ?? '',
      image: json['image'],
      level: json['level'] ?? 0,
      createdBy: json['created_by'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      levelId: json['level_id'] ?? 0,
      translations: (json['translations'] as List<dynamic>?)
              ?.map((t) => QuestionTranslation.fromJson(t))
              .toList() ??
          [],
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => QuestionOption.fromJson(o))
              .toList() ??
          [],
    );
  }

  // Helper method to get question text in specific language (default 'en')
  String getQuestionText([String language = 'en']) {
    final translation = translations.firstWhere(
      (t) => t.language == language,
      orElse: () => translations.isNotEmpty ? translations.first : QuestionTranslation(
        id: 0,
        questionId: id,
        language: language,
        questionText: 'Question not available',
        info: '',
        createdAt: '',
        updatedAt: '',
      ),
    );
    return translation.questionText;
  }

  // Helper method to get question info in specific language (default 'en')
  String getQuestionInfo([String language = 'en']) {
    final translation = translations.firstWhere(
      (t) => t.language == language,
      orElse: () => translations.isNotEmpty ? translations.first : QuestionTranslation(
        id: 0,
        questionId: id,
        language: language,
        questionText: '',
        info: 'Info not available',
        createdAt: '',
        updatedAt: '',
      ),
    );
    return translation.info;
  }

  // Helper method to get correct option index
  int getCorrectOptionIndex() {
    for (int i = 0; i < options.length; i++) {
      if (options[i].isCorrect == 1) {
        return i;
      }
    }
    return 0; // Default to first option if no correct option found
  }

  // Helper method to get option texts in specific language (default 'en')
  List<String> getOptionTexts([String language = 'en']) {
    return options.map((option) => option.getOptionText(language)).toList();
  }
}

class QuestionTranslation {
  final int id;
  final int questionId;
  final String language;
  final String questionText;
  final String info;
  final String createdAt;
  final String updatedAt;

  QuestionTranslation({
    required this.id,
    required this.questionId,
    required this.language,
    required this.questionText,
    required this.info,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionTranslation.fromJson(Map<String, dynamic> json) {
    return QuestionTranslation(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      language: json['language'] ?? '',
      questionText: json['question_text'] ?? '',
      info: json['info'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class QuestionOption {
  final int id;
  final String createdAt;
  final String updatedAt;
  final int questionId;
  final int isCorrect;
  final List<OptionTranslation> translations;

  QuestionOption({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.questionId,
    required this.isCorrect,
    required this.translations,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      questionId: json['question_id'] ?? 0,
      isCorrect: json['is_correct'] ?? 0,
      translations: (json['translations'] as List<dynamic>?)
              ?.map((t) => OptionTranslation.fromJson(t))
              .toList() ??
          [],
    );
  }

  // Helper method to get option text in specific language (default 'en')
  String getOptionText([String language = 'en']) {
    final translation = translations.firstWhere(
      (t) => t.language == language,
      orElse: () => translations.isNotEmpty ? translations.first : OptionTranslation(
        id: 0,
        optionId: id,
        language: language,
        optionText: 'Option not available',
        createdAt: '',
        updatedAt: '',
      ),
    );
    return translation.optionText;
  }
}

class OptionTranslation {
  final int id;
  final int optionId;
  final String language;
  final String optionText;
  final String createdAt;
  final String updatedAt;

  OptionTranslation({
    required this.id,
    required this.optionId,
    required this.language,
    required this.optionText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OptionTranslation.fromJson(Map<String, dynamic> json) {
    return OptionTranslation(
      id: json['id'] ?? 0,
      optionId: json['option_id'] ?? 0,
      language: json['language'] ?? '',
      optionText: json['option_text'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}