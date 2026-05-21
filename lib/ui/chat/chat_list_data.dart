import 'package:flutter/material.dart';

class ChatListItem {
  const ChatListItem({
    required this.id,
    required this.peerId,
    required this.name,
    required this.initials,
    required this.avatarColors,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.online = false,
  });

  final String id;
  final String peerId;
  final String name;
  final String initials;
  final List<Color> avatarColors;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool online;

  bool get hasUnread => unreadCount > 0;
}

const List<ChatListItem> kChatListItems = [
  ChatListItem(
    id: 'aziz',
    peerId: 'b719cf11-4f11-4649-9b8f-1cc700bb95df',
    name: 'Aziz Karimov',
    initials: 'AK',
    avatarColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    lastMessage: 'Salom! Bugungi darsda yangi mavzu bormi?',
    time: '14:32',
    unreadCount: 3,
    online: true,
  ),
  ChatListItem(
    id: 'nilufar',
    peerId: '8a7c1ce0-22a8-4f6e-9c2b-0e4f7a1b2c3d',
    name: 'Nilufar Mirzayeva',
    initials: 'NM',
    avatarColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    lastMessage: 'Rahmat, vazifani tushundim 🙏',
    time: '13:05',
    unreadCount: 1,
  ),
  ChatListItem(
    id: 'otabek-bot',
    peerId: 'd8e3f2a1-9b4c-4d2e-8f1a-7c6b5d4e3f2a',
    name: 'Otabek Bot · IELTS',
    initials: 'OB',
    avatarColors: [Color(0xFF0D9488), Color(0xFF059669)],
    lastMessage: 'Sizga Speaking pack tayyorlandi',
    time: '12:40',
    unreadCount: 5,
    online: true,
  ),
  ChatListItem(
    id: 'sardor',
    peerId: '6f9b1c7e-4a3d-4e2c-9b8a-5d3e7c2a1f04',
    name: 'Sardor Tursunov',
    initials: 'ST',
    avatarColors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    lastMessage: "Mock testni jo'nating iltimos",
    time: '11:18',
    unreadCount: 2,
  ),
  ChatListItem(
    id: 'speaking-group',
    peerId: 'a2c1f5b8-3d4e-4f9a-8b1c-9d2e4f5a6b7c',
    name: 'Speaking guruhi',
    initials: 'SG',
    avatarColors: [Color(0xFFF472B6), Color(0xFFEC4899)],
    lastMessage: 'Madina: Tomorrow at 5pm, deal',
    time: 'Kecha',
  ),
  ChatListItem(
    id: 'malika',
    peerId: '7e8f9a0b-1c2d-3e4f-5a6b-7c8d9e0f1a2b',
    name: 'Malika Yusupova',
    initials: 'MY',
    avatarColors: [Color(0xFFF43F5E), Color(0xFFBE123C)],
    lastMessage: 'Voice xabarni eshitdim',
    time: 'Kecha',
  ),
  ChatListItem(
    id: 'ielts-bot',
    peerId: '5b6c7d8e-9f0a-1b2c-3d4e-5f6a7b8c9d0e',
    name: 'IELTS Practice Bot',
    initials: 'IB',
    avatarColors: [Color(0xFF64748B), Color(0xFF334155)],
    lastMessage: 'Writing task 2 ball: 6.5/9.0',
    time: '6-mart',
  ),
];
