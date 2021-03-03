
`glom` lets you do things like:

``` haxe

/* Components are just data containers */

class Job implements glom.Component {
  var salary:Float = 100.00;
}

class Person implements glom.Component {
   var name:String = "";
   var age:Int = 0;
}


/* Systems operate on rows which are associated with entities.
   A system automatically registers with the components in its row type 
*/

class BirthdaySystem extends glom.System<{person:Person}> {
  override function update (row) {
    row.person.age += 1;
    trace('${row.person.name} had a birthday! Happy ${row.person.age}!');
  }
}


typedef PromotionRow = {person:Person, job:Job};
class PromotionSystem extends glom.System<PromotionRow> {
  override function update (row:PromotionRow) {
    var oldSalary = row.job.salary;
    row.job.salary *= 1.15;
    trace('${row.person.name} got a raise from $oldSalary to ${row.job.salary}');
  }
}


class Main {

  public static function main ()  {

    // instantiate some systems
    var bdays = new BirthdaySystem();
    var promos = new PromotionSystem();

    var goober = new Entity();

    trace("running birthdays and promos. Nothing should happen.");
    bdays.run();
    promos.run();

    // whenever a component is added to an entity, relevant systems are updated
    goober.add(new Person("Goober",99));
    trace("running birthdays and promos. goober should have a birthday.");
    bdays.run();
    promos.run();

    goober.add(new Job());
    trace("running birthdays and promos. goober should have a birthday and get a promotion.");
    bdays.run();
    promos.run();

    goober.drop(Person);
    trace("running birthdays and promos. Nothing should happen.");
    bdays.run();
    promos.run();
  }
}


```


compiling the above and running with , e.g. neko, would produce:

    running birthdays and promos. Nothing should happen.
    running birthdays and promos. goober shoul dhave a birthday.
    Goober had a birthday! Happy 100!
    running birthdays and promos. goober should have a birthday and get a promotion.
    Goober had a birthday! Happy 101!
    Goober got a raise from 100 to 115
    running birthdays and promos. Nothing should happen.
      

