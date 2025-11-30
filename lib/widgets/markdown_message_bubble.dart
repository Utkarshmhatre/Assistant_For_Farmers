import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message_model.dart';

class MarkdownMessageBubble extends StatelessWidget {
  final Message message;
  final EdgeInsetsGeometry padding;

  const MarkdownMessageBubble({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green[400],
              child: const Icon(Icons.eco, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Colors.green[600]
                        : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                    border: message.isUser
                        ? null
                        : Border.all(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[200]!,
                            width: 1,
                          ),
                  ),
                  child: MarkdownBody(
                    data: message.content,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: message.isUser
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                      h1: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: message.isUser
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                        height: 1.3,
                      ),
                      h2: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: message.isUser
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                        height: 1.3,
                      ),
                      h3: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: message.isUser
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                        height: 1.3,
                      ),
                      strong: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: message.isUser
                            ? Colors.white
                            : (isDark ? Colors.green[300] : Colors.green[700]),
                      ),
                      em: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: message.isUser
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                      listBullet: TextStyle(
                        color: message.isUser
                            ? Colors.white
                            : (isDark ? Colors.green[300] : Colors.green[600]),
                        fontSize: 15,
                      ),
                      code: TextStyle(
                        backgroundColor: message.isUser
                            ? Colors.green[700]
                            : (isDark ? Colors.grey[800] : Colors.grey[200]),
                        color: message.isUser
                            ? Colors.white
                            : (isDark ? Colors.green[300] : Colors.green[700]),
                        fontFamily: 'monospace',
                      ),
                      blockquote: TextStyle(
                        color: message.isUser
                            ? Colors.white70
                            : (isDark ? Colors.grey[400] : Colors.grey[700]),
                        fontStyle: FontStyle.italic,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: message.isUser
                                ? Colors.white54
                                : (isDark ? Colors.green[300]! : Colors.green[600]!),
                            width: 4,
                          ),
                        ),
                      ),
                      a: TextStyle(
                        color: message.isUser
                            ? Colors.white
                            : (isDark ? Colors.blue[300] : Colors.blue[700]),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 16, bottom: 4),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) _buildAvatar(true),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser ? Colors.blue[400] : Colors.green[400],
      child: Icon(
        isUser ? Icons.person : Icons.eco,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
