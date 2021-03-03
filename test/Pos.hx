package test;

class Pos implements glom.Component {
   var px:Float = 0.0;
   var py:Float = 0.0;

  public function moveBy(dx,dy) {
    px += dx;
    py += dy;
  }

}
