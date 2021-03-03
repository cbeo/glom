package glom;

import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.ComplexTypeTools;

@:autoBuild(glom.ComponentBuilder.build())
interface Component {
  function __set(e:Entity):Any;
}

class ComponentBuilder {
#if macro
  public static function build():Array<Field> {
    var fields = Context.getBuildFields();

    var args = [];
    var states = [];
    for (f in fields) {
      switch (f.kind) {
      case FVar(t,_):
        args.push({name:f.name, type:t, opt:true, value:null});
        states.push(macro if ($i{f.name} != null) $p{["this", f.name]} = $i{f.name});
        f.access.push(APublic);
      default:
      }
    }

    fields.push({
      name: "new",
          access: [APublic],
          pos: Context.currentPos(),
          kind: FFun({
            args: args,
                expr: macro $b{states},
                params: [],
                ret: null
                })
          });

    var type = Context.toComplexType(Context.getLocalType());
    var resultType = macro : glom.ComponentType.ComponentResult< $type > ;
    var entryType = macro : {version: Int, row: $type};
    var tableType = macro : Array<$entryType> ;
    var systemType = macro : { function add(e:Entity):Void;  function drop(e:Entity):Void;};


    fields.push({
          name: "__table",
          access:[Access.AStatic,Access.APublic],
          kind: FieldType.FVar( tableType,
                                macro []),
          pos: Context.currentPos()
      });

    fields.push({
          name: "__systems",
          access:[Access.AStatic,Access.APublic],
          kind: FieldType.FVar( macro : Array< $systemType >,
                                macro []),
          pos: Context.currentPos()
      });

    fields.push({
      name: "__register",
          access:[Access.AStatic,Access.APublic],
          kind: FFun({
            expr: macro {
                if (!__systems.contains(system)) __systems.push(system);
              },
                args: [{name: "system", type: systemType}],
                ret: macro : Void
                }),
          pos: Context.currentPos()
          });

    fields.push({
      name: "__get",
          access:[Access.AStatic,Access.APublic],
          kind: FFun({
            expr: macro {
                if (!e.alive) return Err(DeadEntity(e));
                var d = __table[e.index];
                return if (d == null || e.version != d.version) Err(EntryNotFound(e))
                  else Ok(d.row);
              },
                args: [{name: "e", type: macro:glom.Entity}],
                ret: resultType
                }),
          pos: Context.currentPos()
          });

    fields.push({
      name: "__set",
          access:[Access.APublic],
          kind: FFun({
            expr: macro {
                if (!e.alive) return Err(DeadEntity(e));
                __table[e.index] = {version: e.version, row: this};
                for (system in __systems) system.add( e );
                return Ok(this);
              },
                args:[{name: "e", type: macro:glom.Entity}],
                ret: macro : Any
                }),
          pos: Context.currentPos()
          });

    fields.push({
      name: "__drop",
          access:[Access.AStatic,Access.APublic],
          kind: FFun({
            expr: macro {
                if (!e.alive) return Err(DeadEntity(e));
                var val = __table[e.index];
                __table[e.index] = null;
                if (val != null) {
                  for (system in __systems) system.drop( e );
                  return Ok( val.row );
                }
                return Err(EntryNotFound(e));
              },
                args:[{name: "e", type: macro:glom.Entity}],
                ret: resultType
                }),
          pos: Context.currentPos()
          });

    return fields;
  }
#end
}