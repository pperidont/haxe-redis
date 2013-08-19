package redis;


@:autoBuild(redis.Macros.macroBuild())
@:keepSub @:skipFields
class Object<T> {
	public var id(default,null) : String;

	public function new( id : T ){
		this.id = Std.string(id);
	}

	public function delete(){
		var fields : String = haxe.rtti.Meta.getType( Type.getClass(this) ).fields[0];
		var a = [];
		for( f in fields.split(",") )
			a.push( f.split("%").join(id) );
		Key.CNX.del(a);
	}
}
