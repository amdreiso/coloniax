function menu_open(inst, x=0, y=0, vars={}){
	if (Paused) return;
	
	if (instance_exists(Menu)) {
		while (instance_exists(Menu)) {
			instance_destroy(Menu);
		}
	}
	
	spawn(x, y, 0, inst, vars);
}

function menu_switch(inst, x=0, y=0, vars={}){
	if (instance_exists(inst)) {
		instance_destroy(inst);
		return;
	}
	
	menu_open(inst, x, y, vars);
}