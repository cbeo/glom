package glom;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ComplexTypeTools;

class ComponentBuilder {
  public static function build():Array<Field> {
    var fields = Context.getBuildFields();

    var type = Context.toComplexType(Context.getLocalType());
    var resultType = macro : haxe.ds.Result<glom.Component.ComponentError, $type>;
    var tableType = macro : Array<$type> ;

    fields.push({
      name: "__name",
          access:[Access.AStatic,Access.AFinal, Access.APublic],
          kind: FieldType.FVar(macro:String, macro $v{type.toString().split(".").pop().toLowerCase()}),
          pos: Context.currentPos()
          });

    fields.push({
          name: "__table",
          access:[Access.AStatic,Access.APublic],
          kind: FieldType.FVar( tableType,
                                macro []),
          pos: Context.currentPos()
      });

    fields.push({
      name: "__get",
          access:[Access.AStatic,Access.APublic],
          kind: FFun({
            expr: macro {
                if (!e.alive) return Err(DeadEntity(e));
                var d = __table[e.index];
                return if (d == null) Err(EntryNotFound(e)) else Ok(d);
              },
                args: [{name: "e", type: macro:glom.Entity}],
                ret: resultType
                }),
          pos: Context.currentPos()
          });

    fields.push({
      name: "__set",
          access:[Access.AStatic,Access.APublic],
          kind: FFun({
            expr: macro {
                if (!e.alive) return Err(DeadEntity(e));
                __table[e.index] = val;
                return Ok(val);
              },
                args:[{name: "e", type: macro:glom.Entity},
                      {name: "val", type: type}],
                ret: resultType
                }),
          pos: Context.currentPos()
          });


    return fields;
  }
}