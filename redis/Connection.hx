#if !sys
	#error "sys required"
#else

package redis;

enum RedisResponse {
	R_String(s:String);
	R_Int(i:Int);
	R_Multi(a:Array<RedisResponse>);
	R_Nil;
}

class Connection {

	static inline var EOL = "\r\n";
	public static var TIMEOUT = 5;

	public static function isOk( r : RedisResponse ){
		var s = str(r);
		if( s != "OK" )
			throw "REDIS: assert failed: "+s;
		return true;
	}

	public static function str( r : RedisResponse ) : String {
		switch( r ){
			case R_Nil: return null;
			case R_String(s): return s;
			default: throw "REDIS: Unexpected response";
		}
	}

	public static function int( r : RedisResponse ) : Int {
		switch( r ){
			case R_Nil: return null;
			case R_Int(i): return i;
			default: throw "REDIS: Unexpected response";
		}
	}

	public static function multistr( r : RedisResponse ) : Array<String> {
		switch( r ){
			case R_Nil: return null;
			case R_Multi(a): return Lambda.array(Lambda.map(a,str));
			default: throw "REDIS: Unexpected response";
		}
	}

	var sock : sys.net.Socket;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	
	public function new( host : String, port = 6379 ){
		this.host = host;
		this.port = port;

		sock = new sys.net.Socket();
		sock.setTimeout(TIMEOUT);
		sock.connect(new sys.net.Host(host),port);
	}

	public function setTimeout( s : Int ){
		sock.setTimeout(s);
	}

	function send( cmd : String, ?args : Array<String> ){
		if( args == null )
			args = [];
		function mkArg( a : String ){
			return "$" + a.length + EOL + a + EOL;
		}

		var sb = new StringBuf();
    	sb.add("*" + (args.length+1) + EOL);
	    sb.add(mkArg(cmd));
    	for( a in args )
	      sb.add(mkArg(a));
		sock.output.writeString(sb.toString());
	}

	public function command( cmd : String, ?args: Array<String> ){
		send(cmd,args);
		return receive();
	}

	public function receive(){
		var line = sock.input.readLine();
		switch( line.charCodeAt(0) ){
		// String
		case "+".code:
			return R_String(line.substr(1));

		// Int
		case ":".code:
			return R_Int(Std.parseInt(line.substr(1)));

		// Bulk
		case "$".code:
			var l = Std.parseInt(line.substr(1));
			if( l == -1 )
				return R_Nil;
			var r = sock.input.read(l).toString();
			sock.input.read(2);
			return R_String(r);

		// Multi
		case "*".code:
			var l = Std.parseInt(line.substr(1));
			if( l == -1 )
				return R_Nil;
			var a = new Array();
			for( i in 0...l )
				a.push(receive());
			return R_Multi(a);

		// Error
		case "-".code:
			throw "REDIS ERROR: "+line.substr(1);
		default:
			throw "REDIS Unknown response";
		}
	}

	public function close(){
		send("QUIT");
		sock.close();
	}

	public function ping(){
		return str(command("PING")) == "PONG";
	}

	public function auth( pass : String ){
		return isOk(command("AUTH",[pass]));
	}

	public function select( idx : Int ){
		return isOk(command("SELECT",[Std.string(idx)]));
	}

	//

	public function multi(){
		return isOk(command("MULTI"));
	}

	public function discard(){
		return isOk(command("DISCARD"));
	}

	// Note: return R_Nil if exec failed
	public function exec(){
		return command("EXEC");
	}

	public function watch( keys : Array<String> ){
		return isOk(command("WATCH",keys));
	}

	public function unwatch(){
		return isOk(command("UNWATCH"));
	}

	// 

	public function exists( key : String ){
		return int(command("EXISTS",[key])) == 1;
	}

	public function del( keys : Array<String> ){
		return int(command("DEL",keys));
	}

	public function keys( pattern : String ){
		return multistr(command("KEYS",[pattern]));
	}

	public function expire( key : String, seconds : Int ){
		return int(command("EXPIRE",[key,Std.string(seconds)])) == 1;
	}

	public function persist( key : String ){
		return int(command("PERSIST",[key])) == 1;
	}

	public function ttl( key : String ){
		return int(command("TTL",[key]));
	}

	// 

	public function set( key : String, value : String, ?expire : Int ){
		if( expire == null )
			return isOk(command("SET",[key, value]));
		else
			return isOk(command("SETEX",[key, Std.string(expire), value]));
	}

