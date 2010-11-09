-- UPDATE common SET com_script='item.id_2801_altar' WHERE com_itemid = 2801;

module("item.id_2801_altar", package.seeall)

function LookAtItem(User,Item)
if (Item.data==701) then
	if (User:getPlayerLanguage() == 0) then
            world:itemInform(User,Item,"Du siehst eine merkw�rdige Konstruktion in deren Mitte ein Loch gemei�elt wurde. 'Das Schloss' ist darunter eingemei�elt.");
        else
            world:itemInform(User,Item,"You see a strange construction with a hole carved in the middle. 'The Lock' is carved underneath");
        end
end;

--for library quest

if (Item.data~=701) then
	if (User:getPlayerLanguage() == 0) then
            world:itemInform(User,Item,"Du siehst einen Altar.");
        else
            world:itemInform(User,Item,"You see an Altar");
        end
end;

end; --end function
	

function UseItem(User,SourceItem,TargetItem,counter,param,lstate)

-- part of the Library Quest

if (SourceItem.data==701) then
--check whether full amulet is present
	local items = User:getItemList(79);
				for i, item in pairs(items) do
					if (item.data == 705) then --full amulet
							if (User:getPlayerLanguage() ==0) then
								User:inform("Das Amulett passt ins Loch. Du sp�rst eine schnelle Bewegung.");
							else
								User:inform("The amulet fits in the hole. You feel rapid motion");
							end
						User:warp(posStruct(0,0,0))
						break;
					end;
				end;
end;

end; --function
	