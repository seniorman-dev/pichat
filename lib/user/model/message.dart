import 'package:cloud_firestore/cloud_firestore.dart';



class MessageModel {
  final String messageId;
  final String senderName;
  final String receiverName;
  final String content;
  final Timestamp timestamp;
  final bool isSeen;

  MessageModel({required this.isSeen, required this.messageId, required this.senderName, required this.receiverName, required this.content, required this.timestamp});

  //convert to a map cause that is how firestore will receive it
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderName': senderName,
      'receiverName': receiverName,
      'content': content,
      'isSeen': isSeen,
      'timestamp': timestamp
    };
  }
}