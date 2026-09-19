
event_inherited();

sun = instance_nearest(x, y, Sun);
controlling = true;

// Camera
var cam = instance_create_depth(x, y, depth, Camera);
cam.target = self;

instance_create_depth(x + 200, y + 200, depth, Enemy_Mercenary);
instance_create_depth(x + 400, y + 200, depth, Enemy_Mother);

// Player
player = {
	ejected: false,
}

// Health
hp = new Stat();

// Movement
canMove = true;
dir = irandom(360);
acceleration = 0.025;
deceleration = 0.005;

maxTurnSpeed = 1.05;
turnSpeed = 0;
turnForce = 0.085;
onPlanet = false;

maxSpeed = 5;
spd = 0;
hsp = 0;
vsp = 0;

ejectPlayer = function() {
	var con = (spd < 0.05 && onPlanet);
	if (!con) return;
	
	Player.controlling = true;
	Camera.target = Player;
	player.ejected = true;
	
	var planet = instance_nearest(x, y, Planet);
	Player.planet = planet;
	
	menuOpen = false;
	controlling = false;
}

boardPlayer = function() {
	var con = (distance_to_object(Player) < 32);
	if (!con) return;
	
	Camera.target = Spaceship;
	player.ejected = false;
	
	Player.controlling = false;
	Player.planet = noone;
	
	controlling = true;
}

createJetParticles = function(xoff, yoff, val) {
	var xx, yy;
	var r = 4;
	xx = x - lengthdir_x(22, angle) + xoff;
	yy = y - lengthdir_y(22, angle) + yoff;
	
	var n = ceil(val * (spd / maxSpeed));
	
	var emitter = part_emitter_create(World.ps);
	part_emitter_region(World.ps, emitter, xx - r, xx + r, yy - r, yy + r, ps_shape_rectangle, ps_distr_gaussian);
	part_emitter_burst(World.ps, emitter, World.particleFire, n);
	
}

pilot = function() {
	if (keyboard_check(ord("W")) && canMove) {
		spd = min(maxSpeed, spd + acceleration);
		var offset = 15;
		
		createJetParticles(-5, 0, 16);
		createJetParticles(5, 0, 16);
		
	} else {
		spd = max(0, spd - deceleration);
		
	}
	
	steer();
}

steer = function() {
	var left = keyboard_check(ord("A"));
	var right = keyboard_check(ord("D"));
	
	var speedFactor = (spd / maxSpeed);
	
	if (left) {
		turnSpeed = min(maxTurnSpeed, turnSpeed + turnForce) * speedFactor;
		
	} else if (right) {
		turnSpeed = max(-maxTurnSpeed, turnSpeed - turnForce) * speedFactor;
		
	} else {
		turnSpeed = lerp(turnSpeed, 0, 0.025);
		
	}
	
	dir += turnSpeed;
}

x = room_width  / 2;
y = room_height / 2;

// Draw
spaceship = sSpaceship_Default;
sprite_index = spaceship;
angle = 0;
scale = 1;
color = c_white;
alpha = 1;

turretAngle = 0;

drawSpaceship = function(spr, x, y, scale, angle, color, alpha, offsetFactor = 1) {
	var s = scale;
	var c = c_red;
	
	var ty = y+4;
	var mx = mouse_x, my = mouse_y;
	var t = point_direction(x, ty, mx, my);
	if (controlling) turretAngle = t;
	
	draw_sprite_stacked(sTurret_Canon, x, ty, SPRITE_STACKED_OFFSET, s, s, turretAngle, color, alpha);
	
	draw_sprite_stacked(spr, x, y, SPRITE_STACKED_OFFSET * offsetFactor, s, s, angle, color, alpha);
	
	if (hp.value < 20) {
		var a = sin(current_time / 300) * 0.25;
		
		draw_set_alpha(a);
		draw_sprite_stacked(spr, x, y, SPRITE_STACKED_OFFSET * offsetFactor, s, s, angle, c_red, a);
		draw_set_alpha(1);
	}
}

