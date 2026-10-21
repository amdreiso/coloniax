
tileID = eTileID.WATER;
sprite = -1;
frameSpeed = irandom_range(300, 500);

isLiquid = false;

tick = irandom(1000);
cooldown = irandom(3 * 60);

update = function(){}

set = function(tileid) {
	var t 			= TILE.Get(tileid);
	tileID 			= tileid;
	sprite 			= t.components.sprite;
	isLiquid 		= t.components.isLiquid;
	update 			= t.components.update;
	frameSpeed		= resolve(t.components.frameSpeed);
	sprite_index 	= sprite;
	
	if (tileid == eTileID.LAVA) {
		tick = 0;
	}
}

draw = function() {
	if (sprite == -1) return;
	draw_sprite_ext(sprite, (current_time + tick) / frameSpeed, x, y, 1, 1, 0, c_white, 1);
}

