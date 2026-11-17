function vela(){
	enum eNodeType {
		TEXT,
		BUTTON,
		PANEL,
		SURFACE,
		METER,
		INPUT_TEXT,
		INPUT_BOX,
		SLIDER,
	}
	
	enum eNodeAnchor {
		TOPLEFT,
		TOPCENTER,
		TOPRIGHT,
		MIDDLELEFT,
		MIDDLECENTER,
		MIDDLERIGHT,
		BOTTOMLEFT,
		BOTTOMCENTER,
		BOTTOMRIGHT,
	}
	
	enum eNodeDirection {
		ROW,
		COLUMN,
	}

	#macro VELA_WHITE	#fafafa
	#macro VELA_BLACK	#050505
	#macro VELA_RED		#f56c6d
	#macro VELA_ORANGE	#f0944f
	#macro VELA_GREEN	#7dca7c
	#macro VELA_BLUE	#73a1d8
	#macro VELA_MAGENTA	#e18fc6
	#macro VELA_PINK	#e9b6d8
	
	G Vela_Theme;
	Vela_Theme = {};
	var themefile = "vela_theme.json";
	
	if (file_exists(themefile)) {
		var f = fopen(themefile);
		var c = fread(f, buffer_string);
		
		Vela_Theme = json_parse(c, function(key, val){
			if (string_char_at(val, 1) == "#") {
				val = string_delete(val, 1, 1);
				var r = hex_to_dec(string_copy(val, 1, 2));
				var g = hex_to_dec(string_copy(val, 3, 2));
				var b = hex_to_dec(string_copy(val, 5, 2));
				val = make_color_rgb(r,g,b);
			}
			return val;
		});
		
		fclose(f);
	} else {
		var f = fopen(themefile);
		fwrite(f, "{}", buffer_string);
		fclose(f);
	}
	
	#macro TRANSPARENT -1
	#macro BUTTON_HOLD_MS 30

	G Vela;
	Vela = {};

	Vela.navigationMode = "gamepad";
	Vela.navigation = {x:0,y:0};
	Vela.nodeY = 0;

	Vela.navigate = function(axis, dir) {
		Vela.navigation[$ string(axis)] += dir;
		Vela.lastNavigationMotion = {axis:axis, dir:dir};
	}
}

function v_GetDefaultStyle() {
	var defaults =  {
		anchor: eNodeAnchor.MIDDLECENTER,
		padding: 0,
		margin: new Dim(),
		direction: eNodeDirection.ROW,
		
		opacity: 1,
		backgroundColor: #181818,
		color: c_white,
		
		border: true,
		borderSize: 1,
		borderColor: c_dkgray,
		borderColorSelected: c_white,
		
		buttonHoverColor: c_white,
		buttonClickColor: c_black,
		buttonSound: -1,
		
		draggable: false,
		width: 0,
		height: 0,
		
		meterColor: VELA_ORANGE,
	}
	
	struct_merge(defaults, Vela_Theme);
	return defaults;
}

// ---------------------------------------------------------------------------
// Anchoring
// ---------------------------------------------------------------------------

/// Offset (from the box's top-left) of an item of size itemW x itemH
/// placed inside a box of size boxW x boxH according to `anchor`.
function v_AnchorOffset(anchor, boxW, boxH, itemW, itemH) {
	var col = anchor mod 3;	// 0 left, 1 center, 2 right
	var row = anchor div 3;	// 0 top,  1 middle, 2 bottom
	return new Vec2(
		(boxW - itemW) * col / 2,
		(boxH - itemH) * row / 2
	);
}

/// Padding of a node as a Vec2 (total horizontal, total vertical).
function v_GetNodePadding(node) {
	var p = node.style.padding;
	if (is_struct(p)) return new Vec2(p.width, p.height);
	return new Vec2(p, p);
}

/// Top-left corner of the node's content (text/sprite/etc) block, placed by
/// node.style.anchor inside the node's padded box.
/// itemW/itemH default to node.textWidth/textHeight.
function v_GetNodeAnchorTopLeft(node, xx, yy, itemW=undefined, itemH=undefined) {
	itemW ??= node.textWidth;
	itemH ??= node.textHeight;
	
	var pad = v_GetNodePadding(node);
	var off = v_AnchorOffset(
		node.style.anchor,
		node.width  - pad.x,
		node.height - pad.y,
		itemW,
		itemH
	);
	
	return new Vec2(xx + pad.x / 2 + off.x, yy + pad.y / 2 + off.y);
}

