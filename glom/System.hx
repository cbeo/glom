package glom;
import glom.ComponentType.ComponentResult;

class System<Row> {

  var contents:Map<Entity,Row> = new Map();

  function query(e:Entity):ComponentResult<Row> {
    throw "must override query";
  }

  function update(r:Row):Void {
    throw "must override update";
  }

  public function run():Void {
    for (e => row in contents)
      if (e.alive) update(row);
  }
  
  public function add(e:Entity):ComponentResult<Row> {
    return query(e).onOk( row -> contents[e] = row);
  }

  public function drop(e:Entity):Bool {
    return contents.remove(e);
  }
  
  public function new () {}
}