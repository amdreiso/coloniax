function item_data(){
	
	G ITEM; ITEM = new Registry();
	
	var defaultComponents = {
		type: eItemType.BLANK,
		icon: -1,
		sprite: -1,
	};
	
	ITEM.SetDefaultComponents(defaultComponents);
	
	ITEM.GetTypeComponents = function(type, components={}) {
		var c = {};
		
		switch (type) {
			case eItemType.BLANK: {
				c = {
					type: eItemType.BLANK,
				}
				struct_merge_recursive(c, components);
				return c;
			}
			case eItemType.PICKAXE: {
				c = {
					type: eItemType.PICKAXE,
					miningSpeed: 1,
				}
				struct_merge_recursive(c, components);
				return c;
			}
			case eItemType.PROP: {
				c = {
					type: eItemType.PROP,
					prop: noone,
				}
				struct_merge_recursive(c, components);
				return c;
			}
		}
	}
	
	ITEM.Prototype = function(type, icon, components={}) {
		var c = {
			icon: icon,
		}
		
		var typeComponents = ITEM.GetTypeComponents(type, components);
		struct_merge_recursive(c, typeComponents);
		return c;
	}
	
	// Blanks
	ITEM.Register(eItemID.WOOD, ITEM.Prototype(eItemType.BLANK, sItem_Wood));
	ITEM.Register(eItemID.STEEL, ITEM.Prototype(eItemType.BLANK, sItem_Steel));
	
	// Tools
	ITEM.Register(eItemID.BASIC_PICKAXE, ITEM.Prototype(eItemType.PICKAXE, sItem_Pickaxe, {
		miningSpeed : 10,
	}));
	
	// Props
	ITEM.Register(eItemID.BASIC_SOLAR_PANEL, ITEM.Prototype(eItemType.PROP, sItem_BasicSolarPanel, {
		prop: Prop_BasicSolarPanel,
		size: [[0, 0]],
	}));
	
	ITEM.Register(eItemID.BASIC_MINING_DRILL, ITEM.Prototype(eItemType.PROP, sItem_BasicMiningDrill, {
		prop: Prop_BasicMiningDrill,
		size: [
			[0, 0],
			[-1, -1],
			[0, -1],
			[0, -2],
		],
	}));
	
}