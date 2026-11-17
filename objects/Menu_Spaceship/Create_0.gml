
defaultStyle = {
	draggable: false,
	border: false,
	backgroundColor: TRANSPARENT,
}

root = new v_Panel(WIDTH/2, HEIGHT/2, {
	direction: eNodeDirection.COLUMN,
	anchor: eNodeAnchor.TOPLEFT,
	draggable: false,
	width: WIDTH / 1.2,
	height: HEIGHT / 1.2,
	
	opacity: 0.9,
	backgroundColor: #181818,
});
root.isRoot = true;
root.SetDefaultChildrenStyle(defaultStyle);

var sep = string_repeat("=", 50);

// NAVBAR
navbar = new v_Panel(0, 0, {
	direction: eNodeDirection.COLUMN,
	anchor: eNodeAnchor.MIDDLECENTER,
	border: false,
});

navbar.PushDefaultChildrenStyle({
	anchor: eNodeAnchor.MIDDLECENTER,
	backgroundColor: TRANSPARENT,
});

navbar.Push(new v_Text(sep, {color: c_gray}));
navbar.Push(new v_Text(T.Getc("spaceship_menu"), {color: c_white}));
navbar.Push(new v_Text(sep, {color: c_gray}));

navbarButtons = new v_Panel(0, 0, {
	border: false,
});

navbarButtons.PushDefaultChildrenStyle({
	padding: new Dim(20, 0),
});

navbarButtons.Push(new v_Button(T.Getc("inventory")));
navbarButtons.Push(new v_Button(T.Getc("modules")));
navbarButtons.Push(new v_Button(T.Getc("stats")));

spaceshipModel = new v_Surface(100, 100, function(xx, yy, width, height){
	if (!instance_exists(Spaceship)) return;
	var theta = -current_time / 30;
	Spaceship.drawSpaceship(
		Spaceship.spaceship, xx, yy, 1.5, theta, Spaceship.color, 1, 3
	);
});

root.Push(navbar);
root.Push(v_Separator());
root.Push(navbarButtons);
root.Push(v_Separator());
root.Push(spaceshipModel);

index = root;
show = false;

Process.Push(function(){
	index.SetPosition(WIDTH / 2 - index.width/2, HEIGHT / 2 - index.height/2);
	show = true;
	return true;
});
