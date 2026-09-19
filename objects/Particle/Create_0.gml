
lifetime = 1;
setLifetime = function(val=1) {
	lifetime = val;
}

particle = World.particleFire;
setParticle = function(part = World.particleFire) {
	particle = part;
}

ps = World.ps;
setParticleSystem = function(system = World.ps) {
	ps = system;
}

emitter = part_emitter_create(ps);

mode = "burst";
function setMode(m="burst") {
	mode = m;
}

range = new Vec2();
setRange = function(x, y) {
	range = new Vec2(x, y);
}

amount = 1;
setAmount = function(val=1) {
	amount = val;
}

shape = ps_shape_rectangle;
setShape = function(val=ps_shape_rectangle) {
	shape = val;
}

