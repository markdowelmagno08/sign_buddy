// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LetterLesson _$LetterLessonFromJson(Map<String, dynamic> json) => LetterLesson(
      name: json['name'] as String,
      progress: json['progress'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      content: (json['content'] as List<dynamic>)
          .map((e) => LessonContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      quiz1: LessonQuiz.fromJson(json['quiz1'] as Map<String, dynamic>),
      quiz2: LessonQuiz.fromJson(json['quiz2'] as Map<String, dynamic>),
      quiz3: LessonQuiz.fromJson(json['quiz3'] as Map<String, dynamic>),
      quiz4: LessonQuiz.fromJson(json['quiz4'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LetterLessonToJson(LetterLesson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'progress': instance.progress,
      'isUnlocked': instance.isUnlocked,
      'content': instance.content,
      'quiz1': instance.quiz1,
      'quiz2': instance.quiz2,
      'quiz3': instance.quiz3,
      'quiz4': instance.quiz4,
    };

LessonContent _$LessonContentFromJson(Map<String, dynamic> json) =>
    LessonContent(
      description: json['description'] as String,
      lessonImage: json['lessonImage'] as String,
    );

Map<String, dynamic> _$LessonContentToJson(LessonContent instance) =>
    <String, dynamic>{
      'description': instance.description,
      'lessonImage': instance.lessonImage,
    };

LessonQuiz _$LessonQuizFromJson(Map<String, dynamic> json) => LessonQuiz(
      question: json['question'] as String,
      quizImage: json['quizImage'] as String?,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctAnswerIndex: (json['correctAnswerIndex'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );

Map<String, dynamic> _$LessonQuizToJson(LessonQuiz instance) =>
    <String, dynamic>{
      'question': instance.question,
      'quizImage': instance.quizImage,
      'options': instance.options,
      'correctAnswerIndex': instance.correctAnswerIndex,
    };
