package glom;

import haxe.ds.Maybe;
import haxe.ds.Result;

enum ComponentError {
  DeadEntity(e:Entity);
  EntryNotFound(e:Entity);
}

typedef ComponentResult<Row> = Result<ComponentError,Row>;

typedef ComponentType<Row> = {
  final __name:String;
  function __get (e:Entity):ComponentResult<Row>;
  function __set (e:Entity, r:Row):ComponentResult<Row>;
};



  