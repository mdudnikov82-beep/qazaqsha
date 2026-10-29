/// Kazakh Cyrillic → Latin, after the 2021 alphabet (31 letters: A Ä B D
/// E F G Ğ H I İ J K L M N Ñ O Ö P Q R S Ş T U Ū Ü V Y Z). Letters only
/// found in Russian loanwords (ц, ч, щ, ё, ю, я) become letter pairs.
library;

const _map = <String, String>{
  'а': 'a', 'ә': 'ä', 'б': 'b', 'в': 'v', 'г': 'g', 'ғ': 'ğ', 'д': 'd', //
  'е': 'e', 'ё': 'io', 'ж': 'j', 'з': 'z', 'и': 'i', 'й': 'i', 'к': 'k',
  'қ': 'q', 'л': 'l', 'м': 'm', 'н': 'n', 'ң': 'ñ', 'о': 'o', 'ө': 'ö',
  'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u', 'ұ': 'ū', 'ү': 'ü',
  'ф': 'f', 'х': 'h', 'һ': 'h', 'ц': 'ts', 'ч': 'ch', 'ш': 'ş', 'щ': 'şş',
  'ъ': '', 'ы': 'y', 'і': 'ı', 'ь': '', 'э': 'e', 'ю': 'iu', 'я': 'ia',
};

/// Upper-case forms that differ from a plain toUpperCase: dotted İ for и/й,
/// dotless I for і.
const _upper = <String, String>{'i': 'İ', 'ı': 'I'};

/// [text] in Latin letters; anything that isn't Kazakh Cyrillic stays.
String toLatin(String text) {
  final out = StringBuffer();
  for (final ch in text.split('')) {
    final lower = ch.toLowerCase();
    final latin = _map[lower];
    if (latin == null) {
      out.write(ch);
    } else if (ch != lower && latin.isNotEmpty) {
      final first = latin[0];
      out
        ..write(_upper[first] ?? first.toUpperCase())
        ..write(latin.substring(1));
    } else {
      out.write(latin);
    }
  }
  return out.toString();
}

/// The alphabet for the lesson: Cyrillic letter, Latin letter, example.
const latinAlphabet = <(String, String, String)>[
  ('А а', 'A a', 'ата → ata'),
  ('Ә ә', 'Ä ä', 'әже → äje'),
  ('Б б', 'B b', 'бала → bala'),
  ('В в', 'V v', 'вагон → vagon'),
  ('Г г', 'G g', 'гүл → gül'),
  ('Ғ ғ', 'Ğ ğ', 'ғалым → ğalym'),
  ('Д д', 'D d', 'дос → dos'),
  ('Е е', 'E e', 'ел → el'),
  ('Ж ж', 'J j', 'жол → jol'),
  ('З з', 'Z z', 'заң → zañ'),
  ('И и, Й й', 'İ i', 'ит → it, үй → üi'),
  ('І і', 'I ı', 'іні → ını'),
  ('К к', 'K k', 'көл → köl'),
  ('Қ қ', 'Q q', 'қала → qala'),
  ('Л л', 'L l', 'лақ → laq'),
  ('М м', 'M m', 'мектеп → mektep'),
  ('Н н', 'N n', 'нан → nan'),
  ('Ң ң', 'Ñ ñ', 'таң → tañ'),
  ('О о', 'O o', 'от → ot'),
  ('Ө ө', 'Ö ö', 'өзен → özen'),
  ('П п', 'P p', 'пияз → piiaz'),
  ('Р р', 'R r', 'рахмет → rahmet'),
  ('С с', 'S s', 'су → su'),
  ('Ш ш', 'Ş ş', 'шай → şai'),
  ('Т т', 'T t', 'тау → tau'),
  ('У у', 'U u', 'ұлу → ūlu'),
  ('Ұ ұ', 'Ū ū', 'ұл → ūl'),
  ('Ү ү', 'Ü ü', 'үй → üi'),
  ('Ф ф', 'F f', 'фото → foto'),
  ('Х х, Һ һ', 'H h', 'хат → hat'),
  ('Ы ы', 'Y y', 'ыдыс → ydys'),
];
