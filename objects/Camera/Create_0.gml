
index	= view_camera[0];

width	= 320;
height	= 180;

zoomPart = 1;
zoom	= 2;
zoomTo	= zoom;
zoomMax = 30;
zoomDown = function(){
	zoom += (zoom < zoomMax) ? zoomPart : 0;
}
zoomUp = function(){
	zoom -= (zoom > zoomPart) ? zoomPart : 0;
}

target = noone;

defaultFollowSpeed = 1;
followSpeed = 1;

left	= 0;
right	= 0;
top		= 0;
bottom	= 0;

shakeValue		= 0;
shakePower		= 2;
shakeFalloff	= 0.1;

offset = new Vec2();

shake = function(value, pwr=2, falloff=0.1) {
	shakeValue		= value;
	shakePower		= pwr;
	shakeFalloff	= falloff;
}

inView = function(xx, yy, width, height) {
	var w = width / 2;
	var h = height / 2;
	
	return (
		right > xx - w && left < xx + w &&
		bottom > yy - h && top < yy + h
	);
}

