package test;

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

class BirthdaySystem extends glom.System<{person:Person}> {
  override function query(e:Entity) {
    return e.select(Person);
  }

  override function update (row) {
    row.person.age += 1;
    trace('${row.person.name} had a birthday! Happy ${row.person.age}!');
  }
}


class Test {
  public static function main () {
    var bdays = new BirthdaySystem();

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
        result.person.name = "colin";
        result.person.age = 39;
        result.pos.moveBy(20,20);
      });

    bdays.add(e);
    bdays.run();

    mySelect(e); //   colin is 39  and is at 10,10

    e.drop(Pos);

    mySelect(e); // EntryNotFound

    e.destroy();
    trace('running bdays, nothing should happen');
    bdays.run();

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