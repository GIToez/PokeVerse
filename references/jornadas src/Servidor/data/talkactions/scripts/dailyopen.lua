function onSay(cid, words, param)
    getDailyRewards(cid, os.date('*t').month, os.date('*t').year)
return true
end