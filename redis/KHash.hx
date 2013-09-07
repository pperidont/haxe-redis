package redis;

class KHash extends Key {
	
	public function length(){
		return Key.CNX.hlen(key);
	}

	public function setAll( h : Map<String,String> ){
		return Key.CNX.hmset(key,h);
	}

	public function set( field : String, value : String ){
		return Key.CNX.hset(key,field,value);
	}

	public function increment( field : String, ?value = 1 ){
		return Key.CNX.hincrby(key,field,value);
	}

	public function get( field : String ){
		return Key.CNX.hget(key,field);
	}

	public function keys(){
		return Key.CNX.hkeys(key);
	}

	public function all(){
		return Key.CNX.hgetall(key);
	}

	public function remove( field : String ){
		return Key.CNX.hdel(key,[field]);
	}

	public function has( field : String ){
		return Key.CNX.hexists(key,field);
	}

}