/// CENTER of the node's content block (use with ALIGN_MIDDLE_CENTER).
function v_GetNodeAnchorPosition(node, xx, yy, itemW=undefined, itemH=undefined) {
	itemW ??= node.textWidth;
	itemH ??= node.textHeight;
	
	var tl = v_GetNodeAnchorTopLeft(node, xx, yy, itemW, itemH);
	return new Vec2(tl.x + itemW / 2, tl.y + itemH / 2);
}

// ---------------------------------------------------------------------------
// Debug helpers
// ---------------------------------------------------------------------------

function v_DebugRect(x1, y1, x2, y2, col) {
	draw_set_alpha(1);
	draw_rectangle_color(x1, y1, x2, y2, col, col, col, col, true);
}

function v_DebugDot(xx, yy, col) {
	draw_set_alpha(1);
	draw_circle_color(xx, yy, 2, col, col, false);
}

function v_NodeDrawBorder(node) {
	var bc = node.style.borderColor;
	var bs = node.style.borderSize;
	
	for (var i = 0; i < bs; i++){
		draw_set_alpha(node.style.opacity);
		draw_rectangle_color(
			initPos.x - i,
			initPos.y - i,
			
			initPos.x + node.width  + i,
			initPos.y + node.height + i,
			bc, bc, bc, bc, true
		);
		draw_set_alpha(1);
	}
}

