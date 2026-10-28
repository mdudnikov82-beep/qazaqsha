"""Tests for the bot. Run: python -m unittest discover bot"""

import unittest

import qazaqsha_bot as bot

# The same vector is checked in test/features/word_import_test.dart, so the
# bot and the app agree on the code format byte for byte.
SHARED_WORDS = [('кітап', 'книга'), ('жүрек', 'сердце'), ('ата-ана', 'родители')]
SHARED_CODE = (
    'eyJ2IjoxLCJ3IjpbWyLQutGW0YLQsNC_Iiwi0LrQvdC40LPQsCJdLFsi0LbSr9GA0LXQuiIs'
    'ItGB0LXRgNC00YbQtSJdLFsi0LDRgtCwLdCw0L3QsCIsItGA0L7QtNC40YLQtdC70LgiXV19'
)


class CodeFormat(unittest.TestCase):
    def test_matches_the_app(self):
        self.assertEqual(bot.encode_words(SHARED_WORDS), SHARED_CODE)

    def test_links(self):
        self.assertEqual(
            bot.web_import_link('X'),
            'https://mdudnikov82-beep.github.io/qazaqsha/#/import?w=X',
        )
        self.assertEqual(bot.app_import_link('X'), 'qazaqsha://app/import?w=X')


class Parsing(unittest.TestCase):
    def test_separators_and_markers(self):
        text = (
            'кітап — книга\n1. қалам - ручка\n• дәптер – тетрадь\n'
            'сабақ\tурок\nмектеп = школа\nсынып: класс\n'
        )
        self.assertEqual(bot.parse_word_lines(text), [
            ('кітап', 'книга'), ('қалам', 'ручка'), ('дәптер', 'тетрадь'),
            ('сабақ', 'урок'), ('мектеп', 'школа'), ('сынып', 'класс'),
        ])

    def test_hyphenated_words_stay_whole(self):
        self.assertEqual(bot.parse_word_lines('ата-ана — родители'),
                         [('ата-ана', 'родители')])

    def test_flips_russian_first(self):
        self.assertEqual(bot.parse_word_lines('сердце — жүрек'),
                         [('жүрек', 'сердце')])
        self.assertEqual(bot.parse_word_lines('бала — ребёнок'),
                         [('бала', 'ребёнок')])

    def test_junk_duplicates_and_limits(self):
        long = 'а' * (bot.MAX_WORD_LENGTH + 1)
        self.assertEqual(
            bot.parse_word_lines(f'просто текст\nкітап — книга\nкітап — книга\n{long} — x'),
            [('кітап', 'книга')],
        )
        many = '\n'.join(f'сөз{i} — слово{i}' for i in range(150))
        self.assertEqual(len(bot.parse_word_lines(many)), bot.MAX_IMPORT_WORDS)


class Replies(unittest.TestCase):
    def test_start_shows_help(self):
        for cmd in ('/start', '/help', '/start@Kei9jkBot'):
            [reply] = bot.build_replies(cmd)
            self.assertIn('Мои слова', reply['text'])

    def test_nothing_found(self):
        [reply] = bot.build_replies('привет')
        self.assertIn('Не нашёл', reply['text'])
        self.assertNotIn('reply_markup', reply)

    def test_words_get_a_button_and_a_code(self):
        [reply] = bot.build_replies('кітап — книга\n<b> — тег')
        button = reply['reply_markup']['inline_keyboard'][0][0]
        code = bot.encode_words([('кітап', 'книга'), ('<b>', 'тег')])
        self.assertEqual(button['url'], bot.web_import_link(code))
        self.assertIn(f'<code>{code}</code>', reply['text'])
        # User text is escaped, so it can't break the HTML markup.
        self.assertIn('&lt;b&gt;', reply['text'])

    def test_long_lists_are_split(self):
        text = '\n'.join(f'сөз{i} — слово{i}' for i in range(90))
        replies = bot.build_replies(text)
        self.assertEqual(len(replies), 3)
        self.assertIn('часть 1 из 3', replies[0]['text'])
        for r in replies:
            self.assertLess(len(r['text']), 4096)  # Telegram message limit
            self.assertLess(len(r['reply_markup']['inline_keyboard'][0][0]['url']), 2048)


if __name__ == '__main__':
    unittest.main()
