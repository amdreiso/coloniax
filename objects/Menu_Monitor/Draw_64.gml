
for (var i = 0; i < itemCount; i++) {
	main.Edit($"item_{i}", function(node){
		var key = node.children[0];
		var value = node.children[2];
		var result = struct_get(instance, key.text);
		value.text = result ?? "???";
		value.UpdateLayout();
	});
}

root.Draw();

