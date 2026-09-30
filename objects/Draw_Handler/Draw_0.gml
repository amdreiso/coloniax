
depth = -9999999;

DRAW.Call();

if (Debug.showDebugUI) {
	with (all) {
		draw_rectangle_color(bbox_left, bbox_top, bbox_right - 1, bbox_bottom - 1, c_aqua, c_aqua, c_aqua, c_aqua, true);
	}
}
