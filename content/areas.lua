--[[
Illarion Server

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>. 
]]
-- here, areas can be added

local polygons = require("base.polygons")

local M = {}

function M.Init()
    if AreaList then
        return;
    end
    AreaList = {};
    
    --[[ Example: I want to add the area "test area", which comprises a triangle on level 0 and a rectangle on level 1 and 2.
    
    AddArea("test area", { 
        {{position(0,0,0),position(1,0,0),position(1,1,0)},{0}},
        {{position(0,0,0),position(3,0,0),position(3,2,0),position(0,2,0)},{1,2}} } );
    
    NOTE:     The points form a line strip, so each neighbour is connected (and the last and first!). Any polygon is allowed.
            The z-coordinate in the positions does not matter, only the second entry of the tuple is important.
            Please use a uniform naming format for the areas, especially lower case letters. You may use spaces.
    ]]
    -- ## ADD AREAS BELOW ##
  AddArea("evilrock1", {
    {{position(952,203,0),position(952,210,0),position(971,210,0),position(971,199,0),position(958,199,0),position(958,203,0)}, {0}}
  });
  AddArea("evilrock2", {
    {{position(960,177,0),position(960,169,0),position(975,169,0),position(975,177,0)}, {0}}
  });
  AddArea("evilrock3", {
    {{position(916,200,0),position(916,183,0),position(935,183,0),position(934,194,0),position(923,200,0)}, {0}}
  });
  AddArea("evilrock4", {
    {{position(914,249,0),position(914,262,0),position(896,262,0),position(896,237,0),position(910,237,0),position(910,249,0)}, {0}}
  });
  AddArea("evilrock5", {
    {{position(952,212,1),position(952,203,1),position(965,203,1),position(965,208,1),position(971,208,1),position(971,210,1),position(971,210,1)}, {1}}
  });
  AddArea("evilrock6", {
    {{position(943,182,-6),position(965,182,-6),position(965,164,-6),position(943,164,-6)}, {-6}}
  });
  AddArea("evilrockstonechamber", {
    {{position(943,182,-6),position(983,182,-6),position(983,164,-6),position(943,164,-6)}, {-6}}
  });

    AddArea("Pauldron", {
    {{position(868,329,0), position(841,356,0), position(865,380,0), position(876,414,0), position(892,437,0), position(894,470,0), position(932,494,0), position(992,444,0), position(1010,357,0), position(969,281,0), position(916,303,0), position(868,329,0)}, {0}}})

    AddArea("Runewick", {
    {{position(867,815,0), position(887,769,0), position(887,750,0), position(947,744,0), position(970,744,0), position(1007,806,0), position(1006,838,0), position(923,892,0), position(891,893,0), position(889,856,0), position(891,852,0), position(891,843,0), position(867,815,0)}, {0}}})

    AddArea("Galmair", {
    {{position(420,223,0), position(379,206,0), position(339,196,0), position(280,237,0), position(280,315,0), position(352,337,0), position(378,331,0),position(392,331,0), position(436,297,0), position(424,274,0), position(420,223,0)}, {0}}})

    AddArea("CadomyrAndDesert", {
    {{position(467,816,0), position(467,579,0), position(418,510,0), position(394,428,0), position(378,429,0), position(324,392,0), position(264,364,0), position(169,111,0), position(142,444,0), position(139,510,0), position(1,510,0), position(1,791,0), position(95,791,0), position(83,781,0), position(75,769,0), position(80,757,0), position(89,756,0), position(107,755,0), position(119,752,0), position(134,752,0), position(134,731,0), position(180,131,0), position(184,726,0), position(195,747,0), position(195,764,0), position(187,775,0), position(187,751,0), position(137,837,0), position(138,841,0), position(308,841,0),position(365,805,0), position(392,822,0), position(458,832,0), position(467,816,0)}, {0}}})
    end

--- adds an area
-- @param string The name for the new area.
-- @param list({list(posStruct),list(int)}) A list of tuples, each tuple forms a polygon with 1. a list of positions and 2. a list of valid z levels
-- @return boolean False if entry already exists, true if adding the area worked.
function AddArea(name, aList)
    if AreaList[name] then
        debug("Area already exists.");
        return false; -- entry already exists
    end
    AreaList[name] = {};
    for _,poly in pairs(aList) do
        table.insert(AreaList[name], polygons.Polygon(poly[1],poly[2]));
    end
    return true;
end

--- Test if a point is in an area
-- @param posStruct The point to be tested
-- @param string The name of the area
-- @return boolean True if point is in area with areaName
function M.PointInArea(point, areaName)
    if not AreaList then
        Init();
    end
    if not AreaList[areaName] then
        debug("Area does not exist.");
        return false;
    end
    for _,poly in pairs(AreaList[areaName]) do
        if poly:pip(point) then
            return true;
        end
    end
    return false;
end

return M