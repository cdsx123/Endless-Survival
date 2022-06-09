extends Node

var attacks = {
	"BasicShot": {"name": "basicShot",
"upgradeInfo": {"title": "Basic Shot", "upgradeText": "Upgrades your basic shot", "icon": "icon"}, 
"level": 1, "max_level": 6, "funcRef": funcref(self, "upgradeBasicShot"), 
"stats": {"damage": 120, "knockback_power": 150, "speed": 180},  "type": "Attack"},

	"Vortex": {"name": "vortex",
"upgradeInfo": {"title": "Vortex", "upgradeText": "A spinning blade cuts through all in it's path", "icon": "icon"},  
"level": 0, "max_level": 6, "funcRef": funcref(self, "upgradeVortex"), "scale": 1, "canSuck": false,
"stats": {"damage": 125, "knockback_power": 150, "speed": 150}, "type": "Attack"}, 

	"Lightning": {"name": "lightning",
"upgradeInfo": {"title": "Lightning", "upgradeText": "Lightning strikes the enemies nearest you", "icon": "icon"},  
"level": 0, "max_level": 6, "funcRef": funcref(self, "upgradeLightning"), 
"stats": {"damage": 500, "knockback_power": 0, "amount": 2, "cooldown": 1.5}, "type": "Attack"},

	"Orbit": {"name": "orbit",
"upgradeInfo": {"title": "Orbit", "upgradeText": "A damaging orb revolves around you", "icon": "icon"},  
"level": 0, "max_level": 6, "funcRef": funcref(self, "upgradeOrbit"), 
"stats": {"damage": 200, "knockback_power": 0, "amount": 0}, "type": "Attack"},

	"Flame": {"name": "flame", 
"upgradeInfo": {"title": "Flame", "upgradeText": "Flames spew forth from your body", "icon": "icon"},  
"level": 0, "max_level": 6, "funcRef": funcref(self, "upgradeFlame"), "isTripled": false,
"stats": {"damage": 120, "knockback_power": 175, "length": 4, "cooldown": 4, "burn": false}, "type": "Attack"},

	"Laser": {"name": "laser",
"upgradeInfo": {"title": "Laser", "upgradeText": "A penetrating laser cuts through your enemies", "icon": "icon"},  
"level": 0, "max_level": 6, "funcRef": funcref(self, "upgradeLaser"),
"stats": {"damage": 150, "knockback_power": 0, "length": 5, "cooldown": 5, "amount": 1}, "type": "Attack"},

#	"Armageddon": {"name": "armageddon", "text": "Armageddon",
#"level": 0, "max_level": 1, "funcRef": funcref(self, "upgradeArmageddon"), "cooldown": 80, "type": "Attack"},
#https://www.youtube.com/watch?v=usLIlbk9P88 circle timer tutorial for armageddon use

	"Shield": {"name": "shield", 
"upgradeInfo": {"title": "Shield", "upgradeText": "An energy shield protects you from harm", "icon": "icon"},  
"level": 0, "max_level": 3, "funcRef": funcref(self, "upgradeShield"), 
"stats": {"rechargeTime": 5, "maxCharges": 0, "damage": 0}, "type": "Attack"},

		"ChainShot": {"name": "chainShot",
"upgradeInfo": {"title": "Chain Shot", "upgradeText": "Shoots lightning that chains between enemies", "icon": "icon"},  
"level": 0, "max_level": 6, "funcRef": funcref(self, "upgradeChainShot"), 
"stats": {"damage": 120, "knockback_power": 0, "cooldown": 1, "redirects": 4}, "type": "Attack"},
}

onready var stats = {
	"Regen": {"name": "regenHealth", "level": 0, "max_level": 6,
"upgradeInfo": {"title": "Regenerate", "upgradeText": "+1% regen/sec", "icon": "icon"}, 
 "amount": 0, "upgrade_amount": base_max_health * 0.01, "type": "Stat"},

	"Ghost": {"name": "ghost", "level": 0, "max_level": 1,
"upgradeInfo": {"title": "Ghost", "upgradeText": "Move through enemies", "icon": "icon"},  
"funcRef": funcref(self, "upgradeGhost"), "type": "Stat"},

	"Speed": {"name": "speed", "level": 0, "max_level": 5, 
"upgradeInfo": {"title": "Speed", "upgradeText": "+10% movement speed", "icon": "icon"},  
"amount": base_max_speed, "upgrade_amount": base_max_speed * 0.1, "type": "Stat"},

	"Defense": {"name": "defense", "level": 0, "max_level": 5, 
"upgradeInfo": {"title": "Defense", "upgradeText": "Take 10% less damage", "icon": "icon"},  
"amount": 1, "upgrade_amount": -0.1, "type": "Stat"},

	"MaxHealth": {"name": "maxhealth", "level": 0, "max_level": 5, 
"upgradeInfo": {"title": "Max Health", "upgradeText": "Max Health increases by 20%", "icon": "icon"},  
"funcRef": funcref(self, "upgradeMaxHealth"), "upgrade_amount": base_max_health * 0.2, "type": "Stat"},

	"Revive": {"name": "revive", "level": 0, "max_level": 1, 
"upgradeInfo": {"title": "Revive", "upgradeText": "Defy death one time", "icon": "icon"},  
"funcRef": funcref(self, "upgradeRevive"),"canRevive": false, "type": "Stat"}
}

