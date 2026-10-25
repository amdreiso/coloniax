
function appearance_get_skin_colors() {
	return [
		#f8dcc4,
		#f1c6a5,
		#eac990,
		#b9825a,
		#a66b45,
		#8c5234,
		#663b2b,
		#3b2219,
	];
}

function appearance_get_hair_colors() {
	return [
		#090806,
		#2C1B18,
		#4B3024,
		#6B4423,
		#8B5A2B,
		#A97142,
		#C68642,
		#E0AC69,
		#F5DEB3,
		#FAD7A0,
		#FFF0C1,
		#B87333,
		#A52A2A,
		#722F37,
		#D62828,
		#FF69B4,
		#9B59B6,
		#3498DB,
		#2ECC71,
		#808080,
	];
}

function appearance_get_eye_colors() {
	return [
		#4A2C20,
		#6B3E26,
		#A97142,
		#C68642,
		#D4A017,
		#8B6F47,
		#6B8E23,
		#228B22,
		#50C878,
		#7FFFD4,
		#40E0D0,
		#4682B4,
		#4169E1,
		#1E90FF,
		#87CEEB,
		#B0C4DE,
		#708090,
		#A9A9A9,
		#C0C0C0,
		#CC66FF,
	]

}

function CharacterAppearance() constructor {
	var skinColors = appearance_get_skin_colors();
	var hairColors = appearance_get_hair_colors();
	var eyeColors  = appearance_get_eye_colors(); 

	self.eyeColor   = array_get_random(eyeColors);
	self.skinColor  = array_get_random(skinColors);
	self.hairColor  = array_get_random(hairColors);
	self.shirtColor = make_color_hsv(irandom(255), irandom_range(50, 87), 225);

	self.eyeID  = irandom(7);
	self.hairID = irandom(9);
	//self.headID = irandom(7);

	self.eye  = asset_get_index("sPlayer_Eye_"+string(self.eyeID));
	self.hair = asset_get_index("sPlayer_Hair_"+string(self.hairID));
	self.head = sPlayer_Head;

	static SetHair = function(index) {
		self.hairID = index;
		self.hair   = asset_get_index("sPlayer_Hair_"+string(index));
	}

	static SetEye = function(index) {
		self.eyeID = index;
		self.eye   = asset_get_index("sPlayer_Eye_"+string(index));
	}
}
