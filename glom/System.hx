package glom;
import glom.ComponentType.ComponentResult;
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;


@:autoBuild(glom.System.SystemBuilder.build())
class System<Row> {

  var contents:Map<Entity,Row> = new Map();

  var toAdd:Array<Entity> = [];
  var toDrop:Array<Entity> = [];

  function query(e:Entity):ComponentResult<Row> {
    return Err(DeadEntity(e));
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


class SystemBuilder {

#if macro
  public static function build():Array<Field> {
    var fields = Context.getBuildFields();
    var thisClass = Context.getLocalClass().get();
    var rowType = thisClass.superClass.params[0];

    var componentNames = switch (rowType) {
    case TAnonymous(ref): 
    ref.get().fields.map( f -> f.type.toComplexType().toString());
    case TType(ref, _): {
      switch (ref.get().type) {
      case TAnonymous(ref):
        ref.get().fields.map( f -> f.type.toComplexType().toString());
      default: throw "cannot extract types";
      }
    }
    default: throw "cannot extract types";
    };

    var components = componentNames.map( name -> Context.parse(name, Context.currentPos()));
    
    var registerBlock = [];
    for (comp in components)
      registerBlock.push(macro ${comp}.__register( this ));

    fields.push({
      name: "register",
          access:[Access.AOverride],
          kind: FFun({
            expr: macro $b{registerBlock},
                args: [],
                ret: macro : Void}),
          pos: Context.currentPos()
          });

    var complexRowType = rowType.toComplexType();

    var queryBlock = [macro var ob : Dynamic = {}];
    for (idx in 0...components.length) {
      var field = componentNames[idx].split(".").pop().toLowerCase();
      var comp = components[idx];
      queryBlock.push( macro switch (${comp}.__get( e )) {
        case Ok(val): ob.$field = val;
        case Err(err): return Err(err);
        });
    }
    queryBlock.push( macro return Ok( ob ));
    
    
    fields.push({
      name: "query",
          access:[Access.AOverride],
          kind: FFun( {
            expr: macro $b{queryBlock},
                args: [{name: "e", type: macro:glom.Entity}],
                ret: macro : glom.ComponentType.ComponentResult< $complexRowType >
                }),
          pos: Context.currentPos()
          });
    
    return fields;
  }
#end
  
}
