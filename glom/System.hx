package glom;
import glom.ComponentType.ComponentResult;

class System<Row> {

  var contents:Map<Entity,Row> = new Map();

  var toAdd:Array<Entity> = [];
  var toDrop:Array<Entity> = [];

  function query(e:Entity):ComponentResult<Row> {
    throw "must override query";
  }

  function update(r:Row):Void {
    throw "must override update";
  }

  function register():Void {
    throw "must override register";
  }


  public function run():Void {
    for (e in toAdd) query(e).onOk(row -> contents[e] = row);
    for (e in toDrop) contents.remove(e);
    for (e => row in contents)
      if (e.alive) update(row) else drop(e);
  }
  
  public function add(e:Entity) {
    toAdd.push(e);
  }

  public function drop(e:Entity) {
    toDrop.push(e);
  }
  
  public function new ()
  {
    register();
  }
}