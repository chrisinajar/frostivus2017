var request = require('request');
var parseTranslation = require('./parse-translation');
var fs = require('fs');
var path = require('path');
var parseKV = require('parse-kv');

var languageShortNames = {
  german: 'de',
  russian: 'ru',
  chinese: 'zh',
  portuguese: 'pt',
  spanish: 'es',
  czech: 'cs',
  polish: 'pl',
  dutch: 'nl',
  hungarian: 'hu'
};
var englishFileString = parseTranslation(false);
var englishData = parseKV(englishFileString);
var transByValue = {};
var dotaEnglish = {};
var unchagedKeys = {};

getDuplicateStrings();

englishFileString = [
  '//---------------------------------------------------------------------------',
  '// This file is generated from a script. Do not edit it directly other than for testing. Your edits will be deleted.',
  '//---------------------------------------------------------------------------',
  '',
  englishFileString
].join('\n');

fs.writeFileSync(path.join(__dirname, '../game/resource/addon_english.txt'), '\ufeff' + englishFileString, {
  encoding: 'ucs2'
});
process.exit(0);

if (!process.env.TRANSIFEX_USER || !process.env.TRANSIFEX_PASSWORD) {
  console.log('No TRANSIFEX_USER or TRANSIFEX_PASSWORD, not generating translations (english only)');
  process.exit(0);
} else {
  request.get({
    url: 'https://raw.githubusercontent.com/SteamDatabase/GameTracking-Dota2/master/game/dota/resource/dota_english.txt'
  }, function (err, result) {
    if (err) {
      throw err;
    }
    dotaEnglish = parseKV(result.body);
    Object.keys(dotaEnglish.lang.Tokens.values).forEach(function (key) {
      if (!transByValue[dotaEnglish.lang.Tokens.values[key]]) {
        transByValue[dotaEnglish.lang.Tokens.values[key]] = key.toLowerCase();
      }
    });
    Object.keys(englishData.lang.Tokens.values).forEach(function (key) {
      if (!unchagedKeys[key.toLowerCase()] && transByValue[englishData.lang.Tokens.values[key]]) {
        unchagedKeys[key.toLowerCase()] = transByValue[englishData.lang.Tokens.values[key]];
        console.log(key, 'is unchanged from', unchagedKeys[key]);
      }
    });
  });

  Object.keys(languageShortNames).map(generateTranslations);
}

// functions

function getDuplicateStrings () {
  var foundStrings = {};
  var duplicateStrings = {};

  Object.keys(englishData.lang.Tokens.values).forEach(function (key) {
    var str = englishData.lang.Tokens.values[key];
    if (foundStrings[str]) {
      if (!duplicateStrings[foundStrings[str]]) {
        duplicateStrings[foundStrings[str]] = {
          string: str,
          keys: [key]
        };
      } else {
        duplicateStrings[foundStrings[str]].keys.push(key);
      }
      return;
    }

    foundStrings[str] = key;
  });

  return duplicateStrings;
}

function getTranslationsForLanguage (lang, cb) {
  request.get({
    url: 'http://www.transifex.com/api/2/project/open-angel-arena/resource/addon_english/translation/' + lang + '?mode=onlytranslated',
    auth: {
      user: process.env.TRANSIFEX_USER,
      pass: process.env.TRANSIFEX_PASSWORD
    },
    json: true
  }, function (err, data) {
    if (typeof data.body !== 'object') {
      console.error('Unexpected output: ', data.body);
      return cb(new Error('Unexpected output from transifex server. Check user / password'));
    }
    data = JSON.parse(data.body.content);
    cb(err, data);
  });
}

function getUnchangedStrings (languageName, cb) {
  if (languageName === 'chinese') {
    languageName = 'schinese';
  }
  request.get({
    url: 'https://raw.githubusercontent.com/SteamDatabase/GameTracking-Dota2/master/game/dota/resource/dota_' + languageName + '.txt'
  }, function (err, result) {
    if (err) {
      console.error(languageName);
      throw err;
    }
    var dotaKVs = parseKV(result.body);
    var translatedKeys = {};
    Object.keys(dotaKVs.lang.Tokens.values).forEach(function (key) {
      dotaKVs.lang.Tokens.values[key.toLowerCase()] = dotaKVs.lang.Tokens.values[key];
    });
    Object.keys(unchagedKeys).forEach(function (key) {
      if (dotaKVs.lang.Tokens.values[unchagedKeys[key]]) {
        translatedKeys[key] = dotaKVs.lang.Tokens.values[unchagedKeys[key]];
      } else {
        console.log(languageName, 'No unchaged value for', key, unchagedKeys[key]);
      }
    });
    cb(translatedKeys);
  });
}

function generateFileForTranslations (languageName, translations, cb) {
  var duplicateStrings = getDuplicateStrings();
  getUnchangedStrings(languageName, function (translatedKeys) {
    var lines = [];
    lines.push('"lang"');
    lines.push('{');
    lines.push('  "Language"      "' + languageName + '"');
    lines.push('  "Tokens"');
    lines.push('  {');
    lines.push('    //==================================================================================');
    lines.push('    // This file is auto-generated, do not edit it directly. Your changes will be lost.');
    lines.push('    //==================================================================================');
    lines.push();

    Object.keys(translatedKeys).map(function (key) {
      var indent = (new Array(100 - key.length)).join(' ');
      lines.push('    ' + JSON.stringify(key) + indent + JSON.stringify(translatedKeys[key]));
    });

    Object.keys(translations).forEach(function (key) {
      if (!translations[key].length) {
        return;
      }
      if (duplicateStrings[key]) {
        lines.push();
      }
      var indent = (new Array(100 - key.length)).join(' ');
      lines.push('    ' + JSON.stringify(key) + indent + JSON.stringify(translations[key].replace(/\\n/g, '\n')));

      if (duplicateStrings[key]) {
        duplicateStrings[key].keys.forEach(function (dupKey) {
          var indent = (new Array(100 - dupKey.length)).join(' ');
          lines.push('    ' + JSON.stringify(dupKey) + indent + JSON.stringify(translations[key].replace(/\\n/g, '\n')));
        });
      }
    });
    // done
    lines.push('  }');
    lines.push('}');
    lines.push('');

    cb(lines);
  });
}

function generateTranslations (lang) {
  getTranslationsForLanguage(languageShortNames[lang], function (err, data) {
    if (err) {
      throw err;
    }

    // translations
    generateFileForTranslations(lang, data, function (lines) {
      fs.writeFileSync(path.join(__dirname, '../game/resource/addon_' + lang + '.txt'), '\ufeff' + lines.join('\n'), {
        encoding: 'ucs2'
      });
    });
  });
}
