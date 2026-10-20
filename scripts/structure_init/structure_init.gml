function structure_init() {

	enum eStructureID {
		RUINS_0,
	}

	G STRUCTURE;
	STRUCTURE = {};
	STRUCTURE.list = {};

	STRUCTURE.Prop = function() {
	}

	STRUCTURE.Tile = function(x, y, prop, sprite, propImageIndex=0, propComponents={}) {
		var t = {}
		t.x = x;
		t.y = y;
		t.prop = prop;

		t.propComponents = {};
		t.propComponents.sprite_index = sprite;
		t.propComponents.image_index = propImageIndex;
		struct_merge_recursive(t.propComponents, propComponents);

		return t;
	}

	STRUCTURE.Map = function() {
		var map = [];
		for (var i = 0; i < argument_count; i++) {
			array_push(map, argument[i]);
		}
		return map;
	}

	STRUCTURE.Create = function(structureID, map) {
		STRUCTURE.list[$ structureID] = map;
	}

	STRUCTURE.Get = function(structureID) {
		return STRUCTURE.list[$ structureID];
	}

	var tile 	= STRUCTURE.Tile;
	var map 	= STRUCTURE.Map;
	var create 	= STRUCTURE.Create;

	create(
		eStructureID.RUINS_0,
		map(
			tile(0, 0, 	Prop_Structure, sProp_Structure_Ruin0, 1, {}),
			tile(-1, 1, Prop_Structure, sProp_Structure_Ruin0, 0, {}),
			tile(0, 1, 	Prop_Structure, sProp_Structure_Ruin0, 2, {}),
			tile(1, 2, 	Prop_Structure, sProp_Structure_Ruin0, 3, {}),
			tile(1, 3, 	Prop_Structure, sProp_Structure_Ruin0, 4, {}),
		)
	);
}
