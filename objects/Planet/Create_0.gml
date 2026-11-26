event_inherited();

/*
populates planet with tiles -> generate surface -> draw surface
*/

sun = instance_nearest(x, y, Sun);
orbitRadius = point_distance(sun.x, sun.y, x, y);
orbitAngle = point_direction(sun.x, sun.y, x, y);	
mass = 10000;
motion = new Vec2();
interactionRange = 1000; // how far to be clicked

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

noise = new perlin(irandom(10000));

type				= irandom(ePlanetType.COUNT - 1);
generation			= PLANET.Generate(type);
chunkSizes			= generation.parameters.getChunkSizes();
geologyChunkSizes	= generation.parameters.getGeologyChunkSizes();

name = planet_generate_name(type);

iconIndex = choose(ePlanetIcon.DEFAULT, ePlanetIcon.RING);
iconColor = PLANET.GetColor(type);

if (type == ePlanetType.EARTH) {
	iconIndex = ePlanetIcon.EARTH;
}

function TileData(parent, generation, x, y) constructor {
	self.parent = parent;
	self.noise = {};
	var params = generation.parameters;
	
	if (irandom(100) < params.chunkInfluence) {
		parent.chunkSizes = generation.parameters.getChunkSizes();
	}
	
	if (irandom(100) < params.geologyInfluence) {
		parent.geologyChunkSizes = generation.parameters.getGeologyChunkSizes();
	}
	
	self.noise.terrain = parent.noise.calculate((x div TILE_WIDTH) + x, (y div (TILE_HEIGHT / 2)) + y, parent.chunkSizes);
	self.noise.geology = parent.noise.calculate((x div TILE_WIDTH) + x, (y div (TILE_HEIGHT / 2)) + y, parent.geologyChunkSizes);
	
	var t = self.noise.terrain;
	var g = self.noise.geology
	
	self.tileID = eTileID.WATER;
	self.sprite = sTile_Water;
	self.children = [];
	self.occupied = false;
	
	var tile;
	var terrain = generation.terrain;
	var waterlevel = -(struct_get(generation.resources, params.base) ?? 0);
	
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
	
	static CreateProp = function(parent, obj, components = {}, occupy=true) {
		// TODO: check occupied tiles depending on prop size
		if (self.occupied) return false;
		
		var prop = prop_create(parent, obj, self.x, self.y, self.index);
		struct_merge(prop, components);

		parent.children.Append(prop);
		
		var size = variable_instance_get(prop, "size") ?? [[0, 0]];
		self.occupied = occupy;

		var iseven = (self.index.y % 2 == 0) ? 1 : 0;
		
		for (var i = 0; i < array_length(size); i++) {
			var tx = size[i][0];
			var ty = size[i][1];
			var xx = self.index.x + tx;
			var yy = self.index.y + ty;
			
			if (iseven) {
				if (ty % 2 != 0) {
					xx += 1;
				}
			}
			
			var tile = parent.grid[# xx, yy];
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
		for (var i = 0; i < array_length(generation.parameters.mineralSpawnTable); i++) {
			var m = generation.parameters.mineralSpawnTable[i];
			var gmin = m.geologyMin, gmax = m.geologyMax;
			var tmin = m.terrainMin, tmax = m.terrainMax;
			var value = struct_get(generation.resources, m.resource);
			
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
	
	components.load(parent, self);
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

radius = (h * TILE_HEIGHT) / 2;
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

createStructure = function(x, y, structureID) {
	var s = STRUCTURE.Get(structureID);
	if (s == undefined) return;

	var iseven = (y % 2 == 0) ? 1 : 0;

	for (var i = 0; i < array_length(s); i++) {
		var t = s[i];
		var xx, yy;
		var tx, ty;
		tx = t.x;
		ty = t.y;
		xx = x + tx;
		yy = y + ty;

		if (iseven) {
			if (ty % 2 == false) {
				xx -= 1;
			}
		}

		var tile = grid[# xx, yy];
		if (tile == undefined) continue;

		tile.CreateProp(self, t.prop, t.propComponents);
	}
}

drawPlanet = function() {
	if (!surface_exists(surface)) return;
	if (!instance_exists(Camera)) return;
	if (!Camera.inView(x, y, width, width)) return;
	
	draw_surface(surface, left, top);
}

inBoundary = function(x, y) {
	return (x > left && x < right && y > top && y < bottom);
}

create = function(t) {
	children.DestroyAll();

	type				= t;
	generation			= PLANET.Generate(type);
	chunkSizes			= generation.parameters.getChunkSizes();
	geologyChunkSizes	= generation.parameters.getGeologyChunkSizes();

	size = 60;
	grid = ds_grid_create(size, size);
	ds_grid_clear(grid, undefined);

	var w = ds_grid_width(grid);
	var h = ds_grid_height(grid);

	width	= w * TILE_WIDTH / 2;
	height	= h * floor(TILE_HEIGHT / 2);

	// center axis
	var cx = w / 2;
	var cy = h / 2;

	name = planet_generate_name(type);

	iconIndex = choose(ePlanetIcon.DEFAULT, ePlanetIcon.RING);
	iconColor = PLANET.GetColor(type);

	if (type == ePlanetType.EARTH) {
		iconIndex = ePlanetIcon.EARTH;
	}

	for (var i = 0; i < w; i++)
	for (var j = 0; j < h; j++) {
		var pos  = isometric_position(i - cx, j - cy);
		var dist = point_distance(0, 0, pos.x, pos.y * 2);

		if (dist <= radius) {
			grid[# i, j] = new TileData(self, generation, i, j);
		}
	}

	surface_destroy(surface);

	Process.Push(function(){
		if (surface_exists(surface)) return true;
		generateSurface();
	});
}

