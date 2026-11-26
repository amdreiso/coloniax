
if (Paused) return;

//depth = -y/500;

orbit_set(true);

left		= x - width / 2;
right		= x + width / 2;
top			= y - height / 2;
bottom		= y + height / 2;

var wasHovering = hovering;
hovering	= (mouse_collision("center", x, y, width, height) && Camera.zoom >= 20 && !instance_exists(Menu));

if (hovering) {
	CursorBusy = true;
	window_set_cursor(cr_handpoint);
}

if (!hovering && wasHovering) {
	CursorBusy = false;
	window_set_cursor(cr_default);
}

children.ForEach(function(e){
	e.x = x - width + e.offset.x;
	e.y = top + e.offset.y;
});

x += hsp;
y += vsp;

