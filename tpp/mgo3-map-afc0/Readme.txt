!!!!IMPORTANT STEP BEFORE INSTALLING THIS!!!!
Copy MGS_TPP\mgo\texture0.dat to MGS_TPP\master\texture5_mgo0.dat
Or 
Run Archive Transferrer from File Monolith: https://www.nexusmods.com/metalgearsolidvtpp/mods/739
You may have already run this if you've done the US Naval Prison Facility addon installation.


Load via Free roam tab in idroid. If you don't have IHHook installed the name will be blank, but you'll see the name and overview map if you select it.


Just an initial release of ported MGO3 map for people to play around with.
Very alpha, only the minimal setup to have the map load and have sideops work.

Current major obstacle to making this a good playable location is the lack of navmeshes for AI/enemies to work correctly when in combat.

The community could do with people with experience in reverse engineering or programming to help with tools.
If you'd like to help, jump in the Modders Heaven discord: https://discord.gg/3rVFWf2vbj

Until then, sideops can still be created, see Addon mission sideop companion workaround.txt if you want to do something with Sideop Companion https://www.nexusmods.com/metalgearsolidvtpp/mods/571


TODO/Issues - incomplete, unordered and no indication of whether they will or can be done:

locations ambient sound
	doesnt work without mgo init.bnk 

bgm
	not sure why phase music isn't working

combat locators
	Soldier on guard targets may appear on roofs, probably due to lack of nav mesh.

routes
	currently just have single point routes, so soldiers all facesame direction and dont move around outside of combat
	also witout a navmesh routes would need to lead around obstacles more carefully than normal

navmesh
	is the reason soldiers cant navigate properly when in alert 
	while a bunch of reversing has been done on it, I don't think there's been successful creation of nav meshes

lighting
	does not have full 24hr support