function planet_init(){
	
	enum ePlanetType {
		EARTH,
		VOLCANIC,
		//ICE,
		
		COUNT,
	}
	
	G PLANET;
	PLANET = {};
	
	PLANET.TerrainLevel = function(tileID, threshold=0) constructor {
		self.tileID = tileID;
		self.threshold = threshold;
	}
	
	PLANET.GenerateComponents = function(type) {
		var level = PLANET.TerrainLevel;
		
		switch (type) {
			case ePlanetType.EARTH:
				return {
					resources: {
						water: irandom_range(2, 10),
						stone: 20,
						tree: 20,
						iron: irandom(20),
						coal: irandom(20),
					},
					
					terrain: [
						new level(eTileID.WATER, 0),
						new level(eTileID.SAND, 48),
						new level(eTileID.GRASS, 50),
						new level(eTileID.STONE, 67),
					],
					
					parameters: {
						base: "water",
						
						getChunkSizes: function(){
							return choose(
								[[64, 64], [32, 32], [16, 16]],
							);
						},
						
						getGeologyChunkSizes: function() {
							return choose(
								[[16, 16], [32, 32]],
								[[16, 16]],
								[[32, 32], [64, 64]],
								[[32, 32], [2, 2]],
							);
						},
						
						// Chance to change chunk sizes
						chunkInfluence:		0,
						geologyInfluence:	10,
					},
				}
				
			case ePlanetType.VOLCANIC:
				return {
					resources: {
						water: 0,
						stone: 0,
						lava: irandom(30),
						iron: irandom_range(10, 40),
						coal: irandom_range(10, 40),
					},
					
					terrain: [
						new level(eTileID.VOLCANIC_ROCK, 0),
						new level(eTileID.LAVA, 70),
					],
					
					parameters: {
						base: "lava",
						
						getChunkSizes: function() {
							return choose(
								[[32, 16], [32, 16], [16, 8], [8, 4]],
								[[16, 16], [16, 16], [16, 8], [8, 4]],
								[[64, 64], [32, 32], [16, 16]],
								[[64, 64], [32, 32]],
								[[32, 32], [8, 8]],
								[[48, 48], [48, 48]],
							);
						},
						
						getGeologyChunkSizes: function() {
							return choose(
								[[128, 64], [64, 32]],
								[[8, 4], [12, 6], [16, 8]], 
								[[8, 4], [12, 6]],
								[[8, 4]],
							);
						},
						
						// Chance to change chunk sizes
						chunkInfluence:		20,
						geologyInfluence:	80,
					},
				}
		}
	}
	
	PLANET.Generate = function(type=irandom(ePlanetType.COUNT-1)) {
		var planet = PLANET.GenerateComponents(type);
		return planet;
	}
}

