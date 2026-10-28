"""Telegram bot that turns «сөз — слово» lines into a Qazaqsha import link.

The bot keeps nothing: every message is parsed, answered with a link and
forgotten. Only the standard library is used, so it runs anywhere with
Python 3.10+:

    QAZAQSHA_BOT_TOKEN=... python qazaqsha_bot.py

(or put QAZAQSHA_BOT_TOKEN=... into bot/.env next to this file).

The parsing rules and the code format mirror
lib/features/custom_words/word_import.dart in the app; a shared test vector
in both test suites keeps them in sync.
"""

from __future__ import annotations

import base64
import html
import json
import logging
import os
import re
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

# --- Parsing and code format (keep in sync with word_import.dart) ----------

MAX_IMPORT_WORDS = 100
MAX_WORD_LENGTH = 60
KAZAKH_EXTRA_LETTERS = 'әғқңөұүһі'

WEB_IMPORT_BASE = 'https://mdudnikov82-beep.github.io/qazaqsha/#/import'
APP_IMPORT_BASE = 'qazaqsha://app/import'

# A dash with spaces around it (so «ата-ана» stays whole), a tab, «=» or «:».
_SEPARATOR = re.compile(r'\s+[—–-]\s+|\t+|\s*=\s*|\s*:\s+')
_LIST_MARKER = re.compile(r'^\s*(?:[-•*]|\d+[.)])\s*')
_KAZAKH_ONLY = re.compile(
    '[' + KAZAKH_EXTRA_LETTERS + KAZAKH_EXTRA_LETTERS.upper() + ']'
)

Word = tuple[str, str]  # (kk, ru)


def has_kazakh_letters(s: str) -> bool:
    return bool(_KAZAKH_ONLY.search(s))


def parse_word_lines(text: str) -> list[Word]:
    """One pair per line, Kazakh first; a Russian-first line is flipped when
    only its second half has Kazakh letters."""
    words: list[Word] = []
    for raw in text.splitlines():
        line = _LIST_MARKER.sub('', raw, count=1).strip()
        parts = _SEPARATOR.split(line)
        if len(parts) != 2:
            continue
        kk, ru = parts[0].strip(), parts[1].strip()
        if not has_kazakh_letters(kk) and has_kazakh_letters(ru):
            kk, ru = ru, kk
        words.append((kk, ru))
    return _clean(words)


def _clean(words: list[Word]) -> list[Word]:
    seen: set[Word] = set()
    result: list[Word] = []
    for kk, ru in words:
        if not kk or not ru:
            continue
        if len(kk) > MAX_WORD_LENGTH or len(ru) > MAX_WORD_LENGTH:
            continue
        if (kk, ru) in seen:
            continue
        seen.add((kk, ru))
        result.append((kk, ru))
    return result[:MAX_IMPORT_WORDS]


def encode_words(words: list[Word]) -> str:
    """base64url of {"v":1,"w":[[kk,ru],…]} without padding — byte for byte
    what the app's encodeWords() produces."""
    payload = json.dumps(
        {'v': 1, 'w': [[kk, ru] for kk, ru in words]},
        ensure_ascii=False,
        separators=(',', ':'),
    )
    return base64.urlsafe_b64encode(payload.encode('utf-8')).decode('ascii').rstrip('=')


def web_import_link(code: str) -> str:
    return f'{WEB_IMPORT_BASE}?w={code}'


def app_import_link(code: str) -> str:
    return f'{APP_IMPORT_BASE}?w={code}'


# --- Replies -----------------------------------------------------------------

# Words per link: keeps each link well under URL length limits.
WORDS_PER_LINK = 40
PREVIEW_WORDS = 15

HELP_TEXT = (
    '<b>Сәлем!</b> Я помогаю добавлять свои слова в приложение '
    '<b>Qazaqsha</b>.\n\n'
    'Пришлите слова — по одной паре на строке:\n'
    '<code>кітап — книга\n'
    'қалам — ручка</code>\n\n'
    'Можно писать и наоборот («книга — кітап»), через «-», «=» или «:». '
    'В ответ пришлю ссылку: нажмите её, и слова появятся в разделе '
    '«Мои слова».\n\n'
    'Я ничего не сохраняю: ваши слова живут только в приложении.'
)

