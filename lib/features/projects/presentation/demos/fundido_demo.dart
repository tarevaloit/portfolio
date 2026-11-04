import 'dart:async';

import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/projects/presentation/demos/piggy_avatar.dart';

/// Fundido mock: a chat with the piggy. Tapping a suggestion sends it,
/// shows "typing…" and then the scripted reply. Example copy.
class FundidoDemo extends StatefulWidget {
  const FundidoDemo({super.key});

  /// Delay before the piggy answers (none with reduced motion).
  static const Duration replyDelay = Duration(milliseconds: 900);

  @override
  State<FundidoDemo> createState() => _FundidoDemoState();
}

/// A message by id: 0 is the greeting, 1..3 the suggestions and replies.
typedef _Message = ({bool fromUser, int id});

class _FundidoDemoState extends State<FundidoDemo> {
  static const Color _background = Color(0xFFFFF1F7);
  static const Color _pink = Color(0xFFF9A8D4);
  static const Color _deep = Color(0xFF831843);
  static const Color _ink = Color(0xFF1F1F1F);

  final List<_Message> _messages = [(fromUser: false, id: 0)];
  final Set<int> _asked = {};
  bool _typing = false;
  Timer? _reply;

  @override
  void dispose() {
    _reply?.cancel();
    super.dispose();
  }

  void _ask(int id) {
    setState(() {
      _asked.add(id);
      _messages.add((fromUser: true, id: id));
      _typing = true;
    });
    _reply?.cancel();
    _reply = Timer(
      context.reduceMotion ? Duration.zero : FundidoDemo.replyDelay,
      () {
        if (!mounted) return;
        setState(() {
          _typing = false;
          _messages.add((fromUser: false, id: id));
        });
      },
    );
  }

  String _text(AppLocalizations l10n, _Message message) {
    if (message.fromUser) {
      return [
        l10n.demoFundidoAsk1,
        l10n.demoFundidoAsk2,
        l10n.demoFundidoAsk3,
      ][message.id - 1];
    }
    return [
      l10n.demoFundidoGreeting,
      l10n.demoFundidoReply1,
      l10n.demoFundidoReply2,
      l10n.demoFundidoReply3,
    ][message.id];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asks = [
      l10n.demoFundidoAsk1,
      l10n.demoFundidoAsk2,
      l10n.demoFundidoAsk3,
    ];
    final pending = [
      for (var id = 1; id <= asks.length; id++)
        if (!_asked.contains(id)) id,
    ];
    final bubbles = [
      for (final message in _messages)
        _Bubble(text: _text(l10n, message), fromUser: message.fromUser),
      if (_typing)
        _Bubble(text: l10n.demoFundidoTyping, fromUser: false, muted: true),
    ];

    return ColoredBox(
      color: _background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Row(
              children: [
                PiggyAvatar(
                  talking: _typing,
                  celebrations: _messages.where((m) => !m.fromUser).length,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.demoFundidoName,
                      style: AppTypography.sans(
                        size: 14,
                        weight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    Text(
                      l10n.demoFundidoStatus,
                      style: AppTypography.sans(
                        size: 11,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              // Newest at the bottom, scrolled into view automatically.
              reverse: true,
              padding: const EdgeInsets.all(12),
              children: bubbles.reversed.toList(),
            ),
          ),
          if (pending.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final id in pending)
                    ActionChip(
                      label: Text(asks[id - 1]),
                      onPressed: _typing ? null : () => _ask(id),
                      labelStyle: AppTypography.sans(size: 11, color: _deep),
                      backgroundColor: Colors.white,
                      // Disabled while the piggy is typing; stays light.
                      disabledColor: const Color(0xFFFDF2F8),
                      side: const BorderSide(color: _pink),
                      shape: const StadiumBorder(),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.pillAll,
            ),
            child: Text(
              l10n.demoFundidoInput,
              style: AppTypography.sans(
                size: 12,
                color: const Color(0xFF9A9A93),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.fromUser,
    this.muted = false,
  });

  final String text;
  final bool fromUser;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: fromUser ? _FundidoDemoState._pink : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(fromUser ? 16 : 4),
            bottomRight: Radius.circular(fromUser ? 4 : 16),
          ),
        ),
        child: Text(
          text,
          style: AppTypography.sans(
            size: 12,
            height: 1.4,
            color: muted ? const Color(0xFF9A9A93) : _FundidoDemoState._ink,
          ),
        ),
      ),
    );
  }
}