function v_DrawInputBox(node, xx, yy) {
	// Input box content fills the padded box, text is drawn from its top-left.
	var padding = v_GetNodePadding(node);
	var pos = new Vec2(xx + padding.x / 2, yy + padding.y / 2);
	var bc = node.style.borderColor;
	var bg = node.style.backgroundColor;
	
	var str = node.text;
	var len = string_length(str);
	var linelen = array_length(node.lines);
	var block = "█";
	var blinkTime = 40;

	node.cursorBlink ++;

	if (node.cursorBlink >= blinkTime) {
		node.cursorBlink = 0;

		if (node.cursorBlock == block) node.cursorBlock = "" else node.cursorBlock = block;
	}

	var close = function(node) {
		node.editing = false;
		KeyboardBusy = false;
	}
	
	var was_hovered = node.hovered;
	node.hovered = node.OnMouse(xx, yy);
	
	if (was_hovered && !node.hovered) {
		window_set_cursor(cr_default);
		CursorBusy = false;
	}
	
	if (node.hovered) {
		CursorBusy = true;
		window_set_cursor(cr_beam);
		
		if (mouse_check_button_released(mb_left)) {
			node.editing = true;
		}
	}

	var checkKeyboard = function(node) {
		var last = keyboard_lastkey;
		var char = keyboard_lastchar;
		var len = string_length(node.text);

		var erase = function(node) {
			if (node.cursor.x == 0) {
				if (node.cursor.y <= 0) {
					node.cursorLength = 0;
					return;
				}
				var prevLen = node.lines[node.cursor.y - 1].len;

				node.text = string_delete(node.text, node.cursorLength, 1);

				node.lines[node.cursor.y - 1].len += node.lines[node.cursor.y].len;
				array_delete(node.lines, node.cursor.y, 1);

				node.cursor.y--;
				node.cursor.x = prevLen;
				node.cursorLength--;
			} else {
				node.text = string_delete(node.text, node.cursorLength, 1);
				node.lines[node.cursor.y].len--;
				node.cursor.x--;
				node.cursorLength--;
			}
			node.CursorReset();
		}

		if (keyboard_check_pressed(vk_anykey) && last != vk_nokey && char != "") {

			if (last == vk_backspace || last == vk_delete) {
				if (string_length(node.text) <= 0) return;

				if (keyboard_check(vk_control)) {
					var currchar = string_char_at(node.text, node.cursorLength);
					while ((currchar != " " && currchar != "," && currchar != "(") && node.cursorLength > 0 && node.cursor.x > 1) {
						erase(node);
						currchar = string_char_at(node.text, node.cursorLength);
					}
					erase(node);

					return;
				}

				erase(node);
				return;
			}

			if (keyboard_check_pressed(ord("V")) && clipboard_has_text()) {
				if (keyboard_check(vk_control)) {
					node.Paste();
				}
			}

			var weirdos = [
				vk_tab, vk_lshift, vk_shift, vk_rshift, vk_escape, vk_control, vk_lcontrol,
				vk_rcontrol, vk_alt, vk_lalt, vk_ralt, vk_right, vk_left, vk_up, vk_down,
				vk_insert, vk_home, vk_pagedown, vk_pageup,
				vk_f1, vk_f2, vk_f3, vk_f4, vk_f5, vk_f6, vk_f7, vk_f8, vk_f9, vk_f10, vk_f11, vk_f12,
				91, 92, // windows keys
			];

			for (var i = 0; i < array_length(weirdos); i++) {
				if (last == weirdos[i]) return;
			}

			if (keyboard_check_pressed(vk_enter)) {
				node.NewLine();
				return;
			}

			for (var i = 0; i < array_length(weirdos); i++) {
				var w = weirdos[i];
				if (w == vk_shift || w == vk_lshift || w == vk_rshift) continue;
				if (keyboard_check(w)) return;
			}

			node.Append(char);
		}
	}

	var cursorMotions = function(node) {
		var left = function(node) {
			if (node.cursorLength <= 0) return;

			if (node.cursor.x == 0 && node.cursor.y > 0) {
				node.cursor.y --;
				node.cursor.x = node.lines[node.cursor.y].len;
				node.cursorLength --;
			} else {
				node.cursor.x -= 1;
				node.cursorLength --;
			}
			
			node.CursorReset();
		}

		var right = function(node) {
			if (node.cursorLength >= string_length(node.text)) return;

			if (node.cursor.x < node.lines[node.cursor.y].len) {
				node.cursor.x ++;
				node.cursorLength ++;
			} else {
				if (node.cursor.y < array_length(node.lines)-1) {
					node.cursor.y ++;
					node.cursor.x = 0;
					node.cursorLength ++;
				}
			}
			
			node.CursorReset();
		}

		if (keyboard_check_pressed(vk_left)) {
			if (keyboard_check(vk_control)) {
				var currchar = string_char_at(node.text, node.cursorLength);
				while ((currchar != " " && currchar != "," && currchar != "(") && node.cursorLength > 0) {
					left(node);
					currchar = string_char_at(node.text, node.cursorLength);
				}
				left(node);
				return;
			}
			left(node);
		}

		if (keyboard_check_pressed(vk_right)) {
			if (keyboard_check(vk_control)) {
				right(node);
				while (string_char_at(node.text, node.cursorLength) != " " && node.cursorLength < string_length(node.text)) {
					right(node);
				}
				return;
			}
			right(node);
		}

		if (keyboard_check_pressed(vk_up) && node.cursor.y > 0) {
			var lastx = node.cursor.x;
			var lastlen = node.lines[node.cursor.y].len;

			node.cursor.y --;
			var len = node.lines[node.cursor.y].len;

			var newx = min(node.cursor.x, len);
			
			node.cursor.x = newx;
			node.cursorLength -= lastx + 1 + len - newx;
			node.CursorReset();
		}

		if (keyboard_check_pressed(vk_down) && node.cursor.y < array_length(node.lines)-1) {
			var lastx = node.cursor.x;
			var lastlen = node.lines[node.cursor.y].len;

			node.cursor.y ++;
			var len = node.lines[node.cursor.y].len;

			var x1 = min(node.cursor.x, len);
			node.cursor.x = x1;
			node.cursorLength += lastlen - lastx + 1 + x1;
			node.CursorReset();
		}
	}
	
	if (node.editing) {
		bc = node.style.borderColorSelected;
		KeyboardBusy = true;

		checkKeyboard(node);
		cursorMotions(node);
	}

	if (node.editing && !node.hovered) {
		CursorBusy = false;
		window_set_cursor(cr_default);
		
		if (mouse_check_button_pressed(mb_left)) {
			close(node);
		}
	}

	// Draw
	draw_rectangle_color(xx, yy, xx + node.width - 1, yy + node.height - 1, bc, bc, bc, bc, true);
	
	var gutterSize = 3;
	var textWidth = (round(node.width / 9) - gutterSize);
	var final = str;

	ALIGN_TOP_LEFT;
	var c = node.style.color;
	var sw = string_width(" ");
	var sh = string_height(" ");
	var gutterx = sw * gutterSize;

	for (var i = 0; i < array_length(node.lines); i++) {
		var gc = #505050;
		if (node.cursor.y == i) gc = #cccccc;
		draw_text_color(pos.x, pos.y + i * sh, string(i+1), gc, gc, gc, gc, node.style.opacity);
	}

	if (node.editing) {
		draw_set_alpha(0.05);
		draw_rectangle_color(
			pos.x,
			pos.y + node.cursor.y * sh - 1, 

			pos.x + node.width,
			pos.y + node.cursor.y * sh + sh - 1, 
			c_white, c_white, c_white, c_white, false
		)
		draw_set_alpha(1);
	}

	draw_text_color(pos.x + gutterx, pos.y, node.text, c, c, c, c, node.style.opacity);

	if (node.editing) {
		draw_text_color(
			pos.x + node.cursor.x * sw + gutterx, 
			pos.y + node.cursor.y * sh, 
			node.cursorBlock, 
			c, c, c, c, node.style.opacity
		);

		if (string_length(node.text) > 0 && node.cursorBlock != "") {
			draw_text_color(
				pos.x + node.cursor.x * sw + gutterx, 
				pos.y + node.cursor.y * sh, 
				string_char_at(node.text, node.cursorLength + 1),
				bg, bg, bg, bg, node.style.opacity
			);
		}
	} 
}

