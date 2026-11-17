function minimap_init(){
	G MINIMAP;
	MINIMAP = {};
	MINIMAP.settings = {
		size: 100,
		margin: 8,
		x: 0, y: 0,
		distance: 100,
		scale: 1,
		controller: noone,
		surface: undefined,
	}

	var stt = MINIMAP.settings;

	MINIMAP.Draw = function() {
		if (instance_exists(Menu)) return;
		
		var Track 	= MINIMAP.Track;
		var stt 	= MINIMAP.settings;
		var scale 	= Settings.graphics.uiScale;
		var size 	= stt.size * scale;
		var margin	= stt.margin * scale;

		var offset 	= size / 2 + margin;
		stt.x = WIDTH - offset; 
		stt.y = HEIGHT - offset; 
		stt.surface = surface_create(size, size);

		stt.controller = Player;
		if (Player.controlling) {
			stt.controller = Player;
		} else if (Spaceship.controlling) {
			stt.controller = Spaceship;
		}

		rect(stt.x, stt.y, size, size, #101010, false);
		rect(stt.x, stt.y, size, size, #202020, true);

		Track(Planet, , function(){
			draw_sprite_ext(sIcon_Minimap_Planet, obj.iconIndex, x, y, scale, scale, 0, obj.iconColor, 1);
		});

		Track(Sun, , function(){
			draw_sprite_ext(sIcon_Minimap_Sun, 0, x, y, scale, scale, 0, c_white, 1);
		});

		Track(Enemy, , function(){
			draw_sprite_ext(sIcon_Minimap_Enemy, 0, x, y, scale, scale, 0, c_white, 1);
		});

		surface_set_target(stt.surface);
		if (stt.controller == Player) {
			draw_sprite_ext(
				sIcon_Minimap_Player, 0, size/2, size/2,
				scale, scale, 0, c_white, 1);
		} 
		else if (stt.controller = Spaceship) {
			draw_sprite_ext(
				sIcon_Minimap_Spaceship, 0, size/2, size/2, 
				scale, scale, Spaceship.dir, c_white, 1);
		}
		surface_reset_target();

		if (surface_exists(stt.surface)) {
			draw_surface(stt.surface, stt.x-size/2, stt.y-size/2);
		}

		surface_free(stt.surface);

		var cscale = scale / 2;
		draw_sprite_ext(sIcon_Minimap_Cardial, 0, stt.x, stt.y-size/2, cscale, cscale, 0, c_white, 1);
		draw_sprite_ext(sIcon_Minimap_Cardial, 1, stt.x+size/2, stt.y, cscale, cscale, 0, c_white, 1);
		draw_sprite_ext(sIcon_Minimap_Cardial, 2, stt.x, stt.y+size/2, cscale, cscale, 0, c_white, 1);
		draw_sprite_ext(sIcon_Minimap_Cardial, 3, stt.x-size/2, stt.y, cscale, cscale, 0, c_white, 1);
	}

	MINIMAP.Track = function(obj, fixed=false, fn=function(){}) {
		var scale = Settings.graphics.uiScale;

		for (var i = 0; i < instance_number(obj); i++) {
			var inst = instance_find(obj, i);
			var px = inst.x - MINIMAP.settings.controller.x;
			var py = inst.y - MINIMAP.settings.controller.y;
			px /= MINIMAP.settings.distance;
			py /= MINIMAP.settings.distance;
			var num = 1.75;

			var s = MINIMAP.settings.size * scale;

			if (fixed) {
				var ss = s/2;
				px = clamp(px, -ss, ss);
				py = clamp(py, -ss, ss);
			}

			var outsideMap = (abs(px) > s / num || abs(py) > s / num);
			if (!outsideMap || fixed) {
				draw_on_surface(MINIMAP.settings.surface, method({
					obj: inst,
					x: s/2+px,
					y: s/2+py,
					scale: scale, //MINIMAP.settings.scale
				}, fn));
			}
		}
	}
}