drawSpeedometer = function(x, y, height) {
	var speedometerMaxSpeed = 50;
	var percentage = (spd / speedometerMaxSpeed);
	var scale = 2;
	var len = 25 * scale;
	
	var offset = -(90 + 22.5) - ((360 - 45) * percentage);
	var dir = offset;
	
	if (percentage > 0) {
		var range = 1.50 * (spd / maxSpeed);
		dir += random_range(-range, range);
	}
	
	var xx = lengthdir_x(len, dir);
	var yy = lengthdir_y(len, dir);
	
	draw_sprite_ext(sUI_SpaceshipSpeedometer, 0, x, y, scale, scale, 0, c_white, 1);
	draw_line_width_color(x, y, x + xx, y + yy, 2, c_red, c_red);
}

// Inventory
inventory = new Inventory();

// Spaceship Menu
menuOpen = false;

Input.Bind.Set(ord("E"), {}, , function(){
	if (!controlling) return;
	menuOpen = !menuOpen;
});


main = new v_Panel(200, 200, {
	direction: eNodeDirection.COLUMN,
	draggable: true,
});

main.Push(new v_Text("==============", {color: c_gray}));
main.Push(new v_InputBox("Spaceship"));
main.Push(new v_Text("==============", {color: c_gray}));

// surface
section0 = new v_Panel(0, 0, {
	border: false, 
	backgroundColor: #141414,
	direction: eNodeDirection.COLUMN,
});
section0.Push(new v_Surface(100, 100, function(xx, yy, width, height){
	var theta = -current_time / 30;
	drawSpaceship(spaceship, xx, yy, 1.5, theta, color, alpha, 3);
}));

main.Push(section0);

// buttons
section1 = new v_Panel(0, 0, {
	direction: eNodeDirection.ROW,
	border: false,
});
section1.PushDefaultChildrenStyle({
	padding: new Dim(10, 0),
});

section1.Push(new v_Button("button1", function(){
	menuOpen = false;
}));
section1.Push(new v_Button("button2"));

section1.Push(new v_Button("button3", function(){
	window_set_fullscreen(!window_get_fullscreen());
}));
section1.Push(new v_Button("false", function(){
	section1.Edit("false_button", function(e){
		var str = (e.text == "true") ? "false" : "true";
		e.text = str;
	});
}), "false_button");
main.Push(section1);
main.Push(v_Separator());

section3 = new v_Panel(0, 0, {
	direction: eNodeDirection.ROW,
	border: false,
});
section3.PushDefaultChildrenStyle({
	padding: new Dim(0, 0),
});

section3.Push(new v_Button(sUI_Switch0, function(e){
	e.spriteIndex = (e.spriteIndex == 0) ? 1 : 0;
}));
section3.Push(new v_Button(sUI_Switch0, function(e){
	e.spriteIndex = (e.spriteIndex == 0) ? 1 : 0;
}));
section3.Push(new v_Button(sUI_Switch0_Green, function(e){
	e.spriteIndex = (e.spriteIndex == 0) ? 1 : 0;
}));
section3.Push(new v_Button(sUI_Switch0_Green, function(e){
	e.spriteIndex = (e.spriteIndex == 0) ? 1 : 0;
}));
main.Push(section3);
main.Push(v_Separator());

section2 = new v_Panel(0, 0, {
	direction: eNodeDirection.ROW,
	border: false,
});
section2.Push(new v_Text("hp:     "));
section2.Push(new v_Meter(80, 8, 100, function(){return hp.value}));
main.Push(section2);
main.Push(v_Separator());

section4 = new v_Panel(0, 0, {
	direction: eNodeDirection.COLUMN,
	border: false,
});

section4.Push(new v_Surface(160, 160, function(xx, yy, width, height){
	drawSpeedometer(xx, yy, height);
}));
main.Push(section4);

main.Push(v_Separator());


GUI.Register(function(){
	if (menuOpen) then main.Draw();
});
