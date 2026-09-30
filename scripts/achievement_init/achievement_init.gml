function achievement_init(){
	enum eAchievementType {
		CRAFT,
		ON_PLANET_LANDING,
		
		COUNT
	}
	
	G ACHIEVEMENT;
	ACHIEVEMENT = {};
	ACHIEVEMENT.data = {};
	
	for (var i = 0; i < eAchievementType.COUNT; i++) {
		ACHIEVEMENT.data[$ i] = [];
	}
	
	ACHIEVEMENT.Register = function(type, condition=function(){}) {
		var achievement = {
			achieved: false,
			condition: condition,
		};
		array_push(ACHIEVEMENT.data[$ type], achievement);
	}
	
	ACHIEVEMENT.Register(
		eAchievementType.ON_PLANET_LANDING,
		function(){
			if (Player.planet == noone) return false;
			if (Player.planet.type != ePlanetType.VOLCANIC) return false;
			
			CHAT.Send("%b [ACHIEVEMENT] %n It's a little chilly in here!");
			return true;
		}
	);
	
	ACHIEVEMENT.Find = function(type) {
		var len = array_length(ACHIEVEMENT.data[$ type]);
		for (var i = 0; i < len; i++) {
			var a = ACHIEVEMENT.data[$ type][i];
			var result = a.condition();
			if (result) {
				a.achieved = true;
			}
		}
	}
}