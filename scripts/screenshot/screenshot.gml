function screenshot(){
	var name = $"coloniax-screenshot-{current_year}-{current_month}-{current_day} {current_hour}-{current_minute}-{current_second} {irandom(1000)}.png";
	screen_save("screenshots/"+name);
	CHAT.Send($"Screenshot '{name}' saved");
}