NOTHING_FOUND = (
    'Не нашёл ни одной пары 🤔\n\n'
    'Пишите по одной паре на строке, между словами — тире с пробелами:\n'
    '<code>кітап — книга</code>'
)


def chunks(words: list[Word], size: int) -> list[list[Word]]:
    return [words[i:i + size] for i in range(0, len(words), size)]


def build_replies(text: str) -> list[dict]:
    """sendMessage parameters (minus chat_id) answering one user message."""
    first = text.strip().split(maxsplit=1)[0:1]
    # In groups commands arrive as /start@BotName.
    if first and first[0].split('@')[0] in ('/start', '/help'):
        return [{'text': HELP_TEXT, 'parse_mode': 'HTML'}]

    words = parse_word_lines(text)
    if not words:
        return [{'text': NOTHING_FOUND, 'parse_mode': 'HTML'}]

    replies = []
    parts = chunks(words, WORDS_PER_LINK)
    for n, part in enumerate(parts, start=1):
        code = encode_words(part)
        lines = [f'<b>{html.escape(kk)}</b> — {html.escape(ru)}'
                 for kk, ru in part[:PREVIEW_WORDS]]
        if len(part) > PREVIEW_WORDS:
            lines.append(f'…и ещё {len(part) - PREVIEW_WORDS}')
        title = f'Слов: {len(part)}'
        if len(parts) > 1:
            title += f' (часть {n} из {len(parts)})'
        body = (
            f'<b>{title}</b>\n' + '\n'.join(lines) + '\n\n'
            'Нажмите кнопку, чтобы добавить их в «Мои слова».\n'
            'В приложении для Android можно вставить этот код '
            '(Словарь → ➕):\n'
            f'<code>{code}</code>'
        )
        replies.append({
            'text': body,
            'parse_mode': 'HTML',
            'reply_markup': {
                'inline_keyboard': [[{
                    'text': '📥 Добавить в Qazaqsha',
                    'url': web_import_link(code),
                }]],
            },
        })
    return replies


# --- Telegram long polling -----------------------------------------------------

log = logging.getLogger('qazaqsha_bot')


class TelegramApi:
    def __init__(self, token: str):
        self._base = f'https://api.telegram.org/bot{token}/'

    def call(self, method: str, params: dict, timeout: float = 30) -> dict:
        data = json.dumps(params).encode('utf-8')
        request = urllib.request.Request(
            self._base + method,
            data=data,
            headers={'Content-Type': 'application/json'},
        )
        with urllib.request.urlopen(request, timeout=timeout) as response:
            body = json.load(response)
        if not body.get('ok'):
            raise RuntimeError(f'{method}: {body.get("description")}')
        return body['result']


def run(token: str) -> None:
    api = TelegramApi(token)
    me = api.call('getMe', {})
    log.info('Running as @%s', me['username'])
    offset = 0
    while True:
        try:
            updates = api.call(
                'getUpdates',
                {'offset': offset, 'timeout': 50, 'allowed_updates': ['message']},
                timeout=60,
            )
        except (urllib.error.URLError, TimeoutError, RuntimeError) as e:
            log.warning('getUpdates failed: %s; retrying in 5 s', e)
            time.sleep(5)
            continue
        for update in updates:
            offset = update['update_id'] + 1
            message = update.get('message') or {}
            text = message.get('text')
            if not text:
                continue
            chat_id = message['chat']['id']
            replies = build_replies(text)
            # Log sizes only — never the words themselves.
            log.info('message → %d repl%s', len(replies), 'y' if len(replies) == 1 else 'ies')
            for reply in replies:
                try:
                    api.call('sendMessage', {'chat_id': chat_id, **reply})
                except (urllib.error.URLError, TimeoutError, RuntimeError) as e:
                    log.warning('sendMessage failed: %s', e)


def load_token() -> str:
    token = os.environ.get('QAZAQSHA_BOT_TOKEN')
    env_file = Path(__file__).with_name('.env')
    if not token and env_file.exists():
        for line in env_file.read_text(encoding='utf-8').splitlines():
            key, _, value = line.partition('=')
            if key.strip() == 'QAZAQSHA_BOT_TOKEN':
                token = value.strip()
    if not token:
        raise SystemExit(
            'Set QAZAQSHA_BOT_TOKEN in the environment or in bot/.env'
        )
    return token


if __name__ == '__main__':
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s %(levelname)s %(message)s',
    )
    run(load_token())
