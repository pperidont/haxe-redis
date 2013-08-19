package redis;

class Key {
	public static var CNX : redis.Connection;

	public var key(default,null) : String;
	
	public function new( key : String ){
		this.key = key;
	}

	public function exists(){
		return CNX.exists(key);
	}

	public function delete(){
		return CNX.del([key]);
	}

	public function expire( seconds : Int ){
		return CNX.expire(key, seconds);
	}

	public function persist(){
		return CNX.persist(key);
	}

	public function ttl(){
		return CNX.ttl(key);
	}
}
