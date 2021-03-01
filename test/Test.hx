package test;

import glom.Entity;
import haxe.ds.Result;
using glom.EntitySelect;

class Person implements glom.Component {
   var name:String;
   var age:Int;
}
class Pos implements glom.Component {
   var px:Float;
   var py:Float;
}
class Test {
  public static function main () {
    // make an entity - an empty container for different kinds of data
    var e = new Entity();

    // here's a function to print info about entities that have both Person and Pos
    var mySelect = (e:Entity) ->
      e.select(Person, Pos)
      .onOk( r -> trace('${r.person.name} is ${r.person.age}  and is at ${r.pos.px},${r.pos.py}'))
      .onError( e -> trace(e));

    // give our entity a Person component
    e.add(new Person("colin", 9999));

    mySelect(e); // EntryNotFound error b/c we don't have a Pos

    e.add(new Pos(22.3, 34.0));

    mySelect(e); //  colin is 9999  and is at 22.3,34

    e.select(Person,Pos).onOk( result -> {
        result.person.age = 39;
        result.pos.px = 0;
        result.pos.py = 0;
      });

    mySelect(e); //   colin is 39  and is at 0,0

    e.drop(Person);

    mySelect(e); // EntryNotFound

    e.destroy();

    mySelect(e); // DeadEntity

    var e2 = new Entity();

    e2.add(new Person("boutade", 0));

    mySelect(e2);

  }
}