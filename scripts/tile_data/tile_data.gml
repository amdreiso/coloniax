function tile_data(){
	
	enum eTileID {
		DEFAULT,
		WATER,
		ICE,
		LAVA,
		GRASS,
		SAND,
		STONE,
		VOLCANIC_ROCK,
		SNOW,
		POISON,
		SHORT_POISONOUS_GRASS,
		POISONOUS_GRASS,
	}
	
	G TILE;
	TILE = new Registry();
	TILE.SetDefaultComponents({
		sprite: sTile_Default,
		load: function(planet, tile){},
		update: function(obj){},
		canPlaceProps: true,
		canSpawnMinerals: false,
		isLiquid: false,
		frameSpeed: irandom_range(300, 500),
		
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
	
	TILE.Register(eTileID.DEFAULT, tile(sTile_Default, {
	}));
	
	TILE.Register(eTileID.GRASS, tile(sTile_Grass, {
		canSpawnMinerals: true,
		load: function(planet, tile) {
			if (irandom(100) > 96) then tile.CreateProp(planet, Prop_Tree, {
				tiltMultiplier: 0.3,
			});
		}
	}));
	
	TILE.Register(eTileID.WATER, tile(sTile_Water, {
		canPlaceProps: false,
		isLiquid: true,
		
		onEntityCollision: function(obj) {
		},
	}));
	
	TILE.Register(eTileID.ICE, tile(sTile_FrozenWater, {
		canPlaceProps: false,
		isLiquid: false,
	}));
	
	TILE.Register(eTileID.SAND,	tile(sTile_Sand, {
	}));
	
	TILE.Register(eTileID.STONE, tile(sTile_Stone, {
		canSpawnMinerals: true,
	}));
	
	TILE.Register(eTileID.LAVA, tile(sTile_Lava, {
		canPlaceProps: false,
		isLiquid: true,
		
		onEntityCollision: function(obj) {
			if (!instance_exists(obj)) return;
			if (!EFFECT.Exists(obj)) return;
			
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
	
	TILE.Register(eTileID.SNOW, tile(sTile_Ice, {
		load: function(planet, t) {
			if (irandom(100) > 80) then t.CreateProp(planet, Prop_IceSpike);
		},
	}));
	
	TILE.Register(eTileID.POISON, tile(sTile_Poison, {
		isLiquid: true,
		frameSpeed: function(){
			return irandom_range(100, 400);
		},

		update: function(obj) {
			if (irandom(1000)>995) {
				var part = instance_create_depth(obj.x, obj.y, obj.depth, Particle);
				part.setLifetime(1);
				part.setAmount(1);
				part.setParticle(World.particlePoison);
				part.setRange(TILE_HEIGHT, TILE_HEIGHT);
			}
		}
	}));

	TILE.Register(eTileID.SHORT_POISONOUS_GRASS, tile(sTile_ShortPoisonousGrass, {
		load: function(planet, tile) {
			var c = irandom_range(220, 255);
			if (irandom(200) < 1) then tile.CreateProp(planet, Prop_Tree, {
				sprite_index: sProp_DeadTree0,
				tiltMultiplier: 0.05,
				image_blend: make_color_rgb(c, c, c),
			});
		}
	}));

	TILE.Register(eTileID.POISONOUS_GRASS, tile(sTile_PoisonousGrass, {
		load: function(planet, tile) {
			var c = irandom_range(220, 255);
			var r = irandom(100);
			if (r < 1) {
				tile.CreateProp(planet, Prop_Tree, {
					sprite_index: choose(sProp_DeadTree0, sProp_DeadTree1),
					tiltMultiplier: 0.05,
					image_blend: make_color_rgb(c, c, c),
				});
			} else if (r < 2) {
				tile.CreateProp(planet, Prop_Mushroom, {});
			}
		}
	}));
}
