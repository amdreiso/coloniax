function planet_generate_name(planetType = ePlanetType.EARTH){
	
	var prepositions	= "of";
	var adjectives		= "giant,big,forgotten,bizarre,colossus,round";
	var nouns			= "ball,planet,body,ziggurat,home,world";
	var objects			= "nothingness,time,junk";
	var demonyms		= "the past";

	switch (planetType) {
		case ePlanetType.POISON:
			adjectives += ",poisonous,toxic,smelly,deadly,venomous,virulent,harmful,noxious";
			break;

		case ePlanetType.VOLCANIC:
			adjectives += ",red-hot,live,blistering,raging,burning,warm";
			break;

		case ePlanetType.ICE:
			adjectives += ",stale,frigid,cold-blooded,inhuman,insensate,cold,frozen,arctic,polar,frosty,cool";
			break;
	}
	
	var get = function(str) {
		str = string_split(str, ",");
		str = array_get_random(str);
		return str + " ";
	}
	
	var type = irandom(4);
	
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

		case 4: {
			// ADJECTIVE PREPOSITION DEMONYM
			var adj = get(adjectives);
			var pre = get(prepositions);
			var dem = get(demonyms);
			
			return string_join("", adj, pre, dem);
		}
	}
	
}
