
itemID = -1;
sprite = -1;
offset = new Vec2();
timeOffset = irandom(1000);

falling = irandom(10);
vsp = 0;

set = function(itemid) {
	itemID = itemid;
	sprite = ITEM.Get(itemid).components.icon;
}

draw = function() {
	if (sprite == -1) return;
	sprite_index = sprite;
	draw_sprite_ext(sprite, 1, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
}