onready var regenTimer = $RegenTimer

var damage = 50
var damageUp = false
export var base_max_health = 2000
var max_health = 2000 setget set_max_health
var health = max_health setget set_health
export var base_damage = 50
var xp = 0 setget set_xp
var base_max_xp = 1000
var max_xp = 1000 setget set_max_xp
var level = 0

export var base_max_speed = 65

signal no_health
signal health_changed(value)
signal max_health_changed(value)
signal xp_changed(value)
signal max_xp_changed(value)
signal level_up
signal upgradeAttack
signal cooldownChange(value)


func _ready():
	resetStats()
	

		
func resetStats():
	for key in attacks:
		attacks[key].baseStats = attacks[key].stats
		attacks[key].level = 0
		attacks.BasicShot.level = 1
		
	for key in stats:
		stats[key].level = 0
		stats.Defense.amount = 1
		
	self.max_health = base_max_health
	self.health = max_health
	self.xp = 0
	self.max_xp = base_max_xp
	Globals.score = 0
	Globals.time = 0
	

func set_max_health(value):
	max_health = max(value, 1)
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = min(value, max_health)
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func set_xp(value):
	xp = value
	emit_signal("xp_changed", xp)
	if xp >= max_xp:
		level_up()

func set_max_xp(value):
	max_xp = value
	emit_signal("max_xp_changed", max_xp)
	

func level_up():
	var used_xp = self.max_xp
	var num_max = 0
	for key in attacks:
		if attacks[key].level >= attacks[key].max_level:
			num_max += 1
	for key in stats:
		if stats[key].level >= stats[key].max_level:
			num_max += 1

	if num_max <= attacks.size() + stats.size():
		emit_signal("level_up")
		
		self.max_xp = base_max_xp * 0.4 * level + 500
		level += 1
		self.xp -= used_xp
		

func upgradeAttack(attack):
	attacks[attack].level += 1
	attacks[attack].funcRef.call_func()
	emit_signal("upgradeAttack", attacks[attack])

func upgradeStat(stat):
	stats[stat].level += 1
	
	if stats[stat].has("funcRef"):
		stats[stat].funcRef.call_func()
	else:
		stats[stat].amount += stats[stat].upgrade_amount
	
func _on_RegenTimer_timeout():
	self.health += stats.Regen.amount

func upgradeRevive():
	stats.Revive.canRevive = true

func upgradeGhost():
	Globals.player.SOFTPOWER = 0

func upgradeMaxHealth():
	var upgradeAmount = stats.MaxHealth.upgrade_amount
	self.max_health += upgradeAmount
	self.health += upgradeAmount
	stats.Regen.amount += stats.Regen.upgrade_amount / 7
	
func upgradeBasicShot():
	var basicShot = attacks.BasicShot
	basicShot.stats.damage *= 1.2
	basicShot.stats.speed *= 1.05
	basicShot.upgradeInfo.upgradeText = "+20% Damage \n +5% Speed"

func upgradeVortex():
	var vortex = attacks.Vortex
	vortex.stats.damage *= 1.1
	vortex.scale *= 1.1
	
	if vortex.level == 6:
		vortex.canSuck = true

func upgradeLightning():
	var lightning = attacks.Lightning
	lightning.stats.damage *= 1.1
	lightning.stats.amount += 1
	lightning.stats.cooldown *= 0.9
	lightning.upgradeInfo.upgradeText = "+10% Damage \n +1 strike \n -10% Cooldown"
	emit_signal("cooldownChange", {"timer": "LightningTimer", 
"cooldown": lightning.stats.cooldown})

func upgradeOrbit():
	var orbit = attacks.Orbit
	orbit.stats.damage *= 1.1
	orbit.stats.amount += 1
	orbit.upgradeInfo.upgradeText = "+1 orb \n +10% Damage"

func upgradeFlame():
	var flame = attacks.Flame
	flame.stats.damage *= 1.1
	flame.stats.cooldown *= 0.9
	flame.upgradeInfo.upgradeText = "+10% Damage \n -10% Cooldown"
	
	if flame.level >= 3:
		flame.stats.burn = true
	if flame.level == 6:
		flame.isTripled = true

	


func upgradeLaser():
	var laser = attacks.Laser
	if laser.level == 3 or laser.level == 5:
		laser.stats.amount += 1
		laser.upgradeInfo.upgradeText = "+10% Damage"
	else:
		laser.stats.damage *= 1.1
		if laser.level == 2 or laser.level == 4:
			laser.upgradeInfo.upgradeText = "+1 laser"
		else:
			laser.upgradeInfo.upgradeText = "+10% Damage"


func upgradeArmageddon():
	pass

func upgradeShield():
	var shield = attacks.Shield
	shield.stats.rechargeTime *= 0.9
	shield.stats.maxCharges += 1
	shield.upgradeInfo.upgradeText = "-10% Recharge Time \n +1 Max Charges"
	
func upgradeChainShot():
	var chainShot = attacks.ChainShot
	chainShot.stats.damage *= 1.1
	chainShot.stats.cooldown *= 0.9
	chainShot.stats.redirects += 3
	chainShot.upgradeInfo.upgradeText = "+10% Damage \n -10% Cooldown Timer \n +3 Redirects"
