
if (!variable_instance_exists(id, "isPuppet")) isPuppet = false;
if (!variable_instance_exists(id, "networkControllerID")) networkControllerID = 0;

dir = 0;

controlledInstance = noone;
controlledObject = "";

// Tell server where controller is
alarm[0] = 1;

player = noone;

control = function(inst) {
	if (!instance_exists(inst)) return;
	
	controlledInstance = inst;
	controlledObject = object_get_name(inst.object_index);
	inst.controlling = true;
}

setPlayer = function(inst) {
	player = inst;
}

update = function() {
	var inst = controlledInstance;
	
	if (inst == noone || !instance_exists(inst)) {
		inst = noone;
		return;
	}
	
	x = inst.x;
	y = inst.y;
	
	switch (controlledObject) {
		case "Spaceship":
			dir = inst.dir;
			
			break;
		
		case "Player":
			
			break;
	}
}

