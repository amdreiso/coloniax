
if (target == noone) return;
if (!instance_exists(target)) return;

var shake = power(shakeValue, shakePower);

x = lerp(x, target.x + offset.x, followSpeed) + random_range(-shake, shake);
y = lerp(y, target.y + offset.y, followSpeed) + random_range(-shake, shake);

shakeValue = max(0, shakeValue - shakeFalloff);

var zoomWidth	= width  * zoomTo;
var zoomHeight	= height * zoomTo;

camera_set_view_pos(index, x - zoomWidth / 2, y - zoomHeight / 2);
camera_set_view_size(index, zoomWidth, zoomHeight);

if (Paused) return;

var zoomPart = max(0.05, zoom * 0.1);
var maxZoom = 30;
var minZoom = 0.05;

zoom += (mouse_wheel_down()) ? zoomPart : 0;
zoom -= (mouse_wheel_up())	 ? zoomPart : 0;

zoom = clamp(zoom, minZoom, maxZoom);

zoomTo = lerp(zoomTo, zoom, 0.33);

left	= x - zoomWidth  / 2;
right	= x + zoomWidth  / 2;
top		= y - zoomHeight / 2;
bottom	= y + zoomHeight / 2;
