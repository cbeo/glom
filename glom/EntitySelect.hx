package glom;

import haxe.macro.Expr;
import haxe.macro.Context;
using haxe.macro.Tools;

using Lambda;
using haxe.macro.ExprTools;
using haxe.macro.MacroStringTools;


class EntitySelect {

  public static macro function select(ent:Expr, exprs:Array<Expr>) {
    var pos = Context.currentPos();

    var ident = (expr:Expr) -> switch (expr.expr) {
    case EConst(CIdent(name)): name.toLowerCase().split(".").pop();
    default: throw "Cannot get ident";
    };

    var typeFromExpr = (expr:Expr) -> switch (expr.expr) {
    case EConst(CIdent(name)): Context.toComplexType(Context.getType(name));
    default: throw "Cannot get type from expr";
    };
    
    var blankOb = {expr:EObjectDecl( [ for (expr in exprs) {field: ident(expr), expr: macro null}]),
      pos:pos};

    var blankObTypeFields = [for (expr in exprs)
        {pos:pos, name: ident(expr), kind: FVar(typeFromExpr( expr ))}];

    var blankObType = TAnonymous(blankObTypeFields);
    
    //var block = [macro var ob : $blankObType];
    var block = [macro var ob = $blankOb];

    for (expr in exprs) {
      var field = ident(expr);
      block.push( macro switch ($expr.__get( $ent )) {
        case Ok(val): ob.$field = val; 
        case Err(err): return Err(err);
        });
    }
    block.push( macro return Ok( (ob : $blankObType) ));

    return macro (() -> $b{block})();
  }

}