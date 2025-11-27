import 'dart:developer';
import 'package:flutter/material.dart';

class UserTierHistoryResponseModel {
  final bool status;
  final List<VisitHistory> history;

  UserTierHistoryResponseModel({
    required this.status,
    required this.history,
  });

  factory UserTierHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle case where history is null or not a list
      final historyJson = json['history'] as List?;
      return UserTierHistoryResponseModel(
        status: json['status'] as bool? ?? false,
        history: historyJson != null 
            ? historyJson.map<VisitHistory>((x) => VisitHistory.fromJson(x as Map<String, dynamic>)).toList()
            : <VisitHistory>[],
      );
    } catch (e) {
      // If there's any error in parsing, return default values
      debugPrint('Error parsing UserTierHistoryResponseModel: $e');
      return UserTierHistoryResponseModel(
        status: false,
        history: <VisitHistory>[],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'history': List<dynamic>.from(history.map((x) => x.toJson())),
    };
  }
}

class VisitHistory {
  final String id;
  final String businessId;
  final String businessName;
  final String? businessImage;
  final String time;
  final String tier;
  final String cardNumber;

  VisitHistory({
    required this.id,
    required this.businessId,
    required this.businessName,
    this.businessImage,
    required this.time,
    required this.tier,
    required this.cardNumber,
  });

  factory VisitHistory.fromJson(Map<String, dynamic> json) {
    return VisitHistory(
      id: json['id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? 'Unknown Business',
      businessImage: json['business_image']?.toString(),
      time: json['time']?.toString() ?? 'Unknown Time',
      tier: (json['tier'] as String?)?.toLowerCase() ?? 'core',
      cardNumber: json['card_number']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'business_name': businessName,
      'business_image': businessImage,
      'time': time,
      'tier': tier,
      'card_number': cardNumber,
    };
  }
}
