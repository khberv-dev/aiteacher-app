import 'package:ai_teacher/core/battle/data/battle_dtos.dart';
import 'package:ai_teacher/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class BattleQueueView extends StatefulWidget {
  const BattleQueueView({
    super.key,
    required this.lobbyPlayers,
    required this.onCancel,
    this.lobbyTick,
  });

  final List<LobbyPlayer> lobbyPlayers;
  final VoidCallback onCancel;
  final int? lobbyTick;

  @override
  State<BattleQueueView> createState() => _BattleQueueViewState();
}

class _BattleQueueViewState extends State<BattleQueueView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = widget.lobbyPlayers.length;
    const max = 4;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) {
              final scale = 1.0 + _pulse.value * 0.12;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFFF97316)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text('⚔️', style: TextStyle(fontSize: 46)),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.battleQueueWaitingTitle,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.battleQueuePlayerCount(count, max),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.lobbyTick != null) ...[
                const SizedBox(width: 10),
                const Text(
                  '·',
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.lobbyTick}s',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),
          _PlayerSlots(players: widget.lobbyPlayers, maxPlayers: max),
          const SizedBox(height: 40),
          TextButton(
            onPressed: widget.onCancel,
            child: Text(
              l10n.commonCancel,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerSlots extends StatelessWidget {
  const _PlayerSlots({required this.players, required this.maxPlayers});

  final List<LobbyPlayer> players;
  final int maxPlayers;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxPlayers, (i) {
        final filled = i < players.length;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled
                      ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                      : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: filled
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: filled
                    ? Text(
                        players[i].firstName.isNotEmpty
                            ? players[i].firstName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFFCBD5E1),
                        size: 22,
                      ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 60,
                child: Text(
                  filled ? players[i].firstName : '...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: filled
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
