package redis;

class KSet extends Key {

	public function add( value : String ){
		return Key.CNX.sadd( key, [value] );
	}

	public function members(){
		return Key.CNX.smembers(key);
	}

	public function length(){
		return Key.CNX.scard(key);
	}

	public function pop(){
		return Key.CNX.spop(key);
	}

	public function randomMember(){
		return Key.CNX.srandmember(key);
	}

	public function randomMembers( count : Int ){
		return Key.CNX.srandmembers(key,count);
	}

	public function remove( member : String ){
		return Key.CNX.srem(key,[member]);
	}
	
	public function has( member : String ){
		return Key.CNX.sismember(key,member);
	}

}
