package test;

import glom.Entity;
import haxe.ds.Result;

using glom.EntitySelect;

class Test {
  public static function main () {
    var e = new Entity();
    e.set(Comp1, new Comp1("hey",10));
    e.set(Comp2, new Comp2(22.3, 34.0));

    e.select(Comp1,Comp2).onOk( (result : {comp1:Comp1,comp2:Comp2}) -> {
        result.comp1.name = "dude";
        result.comp2.px = 1000.00;
      });

    trace(e.get( Comp1 ));
    trace(e.get( Comp2 ));
        
    

  }
}