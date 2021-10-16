/*
CONTAINS:
RSF

*/
/obj/item/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsf"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	opacity = 0
	density = FALSE
	anchored = FALSE
	item_flags = NOBLUDGEON
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	var/matter = 0
	var/mode = 1
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/rsf/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It currently holds [matter]/30 fabrication-units.</span>"

/obj/item/rsf/cyborg
	matter = 30


/obj/item/rsf/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcd_ammo))
		if((matter + 10) > 30)
			to_chat(user, "The RSF can't hold any more matter.")
			return
		qdel(W)
		matter += 10
		playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
		to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
	else
		return ..()

/obj/item/rsf/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(5)
			mode = 1
			to_chat(user, "Changed dispensing mode to 'Drinking Glass'")
		if(1)
			mode = 2
			to_chat(user, "Changed dispensing mode to 'Paper'")
		if(2)
			mode = 3
			to_chat(user, "Changed dispensing mode to 'Pen'")
		if(3)
			mode = 4
			to_chat(user, "Changed dispensing mode to 'Dice Pack'")
		if(4)
			mode = 5
			to_chat(user, "Changed dispensing mode to 'Cigarette'")
	// Change mode

/obj/item/rsf/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if (!(istype(A, /obj/structure/table) || isfloorturf(A)))
		return
	if(iscyborg(user))
		matter = 30 //borgs dont actually use the matter so this is mostly just so it doesnt fail the next check incase of shennanigans
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 200)
			to_chat(user, "<span class='warning'>You do not have enough power to use [src].</span>")
			return
	if(matter < 1)
		to_chat(user, "<span class='warning'>\The [src] doesn't have enough matter left.</span>")
		return


	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	switch(mode)
		if(1)
			to_chat(user, "Dispensing Drinking Glass...")
			new /obj/item/reagent_containers/food/drinks/drinkingglass(T)
			use_matter(20, user)
		if(2)
			to_chat(user, "Dispensing Paper Sheet...")
			new /obj/item/paper(T)
			use_matter(10, user)
		if(3)
			to_chat(user, "Dispensing Pen...")
			new /obj/item/pen(T)
			use_matter(50, user)
		if(4)
			to_chat(user, "Dispensing Dice Pack...")
			new /obj/item/storage/box/dice(T)
			use_matter(200, user)
		if(5)
			to_chat(user, "Dispensing Cigarette...")
			new /obj/item/clothing/mask/cigarette(T)
			use_matter(10, user)

