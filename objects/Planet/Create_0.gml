event_inherited();

sun = instance_nearest(x, y, Sun);
mass = 10000;

children = new Children();

hsp = 0;
vsp = 0;

hovering = false;
outlineSize = 0;

name = planet_generate_name();
seed = irandom(1000000);
noise = new perlin(seed);

randomize();

type = irandom(ePlanetType.COUNT - 1);
planet				= PLANET.Generate(type);
chunkSizes			= planet.parameters.getChunkSizes();
geologyChunkSizes	= planet.parameters.getGeologyChunkSizes();

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
	
	static CreateProp = function(this, obj, components = {}, occupy=true, dumbass=false) {
		if (self.occupied) return false;
		
		var prop = prop_create(this, obj, self.x, self.y, self.index);
		struct_merge_recursive(prop, components);
		self.parent.children.Append(prop);
		
		var size = variable_instance_get(prop, "size") ?? [[0, 0]];
		
		self.occupied = occupy;
		
		for (var i = 0; i < array_length(size); i++) {
			var xx = self.index.x + size[i][0];
			var yy = self.index.y + size[i][1];
			
			var tile = self.parent.grid[# xx, yy];
			if (tile != undefined) {
				tile.occupied = true;
				
				if (dumbass) {
					if (tile.CreateProp(self.parent, Mineral, {
						sprite: sTile_Default_Top,
					}, false)) {
						CHAT.Send($"Placed prop of size {size[i][0]}x{size[i][1]} at x={xx} y={yy}");
					}
				}
			}
		}
		
		return true;
	}
	
	self.animated = (self.tileID == eTileID.WATER);
	self.timeOffset = irandom(1000);
	
	var components = TILE.Get(self.tileID).components;
	
	if (components.canSpawnMinerals) {
		if (g >= 70 && t >= 67) {
			self.CreateProp(self.parent, Mineral, {
				sprite: sMineral_Iron,
			}, false);
		} else if (g >= 65 && t <= 58) {
			self.CreateProp(self.parent, Mineral, {
				sprite: sMineral_Coal,
			}, false);
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
		
		if (tile.tileID == eTileID.WATER || tile.tileID == eTileID.LAVA) {
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
	
	//var spaceshipCollision = (distance_to_object(Spaceship) < radius / 2);
	//var spaceshipCollision = ((dx * dx) / (rx * rx) + (dy * dy) / (ry * ry) <= 1);
	
	draw_surface(surface, left, top);
}

inBoundary = function(x, y) {
	return (x > left && x < right && y > top && y < bottom);
}
