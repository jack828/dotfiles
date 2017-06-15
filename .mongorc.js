DBCollection.prototype.read = function (id) {
  return this.findOne({ _id: ObjectId(id) })
}

DBCollection.prototype.delete = function (id) {
  return this.remove({ _id: ObjectId(id) })
}

function notablescan() {
  var currentValue = db.getSiblingDB('admin').runCommand({ getParameter: 1, notablescan: 1 }).notablescan

  printjson(db.getSiblingDB('admin').runCommand({ setParameter: 1, notablescan: !currentValue }))
}

function clearUpTestDbs() {
  var dbs = db.adminCommand('listDatabases').databases
  dbs.forEach(function (database) {
    if (database.name.match(/^test.+/)) {
      print('Dropping DB: ' + database.name)
      db.getSiblingDB(database.name).dropDatabase()
    }
  })
}

clearUpTestDbs()