function v_Separator() {
	var sep = new v_Text(" ", {
		direction: eNodeDirection.COLUMN,
		border: false,
	});
	return sep;
}

function v_Panel(x=0, y=0, styleComponents={}) constructor {
	self.type = eNodeType.PANEL;
	self.children = [];
	self.length = 0;
	self.nodeClasses = {};
	self.isRoot = false;
	
	self.x = x;
	self.y = y;
	self.initPos = new Vec2(x, y);
	self.navigation = new Vec2(); // gamepad/keyboard navigation
	
	// width / height = final panel size (never smaller than style.width/height)
	// contentWidth / contentHeight = size of the block the children take up
	self.width	= 0;
	self.height = 0;
	self.contentWidth  = 0;
	self.contentHeight = 0;
	self.textWidth  = 0;
	self.textHeight = 0;
	
	self.style = v_GetDefaultStyle();
	struct_merge(self.style, styleComponents);
	
	self.maximum = {
		width: 0,
		height: 0,
		marginWidth: 0,
		marginHeight: 0,
	}
	
	self.defaultChildrenStyle = {};
	
	static SetDefaultChildrenStyle = function(styleComponents={}) {
		self.defaultChildrenStyle = styleComponents;
	}
	
	static PushDefaultChildrenStyle = function(styleComponents={}) {
		struct_merge(self.defaultChildrenStyle, styleComponents);
	}
	
	static Destroy = function() {
		self.children = [];
		self.length = 0;
	}
	
	static ApplyStyle = function(style={}) {
		struct_merge(self.style, style);
	}
	
	static UpdateLayout = function() {
		self.Recalculate();
	}
	
	static Recalculate = function() {
		var w = 0;
		var h = 0;
		
		self.maximum.width  = 0;
		self.maximum.height = 0;
		self.maximum.marginWidth  = 0;
		self.maximum.marginHeight = 0;
		self.length = array_length(self.children);
		
		var isRow = (self.style.direction == eNodeDirection.ROW);
		
		for (var i = 0; i < self.length; i++) {
			var node = self.children[i];
			if (node == undefined) continue;
			
			self.maximum.marginWidth	= max(self.maximum.marginWidth,  node.style.margin.width);
			self.maximum.marginHeight	= max(self.maximum.marginHeight, node.style.margin.height);
			self.maximum.width			= max(self.maximum.width,  node.width);
			self.maximum.height			= max(self.maximum.height, node.height);
			
			// no trailing margin after the last child
			var isLast = (i == self.length - 1);
			var marginWidth  = isLast ? 0 : node.style.margin.width;
			var marginHeight = isLast ? 0 : node.style.margin.height;
			
			// main axis only; cross axis is resolved after the loop
			if (isRow)	w += node.width  + marginWidth;
			else		h += node.height + marginHeight;
		}
		
		if (self.length > 0) {
			var firstMargin = self.children[0].style.margin;
			
			if (isRow) {
				w += firstMargin.width / 2;
				h = self.maximum.height + self.maximum.marginHeight;
			} else {
				h += firstMargin.height / 2;
				w = self.maximum.width + self.maximum.marginWidth;
			}
		}
		
		self.contentWidth  = w;
		self.contentHeight = h;
		self.textWidth  = w;
		self.textHeight = h;
		
		// style.width/height act as a MINIMUM size
		self.width  = max(w, self.style.width);
		self.height = max(h, self.style.height);
	}
	
	static Get = function(index) {
		return self.children[index];
	}
	
	static Insert = function(index, node) {
		array_insert(self.children, index, node);
		self.Recalculate();
	}
	
	static Push = function(node, class=undefined) {
		node.ApplyStyle(self.defaultChildrenStyle);
		node.UpdateLayout();

		array_push(self.children, node);

		var index = array_length(self.children)-1;
		if (class != undefined) self.nodeClasses[$ class] = index;
		self.Recalculate();
	}
	
	static Find = function(class) {
		var index = self.nodeClasses[$ class];
		if (index != undefined) {	// was `if (index)`, which failed for index 0
			return self.children[index];
		}
		return false;
	}
	
	static Edit = function(class, fn=function(e){}) {
		var index = self.nodeClasses[$ class];
		if (index != undefined) {
			fn(self.children[index]);
			return true;
		}
		return false;
	}
	
	static Remove = function(node) {
		var index = array_get_index(self.children, node);
		if (index == -1) return;
		self.RemoveAt(index);
	}
	
	static RemoveAt = function(index) {
		array_delete(self.children, index, 1);
		self.Recalculate();
	}
	
	static Reverse = function() {
		self.children = array_reverse(self.children);
	}

	static DrawNavigationSelection = function() {
		if (self.navigation.x == Vela.navigation.x &&
		self.navigation.y == Vela.navigation.y) {
			//draw_circle_color(self.x+self.width/2, self.y+self.height/2, 4, c_white, c_white, false);
		}

		if (self.isRoot && false) {
			var up = (keyboard_check_pressed(vk_up))
			var down = (keyboard_check_pressed(vk_down));
			var left = (keyboard_check_pressed(vk_left));
			var right = (keyboard_check_pressed(vk_right));

			if (up) 	Vela.navigate(y, -1);
			if (down) 	Vela.navigate(y, 1);
			if (left) 	Vela.navigate(x, -1);
			if (right) 	Vela.navigate(x, 1);
		}
	}
	
	static Draw = function() {
		if (self.length == 0) {
			//print("Trying to draw panel with no length!");
			return;
		}
		
		var mx = window_mouse_get_x();
		var my = window_mouse_get_y();
		
		// drag first so everything below uses the up-to-date position
		self.Drag(mx, my);
		
		if (self.style.backgroundColor != TRANSPARENT) {
			draw_set_alpha(self.style.opacity);
			draw_rectangle_color(initPos.x, initPos.y, initPos.x + self.width, initPos.y + self.height, self.style.backgroundColor, self.style.backgroundColor, self.style.backgroundColor, self.style.backgroundColor, false);
			draw_set_alpha(1);
		}
		
		if (self.style.borderColor != TRANSPARENT && self.style.border) {
			v_NodeDrawBorder(self);
		}
		
		var isRow = (self.style.direction == eNodeDirection.ROW);
		var anchor = self.style.anchor;
		var firstMargin = array_first(self.children).style.margin;
		
		// 1) Where does the children block sit inside the panel? (panel anchor)
		var block = v_AnchorOffset(anchor, self.width, self.height, self.contentWidth, self.contentHeight);
		var bx = self.initPos.x + block.x;
		var by = self.initPos.y + block.y;
		
		// 2) Origin of the first child inside that block
		if (isRow) {
			self.x = bx + firstMargin.width / 2;
			self.y = by + self.maximum.marginHeight / 2;
		} else {
			self.x = bx + self.maximum.marginWidth / 2;
			self.y = by + firstMargin.height / 2;
		}
		
		var xoff = 0;
		var yoff = 0;
		
		for (var i = 0; i < self.length; i++) {
			var node = self.children[i];
			
			if (node == undefined) continue;
			if (node.type == -1) continue;
			
			var xmargin = node.style.margin.width;
			var ymargin = node.style.margin.height;
			
			var xx = self.x + xoff;
			var yy = self.y + yoff;
			var textpos;
			
			// 3) Cross-axis alignment of the child inside its row/column (panel anchor)
			if (isRow) {
				yy += v_AnchorOffset(anchor, 0, self.maximum.height, 0, node.height).y;
			} else {
				xx += v_AnchorOffset(anchor, self.maximum.width, 0, node.width, 0).x;
			}
			
			// size of the node's content block (text/sprite/etc); some nodes override it below
			var tw = node.textWidth;
			var th = node.textHeight;
			
			switch (node.type) {
				case eNodeType.TEXT: {
					
					ALIGN_MIDDLE_CENTER;
					textpos = v_GetNodeAnchorPosition(node, xx, yy);
					
					draw_text_color(textpos.x, textpos.y, node.text, node.style.color, node.style.color, node.style.color, node.style.color, node.style.opacity);
					
					break;
				}
				case eNodeType.BUTTON: {
					
					var bc = node.style.backgroundColor;
					
					if (bc != TRANSPARENT) {
						draw_rectangle_color(xx, yy, xx + node.width - 1, yy + node.height - 1, bc, bc, bc, bc, false);
					}

					if (string_length(node.text) > 0) {
						ALIGN_MIDDLE_CENTER;
						textpos = v_GetNodeAnchorPosition(node, xx, yy);
						draw_text_color(textpos.x, textpos.y, node.text, node.style.color, node.style.color, node.style.color, node.style.color, node.style.opacity);
					}

					if (sprite_exists(node.sprite)) {
						draw_sprite(node.sprite, node.spriteIndex, xx + node.width / 2, yy + node.height / 2);
					}
					
					node.hovered = node.OnMouse(xx, yy);
					
					if (node.hovered) {
						CursorBusy = true;
						window_set_cursor(cr_handpoint);
						node.selected = true;
						
						var bhc = node.style.buttonHoverColor;
						var alpha = 0.25;
						
						if (mouse_check_button(mb_left)) {
							bhc = node.style.buttonClickColor;
							alpha = 0.10;
						}

						draw_set_alpha(alpha);
						draw_rectangle_color(xx, yy, xx + node.width - 1, yy + node.height - 1, bhc, bhc, bhc, bhc, false);
						draw_set_alpha(1);
						
						if (mouse_check_button(mb_left) && node.canHold) {
							node.tick += 1;
							if (node.tick >= BUTTON_HOLD_MS) {
								node.held = true;
								node.callback.Call([node, true]);
							}
						}
						
						if (mouse_check_button_released(mb_left)) {
							if (node.held) {
								node.held = false;
								node.tick = 0;
								CursorBusy = false;
								window_set_cursor(cr_default);
							} else {
								node.tick = 0;
								CursorBusy = false;
								
								var snd = node.style.buttonSound;
								if (snd != -1 && !audio_is_playing(snd)) {
									SOUND.Play(eSoundType.UI, snd, false, 1, 1);
								}
								
								window_set_cursor(cr_default);
								node.callback.Call([node, false]);
							}
						}
						
					}
					
					if (node.selected && !node.hovered) {
						CursorBusy = false;
						node.selected = false;
						node.tick = 0;
						window_set_cursor(cr_default);
					}
					
					break;
				}
				case eNodeType.PANEL: {
					
					node.SetPosition(xx, yy);
					node.Draw();
					
					break;
				}
				case eNodeType.SURFACE: {
					
					// pos = center of the surface's content block
					var pos = v_GetNodeAnchorPosition(node, xx, yy);
					node.callback.Call([pos.x, pos.y, node.width, node.height]);
					
					break;
				}
				case eNodeType.METER: {
					
					// pos = center of the meter
					var pos = v_GetNodeAnchorPosition(node, xx, yy);
					var value = node.meter.get();
					var bg = node.style.meterColor;
					
					rect(pos.x, pos.y, node.width, node.height, node.style.borderColor, true);
					
					var part = (value / node.meter.maxvalue);
					var pw = (node.width * part);
					
					if (value > 0) then draw_rectangle_color(
						pos.x - node.width / 2, pos.y - node.height / 2, 
						(pos.x - node.width / 2) + (node.width * part), pos.y + node.height / 2, 
						
						bg, bg, bg, bg, false
					);
					
					
					break;
				}
				case eNodeType.INPUT_TEXT: {
					
					var bc = node.style.borderColor;
					
					var str = node.text;
					
					var close = function(node) {
						node.editing = false;
						KeyboardBusy = false;
					}
					
					var was_hovered = node.hovered;
					node.hovered = node.OnMouse(xx, yy);
					
					if (was_hovered && !node.hovered) {
						window_set_cursor(cr_default);
						CursorBusy = false;
					}
					
					if (node.hovered) {
						CursorBusy = true;
						window_set_cursor(cr_beam);
						
						if (mouse_check_button_released(mb_left)) {
							node.editing = true;
							keyboard_string = node.text;
						}
					}
					
					if (node.editing) {
						bc = node.style.borderColorSelected;
						str = keyboard_string;
						KeyboardBusy = true;
						
						node.text = keyboard_string;
						if (keyboard_check_pressed(vk_enter)) {
							close(node);
						}
					}
					
					if (node.editing && !node.hovered) {
						CursorBusy = false;
						window_set_cursor(cr_default);
						
						if (mouse_check_button_pressed(mb_left)) {
							close(node);
						}
					}
					
					// Draw
					draw_rectangle_color(xx, yy, xx + node.width - 1, yy + node.height - 1, bc, bc, bc, bc, true);
					
					var textWidth = (round(node.width / 9));
					
					var len = string_length(str);
					var final = str;
					
					if (len > textWidth) {
						if (node.editing) {
							final = string_copy(str, len - textWidth, textWidth + 1);
						} else {
							var maxOffset = len - textWidth;
							
							var spd = 100; 
							var pause = 1000;
							var cycle = pause + maxOffset * spd + pause + maxOffset * spd;
							var t = current_time % cycle;
							var offset = 0;
							
							if (t < pause) {
							    offset = 0;
							} else if (t < pause + maxOffset * spd) {
							    offset = floor((t - pause) / spd);
							} else if (t < pause + maxOffset * spd + pause) {
							    offset = maxOffset;
							} else {
							    offset = maxOffset - floor(
							        (t - pause - maxOffset * spd - pause) / spd
							    );
							}
							
							final = string_copy(str, offset + 1, textWidth);
						}
					}
					
					// the text changes while editing, so anchor using the CURRENT text size
					tw = string_width(final);
					th = max(string_height(final), node.textHeight);
					
					ALIGN_MIDDLE_CENTER;
					var pos = v_GetNodeAnchorPosition(node, xx, yy, tw, th);
					draw_text_color(pos.x, pos.y, final, node.style.color, node.style.color, node.style.color, node.style.color, node.style.opacity);
					
					break;
				}
				case eNodeType.INPUT_BOX: {
					v_DrawInputBox(node, xx, yy);
					
					// content block of an input box = its whole padded area
					var ipad = v_GetNodePadding(node);
					tw = node.width  - ipad.x;
					th = node.height - ipad.y;
					
					break;
				}
				case eNodeType.SLIDER: {
					var pos = v_GetNodeAnchorPosition(node, xx, yy);
					break;
				}
			}
			
			if (keyboard_check_pressed(vk_escape)) {
				node.editing = false;
				KeyboardBusy = false;
	 		}
			
			// ---- debug: per-node rectangles (panels draw their own) ----
			if (Debug.velaUI && node.type != eNodeType.PANEL) {
				// aqua    = node box (incl. padding)
				v_DebugRect(xx, yy, xx + node.width - 1, yy + node.height - 1, c_aqua);
				
				// lime    = padded inner box (only if there is padding)
				var dpad = v_GetNodePadding(node);
				if (dpad.x != 0 || dpad.y != 0) {
					v_DebugRect(
						xx + dpad.x / 2, yy + dpad.y / 2,
						xx + node.width  - dpad.x / 2 - 1,
						yy + node.height - dpad.y / 2 - 1,
						c_lime
					);
				}
				
				// fuchsia = content (text) block placed by the node's anchor, yellow dot = its center
				var dtl = v_GetNodeAnchorTopLeft(node, xx, yy, tw, th);
				v_DebugRect(dtl.x, dtl.y, dtl.x + tw - 1, dtl.y + th - 1, c_fuchsia);
				v_DebugDot(dtl.x + tw / 2, dtl.y + th / 2, c_yellow);
			}
			
			if (isRow)	then xoff += node.width  + (xmargin);
			else			 yoff += node.height + (ymargin);
		}
		
		// ---- debug: panel rectangles ----
		if (Debug.velaUI) {
			// red (root) / aqua = panel box
			var pc = self.isRoot ? c_red : c_aqua;
			v_DebugRect(initPos.x, initPos.y, initPos.x + self.width - 1, initPos.y + self.height - 1, pc);
			
			// yellow = children block, positioned by the panel anchor; dot = its center
			v_DebugRect(bx, by, bx + self.contentWidth - 1, by + self.contentHeight - 1, c_yellow);
			v_DebugDot(bx + self.contentWidth / 2, by + self.contentHeight / 2, c_yellow);
		}

		self.DrawNavigationSelection();
	}
	
	static SetPosition = function(x, y) {
		self.x = x;
		self.y = y;
		self.initPos = new Vec2(x, y);
	};
	
	self.dragging = false;
	self.dragOffset = new Vec2();
	
	static Drag = function(mx, my) {
		if (!self.style.draggable) return;
		
		var range = (mx > self.initPos.x && mx < self.initPos.x + self.width && 
					 my > self.initPos.y && my < self.initPos.y + self.height);
		
		if (range && !CursorBusy) {
			if (mouse_check_button_pressed(mb_left)) {
				self.dragOffset = new Vec2(self.initPos.x - mx, self.initPos.y - my);
				self.dragging = true;
			}
		}
		
		if (self.dragging) {
			CursorBusy = true;
			self.initPos = new Vec2(mx + self.dragOffset.x, my + self.dragOffset.y);
			
			if (mouse_check_button_released(mb_left)) {
				self.dragging = false;
				CursorBusy = false;
			}
		}
	}
}

