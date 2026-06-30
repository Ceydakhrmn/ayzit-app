 import 'package:flutter/material.dart';
import '../gen_l10n/app_localizations.dart';
import '../services/ai_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({
    super.key,
    this.contextSummary,
    this.showAppBar = true,
  });

  final String? contextSummary;
  final bool showAppBar;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatEntry {
  _AiChatEntry({required this.isUser, required this.text});

  final bool isUser;
  final String text;
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<_AiChatEntry> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  static const String _baseUrl = 'http://192.168.1.38:8000';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({required bool includeAdvice}) async {
    final l10n = AppLocalizations.of(context)!;
    final text = _messageController.text.trim();
    if (text.isEmpty && !includeAdvice) {
      return;
    }

    final contextSummary = (widget.contextSummary ?? '').trim();
    final adviceSource = contextSummary.isNotEmpty ? contextSummary : text;
    if (includeAdvice && adviceSource.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adviceNeedsInput)),
      );
      return;
    }

    if (!includeAdvice) {
      setState(() {
        _messages.add(_AiChatEntry(isUser: true, text: text));
        _sending = true;
      });
    } else {
      setState(() {
        _sending = true;
      });
    }

    _messageController.clear();
    _scrollToBottom();

    final locale = Localizations.localeOf(context).languageCode;
    final service = AiService(baseUrl: _baseUrl);

    try {
      final response = includeAdvice
          ? await service.advice(
              summary: adviceSource,
              locale: locale,
            )
          : await service.chat(
              messages: _buildChatMessages(text),
              locale: locale,
            );

      if (!mounted) return;
      setState(() {
        _messages.add(_AiChatEntry(isUser: false, text: response));
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.aiRequestFailed)),
      );
    }
  }

  List<AiChatMessage> _buildChatMessages(String latest) {
    final messages = <AiChatMessage>[];
    final context = widget.contextSummary;
    if (context != null && context.isNotEmpty) {
      messages.add(
        AiChatMessage(
          role: 'user',
          content: 'Context:\n$context',
        ),
      );
    }
    for (final entry in _messages) {
      messages.add(
        AiChatMessage(
          role: entry.isUser ? 'user' : 'assistant',
          content: entry.text,
        ),
      );
    }
    if (latest.trim().isNotEmpty) {
      messages.add(
        AiChatMessage(
          role: 'user',
          content: latest,
        ),
      );
    }
    return messages;
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(l10n.aiAssistant),
              centerTitle: true,
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        l10n.aiAssistantSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final align =
                          message.isUser ? Alignment.centerRight : Alignment.centerLeft;
                      final color = message.isUser
                          ? Colors.pink.shade100
                          : Colors.grey.shade200;
                      return Align(
                        alignment: align,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(message.text),
                        ),
                      );
                    },
                  ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: l10n.typeMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _sending
                          ? null
                          : () => _sendMessage(includeAdvice: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      child: Text(
                        l10n.sendMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _sending
                          ? null
                          : () => _sendMessage(includeAdvice: true),
                      child: Text(l10n.getAdvice),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
