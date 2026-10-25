
range = new Vec2();
shape = ps_shape_rectangle;
lifetime = 1;
setLifetime = function(val=1) {
	lifetime = val;
}

particle = World.particleFire;
setParticle = function(part) {
	particle = part;
}

ps = World.ps;
setParticleSystem = function(system = World.ps) {
	ps = system;
}

emitter = part_emitter_create(ps);

mode = "burst";
setMode = function(m="burst") {
	mode = m;
}

setRange = function(x, y) {
	range = new Vec2(x, y);
}

animationSpeed = 1;
setAnimationSpeed = function(value) {
	animationSpeed = current_time / value;
}

amount = 1;
setAmount = function(val=1) {
	amount = val;
}

setShape = function(val=ps_shape_rectangle) {
	shape = val;
}

Await.Register(5 * 60, function(){
	if (part_emitter_exists(ps, emitter)) 
		part_emitter_destroy(ps, emitter);
});
