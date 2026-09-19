
lifetime = max(0, lifetime - GameSpeed);

if (lifetime <= 0) {
	instance_destroy();
}

part_emitter_region(ps, emitter, x-range.x/2, x+range.x/2, y-range.y/2, y+range.y/2, shape, ps_distr_gaussian);

switch (mode) {
	case "burst":
		part_emitter_burst(ps, emitter, particle, amount);
		break;
		
	case "stream":
		part_emitter_stream(ps, emitter, particle, amount);
		break;
}

