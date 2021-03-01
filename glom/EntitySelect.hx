package glom;

import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.Tools;

using Lambda;
using haxe.macro.ExprTools;
using haxe.macro.MacroStringTools;


class EntitySelect {

  /* 
     var ret:ReturnType;

     entity.get(Moo)
       .then(moo -> {ret.moo = moo; return entity.get(Foo)})
       .then(foo -> {ret.foo = foo; return entity.get(Zoo)})
       .map(zoo -> {ret.zoo = zoo; return zoo});

   */  


  public static macro function select(ent:Expr, exprs:Array<Expr>) {
    var pos = Context.currentPos();

    var ident = (expr:Expr) -> switch (expr.expr) {
    case EConst(CIdent(name)): name.toLowerCase().split(".").pop();
    default: throw "Cannot get ident";
    };

    var blankOb = {expr:EObjectDecl( [ for (expr in exprs) {field: ident(expr), expr: macro null}]),
      pos:pos};

    var block = [macro var ob = $blankOb];

    for (expr in exprs) {
      var field = ident(expr);
      block.push( macro switch ($ent.get( $expr )) {
        case Ok(val): ob.$field = val; 
        case Err(err): return Err(err);
        });
    }

    block.push( macro return Ok(ob) );

    return macro (() -> $b{block})();
  }

}