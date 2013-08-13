-- INSERT INTO "quests" ("qst_id", "qst_script") VALUES (75, 'quest.hassan_75_cadomyr');

require("base.common")
module("quest.hassan_75_cadomyr", package.seeall)

GERMAN = Player.german
ENGLISH = Player.english

-- Insert the quest title here, in both languages
Title = {}
Title[GERMAN] = "Der Schwätzer von Cadomyr"
Title[ENGLISH] = "Cadomyr's Gossiper"

-- Insert an extensive description of each status here, in both languages
-- Make sure that the player knows exactly where to go and what to do
Description = {}
Description[GERMAN] = {}
Description[ENGLISH] = {}
Description[GERMAN][1] = "Besorge ein Glas mit Wein und bringe es Hassan. Du kannst ein Glas mit Wein vom Händler kaufen oder fülle Wein aus einer Flasche in ein leeres Glas."
Description[ENGLISH][1] = "Produce a glass with wine and bring it to Hassan. You can buy a glass with wine from a merchant or fill wine from a bottle into a glass."
Description[GERMAN][2] = "Rede mit Hassan, er kann dir einiges erzählen."
Description[ENGLISH][2] = "Talk to Hassan, he can tell you a lot."

-- For each status insert a list of positions where the quest will continue, i.e. a new status can be reached there
QuestTarget = {}
QuestTarget[1] = {position(110, 574, 0), position(113, 574, 0)} -- Händler
QuestTarget[2] = {position(110, 574, 0)} 


-- Insert the quest status which is reached at the end of the quest
FINAL_QUEST_STATUS = 2


function QuestTitle(user)
    return base.common.GetNLS(user, Title[GERMAN], Title[ENGLISH])
end

function QuestDescription(user, status)
    local german = Description[GERMAN][status] or ""
    local english = Description[ENGLISH][status] or ""

    return base.common.GetNLS(user, german, english)
end

function QuestTargets(user, status)
    return QuestTarget[status]
end

function QuestFinalStatus()
    return FINAL_QUEST_STATUS
end