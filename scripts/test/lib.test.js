var test = require('tape');
var Lib = require('../kv-lib');

test('kv lib', function (t) {
  t.plan(6);

  Lib.items(function (err, items) {
    t.notOk(err, 'no error');
    t.ok(isFinite(Object.keys(items).length), 'gets items');
  });
  Lib.abilities(function (err, abilities) {
    t.notOk(err, 'no error');
    t.ok(isFinite(Object.keys(abilities).length), 'gets abilities');
  });
  Lib.all(function (err, all) {
    t.notOk(err, 'no error');
    t.ok(isFinite(Object.keys(all).length), 'gets all');
  });
});
