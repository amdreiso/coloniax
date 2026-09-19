function effect_init(){
	
	enum eEffectID {
		Flames,
		Freeze,
		Poison,
	}
	
	G EFFECT;
	EFFECT = {};
	
	EFFECT.map = ds_map_create();
	
	EFFECT.Token = function(effectID, time = 5 * 60) constructor {
		self.effectID = effectID;
		self.time = time;
		self.timeDefault = time;
	}
	
	EFFECT.State = function(parent) constructor {
		self.list = [];
		self.immunity = [];
		self.parent = parent;
		
		static Has = function(effectID) {
			for (var i = 0; i < array_length(self.list); i++) {
				if (self.list[i].effectID == effectID) {
					return i;
				}
			}
			return -1;
		}
		
		static Add = function(effectID, time = 5 * 60) {
			var index = self.Has(effectID);
			
			// Maybe cue when effect is blocked by immunity
			if (array_contains(self.immunity, effectID)) return;
			
			if (index != -1) {
				self.list[index].time			= time;
				self.list[index].timeDefault	= time;
				return;
			}
			
			array_push(self.list, new EFFECT.Token(effectID, time));
			self.Call("load");
		}
		
		static Apply = function() {
			for (var i = 0; i < array_length(self.list); i++) {
				var e = self.list[i];
				e.time = max(0, e.time - GameSpeed);
				if (e.time == 0) {
					self.Call("finish");
					array_delete(self.list, i, 1);
				}
			}
		}
		
		static Call = function(name) {
			for (var i = 0; i < array_length(self.list); i++) {
				var e = self.list[i];
				var effect = EFFECT.map[? e.effectID];
				var fn = struct_get(effect, name);
				if (fn != undefined) fn(self.parent);
			}
		}
	}
	
	EFFECT.Register = function(effectID, load = function(e){}, update = function(e){}, draw = function(e){}, finish = function(e){}) {
		var eff = {};
		eff.load = load;
		eff.update = update;
		eff.draw = draw;
		eff.finish = finish;
		
		EFFECT.map[? effectID] = eff;
	}
	
	#region Effects
	
	EFFECT.Register(
		eEffectID.Flames,
		function(e){
			CHAT.SendTime("Player got burned");
		},
		function(e){
			static tick = 0;
			tick ++;
			if (tick > 30) {
				CHAT.SendTime("WARNING:: You are burning!");
				tick = 0;
			}
		},
		function(e){
		},
		function(e){
		}
	);
	
	EFFECT.Register(
		eEffectID.Freeze,
		function(e){
		},
		function(e){
		},
		function(e){
		},
		function(e){
		}
	);
	
	EFFECT.Register(
		eEffectID.Poison,
		function(e){
		},
		function(e){
		},
		function(e){
		},
		function(e){
		}
	);
	
	#endregion
}