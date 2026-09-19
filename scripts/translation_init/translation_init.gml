function translation_init(){
	
	enum eLanguageID {
		ENGLISH,
		BRAZILIAN,
		COUNT,
	}
	
	G TRANSLATION;
	G Language;
	Language = eLanguageID.ENGLISH;
	
	#macro T TRANSLATION
	
	TRANSLATION = {
		data: ds_map_create(),
	};
	
	TRANSLATION.Add = function(key) {
		token = ds_map_create();
		_key = key;
		
		methods = {};
		
		methods.set = function(languageID, str) {
			token[? languageID] = str;
			return methods;
		}
		
		methods.finalize = function() {
			TRANSLATION.data[? _key] = token;
		}
		
		return methods;
	};
	
	TRANSLATION.Set = function(key, lang, val) {
		TRANSLATION.data[? key][? lang] = val;
	};
	
	TRANSLATION.Get = function(key) {
		return TRANSLATION.data[? key][? Language]
			?? TRANSLATION.data[? key][? eLanguageID.ENGLISH];
	};
	
	TRANSLATION.Tile = function(tileID){return "tile_"+string(tileID);}
	
	G LANGUAGE_SLOTS; 
	LANGUAGE_SLOTS = [
		eLanguageID.ENGLISH,
		eLanguageID.BRAZILIAN,
	];
	
	TRANSLATION.Add(eLanguageID.ENGLISH)
		.set(eLanguageID.ENGLISH, "en")
		.finalize();
	
	TRANSLATION.Add(eLanguageID.BRAZILIAN)
		.set(eLanguageID.ENGLISH, "br")
		.finalize();
		
	#region Tiles
	
	T.Add(T.Tile(eTileID.DEFAULT))
		.set(eLanguageID.ENGLISH, "Default Tile")
		.finalize();
		
	T.Add(T.Tile(eTileID.GRASS))
		.set(eLanguageID.ENGLISH, "Grass Tile")
		.finalize();
		
	T.Add(T.Tile(eTileID.WATER))
		.set(eLanguageID.ENGLISH, "Water Tile")
		.finalize();
		
	T.Add(T.Tile(eTileID.SAND))
		.set(eLanguageID.ENGLISH, "Sand Tile")
		.finalize();
		
	T.Add(T.Tile(eTileID.STONE))
		.set(eLanguageID.ENGLISH, "Stone Tile")
		.finalize();
		
	T.Add(T.Tile(eTileID.LAVA))
		.set(eLanguageID.ENGLISH, "Lava Tile")
		.finalize();
		
	T.Add(T.Tile(eTileID.VOLCANIC_ROCK))
		.set(eLanguageID.ENGLISH, "Volcanic Rock Tile")
		.finalize();
	
	#endregion
	
}