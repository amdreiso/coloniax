function planet_init(){
	
	enum ePlanetType {
		EARTH,
		VOLCANIC,
		ICE,
		
		COUNT,
	}
	
	G PLANET;
	PLANET = {};
	
	PLANET.TerrainLevel = function(tileID, threshold=0) constructor {
		self.tileID = tileID;
		self.threshold = threshold;
	}
	
	PLANET.Mineral = function(geologyMin, geologyMax, terrainMin, terrainMax, resource) constructor {
		self.geologyMin = geologyMin;
		self.geologyMax = geologyMax;
		self.terrainMin = terrainMin;
		self.terrainMax = terrainMax;
		self.resource	= resource;
	}
	
	PLANET.GenerateComponents = function(type) {
		var level = PLANET.TerrainLevel;
		
		switch (type) {
			case ePlanetType.EARTH: {
				return {
					resources: {
						water: irandom_range(2, 10),
						stone: 20,
						tree: 20,
						lava: 0,
						iron: irandom(10),
						coal: irandom(20),
					},
					
					terrain: [
						new level(eTileID.WATER, 0),
						new level(eTileID.SAND, 48),
						new level(eTileID.GRASS, 50),
						new level(eTileID.STONE, 70),
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
						
						mineralSpawnTable: [
							new PLANET.Mineral(70, 100, 72, 80, "iron"),
							new PLANET.Mineral(30, 35, 40, 58, "coal"),
						],
						
						// Chance to change chunk sizes
						chunkInfluence:		2,
						geologyInfluence:	50,
					},
				}
			}
				
			case ePlanetType.VOLCANIC: {
				return {
					resources: {
						water: 0,
						stone: 0,
						tree: 0,
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
						
						mineralSpawnTable: [
							new PLANET.Mineral(70, 100, 50, 65, "iron"),
							new PLANET.Mineral(10, 62, 20, 40, "coal"),
						],
						
						// Chance to change chunk sizes
						chunkInfluence:		20,
						geologyInfluence:	80,
					},
				}
			}
			
			case ePlanetType.ICE: {
				return {
					resources: {
						water: irandom_range(0, 2),
						stone: 0,
						tree: 0,
						lava: 0,
						iron: 0,
						coal: 0,
					},
					
					terrain: [
						new level(eTileID.FROZEN_WATER, 0),
						new level(eTileID.ICE, 35),
					],
					
					parameters: {
						base: "water",
						
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
						
						mineralSpawnTable: [
							new PLANET.Mineral(70, 100, 50, 65, "iron"),
							new PLANET.Mineral(10, 62, 20, 40, "coal"),
						],
						
						// Chance to change chunk sizes
						chunkInfluence:		20,
						geologyInfluence:	80,
					},
				}
			}
		}
	}
	
	PLANET.Generate = function(type=irandom(ePlanetType.COUNT-1)) {
		var planet = PLANET.GenerateComponents(type);
		return planet;
	}
}

