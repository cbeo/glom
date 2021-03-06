
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


// row types can be typedefs that you pass in
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

    // Instantiate systems. Each is registered with its components.
    var bdays = new BirthdaySystem();
    var promos = new PromotionSystem();

    // Make some entities. Empty containers for components.
    var goober = new Entity();
    var bloober = new Entity();

    // Nothing happens b/c our systems have no components yet.
    trace("running birthdays and promos. Nothing should happen.");
    bdays.run();
    promos.run();

    // Adding a Person to goober means that the birthday system 
    // now has something to do.
    goober.add(new Person("Goober",100));
    trace("running birthdays and promos. goober should have a birthday.");
    bdays.run();
    promos.run();

    // Adding another Person component gives us another birthday. 
    // Adding a Job to goober means that the PromotionSystem now 
    // has something to do too.
    bloober.add(new Person("Bloober", 10));
    goober.add(new Job());

    trace("running birthdays and promos.");
    trace("goober should have a birthday and get a promotion.");
    trace("bloober should have a birthday");
    bdays.run();
    promos.run();

    // Both systems use Person, so dropping person from both entities means that
    // the systems again have nothing to do.
    goober.drop(Person);
    bloober.drop(Person);
    trace("running birthdays and promos. Nothing should happen.");
    bdays.run();
    promos.run();
  }
}


```


compiling the above and running with , e.g. neko, would produce:

    running birthdays and promos. Nothing should happen.
    running birthdays and promos. goober should have a birthday.
    Goober had a birthday! Happy 101!
    running birthdays and promos.
    goober should have a birthday and get a promotion.
    bloober should have a birthday
    Bloober had a birthday! Happy 11!
    Goober had a birthday! Happy 102!
    Goober got a raise from 100 to 115
    running birthdays and promos. Nothing should happen.


## Dependenies

Glom depends on [JustResults](https://github.com/cbeo/JustResults),
which provides `Maybe` and a `Result` datatypes and some convenience
functions for using them.

## Some Evil Magic in Row Types

Presently, `glom` depends on one piece of implicit knowledge when it
comes to the "row types" of systems. Row types must be either
_typedefs_ or _anonymous structure types_ as in the two examples
above:

    class BirthdaySystem extends glom.System<{person:Person}> 
    
and 
     
    typedef PromotionRow = {person:Person, job:Job};
    class PromotionSystem extends glom.System<PromotionRow>

Furthermore, each field in a row type is required to have a specific
format.  The *type* of the field *MUST* be a class that implements
`glom.Component`, and the *name* of that field *MUST* be the name of
the class, but all lowercases.

e.g. If you have a component 

    class FooBarGoo implements glom.Component { ... 
    
and you want to make a system that uses the component, its row must
look like:

    typedef MySysRow = {foobargoo: FooBarGoo, person: Person, ... };
    class MySys extends glom.System<MySysRow> { ... 
    
Under the hood, `glom` depends on a few build macros to create
`System` and `Component` types.  It is these build macros that (for
the time being) force the names of fields in row types to be all
lowercase.  In the future that unpleasant requirement may be removed.
