
slots = [];
spacing = 64;

columns = 5;
dir = 90;

unitAdd = function(obj){
	var index = array_length(slots);
	obj.formation = self;
	obj.formationIndex = index;
	array_push(slots, obj);
}

for (var i = 0; i < 15; i++) {
	var pos = irandvec2(x, y, 200);
	var obj = spawn(pos.x, pos.y, "Spaceship", Enemy_Destroyer);
	unitAdd(obj);
}

