// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LetterLesson _$LetterLessonFromJson(Map<String, dynamic> json) => LetterLesson(
      name: json['name'] as String,
      progress: json['progress'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      content1:
          LessonContent.fromJson(json['content1'] as Map<String, dynamic>),
      content2:
          LessonContent.fromJson(json['content2'] as Map<String, dynamic>),
      content3:
          LessonContent.fromJson(json['content3'] as Map<String, dynamic>),
      content4:
          LessonContent.fromJson(json['content4'] as Map<String, dynamic>),
      content5:
          LessonContent.fromJson(json['content5'] as Map<String, dynamic>),
      content6:
          LessonContent.fromJson(json['content6'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LetterLessonToJson(LetterLesson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'progress': instance.progress,
      'isUnlocked': instance.isUnlocked,
      'content1': instance.content1,
      'content2': instance.content2,
      'content3': instance.content3,
      'content4': instance.content4,
      'content5': instance.content5,
      'content6': instance.content6,
    };

LessonContent _$LessonContentFromJson(Map<String, dynamic> json) =>
    LessonContent(
      description: json['description'] as String,
      contentImage: json['contentImage'] as List<dynamic>?,
      contentOption: json['contentOption'] as List<dynamic>?,
      correctAnswerIndex: json['correctAnswerIndex'] as List<dynamic>?,
    );

Map<String, dynamic> _$LessonContentToJson(LessonContent instance) =>
    <String, dynamic>{
      'description': instance.description,
      'contentImage': instance.contentImage,
      'contentOption': instance.contentOption,
      'correctAnswerIndex': instance.correctAnswerIndex,
    };
