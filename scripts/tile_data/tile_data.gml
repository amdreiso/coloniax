function tile_data(){
	
	enum eTileID {
		DEFAULT,
		WATER,
		FROZEN_WATER,
		LAVA,
		GRASS,
		SAND,
		STONE,
		VOLCANIC_ROCK,
		ICE,
	}
	
	G TILE;
	TILE = new Registry();
	TILE.SetDefaultComponents({
		sprite: sTile_Default,
		load: function(){},
		update: function(self){},
		canPlaceProps: true,
		canSpawnMinerals: false,
		isLiquid: false,
		
		onEntityCollision: function(obj) {
		},
	});
	
	var tile = function(sprite, components={}) {
		var c = {
			sprite: sprite,
		}
		struct_merge_recursive(c, components);
		return c;
	}
	
	TILE.Register(eTileID.DEFAULT,	tile(sTile_Default, {
	}));
	
	TILE.Register(eTileID.GRASS,	tile(sTile_Grass, {
		canSpawnMinerals: true,
		load: function(planet, t) {
			if (irandom(100) > 96) then t.CreateProp(planet, Prop_Tree);
		}
	}));
	
	TILE.Register(eTileID.WATER,	tile(sTile_Water, {
		canPlaceProps: false,
		isLiquid: true,
		
		onEntityCollision: function(obj) {
		},
	}));
	
	TILE.Register(eTileID.FROZEN_WATER,	tile(sTile_FrozenWater, {
		canPlaceProps: false,
		isLiquid: false,
	}));
	
	TILE.Register(eTileID.SAND,		tile(sTile_Sand, {
	}));
	
	TILE.Register(eTileID.STONE,	tile(sTile_Stone, {
		canSpawnMinerals: true,
	}));
	
	TILE.Register(eTileID.LAVA, tile(sTile_Lava, {
		canPlaceProps: false,
		isLiquid: true,
		
		onEntityCollision: function(obj) {
			if (!instance_exists(obj)) return;
			if (!variable_instance_exists(obj, "effect")) return;
			
			obj.effect.Add(eEffectID.Flames);
		},
		update: function(obj) {
			if (irandom(1000)>999) {
				var part = instance_create_depth(obj.x, obj.y, obj.depth, Particle);
				part.setLifetime(1);
				part.setAmount(irandom(1)+1);
				part.setParticle(World.particleLavaDropplet);
				part.setRange(TILE_HEIGHT, TILE_HEIGHT);
			}
		},
	}));
	
	TILE.Register(eTileID.VOLCANIC_ROCK, tile(sTile_VolcanicRock, {
		canSpawnMinerals: true,
	}));
	
	TILE.Register(eTileID.ICE, tile(sTile_Ice, {
		load: function(planet, t) {
			if (irandom(100) > 80) then t.CreateProp(planet, Prop_IceSpike);
		},
	}));

}
