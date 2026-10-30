"""Moves reviewed recordings into the app.

Run from the project root:  python tools/review/import.py

Copies tools/review/audio/<key>.webm to assets/audio/ and writes
assets/audio/index.json: Kazakh text -> key, which the app's 🔊 button
looks up before falling back to text-to-speech. Corrections are listed
and stop the import: they change dictionary entries, which needs an app
migration done by hand.
"""
import json
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
DICTIONARY = ROOT / 'assets' / 'data' / 'dictionary.json'
OUT = ROOT / 'assets' / 'audio'


def main():
    review = json.loads((HERE / 'review.json').read_text(encoding='utf-8'))
    fixes = {k: v for k, v in review.items() if v['status'] == 'fix'}
    if fixes:
        print('Corrections to apply first (dictionary + migration):')
        for k, v in sorted(fixes.items()):
            print(f'  {k}: {v}')
        sys.exit(1)

    dictionary = json.loads(DICTIONARY.read_text(encoding='utf-8'))
    text = {
        f"{c['id']}-{i}": w[1]
        for c in dictionary['categories']
        for i, w in enumerate(c['words'])
    }
    OUT.mkdir(exist_ok=True)
    index = {}
    for file in sorted((HERE / 'audio').glob('*.webm')):
        key = file.stem
        if key not in text:
            print('skipped, no such word:', key)
            continue
        shutil.copyfile(file, OUT / file.name)
        index.setdefault(text[key].strip().lower(), key)
    for stale in OUT.glob('*.webm'):
        if stale.stem not in index.values():
            stale.unlink()
    (OUT / 'index.json').write_text(
        json.dumps(index, ensure_ascii=False, indent=1, sort_keys=True),
        encoding='utf-8')
    size = sum(f.stat().st_size for f in OUT.glob('*.webm'))
    print(f'{len(index)} recordings, {size // 1024} KB in assets/audio')


if __name__ == '__main__':
    main()
