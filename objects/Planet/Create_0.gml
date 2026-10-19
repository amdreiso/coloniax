event_inherited();

sun = instance_nearest(x, y, Sun);
orbitRadius = point_distance(sun.x, sun.y, x, y);
orbitAngle = point_direction(sun.x, sun.y, x, y);	
mass = 10000;
motion = new Vec2();

children = new Children();
riders = [];
riderPush = function(obj) {
	if (!instance_exists(obj)) return;
	array_push(riders, obj);
}
riderRemove = function(obj) {
	for (var i = 0; i < array_length(riders); i++) {
		if (riders[i] == obj) {
			array_delete(riders, i, 1);
		}
	}
}

hsp = 0;
vsp = 0;

hovering = false;
outlineSize = 0;

name = planet_generate_name();
seed = irandom(1000000);
noise = new perlin(seed);

randomize();

type				= irandom(ePlanetType.COUNT - 1);
planet				= PLANET.Generate(type);
chunkSizes			= planet.parameters.getChunkSizes();
geologyChunkSizes	= planet.parameters.getGeologyChunkSizes();

iconIndex = choose(ePlanetIcon.DEFAULT, ePlanetIcon.RING);
iconColor = PLANET.GetColor(type);

if (type == ePlanetType.EARTH) {
	iconIndex = ePlanetIcon.EARTH;
}

function TileData(this, planet, x, y) constructor {
	self.parent = this;
	var params = planet.parameters;
	self.noise = {};
	
	if (irandom(100) < params.chunkInfluence) {
		this.chunkSizes = planet.parameters.getChunkSizes();
	}
	
	if (irandom(100) < params.geologyInfluence) {
		this.geologyChunkSizes = planet.parameters.getGeologyChunkSizes();
	}
	
	self.noise.terrain		= this.noise.calculate((x div TILE_WIDTH) + x, (y div (TILE_HEIGHT / 2)) + y, this.chunkSizes);
	self.noise.geology		= this.noise.calculate((x div TILE_WIDTH) + x, (y div (TILE_HEIGHT / 2)) + y, this.geologyChunkSizes);
	
	var t = self.noise.terrain;
	var g = self.noise.geology
	
	self.tileID = eTileID.WATER;
	self.sprite = sTile_Water;
	self.children = [];
	self.occupied = false;
	
	var tile;
	var terrain = planet.terrain;
	var waterlevel = -(struct_get(planet.resources, params.base) ?? 0);
	
	var pos = isometric_position(x, y);
	self.index = new Vec2(x, y);
	self.x = pos.x;
	self.y = pos.y;
	
	for (var i = 0; i < array_length(terrain); i++) {
		if (t >= terrain[i].threshold + waterlevel) {
			var tileID = terrain[i].tileID;
			tile = TILE.Get(tileID).components;
			self.tileID = tileID;
			self.sprite = tile.sprite ?? sTile_Default;
		}
	}
	
	static CreateProp = function(this, obj, components = {}, occupy=true) {
		if (self.occupied) return false;
		
		var prop = prop_create(this, obj, self.x, self.y, self.index);
		struct_merge_recursive(prop, components);
		self.parent.children.Append(prop);
		
		var size = variable_instance_get(prop, "size") ?? [[0, 0]];
		
		self.occupied = occupy;
		
		for (var i = 0; i < array_length(size); i++) {
			var xx = self.index.x + size[i][0];
			var yy = self.index.y + size[i][1];
			
			if (size[i][1] % 2 != 0 && yy % 2 == 0) {
				xx += 1;
			}
			
			var tile = self.parent.grid[# xx, yy];
			if (tile != undefined) {
				tile.occupied = true;
				
			}
		}
		return true;
	}
	
	self.animated = (self.tileID == eTileID.WATER);
	self.timeOffset = irandom(1000);
	
	var components = TILE.Get(self.tileID).components;
	
	if (components.canSpawnMinerals) {
		for (var i = 0; i < array_length(planet.parameters.mineralSpawnTable); i++) {
			var m = planet.parameters.mineralSpawnTable[i];
			var gmin = m.geologyMin, gmax = m.geologyMax;
			var tmin = m.terrainMin, tmax = m.terrainMax;
			var value = struct_get(planet.resources, m.resource);
			
			var spr = sMineral_Coal;
			if (m.resource == "iron") {
				spr = sMineral_Iron;
			}
			
			if ((g >= gmin && g <= gmax) && (t >= (tmin - value) && t <= tmax)) {
				self.CreateProp(self.parent, Mineral, {
					sprite: spr,
				}, false);
			}
		}
	}
	
	self.color = c_white;
	self.color = color_darkness(self.color, irandom(10));
	self.imageIndex = irandom(sprite_get_number(self.sprite));
	
	self.canPlaceProps = components.canPlaceProps;
	
	components.load(this, self);
}

size = 60;
grid = ds_grid_create(size, size);
ds_grid_clear(grid, undefined);

var w = ds_grid_width(grid);
var h = ds_grid_height(grid);

width	= w * TILE_WIDTH / 2;
height	= h * floor(TILE_HEIGHT / 2);
left	= x - width / 2;
right	= x + width / 2;
top		= y - height / 2;
bottom	= y + height / 2;

var cx = w / 2;
var cy = h / 2;
radius = (h * TILE_HEIGHT) / 2;

for (var i = 0; i < w; i++) {
    for (var j = 0; j < h; j++) {
        var pos  = isometric_position(i - cx, j - cy);
        var dist = point_distance(0, 0, pos.x, pos.y * 2);

        if (dist <= radius) {
            grid[# i, j] = new TileData(self, planet, i, j);
        }
    }
}

surface = -1;

generateSurface = function() {
	if (!surface_exists(surface)) {
		surface = surface_create(width, height + TILE_TAIL);
	}
	
	for (var j = 0; j < ds_grid_height(grid); j++)
	for (var i = 0; i < ds_grid_width(grid); i++) {
		var tile = grid[# i, j];
		if (tile == undefined) continue;
	
		var spr = tile.sprite;
		var color = tile.color;
		var index = (!tile.animated) ? tile.imageIndex : (current_time + tile.timeOffset) / 500;
		
		surface_set_target(surface);
		
		var t = TILE.Get(tile.tileID).components;
		
		if (t.isLiquid) {
			gpu_set_blendmode(bm_subtract);
			draw_sprite_ext(
				spr, index,
				tile.x - width / 2,
				tile.y,
				1, 1, 0, color, 1);
			gpu_set_blendmode(bm_normal);
			
			var prop = prop_create(self, Tile, tile.x, tile.y);
			prop.depth = -(floor(tile.y)) + depth + 10000;
			prop.set(tile.tileID);
			prop.image_index = irandom(1);
			prop.image_speed = 0.02;
			children.Append(prop);
			
		} else {
			draw_sprite_ext(
				spr, index,
				tile.x - width / 2,
				tile.y,
				1, 1, 0, color, 1
			);
		}
		surface_reset_target();
	}
}

drawPlanet = function() {
	var dx = Spaceship.x - x;
	var dy = Spaceship.y - y;
	var rx = radius;
	var ry = radius / 2;
	
	if (!Camera.inView(x, y, width, width)) return;
	
	draw_surface(surface, left, top);
}

inBoundary = function(x, y) {
	return (x > left && x < right && y > top && y < bottom);
}