function v_Node() constructor {
	self.type = -1;
	self.text = "";
	
	self.sprite = -1;
	self.spriteIndex = 0;
	
	self.width = 0;
	self.height = 0;
	
	// size the node had before text/padding/style were applied
	// (captured on the first UpdateLayout so repeated calls don't stack padding)
	self.baseWidth  = -1;
	self.baseHeight = -1;
	
	// size of the content block (text, or the node itself for text-less nodes)
	self.textWidth  = string_width(self.text);
	self.textHeight = string_height(self.text);
	
	self.hovered = false;
	self.selected = false;
	self.editing = false;
	self.style = v_GetDefaultStyle();
	self.tick = 0;
	self.held = false;
	
	self.callback = new Callback();
	
	static ApplyStyle = function(style={}) {
		struct_merge(self.style, style);
	}
	
	static CalculateSize = function() {
		var sw = (self.sprite != -1) ? sprite_get_width(self.sprite)  : 0;
		var sh = (self.sprite != -1) ? sprite_get_height(self.sprite) : 0;
		
		self.width	= max(string_width(self.text),  sw, self.baseWidth,  self.style.width);
		self.height	= max(string_height(self.text), sh, self.baseHeight, self.style.height);
	}
	
	static UpdateLayout = function() {
		if (self.baseWidth < 0) {
			self.baseWidth  = self.width;
			self.baseHeight = self.height;
		}
		
		var sw = (self.sprite != -1) ? sprite_get_width(self.sprite)  : 0;
		var sh = (self.sprite != -1) ? sprite_get_height(self.sprite) : 0;
		
		if (string_length(self.text) > 0) {
			self.textWidth  = string_width(self.text);
			self.textHeight = string_height(self.text);
		} else {
			// text-less nodes (meter, surface, slider, sprite buttons): the node IS the content
			self.textWidth  = max(sw, self.baseWidth);
			self.textHeight = max(sh, self.baseHeight);
		}
		
		self.CalculateSize();
		
		var padding = self.style.padding;
		
		if (is_struct(padding)) {
		    self.width  += padding.width;
		    self.height += padding.height;
		} else {
		    self.width  += padding;
		    self.height += padding;
		}
	}
	
	static OnMouse = function(xx, yy) {
		var mx = window_mouse_get_x();
		var my = window_mouse_get_y();
		return (mx > xx && mx < xx + self.width && my > yy && my < yy + self.height);
	}
}

