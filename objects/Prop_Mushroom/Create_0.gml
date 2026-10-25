
event_inherited();

//dropTable.Add(eItemID.STEEL, 0.25, [3, 4]);
//dropTable.Add(eItemID.WOOD, 0, [3, 4]);
dropTable.Set(new ItemStack(eItemID.WOOD, [3,4]), 10);
dropTable.Set(new ItemStack(eItemID.STEEL, [3,4]), 10);
hp.UpdateValue(100);

sprite_index = sProp_Mushroom0;
image_xscale = choose(-1, 1);
image_index = irandom(sprite_get_number(sprite_index));
image_speed = random_range(0.010, 0.200);

