
if (target == noone) return;
if (!instance_exists(target)) return;

var shake = power(shakeValue, shakePower);
x = lerp(x, target.x, 0.1) + random_range(-shake, shake);
y = lerp(y, target.y, 0.1) + random_range(-shake, shake);

shakeValue = max(0, shakeValue - shakeFalloff);

var zoomWidth = width * zoomTo;
var zoomHeight = height * zoomTo;

camera_set_view_pos(index, x - zoomWidth / 2, y - zoomHeight / 2);
camera_set_view_size(index, zoomWidth, zoomHeight);

var zoomPart = 1;
var maxZoom = 30;
var minZoom = zoomPart;

zoom += (mouse_wheel_down() && zoom < maxZoom) ? zoomPart : 0;
zoom -= (mouse_wheel_up() && zoom > minZoom) ? zoomPart : 0;

zoomTo = lerp(zoomTo, zoom, 0.33);

left	= x - zoomWidth  / 2;
right	= x + zoomWidth  / 2;
top		= y - zoomHeight / 2;
bottom	= y + zoomHeight / 2;


