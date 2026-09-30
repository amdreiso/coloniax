
// Particles

// Particle system
ps = part_system_create();
part_system_automatic_draw(ps, false);
part_system_depth(ps, 0);

// Fire particle
particleFire = part_type_create();
part_type_sprite(particleFire, sParticle_Fire_2, false, false, true);
part_type_speed(particleFire, 0, 0.10, -0.0001, 0);
part_type_colour3(particleFire, c_yellow, c_red, c_black);
part_type_alpha2(particleFire, 1, 0);
part_type_size(particleFire, 0.8, 1.5, 0.025, 0);
part_type_direction(particleFire, -180, 180, 0, 0);
part_type_orientation(particleFire, -180, 180, 0, 0, true);
part_type_life(particleFire, 4 * 60, 8 * 60);

particleSplash = part_type_create();
part_type_direction(particleSplash, 60, 120, 0, 0);
part_type_sprite(particleSplash, sParticle_WaterSplash, false, false, true);
part_type_speed(particleSplash, 0.5, 1.5, -0.01, 0);
part_type_life(particleSplash, 15, 30);
part_type_size(particleSplash, 0.5, 1.00, -0.005, 0);
part_type_gravity(particleSplash, 0.08, 270);

particleFoam = part_type_create();
part_type_sprite(particleFoam, sParticle_WaterFoam, false, false, true);
part_type_life(particleFoam, 15, 30);
part_type_size(particleFoam, 0.80, 1.20, -0.001, 0.001);
part_type_alpha2(particleFoam, 1, 0);

particleFlame = part_type_create();
part_type_sprite(particleFlame, sParticle_Flames, false, false, true);
part_type_direction(particleFlame, 90, 90, 0, 0);
part_type_life(particleFlame, 60, 180);
part_type_speed(particleFlame, 0.2, 0.5, 0, 0);
part_type_alpha2(particleFlame, 1, 0);

particleFlash = part_type_create();
part_type_sprite(particleFlash, sParticle_Flash, false, false, true);
part_type_life(particleFlash, 3, 4);

particleSmoke = part_type_create();
part_type_sprite(particleSmoke, sParticle_Smoke, false, false, true);
part_type_life(particleSmoke, 2 * 60, 5 * 60);
part_type_alpha2(particleSmoke, 0.7, 0.0);
part_type_direction(particleSmoke, 90, 90, 0, 0);
part_type_speed(particleSmoke, 0.10, 0.50, -0.01, 0);


// Space Generation
chunks = {};
job = [];

function chunkGetKey(x, y) {
	var key = $"{x}x{y}";
	return key;
}

function World_Star(x, y, depth=0) constructor {
	self.x = x;
	self.y = y;
	self.color = choose(
	    #9BB0FF,
	    #AABFFF,
	    #CAD7FF,
	    #F8F7FF,
	    #FFF4EA,
	    #FFD2A1,
	    #FFB56B 
	);
	var val = color_get_value(self.color);
	self.color = color_darkness(self.color, irandom_range(70, val));
	self.depth = depth;
}

function World_Chunk(x, y) constructor {
	self.x = x;
	self.y = y;
	self.id = $"{self.x}x{self.y}";
	self.stars = [];
	
	static Draw = function() {
		var xx = self.x * CHUNK_SIZE;
		var yy = self.y * CHUNK_SIZE;
		
		if (!Camera.inView(xx, yy, CHUNK_SIZE, CHUNK_SIZE)) {
			return;
		}
		
		for (var i = 0; i < array_length(self.stars); i++) {
			var s = self.stars[i];
			draw_point_color(xx + s.x - Camera.x * s.depth, yy + s.y - Camera.y * s.depth, s.color);
		}
	}
	
	static Unload = function() {
		self.stars = [];
	}
	
	static Load = function() {
		var starMinDepth = 0.0010;
		var starMaxDepth = 0.0100;
		repeat (CHUNK_SIZE / 9) {
			var pos = randvec2(self.x, self.y, CHUNK_SIZE / 2);
			array_push(self.stars, new World.World_Star(
				pos.x, pos.y, random_range(starMinDepth, starMaxDepth)
			));
		}
	}
}

function getChunkPosition(x, y) {
	return new Vec2(
		floor((x + CHUNK_SIZE / 2) / CHUNK_SIZE),
		floor((y + CHUNK_SIZE / 2) / CHUNK_SIZE)
	);
}
