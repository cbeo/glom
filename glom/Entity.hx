package glom;

import haxe.ds.Result;
import glom.ComponentType.ComponentResult;

typedef Index = Int;
typedef Version = Int;

class VersionEntry {
  public var alive:Bool;
  public var version:Version;

  public function new() {
    this.alive = true;
    this.version = 0;
  }
}

class Entity {
  static var freed:Array<Index> = [];
  static var entries:Array<VersionEntry> = [];

  public var index(default, null):Index;
  public var version(default,null):Version;

  public var alive(get,never):Bool;
  function get_alive():Bool {
    return switch(Entity.entries[index]) {
    case null: false;

    case entry: entry.alive && entry.version == version;
    };
  }

  public function new () {
    var idx = Entity.freed.pop();
    if (idx != null) {
      var entry = Entity.entries[idx];
      if (entry == null) throw "Corrupted Entity Table";
      entry.version += 1;
      entry.alive = true;
      this.index = idx;
      this.version = entry.version;
    } else {
      idx = Entity.entries.length;
      Entity.entries.push( new VersionEntry() );
      this.index = idx;
      this.version = 0;
    }
  }

  public function destroy() {
    Entity.entries[index].alive = false;
    Entity.freed.push(index);
  }

  public function add<Row:Component>(r:Row):ComponentResult<Row> {
    return r.__set(this);
  }

  public function drop<Row, Comp:ComponentType<Row>>(comp:Comp):ComponentResult<Row> {
    return comp.__drop(this);
  }

}


