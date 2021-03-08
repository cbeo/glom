package glom;
import glom.ComponentType.ComponentResult;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
#end

typedef SystemType =  {
  function run():Void;
}


@:autoBuild(glom.System.SystemBuilder.build())
class System<Row> {
  
  var contents:Map<Entity,Row> = new Map();

  var toAdd:Array<Entity> = [];
  var toDrop:Array<Entity> = [];

  // do not need to touch this - the build macro defines it
  function query(e:Entity):ComponentResult<Row> {
    throw "must override query";
  }

  function update(r:Row):Void {
    throw "must override update";
  }

  // do not need to touch this - the build macro defines it
  function register():Void {}

  public function run():Void {
    for (e => row in contents)
      if (e.alive) update(row) else drop(e); 
  }

  public function iterator():Iterator<Row> {
    return contents.iterator();
  }

  public function keyValueIterator():KeyValueIterator<Entity,Row> {
    return contents.keyValueIterator();
  }

  public function add(e:Entity) {
    query(e).onOk(row -> {
        contents[e] = row;
        onAdd(row);
      });
  }

  public function drop(e:Entity) {
    if (contents.exists(e)) {
      onDrop( contents[e] );
      contents.remove(e);
    }
  }

  function onAdd(r:Row):Void {};
  function onDrop(r:Row):Void {};
  
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

    var fieldFormatter = (f:ClassField) -> {
      return switch (f.type) {
      case TInst(_,_): {name: f.type.toComplexType().toString(), isOptional:false};
      case TAbstract(_null, [type]):
        {name: type.toComplexType().toString(), isOptional: true};
      default: throw "error formatting row type field";
      }
    };


    var componentNames = switch (rowType) {
    case TAnonymous(ref): 
    ref.get().fields.map( fieldFormatter); //.map( f -> f.type.toComplexType().toString());
    case TType(ref, _): {
      switch (ref.get().type) {
      case TAnonymous(ref):
        ref.get().fields.map( fieldFormatter); //.map( f -> f.type.toComplexType().toString());
      default: throw "cannot extract types";
      }
    }
    default: throw "cannot extract types";
    };

    var components = componentNames.map( f -> Context.parse(f.name, Context.currentPos()));

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
      var field = componentNames[idx].name.split(".").pop().toLowerCase();
      var isOptional = componentNames[idx].isOptional;
      var comp = components[idx];

      if (isOptional) 
        queryBlock.push( macro switch (${comp}.__get( e )) {
          case Ok(val): ob.$field = val;
          case Err(_): ob.$field = null;
          });
      else 
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
