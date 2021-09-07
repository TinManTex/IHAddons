--VOID.lua
--locationInfo, implemented by InfMission module
local this={
	description="The Void",
	locationName="VOID",
	locationId=300,
	packs={"/Assets/tpp/pack/location/void/void.fpk"},
	questAreas={
		{
			areaName="void",
			--xMin,yMin,xMax,yMax,
			loadArea={100,100,120,120},
			activeArea={101,101,119,119},
			invokeArea={101,101,119,119},
		},
	},
}--this
return this