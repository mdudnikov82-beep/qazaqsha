"""Local review studio for the Qazaqsha dictionary.

Run from the project root:  python tools/review/server.py
then open http://127.0.0.1:8765 in Chrome on this computer.

A native speaker marks every word as right or writes a correction, and
records the word with the microphone. Marks go to tools/review/review.json,
recordings to tools/review/audio/<key>.webm, where <key> is
"<category id>-<index in category>" from assets/data/dictionary.json.
Only this computer can reach the server (it listens on 127.0.0.1).
"""
import json
import re
import sys
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
DICTIONARY = ROOT / 'assets' / 'data' / 'dictionary.json'
STATE = HERE / 'review.json'
AUDIO = HERE / 'audio'
PORT = 8765
KEY = re.compile(r'^[a-z0-9_]+-\d+$')
MAX_AUDIO = 2 * 1024 * 1024

lock = threading.Lock()


def load_state():
    if STATE.exists():
        return json.loads(STATE.read_text(encoding='utf-8'))
    return {}


def save_state(state):
    tmp = STATE.with_suffix('.tmp')
    tmp.write_text(json.dumps(state, ensure_ascii=False, indent=1, sort_keys=True),
                   encoding='utf-8')
    tmp.replace(STATE)


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def send(self, code, body=b'', ctype='application/json; charset=utf-8'):
        self.send_response(code)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(body)

    def json(self, obj, code=200):
        self.send(code, json.dumps(obj, ensure_ascii=False).encode('utf-8'))

    def key_param(self):
        key = self.path.split('key=', 1)[-1] if 'key=' in self.path else ''
        return key if KEY.match(key) else None

    def do_GET(self):
        path = self.path.split('?', 1)[0]
        if path == '/':
            self.send(200, (HERE / 'index.html').read_bytes(),
                      'text/html; charset=utf-8')
        elif path == '/api/data':
            with lock:
                state = load_state()
            audio = sorted(p.stem for p in AUDIO.glob('*.webm'))
            dictionary = json.loads(DICTIONARY.read_text(encoding='utf-8'))
            self.json({'dictionary': dictionary, 'review': state, 'audio': audio})
        elif path == '/api/audio':
            key = self.key_param()
            file = AUDIO / f'{key}.webm' if key else None
            if file and file.exists():
                self.send(200, file.read_bytes(), 'audio/webm')
            else:
                self.send(404)
        else:
            self.send(404)

    def do_POST(self):
        path = self.path.split('?', 1)[0]
        length = int(self.headers.get('Content-Length', 0))
        if path == '/api/review':
            body = json.loads(self.rfile.read(length) or b'{}')
            key = body.get('key', '')
            if not KEY.match(key):
                return self.json({'error': 'bad key'}, 400)
            with lock:
                state = load_state()
                if body.get('status') in ('ok', 'fix'):
                    state[key] = {k: str(body.get(k, ''))[:300]
                                  for k in ('status', 'ru', 'kk', 'hint', 'note')}
                else:
                    state.pop(key, None)
                save_state(state)
            self.json({'saved': key})
        elif path == '/api/audio':
            key = self.key_param()
            if not key or not 0 < length <= MAX_AUDIO:
                return self.json({'error': 'bad recording'}, 400)
            AUDIO.mkdir(exist_ok=True)
            (AUDIO / f'{key}.webm').write_bytes(self.rfile.read(length))
            self.json({'saved': key})
        else:
            self.send(404)

    def do_DELETE(self):
        key = self.key_param()
        if self.path.startswith('/api/audio') and key:
            (AUDIO / f'{key}.webm').unlink(missing_ok=True)
            return self.json({'deleted': key})
        self.send(404)


if __name__ == '__main__':
    server = ThreadingHTTPServer(('127.0.0.1', PORT), Handler)
    print(f'Студия проверки: http://127.0.0.1:{PORT}  (Ctrl+C — остановить)')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        sys.exit(0)
