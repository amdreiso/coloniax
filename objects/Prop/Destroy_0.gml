
var item = dropTable.Roll();
if (item != undefined) {
	repeat (array_get_random(item.quantity)) {
		var pos = randvec2(x, y, 5);
		var drop = instance_create_depth(0, 0, depth, ItemDrop);
		drop.set(item.itemID);
		drop.offset = new Vec2(pos.x - parent.left + parent.width / 2, pos.y - parent.top);
		parent.children.Append(drop);
	}
}

parent.grid[# tileIndex.x, tileIndex.y].occupied = false;

DRAW.Remove(DRAW_index);

audio_emitter_free(emitter);