function v_Text(text, styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.TEXT;
	self.text = text;
	
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
}

function v_Button(textOrSprite, func=function(){}, styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.BUTTON;
	self.callback.Register(func);
	self.canHold = true;
	
	if (is_string(textOrSprite)) {
		self.text = textOrSprite;
	} else if (sprite_exists(textOrSprite)) {
		self.sprite = textOrSprite;
	}
	
	self.ApplyStyle({
		backgroundColor: TRANSPARENT,
	});
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
}

function v_Surface(width, height, func=function(x, y, width, height){}, styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.SURFACE;
	self.callback.Register(func);
	
	self.width = width;
	self.height = height;
	
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
}

function v_Meter(width, height, maxvalue, get=function(){}, styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.METER;
	//self.callback.Register(func);
	
	self.width = width;
	self.height = height;
	self.meter = {
		get: get,
		maxvalue: maxvalue,
	};
	
	var defaultColor = VELA_ORANGE;
	
	self.ApplyStyle({
		margin: new Dim(0, 10),
		borderColor: defaultColor,
		meterColor: defaultColor,
	});
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
}

function v_InputText(str="text here...", styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.INPUT_TEXT;
	self.text = str;
	
	self.ApplyStyle({
		padding: new Dim(20, 0),
	});
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
}

