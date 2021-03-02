
`glom` lets you do things like:

``` haxe

import glom.Entity;
import glom.ComponentType.ComponentError;
import haxe.ds.Result;

using glom.EntitySelect;

class Person implements glom.Component {
   var name:String = "";
   var age:Int = 0;
}
class Pos implements glom.Component {
   var px:Float = 0.0;
   var py:Float = 0.0;

  public function moveBy(dx,dy) {
    px += dx;
    py += dy;
  }

}
class Job implements glom.Component {
  var salary:Float = 100.00;
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
    e.add(new Person());

    mySelect(e); // EntryNotFound error b/c we don't have a Pos

    e.add(new Pos());

    mySelect(e); //  is 0  and is at 0,0

    e.select(Person,Pos).onOk( result -> {
        result.person.name = "goober";
        result.person.age = 7;
        result.pos.moveBy(20,20);
      });

    mySelect(e); //   goober is 7  and is at 10,10

    e.drop(Person);

    mySelect(e); // EntryNotFound

    e.destroy();

    mySelect(e); // DeadEntity

    var e2 = new Entity();

    e2.add(new Person("boutade"));

    mySelect(e2); // EntryNotFound

    e2.add(new Job());

    e2.select(Person, Job)
      .onOk( r -> trace('${r.person.name} makes ${"$" + r.job.salary} per year'));
    // boutade makes $100 per year

  }
}

```

Compiling and running the above prints out:

     $ neko main.n
     Main.hx:33: EntryNotFound({ version => 0, index => 0 })
     Main.hx:32:  is 0  and is at 0,0
     Main.hx:32: goober is 7  and is at 20,20
     Main.hx:33: EntryNotFound({ version => 0, index => 0 })
     Main.hx:33: DeadEntity({ version => 0, index => 0 })
     Main.hx:33: EntryNotFound({ version => 1, index => 0 })
     Main.hx:69: boutade makes $100 per year
