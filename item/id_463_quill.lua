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
-- UPDATE items SET itm_script='item.id_463_quill' WHERE itm_id IN (463);
local common = require("base.common")
local alchemy = require("alchemy.base.alchemy")
local lookat = require("base.lookat")
local recipe_creation = require("alchemy.base.recipe_creation")

local M = {}

local function getText(User,deText,enText)
    return common.GetNLS(User,deText,enText)
end

function M.UseItem(User, SourceItem, ltstate)

    if SourceItem.itempos ~= 5 and SourceItem.itempos ~= 6 then
        User:inform("Du musst die Schreibfeder in der Hand halten.","You have to hold the quill in your hand.",Character.highPriority)
        return
    end

    local callback = function(dialog)
        local success = dialog:getSuccess()
        if success then
            local selected = dialog:getSelectedIndex()+1
            if selected == 2 then
                if not CheckIfBottleInHand(User, SourceItem) then
                    User:inform("Du brauchst eine Flasche, um diese zu beschriften.","You need a bottle if you want to label one.",Character.highPriority)
                    return
                else
                    WriteLabel(User,SourceItem)
                end
            elseif selected == 3 then
                local parchment = recipe_creation.GetParchmentQuill(User)
                parchment = recipe_creation.IsParchmentOK(User,parchment)
                if not parchment then
                    return
                else
                    recipe_creation.FirstMenu(User)
                end
            elseif selected == 1 then
                if not CheckIfContainerPresent(User) then
                    User:inform("Du brauchst eine Tasche, um diese zu beschriften.","You need a bag if you want to label one.",Character.highPriority)
                    return
                else
                    WriteContainerLabel(User,SourceItem)
                end
            elseif selected == 4 then
                if not CheckIfEmptyBottlePresent(User) then
                    User:inform("Du brauchst Flaschen von denen du das Etikett entfernen kannst.","You need bottles to remove labels.",Character.highPriority)
                    return
                else
                    removeLabel(User)
                end
            elseif selected == 5 then
                if not CheckIfParchmentInHand(User,SourceItem) then
                    User:inform("Du brauchst ein einzelnes leeres Pergament auf dem du schreiben kannst.","You need a single empty parchment to write on.",Character.highPriority)
                    return
                else
                    WriteParchment(User,SourceItem)
                end
            elseif selected == 6 then
                if not CheckIfParchmentCanSigned(User,SourceItem) then
                    User:inform("Du brauchst ein beschriebenes Pergament auf dem du unterschreiben kannst.","You need a written parchment to sign.",Character.highPriority)
                    return
                else
                    SignParchment(User,SourceItem)
                end
            end
        end
    end

    local dialog = SelectionDialog(getText(User,"Schreibfeder","Quill") , getText(User,"W�hle aus, was du machen willst.","Select what you want to do.") , callback)
    dialog:addOption(0, getText(User,"Tasche beschriften","Label bag"))
    dialog:addOption(0, getText(User,"Flasche beschriften","Label a bottle"))
    dialog:addOption(0, getText(User,"Alchemierezept schreiben","Write an alchemy recipe"))
    dialog:addOption(0, getText(User,"Flaschenetikett entfernen","Remove label of a bottle"))
    dialog:addOption(0, getText(User,"Pergament beschreiben","Write a parchment"))
    dialog:addOption(0, getText(User,"Pergament unterschreiben","Sign a parchment"))

    User:requestSelectionDialog(dialog)
end

function CheckIfContainerPresent(User)

    local containerList = {97,799};
    local containerItem = User:getItemAt(0);

    for i=1,#containerList do

        if (containerItem.id == containerList[i]) then
            return containerItem;
        end
    end

    return nil;
end

local emptyBottleList = {518, 1317, 790, 164, 2498};

function CheckIfEmptyBottlePresent(User)

    for i=1, #emptyBottleList do
        local bottleCount = User:countItem(emptyBottleList[i]);
        if bottleCount > 0 then
            return true;
        end
    end

    return false;
end

function CheckIfBottleInHand(User, SourceItem)

    local potionBottleList = alchemy.bottleList
    local beverageBottleList = {517, 1315, 1316, 1318, 1319, 1320, 1321, 1322,1323, 783, 784, 785, 786, 787, 788, 789, 791, 2500, 2496, 2497, 2501, 2499,3720,3721,3722};

    local bottleItem = common.GetTargetItem(User, SourceItem);
    if bottleItem == nil then
        return nil;
    end

    for i=1, #potionBottleList do
        if (bottleItem.id == potionBottleList[i]) then
            return bottleItem;
        end
    end
    for i=1, #beverageBottleList do
        if (bottleItem.id == beverageBottleList[i]) then
            return bottleItem;
        end
    end
    for i=1, #emptyBottleList do
        if (bottleItem.id == emptyBottleList[i]) then
            return bottleItem;
        end
    end

    return nil;
end

function CheckIfParchmentInHand(User, SourceItem)
    local parchmentList = {2745, 3109};

    local parchmentItem = common.GetTargetItem(User, SourceItem);
    if parchmentItem == nil then
        return nil;
    end

    for i=1, #parchmentList do
        if ((parchmentItem.id == parchmentList[i]) and (common.IsNilOrEmpty(parchmentItem:getData("descriptionEn"))) and (common.IsNilOrEmpty(parchmentItem:getData("writtenText"))) and (User:countItemAt("body",parchmentList[i])==1) )then
            return parchmentItem;
        end
    end

    return nil;
