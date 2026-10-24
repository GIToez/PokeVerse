// Sorts the "6500 sprite pokemon" Drive folder by rename_plan.csv: each sheet gets a readable name
// and moves into a numbered subfolder. Paste into a new project at script.google.com, run sortPack
// and allow Drive access. It runs about five minutes at a time and schedules itself to continue
// until every file is done; files already renamed and moved are skipped, so it can run again.
// undoSort puts the original outfit_<n>_.png names back in the main folder.

var ROOT_ID = '1_v7tHXlNW3LQTBQ7V-6J1iahSOXGf3hq';
var PLAN_URL = 'https://raw.githubusercontent.com/GIToez/PokeVerse/cursor/sprite-pack-species-c8d5/docs/sprite-pack-review/rename_plan.csv';
var BUDGET_MS = 5 * 60 * 1000;

function sortPack() {
  run_('sortPack', function (row, folders) {
    var file = DriveApp.getFileById(row.id);
    var folder = folders(row.folder);
    if (file.getName() !== row.name) file.setName(row.name);
    if (!inFolder_(file, folder.getId())) file.moveTo(folder);
  });
}

function undoSort() {
  var root = DriveApp.getFolderById(ROOT_ID);
  run_('undoSort', function (row) {
    var n = (row.name.match(/#(\d+)\.png$/) || [])[1];
    if (!n) return;
    var file = DriveApp.getFileById(row.id);
    var name = 'outfit_' + n + '_.png';
    if (file.getName() !== name) file.setName(name);
    if (!inFolder_(file, ROOT_ID)) file.moveTo(root);
  });
}

function run_(job, apply) {
  var start = Date.now();
  var props = PropertiesService.getScriptProperties();
  var key = job + ':next';
  var rows = plan_();
  var folders = folderCache_();
  var i = Number(props.getProperty(key) || 0);
  var failed = 0;
  for (; i < rows.length; i++) {
    if (Date.now() - start > BUDGET_MS) break;
    try {
      apply(rows[i], folders);
    } catch (e) {
      failed++;
      console.warn('row ' + (i + 2) + ' ' + rows[i].id + ': ' + e.message);
    }
  }
  clearTriggers_(job);
  if (i < rows.length) {
    props.setProperty(key, String(i));
    ScriptApp.newTrigger(job).timeBased().after(60 * 1000).create();
    console.log(job + ': ' + i + ' of ' + rows.length + ' done, continuing in a minute (' + failed + ' failed this run)');
  } else {
    props.deleteProperty(key);
    console.log(job + ': all ' + rows.length + ' files done (' + failed + ' failed this run)');
  }
}

function plan_() {
  var csv = Utilities.parseCsv(UrlFetchApp.fetch(PLAN_URL).getContentText('UTF-8'));
  var head = csv[0];
  return csv.slice(1).filter(function (r) { return r.length === head.length; }).map(function (r) {
    return { id: r[0], folder: r[1], name: r[2] };
  });
}

function folderCache_() {
  var root = DriveApp.getFolderById(ROOT_ID);
  var cache = {};
  return function (name) {
    if (cache[name]) return cache[name];
    var found = root.getFoldersByName(name);
    cache[name] = found.hasNext() ? found.next() : root.createFolder(name);
    return cache[name];
  };
}

function inFolder_(file, folderId) {
  var parents = file.getParents();
  while (parents.hasNext()) {
    if (parents.next().getId() === folderId) return true;
  }
  return false;
}

function clearTriggers_(job) {
  ScriptApp.getProjectTriggers().forEach(function (t) {
    if (t.getHandlerFunction() === job) ScriptApp.deleteTrigger(t);
  });
}
