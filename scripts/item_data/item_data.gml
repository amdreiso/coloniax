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
					size: [[0, 0]],
				}
				struct_merge_recursive(c, components);
				return c;
			}
			
			case eItemType.GUN: {
				c = {
					projectileID: -1,
					
					damage: 0,
					recoil: 0,
					
				};
				struct_merge_recursive(c, components);
				return c;
			}
			
			case eItemType.SPACESHIP_MODULE_TURRET: {
				c = {
					type: eItemType.SPACESHIP_MODULE_TURRET,
					sprite: sTurret_Canon,
					damage: 10,
					firerate: 0,
				}
				struct_merge_recursive(c, components);
				return c;
			}
			
			case eItemType.SPACESHIP_MODULE_PROPELLER: {
				c = {
					type: eItemType.SPACESHIP_MODULE_PROPELLER,
					acceleration: 0,
					deceleration: 0,
					maxSpeed: 0,
				}
				struct_merge_recursive(c, components);
				return c;
			}
			
			case eItemType.SPACESHIP_MODULE_ARMOR: {
				c = {
					type: eItemType.SPACESHIP_MODULE_ARMOR,
				}
				struct_merge_recursive(c, components);
				return c;
			}
			
			case eItemType.SPACESHIP_MODULE_GYRO: {
				c = {
					type: eItemType.SPACESHIP_MODULE_GYRO,
					turnForce: 0,
					maxTurnSpeed: 0,

					independent: false,
				}
				struct_merge_recursive(c, components);
				return c;
			}
			
			case eItemType.TURRET_PROJECTILE: {
				c = {
					type: eItemType.TURRET_PROJECTILE,
					damage: 0,
					spd: 0,
					knockback: 0,
					sprite: -1,
					piercing: 0,
					
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
	
	// all the items
	
	#region Blanks
	
	ITEM.Register(eItemID.WOOD, ITEM.Prototype(eItemType.BLANK, sItem_Wood));
	ITEM.Register(eItemID.STEEL, ITEM.Prototype(eItemType.BLANK, sItem_Steel));
	ITEM.Register(eItemID.URANIUM, ITEM.Prototype(eItemType.BLANK, sItem_Uranium));
	
	#endregion
	
	#region Tools
	
	ITEM.Register(eItemID.BASIC_PICKAXE, ITEM.Prototype(eItemType.PICKAXE, sItem_Pickaxe, {
		miningSpeed : 10,
	}));
	
	#endregion
	
	#region Props
	
	ITEM.Register(eItemID.BASIC_SOLAR_PANEL, ITEM.Prototype(eItemType.PROP, sItem_BasicSolarPanel, {
		prop: Prop_BasicSolarPanel,
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
	
	#endregion
	
	#region Spaceship Modules
	
	// Turrets
	ITEM.Register(eItemID.BASIC_TURRET, ITEM.Prototype(eItemType.SPACESHIP_MODULE_TURRET, sItem_Steel, {
		sprite: sTurret_Canon,
		firerate: 24,
	}));
	
	ITEM.Register(eItemID.DOUBLE_BARREL_TURRET, ITEM.Prototype(eItemType.SPACESHIP_MODULE_TURRET, sItem_Steel, {
		sprite: sTurret_DoubleCanon,
		firerate: 20,
	}));
	
	// Gyros
	ITEM.Register(eItemID.BASIC_GYRO, ITEM.Prototype(eItemType.SPACESHIP_MODULE_GYRO, -1, {
		turnForce: 0.085,
		maxTurnSpeed: 1.05,
	}));
	
	ITEM.Register(eItemID.IMPROVED_GYRO, ITEM.Prototype(eItemType.SPACESHIP_MODULE_GYRO, -1, {
		turnForce: 0.1,
		maxTurnSpeed: 2.0,
		independent: true,
		minSpeed: 0.25,
	}));
	
	// Propellers
	ITEM.Register(eItemID.BASIC_PROPELLER, ITEM.Prototype(eItemType.SPACESHIP_MODULE_PROPELLER, -1, {
		acceleration: 0.025,
		deceleration: 0.005,
		maxSpeed: 5,
	}));
	
	ITEM.Register(eItemID.IMPROVED_PROPELLER, ITEM.Prototype(eItemType.SPACESHIP_MODULE_PROPELLER, -1, {
		acceleration: 0.03,
		deceleration: 0.005,
		maxSpeed: 5,
	}));
	
	#endregion
	
	#region Projectiles
	
	// Turret Projectiles
	ITEM.Register(eItemID.BASIC_PROJECTILE, ITEM.Prototype(eItemType.TURRET_PROJECTILE, -1, {
		sprite: sTurretProjectile_Basic,
		spd: 10,
		knockback: 0.4,
		piercing: 0,
	}));
	
	#endregion
	
}
