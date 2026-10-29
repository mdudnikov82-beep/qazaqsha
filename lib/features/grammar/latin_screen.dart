import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/kazakh_letters.dart';
import '../../core/latin.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/teal_header.dart';
import '../../data/providers.dart';

/// The Latin alphabet Kazakhstan is moving to: the letters, a converter,
/// and the switch that shows Latin spelling across the app.
class LatinScreen extends ConsumerStatefulWidget {
  const LatinScreen({super.key});

  @override
  ConsumerState<LatinScreen> createState() => _LatinScreenState();
}

class _LatinScreenState extends ConsumerState<LatinScreen> {
  final _input = TextEditingController(text: 'Сәлем! Қалайсың?');

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _insert(String letter) {
    final v = _input.value;
    final sel = v.selection.isValid
        ? v.selection
        : TextSelection.collapsed(offset: v.text.length);
    _input.value = TextEditingValue(
      text: v.text.replaceRange(sel.start, sel.end, letter),
      selection: TextSelection.collapsed(offset: sel.start + letter.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final on = ref.watch(showLatinProvider);
    final latin = toLatin(_input.text);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            const TealHeader(
              leading: BackButton(color: Colors.white),
              title: 'Латиница',
              subtitle: 'Жаңа әліпби · алфавит 2021 года',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Казахстан постепенно переходит с кириллицы на латиницу. '
                    'Здесь — новый алфавит из 31 буквы. Написание ещё может '
                    'уточняться, поэтому это подсказка, а не замена кириллице.',
                    style: TextStyle(color: c.muted, height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  SurfaceCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SwitchListTile(
                      title: const Text(
                        'Показывать латиницу',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text(
                        'Рядом с казахскими словами в словаре, карточках и уроках',
                      ),
                      value: on,
                      onChanged: ref.read(statsRepositoryProvider).setShowLatin,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Конвертер',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Кириллицей'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final l in kazakhExtraLetters)
                        ActionChip(
                          label: Text(l, style: TextStyle(color: c.accent)),
                          tooltip: 'Вставить букву $l',
                          onPressed: () => _insert(l),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SurfaceCard(
                    color: c.accentSoft,
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            latin.isEmpty ? '…' : latin,
                            style: TextStyle(
                              color: c.accent,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Скопировать',
                          onPressed: latin.isEmpty
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  await Clipboard.setData(
                                    ClipboardData(text: latin),
                                  );
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Скопировано'),
                                    ),
                                  );
                                },
                          icon: Icon(Icons.copy_rounded, color: c.accent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Алфавит',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  SurfaceCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (final (i, (cyr, lat, example))
                            in latinAlphabet.indexed) ...[
                          if (i > 0) Divider(height: 1, color: c.line),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 84,
                                  child: Text(
                                    cyr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 52,
                                  child: Text(
                                    lat,
                                    style: TextStyle(
                                      color: c.accent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    example,
                                    style: TextStyle(color: c.muted),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Буквы ц, ч, щ, ё, ю, я встречаются в заимствованных словах '
                    'и пишутся сочетаниями: ts, ch, şş, io, iu, ia.',
                    style: TextStyle(color: c.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
