// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      sender: json['sender'] as String,
      text: json['text'] as String,
      textTranslated: json['textTranslated'] as String?,
      imageUrl: json['imageUrl'] as String?,
      language: json['language'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      isSystem: json['isSystem'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'sender': instance.sender,
      'text': instance.text,
      'textTranslated': instance.textTranslated,
      'imageUrl': instance.imageUrl,
      'language': instance.language,
      'isRead': instance.isRead,
      'isSystem': instance.isSystem,
      'timestamp': instance.timestamp.toIso8601String(),
    };

_$ChatConversationImpl _$$ChatConversationImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatConversationImpl(
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String,
      driverPhoto: json['driverPhoto'] as String?,
      lastMessage: json['lastMessage'] == null
          ? null
          : ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
    );

Map<String, dynamic> _$$ChatConversationImplToJson(
        _$ChatConversationImpl instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'orderNumber': instance.orderNumber,
      'driverId': instance.driverId,
      'driverName': instance.driverName,
      'driverPhoto': instance.driverPhoto,
      'lastMessage': instance.lastMessage,
      'unreadCount': instance.unreadCount,
      'lastActivityAt': instance.lastActivityAt.toIso8601String(),
    };
