package test;

import glom.Entity;
import haxe.ds.Result;
using glom.EntitySelect;

@:structInit
class Person implements glom.Component {
   var name:String;
   var age:Int;
}

@:structInit
class Position implements glom.Component {
   var px:Float;
   var py:Float;
}

class Test {
  public static function main () {
    var e = new Entity();
    var p:Person = {name:"colin", age:9999};

    var mySelect = (e:Entity) -> switch(e.select(Person,Position)) {
    case Ok({person:{name:name,age:age},position:{px:px,py:py}}): 
      trace('$name is $age years old and is located at ($px,$py)');
    case Err(err):
       trace(err);
    };
    
    e.set(Person, p);

    mySelect(e);

    e.set(Position, new Position(22.3, 34.0));

    mySelect(e);

    trace(e.get( Person ));
    trace(e.get( Position ));

    
  }
}