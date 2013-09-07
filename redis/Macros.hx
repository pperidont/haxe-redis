package redis;

import haxe.macro.Context;
import haxe.macro.Expr;

class Macros {

	public static function macroBuild() : Array<Field> {
		var pos = Context.currentPos();
		var fields = Context.getBuildFields();
		var cname = haxe.macro.Context.getLocalClass().get().name;
		var oname = { expr: EConst(CString(cname+"#")), pos: pos };
		var cl = Context.getLocalClass();
		
		var names = new Array();
		for( f in fields ){
			var skip = false;
			for( m in f.meta ){
				switch( m.name ){
				case ":skip":
					skip = true;
				}
			}
			if( skip )
				continue;

			switch( f.kind ){
			case FVar(t,_):
				switch( t ){
				case TPath(p):
					if( p.pack.length != 1 || p.pack[0] != "redis" || !Lambda.has(["KList","Queue","KString","KHash","KSet"],p.name) )
						Context.error("@:skip missing ?",f.pos);
					
					names.push(cname+"#%_"+f.name);
					f.kind = FProp("dynamic", "never", t, null);
					var cache = "cache_" + f.name;
					var ecache = { expr : EConst(CIdent(cache)), pos : pos };
					var fname = { expr : EConst(CString("_"+f.name)), pos : pos };
					var obj = { expr: ENew(p,[macro $oname + this.id + $fname]), pos: pos };

					var get = {
						args : [],
						params : [],
						ret : t,
						expr : macro { if( $ecache == null ) $ecache = $obj;  return $ecache; },
					};
					fields.push( { name : cache, pos : pos, meta : [ { name:":skip", params:[], pos:pos } ], access : [APrivate], doc : null, kind : FVar(t, null) } );
					fields.push( { name : "get_" + f.name, pos : pos, meta : [], access : [APrivate], doc : null, kind : FFun(get) } );
				default:
				}
			default:
			}
		}
		cl.get().meta.add( "fields", [{expr: EConst(CString(names.join(","))),pos: pos}], pos);

		return fields;
	}

}


