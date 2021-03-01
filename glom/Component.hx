package glom;

import haxe.ds.Maybe;
import haxe.ds.Result;

enum ComponentError {
  DeadEntity(e:Entity);
  EntryNotFound(e:Entity);
}

typedef Component<Row> = {
  final __name:String;
  function __get (e:Entity):Result<ComponentError,Row>;
  function __set (e:Entity, r:Row):Result<ComponentError,Row>;
};



  