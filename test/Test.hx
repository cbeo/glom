package test;


class Job implements glom.Component {
  var salary:Float = 100.00;
}

class Person implements glom.Component {
   var name:String = "";
   var age:Int = 0;
}

class Bongos {
  var bongos:String;
  public function new (b) {
    bongos = b;
  }
}

class Pos extends Bongos implements glom.Component {
   var px:Float = 0.0;
   var py:Float = 0.0;

  public function new (b) {
    super(b);
  }

  public function moveBy(dx,dy) {
    px += dx;
    py += dy;
  }
}

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


class Test {

  public static function main ()  {
    //test1();
    test2();
  }

  public static function test2 () {
    var bdays = new BirthdaySystem();
    var promos = new PromotionSystem();

    var goober = new Entity();
    var bloober = new Entity();

    trace("running birthdays and promos. Nothing should happen.");
    bdays.run();
    promos.run();

    goober.add(new Person("Goober",100));
    trace("running birthdays and promos. goober should 11have a birthday.");
    bdays.run();
    promos.run();

    bloober.add(new Person("Bloober", 10));
    goober.add(new Job());

    trace("running birthdays and promos.");
    trace("goober should have a birthday and get a promotion.");
    trace("bloober should have a birthday");
    bdays.run();
    promos.run();

    goober.drop(Person);
    bloober.drop(Person);
    trace("running birthdays and promos. Nothing should happen.");
    bdays.run();
    promos.run();
  }

  public static function test1 () {
    var bdays = new BirthdaySystem();
    var promos = new  PromotionSystem();

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

    e.add(new Pos("my bongos"));

    mySelect(e); //  is 0  and is at 0,0

    e.select(Person,Pos).onOk( result -> {
        result.person.name = "goober";
        result.person.age = 39;
        result.pos.moveBy(20,20);
      });

    bdays.run();

    mySelect(e); //   goober is 39  and is at 10,10

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

    promos.run();

  }
}