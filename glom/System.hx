package glom;
import glom.ComponentType.ComponentResult;

class System<Row> {

  var contents:Map<Entity,Row> = new Map();

  function query(e:Entity):ComponentResult<Row> {
    throw "must override query";
  }

  public function update():Void {
    throw "must override update";
  }

  public function add(e:Entity):ComponentResult<Row> {
    return query(e).onOk( row -> contents[e] = row);
  }

  public function drop(e:Entity):Bool {
    return contents.remove(e);
  }
  
  public function new () {}
}