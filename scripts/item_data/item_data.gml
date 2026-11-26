function item_data(){
	enum eItemType {
		BLANK,
		PICKAXE,
		PROP,
		GUN,
		SPACESHIP_MODULE_TURRET,
		SPACESHIP_MODULE_PROPELLER,
		SPACESHIP_MODULE_ARMOR,
		SPACESHIP_MODULE_GYRO,
		
		TURRET_PROJECTILE,
	}
	
	enum eItemID {
		// Blanks
		WOOD,
		STEEL,
		URANIUM,

		// Guns
		PISTOL,
		LMG,
		
		// Pickaxes
		BASIC_PICKAXE,
		
		// Props
		BASIC_SOLAR_PANEL,
		BASIC_MINING_DRILL,
		
		// Spaceship Turrets
		BASIC_TURRET,
		DOUBLE_BARREL_TURRET,
		
		// Spaceship Gyros
		BASIC_GYRO,
		IMPROVED_GYRO,
		
		// Spaceship Propellers
		BASIC_PROPELLER,
		IMPROVED_PROPELLER,
		
		// Turret Projectiles
		BASIC_PROJECTILE,
		ARMOR_PIERCING_PROJECTILE,
	}

	G ITEM; ITEM = new Registry();
	
	var defaultComponents = {
		type: eItemType.BLANK,
		icon: -1,
		sprite: -1,
		translationKey: "",
	};
	
	ITEM.SetDefaultComponents(defaultComponents);
	
	ITEM.GetTypeComponents = function(type, components={}) {
		var c = {};
		
		switch (type) {
			case eItemType.BLANK: {
				c = {
					type: eItemType.BLANK,
				}
				struct_merge(c, components);
				return c;
			}
			
			case eItemType.PICKAXE: {
				c = {
					type: eItemType.PICKAXE,
					miningSpeed: 1,
				}
				struct_merge(c, components);
				return c;
			}
			
			case eItemType.PROP: {
				c = {
					type: eItemType.PROP,
					prop: noone,
					size: [[0, 0]],
				}
				struct_merge(c, components);
				return c;
			}
			
			case eItemType.GUN: {
				c = {
					type: eItemType.GUN,
					projectileID: -1,
					
					damage: 0,
					recoil: 0,
					firerate: 0,
					automatic: false,
					precision: 0,
					cameraShake: 1,
					ammo: 0,
					magazine: 0,
					sprite: -1,
				};
				struct_merge(c, components);
				return c;
			}
			
			case eItemType.SPACESHIP_MODULE_TURRET: {
				c = {
					type: eItemType.SPACESHIP_MODULE_TURRET,
					sprite: sTurret_Canon,
					damage: 10,
					firerate: 0,
				}
				struct_merge(c, components);
				return c;
			}
			
			case eItemType.SPACESHIP_MODULE_PROPELLER: {
				c = {
					type: eItemType.SPACESHIP_MODULE_PROPELLER,
					acceleration: 0,
					deceleration: 0,
					maxSpeed: 0,
				}
				struct_merge(c, components);
				return c;
			}
			
			case eItemType.SPACESHIP_MODULE_ARMOR: {
				c = {
					type: eItemType.SPACESHIP_MODULE_ARMOR,
				}
				struct_merge(c, components);
				return c;
			}
			
			case eItemType.SPACESHIP_MODULE_GYRO: {
				c = {
					type: eItemType.SPACESHIP_MODULE_GYRO,
					turnForce: 0,
					maxTurnSpeed: 0,
					minSpeed: 1,

					independent: false,
				}
				struct_merge(c, components);
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
				struct_merge(c, components);
				return c;
			}
		}
	}
	
	ITEM.Prototype = function(type, icon, tkey, components={}) {
		var c = {
			icon: icon,
			translationKey: tkey,
		}
		
		var typeComponents = ITEM.GetTypeComponents(type, components);
		struct_merge(c, typeComponents);
		return c;
	}
	
	// all the items
	
	#region Blanks
	
	ITEM.Register(eItemID.WOOD, ITEM.Prototype(eItemType.BLANK, sItem_Wood, "item_wood"));
	ITEM.Register(eItemID.STEEL, ITEM.Prototype(eItemType.BLANK, sItem_Steel, "item_steel"));
	ITEM.Register(eItemID.URANIUM, ITEM.Prototype(eItemType.BLANK, sItem_Uranium, "item_uranium"));
	
	#endregion

	#region Guns

	ITEM.Register(eItemID.PISTOL, ITEM.Prototype(eItemType.GUN, sItem_Gun_Pistol, "item_pistol", {
		damage: 5,
		recoil: 4,
		firerate: 50,
		automatic: false,
		precision: 2.0,
		cameraShake: 1,
		ammo: 0,
		magazine: 0,
		projectileOffset: 16,
	}));
	
	ITEM.Register(eItemID.LMG, ITEM.Prototype(eItemType.GUN, sItem_Gun_LMG, "item_lmg", {
		damage: 5,
		recoil: 2,
		firerate: 10,
		automatic: true,
		precision: 2.0,
		cameraShake: 0.75,
		ammo: 0,
		projectileOffset: 16,
	}));

	#endregion
	
	#region Tools
	
	ITEM.Register(eItemID.BASIC_PICKAXE, ITEM.Prototype(eItemType.PICKAXE, sItem_Pickaxe, "item_pickaxe", {
		miningSpeed : 10,
	}));
	
	#endregion
	
	#region Props
	
	ITEM.Register(eItemID.BASIC_SOLAR_PANEL, ITEM.Prototype(eItemType.PROP, sItem_BasicSolarPanel, "item_basicsolarpanel", {
		prop: Prop_BasicSolarPanel,
		sprite: sProp_SolarPanel,
		size: [
			[0, 0],
			[-1, -1],
			[0, -1],
			[0, -2],
		],
	}));
	
	ITEM.Register(eItemID.BASIC_MINING_DRILL, ITEM.Prototype(eItemType.PROP, sItem_BasicMiningDrill, "item_basicminingdrill", {
		prop: Prop_BasicMiningDrill,
		sprite: sProp_BasicMiningDrill,
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
	ITEM.Register(eItemID.BASIC_TURRET, ITEM.Prototype(eItemType.SPACESHIP_MODULE_TURRET, sItem_Steel, "item_basicturret", {
		sprite: sTurret_Canon,
		firerate: 24,
	}));
	
	ITEM.Register(eItemID.DOUBLE_BARREL_TURRET, ITEM.Prototype(eItemType.SPACESHIP_MODULE_TURRET, sItem_Steel, "item_doubleturret", {
		sprite: sTurret_DoubleCanon,
		firerate: 20,
	}));
	
	// Gyros
	ITEM.Register(eItemID.BASIC_GYRO, ITEM.Prototype(eItemType.SPACESHIP_MODULE_GYRO, -1, "item_basic_gyro", {
		turnForce: 0.085,
		maxTurnSpeed: 1.05,
	}));
	
	ITEM.Register(eItemID.IMPROVED_GYRO, ITEM.Prototype(eItemType.SPACESHIP_MODULE_GYRO, -1, "item_improved_gyro", {
		turnForce: 0.4,
		maxTurnSpeed: 3.0,
		minSpeed: 0.45,
		independent: true,
	}));
	
	// Propellers
	ITEM.Register(eItemID.BASIC_PROPELLER, ITEM.Prototype(eItemType.SPACESHIP_MODULE_PROPELLER, -1, "item_basic_propeller", {
		acceleration: 0.025,
		deceleration: 0.005,
		maxSpeed: 5,
	}));
	
	ITEM.Register(eItemID.IMPROVED_PROPELLER, ITEM.Prototype(eItemType.SPACESHIP_MODULE_PROPELLER, -1, "item_improved_propeller", {
		acceleration: 0.03,
		deceleration: 0.005,
		maxSpeed: 5,
	}));
	
	#endregion
	
	#region Projectiles
	
	// Turret Projectiles
	ITEM.Register(eItemID.BASIC_PROJECTILE, ITEM.Prototype(eItemType.TURRET_PROJECTILE, -1, "item_basic_projectile", {
		sprite: sTurretProjectile_Basic,
		spd: 10,
		knockback: 0.4,
		piercing: 0,
	}));
	
	#endregion
	
}
