function planet_generate_name(){
	
	var prepositions	= "of";
	var adjectives		= "giant,big,forgotten,bizarre,dry,hot,cold,colossus,round";
	var nouns			= "planet,body,ziggurat,home,world";
	var objects			= "nothingness,the past,time,junk";
	
	var get = function(str) {
		str = string_split(str, ",");
		str = array_get_random(str);
		return str + " ";
	}
	
	var type = irandom(3);
	
	switch (type) {
		case 0: {
			// NOUN OF OBJECT
			var noun = get(nouns);
			var pre = get(prepositions);
			var obj = get(objects);
			
			return string_join("", noun, pre, obj);
		}
		
		case 1: {
			// ADJECTIVE NOUN OF OBJECT
			var adj = get(adjectives);
			var noun = get(nouns);
			var pre = get(prepositions);
			var obj = get(objects);
			
			return string_join("", adj, noun, pre, obj);
		}
		
		case 2: {
			// ADJECTIVE NOUN
			var adj = get(adjectives);
			var noun = get(nouns);
			
			return string_join("", adj, noun);
		}
		
		case 3: {
			// ADJECTIVE OBJECTS
			var adj = get(adjectives);
			var obj = get(objects);
			
			return string_join("", adj, obj);
		}
	}
	
}