function v_InputBox(str="", styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.INPUT_BOX;
	self.text = str;
	self.cursor = new Vec2();
	self.lines = [
		{len: 0},
	];
	self.cursorLength = 0;
	self.cursorBlink = 0;
	self.cursorBlock = "█";

	static CursorReset = function() {
		self.cursorBlink = 0;
		self.cursorBlock = "█";
	}

	static Append = function(char) {
		var index = self.cursorLength + 1;
		self.text = string_insert(char, self.text, index);
		self.lines[self.cursor.y].len ++;
		self.cursorLength ++;
		self.cursor.x ++;
		self.CursorReset();
	}

	static NewLine = function() {
		var linelen = self.lines[self.cursor.y].len;

		self.text = string_insert("\n", self.text, self.cursorLength + 1);

		var left = self.cursor.x;
		var right = linelen - left;

		// Current line is left thingy
		self.lines[self.cursor.y].len = left;

		self.cursor.x = 0;
		self.cursorLength ++;
		self.cursor.y ++;

		// Insert newline with size of right
		array_insert(self.lines, self.cursor.y, {len: right});
		self.CursorReset();
	}

	static Paste = function() {
		var clip = clipboard_get_text();
		var cliplen = string_length(clip);
		var i = 1;

		while (i <= cliplen) {
			var curr = string_char_at(clip, i);
			if (curr == "\n") {
				self.NewLine();
				i++;
				continue;
			}
			self.Append(curr);
			i++;
		}
	}
	
	self.ApplyStyle({
		padding: new Dim(20, 0),
		anchor: eNodeAnchor.TOPLEFT,
	});
	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
}

function v_Slider(width, minvalue, maxvalue, get, styleComponents={}) : v_Node() constructor {
	self.type = eNodeType.SLIDER;
	self.slider = {
		get: get,
		minvalue: minvalue,
		maxvalue: maxvalue,
	}
	self.width = width;

	self.ApplyStyle(styleComponents);
	self.UpdateLayout();
}