/obj/item/rsf/proc/use_matter(charge, mob/user)
	if (iscyborg(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= charge
	else
		matter--
		to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")

/obj/item/cookiesynth
	name = "Cookie Synthesizer"
	desc = "A self-recharging device used to rapidly deploy cookies."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsf"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	var/matter = 10
	var/toxin = 0
	var/cooldown = 0
	var/cooldowndelay = 10
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/cookiesynth/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It currently holds [matter]/10 cookie-units.</span>"

/obj/item/cookiesynth/attackby()
	return

/obj/item/cookiesynth/emag_act(mob/user)
	. = ..()
	obj_flags ^= EMAGGED
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>You short out [src]'s reagent safety checker!</span>")
	else
		to_chat(user, "<span class='warning'>You reset [src]'s reagent safety checker!</span>")
		toxin = FALSE
	return TRUE

/obj/item/cookiesynth/attack_self(mob/user)
	var/mob/living/silicon/robot/P = null
	if(iscyborg(user))
		P = user
	if((obj_flags & EMAGGED)&&!toxin)
		toxin = 1
		to_chat(user, "Cookie Synthesizer Hacked")
	else if(P.emagged&&!toxin)
		toxin = 1
		to_chat(user, "Cookie Synthesizer Hacked")
	else
		toxin = 0
		to_chat(user, "Cookie Synthesizer Reset")

/obj/item/cookiesynth/process()
	if(matter < 10)
		matter++

/obj/item/cookiesynth/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(cooldown > world.time)
		return
	if(!proximity)
		return
	if (!(istype(A, /obj/structure/table) || isfloorturf(A)))
		return
	if(matter < 1)
		to_chat(user, "<span class='warning'>[src] doesn't have enough matter left. Wait for it to recharge!</span>")
		return
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 400)
			to_chat(user, "<span class='warning'>You do not have enough power to use [src].</span>")
			return
	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	to_chat(user, "Fabricating Cookie..")
	var/obj/item/reagent_containers/food/snacks/cookie/S = new /obj/item/reagent_containers/food/snacks/cookie(T)
	if(toxin)
		S.reagents.add_reagent(/datum/reagent/toxin/cyanide, 10)
	if (iscyborg(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= 100
	else
		matter--
	cooldown = world.time + cooldowndelay
	
// Crafter Borg synthesizers

// basic pistol synth

/obj/item/rsf/cyborg/pistol
	name = "\improper Craft-o-Tron 'PistolWhipper 1000'"
	desc = "A gun that prints smaller guns using a robots onboard power supply."

/obj/item/rsf/cyborg/pistol/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(6)
			mode = 1
			to_chat(user, "Changed dispensing mode to '9mm Handgun'")
		if(1)
			mode = 2
			to_chat(user, "Changed dispensing mode to '9mm Magazine'")
		if(2)
			mode = 3
			to_chat(user, "Changed dispensing mode to '.45 Handgun'")
		if(3)
			mode = 4
			to_chat(user, "Changed dispensing mode to '.45 Magazine'")
		if(4)
			mode = 5
			to_chat(user, "Changed dispensing mode to '.38 Revolver'")
		if(5)
			mode = 6
			to_chat(user, "Changed dispensing mode to '.38 Clip'")

/obj/item/rsf/cyborg/pistol/afterattack(atom/A, mob/user, proximity)
	. = ..()

	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	switch(mode)
		if(1)
			to_chat(user, "Dispensing 9mm Handgun...")
			new /obj/item/gun/ballistic/automatic/pistol/ninemil(T)
			use_matter(100, user)
		if(2)
			to_chat(user, "Dispensing 9mm Magazine...")
			new /obj/item/ammo_box/magazine/m9mm(T)
			use_matter(20, user)
		if(3)
			to_chat(user, "Dispensing .45 Handgun...")
			new /obj/item/gun/ballistic/automatic/pistol/m1911(T)
			use_matter(200, user)
		if(4)
			to_chat(user, "Dispensing .45 Magazine...")
			new /obj/item/ammo_box/magazine/m45(T)
			use_matter(25, user)
		if(5)
			to_chat(user, "Dispensing .38 Revolver...")
			new /obj/item/gun/ballistic/revolver/police(T)
			use_matter(250, user)
		if(6)
			to_chat(user, "Dispensing .38 Clip...")
			new /obj/item/ammo_box/c38(T)
			use_matter(10, user)
			
// basic shotgun synth
			
/obj/item/rsf/cyborg/shotgun
	name = "\improper Shotstick SynthTron v1.0"
	desc = "A device which synthesizes a variety of simple shotguns using a robots onboard power supply."

/obj/item/rsf/cyborg/shotgun/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(3)
			mode = 1
			to_chat(user, "Changed dispensing mode to 'Single Shotgun'")
		if(1)
			mode = 2
			to_chat(user, "Changed dispensing mode to 'Caravan Shotgun'")
		if(2)
			mode = 3
			to_chat(user, "Changed dispensing mode to 'Hunting Shotgun'")

/obj/item/rsf/cyborg/shotgun/afterattack(atom/A, mob/user, proximity)
	. = ..()

	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	switch(mode)
		if(1)
			to_chat(user, "Dispensing Single Shotgun...")
			new /obj/item/gun/ballistic/revolver/single_shotgun(T)
			use_matter(100, user)
		if(2)
			to_chat(user, "Dispensing Caravan Shotgun...")
			new /obj/item/gun/ballistic/revolver/caravan_shotgun(T)
			use_matter(250, user)
		if(3)
			to_chat(user, "Dispensing Hunting Shotgun...")
			new /obj/item/gun/ballistic/shotgun/hunting(T)
			use_matter(600, user)

// rifle synth

/obj/item/rsf/cyborg/rifle
	name = "\improper RobCo RifleMaker MK.I"
	desc = "A complex device that can synthesize rifles and their magazines using a robots onboard power supply."

/obj/item/rsf/cyborg/rifle/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(4)
			mode = 1
			to_chat(user, "Changed dispensing mode to '5.56mm Hunting Rifle'")
		if(1)
			mode = 2
			to_chat(user, "Changed dispensing mode to 'Small 5.56mm Magazine'")
		if(2)
			mode = 3
			to_chat(user, "Changed dispensing mode to '7.62mm Bolt-Action Rifle'")
		if(3)
			mode = 4
			to_chat(user, "Changed dispensing mode to '7.62mm Stripper Clip'")

/obj/item/rsf/cyborg/rifle/afterattack(atom/A, mob/user, proximity)
	. = ..()

	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	switch(mode)
		if(1)
			to_chat(user, "Dispensing 5.56mm Hunting Rifle...")
			new /obj/item/gun/ballistic/rifle/mag/varmint(T)
			use_matter(200, user)
		if(2)
			to_chat(user, "Dispensing Small 5.56mm Magazine...")
			new /obj/item/ammo_box/magazine/m556/rifle/small(T)
			use_matter(20, user)
		if(3)
			to_chat(user, "Dispensing 7.62mm Bolt-Action Rifle..")
			new /obj/item/gun/ballistic/rifle/boltaction(T)
			use_matter(500, user)
		if(4)
			to_chat(user, "Dispensing 7.62mm Stripper Clip...")
			new /obj/item/ammo_box/magazine/garand308(T)
			use_matter(20, user)
			
// crafting material synth
			
/obj/item/rsf/cyborg/parts
	name = "\improper RobCo ScrapMatic Deluxe"
	desc = "A tool that synthesizes raw materials from electricity using a robots onboard power supply."

/obj/item/rsf/cyborg/parts/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(6)
			mode = 1
			to_chat(user, "Changed dispensing mode to 'Steel Sheets'")
		if(1)
			mode = 2
			to_chat(user, "Changed dispensing mode to 'Glass Sheets'")
		if(2)
			mode = 3
			to_chat(user, "Changed dispensing mode to 'Gunpowder Pouches'")
		if(3)
			mode = 4
			to_chat(user, "Changed dispensing mode to 'Metal Parts'")
		if(4)
			mode = 5
			to_chat(user, "Changed dispensing mode to 'High-Quality Metal Parts'")
		if(5)
			mode = 6
			to_chat(user, "Changed dispensing mode to 'Electronic Parts'")

/obj/item/rsf/cyborg/parts/afterattack(atom/A, mob/user, proximity)
	. = ..()

	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	switch(mode)
		if(1)
			to_chat(user, "Dispensing Steel Sheets...")
			new /obj/item/stack/sheet/metal/ten(T)
			use_matter(100, user)
		if(2)
			to_chat(user, "Dispensing Glass Sheets...")
			new /obj/item/stack/sheet/glass/ten(T)
			use_matter(50, user)
		if(3)
			to_chat(user, "Dispensing Gunpowder Pouches...")
			new /obj/item/stack/crafting/powder/ten(T)
			use_matter(200, user)
		if(4)
			to_chat(user, "Dispensing Metal Parts...")
			new /obj/item/stack/crafting/metalparts/five(T)
			use_matter(250, user)
		if(5)
			to_chat(user, "Dispensing High-Quality Metal Parts...")
			new /obj/item/stack/crafting/goodparts/five(T)
			use_matter(500, user)
		if(6)
			to_chat(user, "Dispensing Electronic Parts...")
			new /obj/item/stack/crafting/electronicparts/five(T)
			use_matter(300, user)
			
// laser weapon synth (upgrade only)

/obj/item/rsf/cyborg/energy
	name = "\improper Wattz LasPrinter Beta"
	desc = "An experimental device that can rapidly print various laser weapons, MF cells, and energy cells."

/obj/item/rsf/cyborg/energy/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(6)
			mode = 1
			to_chat(user, "Changed dispensing mode to 'Civilian Laser Pistol'")
		if(1)
			mode = 2
			to_chat(user, "Changed dispensing mode to 'Military Laser Pistol'")
		if(2)
			mode = 3
			to_chat(user, "Changed dispensing mode to 'Civilian Laser Rifle'")
		if(3)
			mode = 4
			to_chat(user, "Changed dispensing mode to 'Military Laser Rifle'")
		if(4)
			mode = 5
			to_chat(user, "Changed dispensing mode to 'Energy Charge Pack'")
		if(5)
			mode = 6
			to_chat(user, "Changed dispensing mode to 'Microfusion Cell'")

/obj/item/rsf/cyborg/energy/afterattack(atom/A, mob/user, proximity)
	. = ..()

	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, 1)
	switch(mode)
		if(1)
			to_chat(user, "Dispensing Civilian Laser Pistol...")
			new /obj/item/gun/energy/laser/wattz(T)
			use_matter(250, user)
		if(2)
			to_chat(user, "Dispensing Military Laser Pistol...")
			new /obj/item/gun/energy/laser/pistol(T)
			use_matter(600, user)
		if(3)
			to_chat(user, "Dispensing Civilian Laser Rifle...")
			new /obj/item/gun/energy/laser/wattz2k(T)
			use_matter(750, user)
		if(4)
			to_chat(user, "Dispensing Military Laser Rifle..")
			new /obj/item/gun/energy/laser/aer9(T)
			use_matter(1000, user)
		if(5)
			to_chat(user, "Dispensing Energy Charge Pack..")
			new /obj/item/stock_parts/cell/ammo/ec(T)
			use_matter(100, user)
		if(6)
			to_chat(user, "Dispensing Microfusion Cell..")
			new /obj/item/stock_parts/cell/ammo/mfc(T)
			use_matter(200, user)
