
world_particle_init();

// Space Generation
//seed = irandom(10000000);
seed = Seed;

chunks = {};
job = [];

random_set_seed(seed);

function chunkGetKey(x, y) {
	var key = $"{x}x{y}";
	return key;
}

function World_Star(x, y, depth=0) constructor {
	self.x = x;
	self.y = y;
	self.color = choose(#9BB0FF, #AABFFF, #CAD7FF, #F8F7FF, #FFF4EA, #FFD2A1, #FFB56B);
	var val = color_get_value(self.color);
	self.color = color_darkness(self.color, irandom_range(20, val));
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

createPlanet = function(cx, cy, type, mindis, maxdis) {
	var dir = random(360);
	var dis = sqrt(random_range(mindis * mindis, maxdis * maxdis));
	var px = cx + lengthdir_x(dis, dir);
	var py = cy + lengthdir_y(dis, dir);
	
	var planet = instance_create_layer(px, py, "Planet", Planet);
	var t = (type == -1) ? planet.type : type;
	planet.create(t);
	
	return planet;
}

createSolarSystem = function(x, y) {
	var planetNum = ePlanetType.COUNT;
	
	var sun = instance_create_layer(x, y, "Sun", Sun);
	sun.image_xscale = 10;
	sun.image_yscale = 10;

	var disoffset = 1.1;
	var mindis = (sun.sprite_width / 2) * disoffset;
	var maxdis = mindis * 2;
	
	var placed = 0;
	var attempts = 0;
	var maxAttempts = 100;

	while (placed < planetNum && attempts < maxAttempts) {
		attempts++;

		var dir = irandom(360);
		var dis = sqrt(random_range(mindis * mindis, maxdis * maxdis));
		var px = x + lengthdir_x(dis, dir);
		var py = y + lengthdir_y(dis, dir);

		if (instance_exists(Planet)) {
			var near = instance_nearest(px, py, Planet);
			if (point_distance(px, py, near.x, near.y) < 400) continue;
		}

		var planet = instance_create_layer(px, py, "Planet", Planet);
		planet.create(attempts % ePlanetType.COUNT);
		placed++;
	}
}

createSolarSystem(0, 0);