end

function WriteParchment(User,SourceItem)

    local title = getText(User, "Pergament beschreiben", "Write Parchment");
    local infoText = getText(User, "F�ge hier den Text ein, den du auf das Pergament schreiben willst.", "Insert the text you want to write on the parchment.");

    -- input dialog
    local callback = function(dialog)
        if not dialog:getSuccess() then
            return;
        else
            local parchment = CheckIfParchmentInHand(User,SourceItem) -- check for the parchment again
            if parchment then
                local writtenText = dialog:getInput()
                parchment:setData("writtenText",writtenText)
                lookat.SetSpecialDescription(parchment,"Das Pergament ist beschrieben.","The parchment has been written on.")
                world:changeItem(parchment)
                User:inform("Du schreibst auf das Pergament:\n'".. string.gsub (writtenText,"\\n","\n") .."'.","You write on the parchment:\n'".. string.gsub (writtenText,"\\n","\n") .."'.")
            else
                User:inform("Du brauchst ein Pergament, um darauf zu schreiben.","You need a parchment if you want to write.")
            end
        end
    end
    local dialog = InputDialog(title, infoText, false, 255, callback)
    User:requestInputDialog(dialog)
end

function SignParchment(User,SourceItem)

    local parchment = CheckIfParchmentCanSigned(User,SourceItem) -- check for the parchment again

    if parchment then
        parchment:setData("signatureText",User.name)
        lookat.SetSpecialDescription(parchment,"Das Pergament ist unterschrieben.","The parchment is signed.")
        world:changeItem(parchment)
        User:inform("Du unterschreibst das Pergament.","You sign the parchment.")
    else
        User:inform("Du brauchst ein beschriebes Pergament, um zu unterschreiben.","You need a written parchment to sign.")
    end
end

function CheckIfParchmentCanSigned(User, SourceItem)
    local parchmentList = {2745, 3109};

    local parchmentItem = common.GetTargetItem(User, SourceItem);
    if parchmentItem == nil then
        return nil;
    end

    for i=1, #parchmentList do
        if ((parchmentItem.id == parchmentList[i]) and not (common.IsNilOrEmpty(parchmentItem:getData("writtenText"))) and (common.IsNilOrEmpty(parchmentItem:getData("signatureText"))) )then
            return parchmentItem;
        end
    end

    return nil;
end


function WriteContainerLabel(User,SourceItem)

    local title = getText(User, "Taschenbeschriftung", "Bag labelling");
    local infoText = getText(User, "F�ge hier den Text ein, mit dem du die Tasche beschriften willst.", "Insert the text you want to write on the label.");

    -- input dialog
    local callback = function(dialog)
        if not dialog:getSuccess() then
            return;
        else
            local bag = CheckIfContainerPresent(User) -- check for the bag again
            if bag then
                local labelText = dialog:getInput()
                lookat.SetSpecialDescription(bag,labelText,labelText)
                world:changeItem(bag)
                User:inform("Du beschriftest die Tasche mit '"..labelText.."'.","You label the bag as '"..labelText.."'.")
            else
                User:inform("Du brauchst eine Tasche, um diese zu beschriften.","You need a bag if you want to label one.")
            end
        end
    end
    local dialog = InputDialog(title, infoText, false, 100, callback)
    User:requestInputDialog(dialog)
end

function WriteLabel(User,SourceItem)

    local title  = getText(User, "Flaschenetikettierung", "Bottle labelling");
    local infoText = getText(User, "F�ge hier den Text ein, mit dem du das Etikett beschriften willst.", "Insert the text you want to write on the label.");

    -- input dialog
    local callback = function(dialog)
        if not dialog:getSuccess() then
            -- player canceled the dialog; nothing
        else
            local bottle = CheckIfBottleInHand(User, SourceItem) -- check for the bottle again
            if bottle then
                --if bottle.number > 1 then
                --    User:inform("Du kannst immer nur eine Flasche beschriften.","You can label only one bottle at once.")
                --    return
                --end
                local labelText = dialog:getInput()
                lookat.SetSpecialDescription(bottle,labelText,labelText)
                world:changeItem(bottle)
                User:inform("Du beschriftest die Flasche mit '"..labelText.."'.","You label the bottle as '"..labelText.."'.")
                
            else
                User:inform("Du brauchst eine Flasche, um diese zu beschriften.","You need a bottle if you want to label one.")
            end
        end
    end
    local dialog = InputDialog(title, infoText, false, 100, callback)
    User:requestInputDialog(dialog)
end

function removeLabel(User)

    local removalCount = 0;

    for i=1, #emptyBottleList do
        local itemList = User:getItemList(emptyBottleList[i]);
        for item=1, #itemList do
            lookat.UnsetSpecialDescription(itemList[item]);
            lookat.UnsetItemCraftedBy(itemList[item]); -- hack for "old" items
            world:changeItem(itemList[item]);
            removalCount = removalCount + itemList[item].number;
        end
    end

    if removalCount == 1 then
        User:inform("Du hast von "..removalCount.." Flasche das Etikett entfernt.","You removed the label of "..removalCount.." bottle.");
    else
        User:inform("Du hast von "..removalCount.." Flaschen die Etiketten entfernt.","You removed the labels of "..removalCount.." bottles.");
    end
end


return M

