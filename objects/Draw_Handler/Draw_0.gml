
depth = -9999999;

DRAW.Call();

if (Debug.showHitboxes) {
	with (all) {
		var c = #adadad;
		draw_rectangle_color(bbox_left, bbox_top, bbox_right - 1, bbox_bottom - 1, c, c, c, c, true);
	}
}
