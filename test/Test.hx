package test;

import glom.Entity;

class Test {
  public static function main () {
    trace(Comp1.__name);
    var c1 = new Comp1("hey",10);
    var e = new Entity();
    e.set(Comp1, c1);
    e.get(Comp1).onOk( (val:Comp1) -> trace(val.name));
  }
}