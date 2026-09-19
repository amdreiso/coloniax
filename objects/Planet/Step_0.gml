
//depth = -y/500;

orbit_set();

left		= x - width / 2;
right		= x + width / 2;
top			= y - height / 2;
bottom		= y + height / 2;
hovering	= (mouse_collision("center", x, y, width, height));

children.ForEach(function(e){
	e.x = x - width + e.offset.x;
	e.y = top + e.offset.y;
});

x += hsp;
y += vsp;