	public function get( key : String ){
		return str(command("GET",[key]));
	}

	public function strlen( key : String ){
		return int(command("STRLEN",[key]));
	}

	//
	
	public function lpush( key : String, values : Array<String> ){
		var args = [key];
		args = args.concat(values);
		return int(command("LPUSH",args));
	}

	public function rpush( key : String, values : Array<String> ){
		var args = [key];
		args = args.concat(values);
		return int(command("RPUSH",args));
	}

	public function llen( key : String ){
		return int(command("LLEN",[key]));
	}

	public function lrange( key : String, start : Int = 0, stop: Int = -1 ){
		return multistr(command("LRANGE",[key,Std.string(start),Std.string(stop)]));
	}

	public function lrem( key : String, value : String, ?count = 0 ){
		return int(command("LREM",[key,Std.string(count),value]));
	}

	public function lindex( key : String, index : Int ){
		return str(command("LINDEX",[key,Std.string(index)]));
	}

	public function lset( key : String, index : Int, value : String ){
		return isOk(command("LSET",[key,Std.string(index),value]));
	}

	public function lpop( key : String ){
		return str(command("LPOP",[key]));
	}

	public function rpop( key : String ){
		return str(command("RPOP",[key]));
	}

	//

	public function hgetall( key : String ){
		var r = multistr(command("HGETALL",[key]));
		var h = new Map();
		var k = null;
		for( e in r ){
			if( k == null ){
				k = e;
			}else{
				h.set(k,e);
				k = null;
			}
		}
		return h;
	}

	public function hkeys( key : String ){
		return multistr(command("HKEYS",[key]));
	}

	public function hvals( key : String ){
		return multistr(command("HVALS",[key]));
	}

	public function hset( key : String, hk : String, hv : String ){
		return int(command("HSET",[key,hk,hv]));
	}

	public function hget( key : String, hk : String ){
		return str(command("HGET",[key,hk]));
	}

	public function hdel( key : String, fields : Array<String> ){
		var a = [key];
		for( f in fields )
			a.push(f);
		return int(command("HDEL",a));
	}

	public function hmset( key : String, h : Map<String,String> ){
		var l = new List();
		l.add(key);
		for( k in h.keys() ){
			l.add(k);
			l.add(h.get(k));
		}
		return isOk(command("HMSET",Lambda.array(l)));
	}

	public function hmget( key : String, fields: Array<String> ){
		var a = [key];
		for( f in fields )
			a.push(f);
		var r = multistr(command("HMGET",a));
		if( r.length != fields.length )
			throw "";
		var h = new Map();
		var i = 0;
		for( f in fields )
			h.set( f, r[i++] );
		return h;
	}

	public function hlen( key : String ){
		return int(command("HLEN",[key]));
	}

	public function hexists( key : String, field : String ){
		return int(command("HEXISTS",[key,field])) == 1;
	}

	public function hincrby( key : String, field : String, increment : Int ){
		return int(command("HINCRBY",[key,field,Std.string(increment)]));
	}

	public function hincrbyfloat( key : String, field : String, increment : Float ){
		return int(command("HINCRBYFLOAT",[key,field,Std.string(increment)]));
	}

	//

	public function sadd( key : String, values : Array<String> ){
		var a = [key];
		for( f in values )
			a.push(f);
		return int(command("SADD",a));
	}

	public function smembers( key : String ){
		return multistr(command("SMEMBERS",[key]));
	}

	public function scard( key : String ){
		return int(command("SCARD",[key]));
	}

	public function spop( key : String ){
		return str(command("SPOP",[key]));
	}

	public function srandmember( key : String ){
		return str(command("SRANDMEMBER",[key]));
	}

	public function srandmembers( key : String, count : Int ){
		return multistr(command("SRANDMEMBER",[key,Std.string(count)]));
	}

	public function srem( key : String, members: Array<String> ){
		var a = [key];
		for( m in members )
			a.push( m );
		return int(command("SREM",a));
	}
	
	public function sismember( key : String, member : String ){
		return int(command("SISMEMBER",[key,member])) == 1;
	}

	/*
	// TODO
	public function smove(){
	}
	public function sdiff(){
	}
	public function sdiffstore(){
	}
	public function sinter(){
	}	
	public function sinterstore(){
	}
	public function sunion(){
	}
	public function sunionstore(){
	}
	*/

	// 

	public function publish( channel : String, msg : String ){
		return int(command("PUBLISH",[channel,msg]));
	}

}

#end
