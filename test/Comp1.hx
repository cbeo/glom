package test;

@:build(glom.ComponentBuilder.build())
class Comp1 {
  public var name:String;
  public var age:Int;

  public function new (n,a) { this.name = n; this.age = a; }

}