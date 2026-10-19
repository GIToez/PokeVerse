# NPC line rewrites

Every line in [npc-conversations.md](npc-conversations.md) was read for broken or unclear English
(a reading review, not an automatic check). These are the lines that needed work, each with a
rewrite that keeps the blue {words}, placeholders, names and numbers. They are applied; the same
list is in `npc-rewrites.json` and `scripts/apply_npc_rewrites.py` applies it.

Later fixes are in `npc-fixes.json`, in the same format (`python3 scripts/apply_npc_rewrites.py
--file docs/npc-fixes.json`): copies of these lines in other NPCs and shared scripts
(`"where": "everywhere"`), quest lines that now say what the quest checks and how many, blue
words that were meant for another NPC, the travel and shop "gold coins", and spelling.

1634 of 2938 lines, 428 NPCs or shared files.

## Abi

- message_greet - Broken question grammar
  - was: Hey |PLAYERNAME|, it is hot? This desert is getting worse.
  - now: Hey |PLAYERNAME|, is it hot? This desert is getting worse.
- quest 8048 talk_questStarting - Unnatural phrasing, redundant 'for you'
  - was: The desert is a very dangerous place, you can walk to the death. I need some items, if you bring them to me I'll get you some clothes for you to walk in the desert.
  - now: The desert is a very dangerous place, you could walk to your death. I need some items. If you bring them to me, I'll make you some clothes for walking in the desert.
- quest 8048 talk_questFinishing - Broken question word order
  - was: You have got what I asked?
  - now: Have you got what I asked for?
- quest 8048 talk_questFinished - Incomplete 'here is'
  - was: Good work, here is.
  - now: Good work, here it is.
- quest 8049 talk_questStarting - Unclear offer phrasing
  - was: The sun is getting stronger, you will need a better protection to defend against it! We can make an agreement to fix this.
  - now: The sun is getting stronger, you will need better protection against it! Maybe we can make a deal to fix this.
- quest 8049 talk_questFinishFail - Broken 'Where is?'
  - was: No! Where is?
  - now: No! Where is it?

## Adelyn Star

- message_greet - Misspelling Heremit; 'exchange into'
  - was: Welcome to the Heremit Mastery! Here you can exchange your heremit tokens into rewards. Type {options} to see.
  - now: Welcome to the Hermit Mastery! Here you can exchange your hermit tokens for rewards. Type {options} to see.

## Ader

- npc/scripts/mastery_blaze.lua - 'join into' unnatural
  - was: Do you want to join into the %s Mastery?
  - now: Do you want to join the %s Mastery?
- npc/scripts/mastery_blaze.lua - Grammar: 'has'; 'dismiss with'
  - was: You already has a mastery, if you want to join here first you need to dismiss with your mastery leader.
  - now: You already have a mastery. If you want to join here, you first need to leave it with your mastery leader.
- npc/scripts/mastery_blaze.lua - Wrong preposition
  - was: Are you ready to the next level?
  - now: Are you ready for the next level?
- npc/scripts/mastery_blaze.lua - Wrong preposition
  - was: Are you ready to the dungeon?
  - now: Are you ready for the dungeon?
- npc/scripts/mastery_blaze.lua - 'dismiss with' unclear
  - was: You need to dismiss with your mastery leader, not here.
  - now: You need to leave your mastery through your own mastery leader, not here.
- npc/scripts/mastery_blaze.lua - Unnatural Portuguese-ism
  - was: Your account must be with the premium days to join here.
  - now: Your account must have premium days to join here.
- npc/scripts/mastery_blaze.lua - 'join into' unnatural
  - was: Do you really want to join into the %s Mastery?
  - now: Do you really want to join the %s Mastery?
- npc/scripts/mastery_blaze.lua - 'win my assistant' wrong
  - was: You have already paid the necessary plates, now you need to win my assistant %s.
  - now: You have already paid the necessary plates, now you need to defeat my assistant %s.
- npc/scripts/mastery_blaze.lua - 'You're with them?' Portuguese-ism
  - was: To join into %s Mastery you will need %s. You're with them?
  - now: To join the %s Mastery you will need %s. Do you have them?
- npc/scripts/mastery_blaze.lua - 'win a battle with' ambiguous
  - was: To complete your initiation, you must win a battle with my assistant %s.
  - now: To complete your initiation, you must win a battle against my assistant %s.
- npc/scripts/mastery_blaze.lua - 'when you're with them' Portuguese-ism
  - was: You do not have the necessary plates, come back here when you're with them. Remember that you must achieve %s points through our element plates.
  - now: You do not have the necessary plates, come back when you have them. Remember that you must reach %s points with our element plates.
- npc/scripts/mastery_blaze.lua - Missing article
  - was: Congratulations! You are now part of %s Mastery! Honor your Mastery!
  - now: Congratulations! You are now part of the %s Mastery! Honor your Mastery!
- npc/scripts/mastery_blaze.lua - Missing article
  - was: Congratulations! You were promoted in %s Mastery!
  - now: Congratulations! You were promoted in the %s Mastery!
- npc/scripts/mastery_blaze.lua - 'win the dungeon' wrong
  - was: You have already paid the necessary tokens, now you need to win the {dungeon}.
  - now: You have already paid the necessary tokens, now you need to complete the {dungeon}.
- npc/scripts/mastery_blaze.lua - Garbled grammar, Portuguese-isms
  - was: To advance in rank within the Mastery you need to prove that you're dominating it, joining %s tokens, you can get them by completing missions with the inhabitants of this base. You are already with the %s %s tokens?
  - now: To advance in rank within the Mastery you need to prove you've mastered it by collecting %s tokens. You can get them by completing missions for the inhabitants of this base. Do you already have the %s %s tokens?
- npc/scripts/mastery_blaze.lua - 'make the dungeon' wrong verb
  - was: Now you're ready to make the {dungeon} and prove that you are able to advance. When you are ready come talk to me.
  - now: Now you're ready to do the {dungeon} and prove that you are able to advance. When you are ready, come talk to me.
- npc/scripts/mastery_blaze.lua - 'when you're with them' Portuguese-ism
  - was: You do not have the necessary tokens, come back here when you're with them.
  - now: You do not have the necessary tokens, come back when you have them.
- npc/scripts/mastery_blaze.lua - Broken grammar
  - was: Before to this dungeon you need pay the necessary tokens.
  - now: Before entering this dungeon you need to pay the necessary tokens.
- npc/scripts/mastery_blaze.lua - Misspelling avaiable
  - was: There is no dungeon avaiable, please try again later.
  - now: There is no dungeon available, please try again later.
- npc/scripts/mastery_blaze.lua - Awkward 'Mastery %s types'
  - was: You can only enter the dungeon carrying Pokemon with Mastery %s types and without Ditto!
  - now: You can only enter the dungeon carrying Pokemon of the %s Mastery types and no Ditto!

## Adventurer Lucy

- npc/scripts/quest_adventurerLucy.lua - Garbled story, broken grammar
  - was: Once there were three kings who ruled their small tribes that were always hidden. These tribes have always helped each other in secret and cooperated to maintain balance in the Islands. Once an evil being would awaken an ancient guardian of the seas to cause chaos in the archipelago, and for that he would need the mystical artifact of the three legendary birds. The three kings knowing the plan, were behind the evil and be locked up inside a Stone along with his household using psychic powers. Unfortunately during the three kings perished and fell before the exhaust by using so much energy. This is the story that I know, and seeking the {location of prophecy} since.
  - now: Once there were three kings who ruled small tribes that were always hidden. These tribes secretly helped each other to keep balance in the Islands. One day an evil being sought to awaken an ancient guardian of the seas to bring chaos to the archipelago, and for that he needed the mystical artifacts of the three legendary birds. Knowing his plan, the three kings went after the villain and sealed him and his household inside a Stone using psychic powers. Sadly, the three kings perished from exhaustion after using so much energy. This is the story I know, and I've been seeking the {location of prophecy} ever since.
- npc/scripts/quest_adventurerLucy.lua - Missing 'me'
  - was: Excuse, I'm busy now!
  - now: Excuse me, I'm busy now!
- npc/scripts/quest_adventurerLucy.lua - Missing 'do'
  - was: Hello |PLAYERNAME|, you want to hear a good story?
  - now: Hello |PLAYERNAME|, do you want to hear a good story?
- quest 8240 talk_questStarting - Broken sentence
  - was: I have three clues about where the stone of prophecy. Will you help me look?
  - now: I have three clues about where the stone of prophecy is. Will you help me look?
- quest 8240 talk_questStarted - 'She' for stone; 'you goes'
  - was: She may be in the Golden or Butwal Island. Thanks buddy, pay close attention to where you goes!
  - now: It may be on Golden or Butwal Island. Thanks buddy, pay close attention to where you go!
- quest 8240 talk_questFinished - 'she says of' unclear
  - was: My goodness! What a wonderful thing... she says of an {elder}?
  - now: My goodness! What a wonderful thing... it speaks of an {elder}?

## Agustin

- npc/scripts/quest_agustin.lua - Garbled sentence
  - was: Rock? It is an old friend. Hehe, time does not see it.
  - now: Rock? He's an old friend. Hehe, I haven't seen him in ages.
- npc/scripts/quest_agustin.lua - Missing 'Will'
  - was: Also, I got a letter to deliver to him. You do this favor for me?
  - now: Also, I have a letter to deliver to him. Will you do me this favor?
- npc/scripts/quest_agustin.lua - Incomplete 'here is'
  - was: Ok, here is.
  - now: Ok, here it is.

## Aila

- quest 8095 talk_questStarted - Missing 'to'; 'them' for one
  - was: Thanks! Your task is catch 1 Charmander and bring them to me.
  - now: Thanks! Your task is to catch 1 Charmander and bring it to me.
- quest 8095 talk_questFinishing - Broken question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8096 talk_questStarted - Missing 'to'; 'them' for one
  - was: Thanks! Your task is catch 1 Vulpix and bring them to me.
  - now: Thanks! Your task is to catch 1 Vulpix and bring it to me.
- quest 8097 talk_questStarted - Missing 'to'; 'them' for one
  - was: Thanks! Your task is catch 1 Growlithe and bring them to me.
  - now: Thanks! Your task is to catch 1 Growlithe and bring it to me.
- quest 8098 talk_questStarted - Missing 'to'; 'them' for one
  - was: Thanks! Your task is catch 1 Ponyta and bring them to me.
  - now: Thanks! Your task is to catch 1 Ponyta and bring it to me.

## Albert

- npc/scripts/quest_albert.lua - Incomplete 'here is'
  - was: Oh! I finished the extraction, here is.
  - now: Oh! I finished the extraction, here it is.
- quest 8216 talk_questStarting - 'she' for plant; missing 'Could'
  - was: Oh, Ivy told me you were bringing a new plant, let me see it. Hmmm... she has unique characteristics. You could buy a flask for me in the Poke Mart?
  - now: Oh, Ivy told me you were bringing a new plant, let me see it. Hmmm... it has unique characteristics. Could you buy a flask for me at the Poke Mart?
- quest 8216 talk_questFinishing - Broken question word order
  - was: You've got the flask?
  - now: Have you got the flask?
- quest 8216 talk_questFinished - Awkward tense
  - was: Thanks for the flask. Come back in 30 minutes, I will finish the {extraction} process.
  - now: Thanks for the flask. Come back in 30 minutes, I will have finished the {extraction} process.

## Aldo Vumblevore

- quest 8670 talk_questFinishing - Wrong tense
  - was: Did you find what I've asked?
  - now: Did you find what I asked for?
- message_greet - Typo 'hi' for 'he'
  - was: Hey |PLAYERNAME|, join us to {defeat} the evil Suramoon. I know him very well, hi is an evil taskmaster.
  - now: Hey |PLAYERNAME|, join us to {defeat} the evil Suramoon. I know him very well, he is an evil taskmaster.

## Aleb

- npc/scripts/quest_aleb.lua - Garbled ramble beyond voice
  - was: That place is beautiful %s. I lived moments there, and various {battles} and adventures and got lost... Han, hi.
  - now: That place is beautiful, %s. I lived great moments there, many {battles} and adventures, and got lost... Huh, hi.
- npc/scripts/quest_aleb.lua - Garbled grammar
  - was: I do not remember them but had water, had dark, had lightning, fire and ice... oh, Runford can remember... Who is he? A sailor...? Ah... hi.
  - now: I don't remember them, but there was water, darkness, lightning, fire and ice... oh, Runford may remember... Who is he? A sailor...? Ah... hi.

## Alec Hudson

- message_greet - 'destiny' / 'flow' wrong words
  - was: Hello, welcome to Cerulean central trains! Tell your destiny! If you don't know where to flow, say {travel}.
  - now: Hello, welcome to Cerulean central trains! Tell me your destination! If you don't know where to go, say {travel}.

## Alex

- message_greet - Misspelling citzen
  - was: Hey |PLAYERNAME|, how are you? My name is Alex, I'm a former citzen from Fuchsia and you can buy diving equipment from me. I am also doing {research} on wetsuits.
  - now: Hey |PLAYERNAME|, how are you? My name is Alex, I'm a former citizen of Fuchsia and you can buy diving equipment from me. I am also doing {research} on wetsuits.
- quest 8387 talk_questStarting - Typo 'through'; garbled
  - was: Oh, you want to test the new dive equipment? It's a long process through... First you must get some items that I can bring to the clothing manufacturing.
  - now: Oh, you want to test the new dive equipment? It's a long process though... First you must get some items that I can bring to the clothing manufacturer.
- quest 8387 talk_questStarted - Wrong apostrophes in plurals
  - was: You must bring me 200 fur's, 30 ape hair's, 5 gyarados tail's and 30 shell bell's.
  - now: You must bring me 200 furs, 30 ape hairs, 5 gyarados tails and 30 shell bells.
- quest 8387 talk_questFinishing - 'Did you got the itens'
  - was: Did you got the itens to the clothing manufacture?
  - now: Did you get the items for the clothing manufacturer?
- quest 8388 talk_questStarting - Awkward 'Use the bottle to it'
  - was: Now you need to get the oil of a Pokemon that is in the lake of my land. Use the bottle to it. Do you want to go now?
  - now: Now you need to get the oil of a Pokemon that lives in the lake of my land. Use the bottle on it. Do you want to go now?
- quest 8388 talk_questFinishing - Broken question
  - was: You got the Pokemon oil?
  - now: Did you get the Pokemon oil?
- quest 8388 talk_questFinished - 'benefit myself' unclear
  - was: Now you're ready for the {last} part, which is to benefit myself.
  - now: Now you're ready for the {last} part, which is a favor for me.
- quest 8389 talk_questStarting - Missing object 'it'
  - was: Hehe... Your new equipment is ready but before I give you, I want you to find a black pearl in the sea. Can you do this for me?
  - now: Hehe... Your new equipment is ready, but before I give it to you, I want you to find a black pearl in the sea. Can you do this for me?
- quest 8389 talk_questFinishing - Broken question
  - was: You got the black pearl?
  - now: Did you get the black pearl?

## Alfonso

- message_greet - 'let's battle?' awkward
  - was: Hello |PLAYERNAME|! I'm Alfonso, let's {battle}?
  - now: Hello |PLAYERNAME|! I'm Alfonso, shall we {battle}?

## Allen Clancy

- message_greet - Garbled question
  - was: Will not need this plate?
  - now: Won't you need this plate?

## Ancient Times

- message_greet - Broken question grammar
  - was: Hey |PLAYERNAME|, it is hot? This desert is getting worse.
  - now: Hey |PLAYERNAME|, is it hot? This desert is getting worse.
- quest 8369 talk_questStarted - 'where no one dared to come' awkward
  - was: You have to go through a new trial. Decipher our little secret and go where no one dared to come.
  - now: You have to go through a new trial. Decipher our little secret and go where no one has dared to go.
- quest 8369 talk_questFinishing - Broken question
  - was: Concluded our secret?
  - now: Have you solved our secret?
- quest 8369 talk_questFinished - Garbled, unclear instructions
  - was: Now go to the island corresponding to the element. They get to around this main island and deposit the Orb in the correct location. You then come to Deepsoul Stone.
  - now: Now go to the island matching the element. The islands lie around this main island; place the Orb in the correct spot there. Then come to Deepsoul Stone.
- quest 8369 talk_questFinishFail - Unnatural 'Looks like no'
  - was: Looks like no.
  - now: Looks like you haven't.

## Anderson Dalton

- message_greet - 'So' should be 'Then'
  - was: Hello |PLAYERNAME|. Thirsty? So you came to the right place.
  - now: Hello |PLAYERNAME|. Thirsty? Then you came to the right place.

## Andy

- message_greet - Word order 'how I can help'
  - was: Hey |PLAYERNAME|, how I can help? You can buy bikes here, just say {trade}.
  - now: Hey |PLAYERNAME|, how can I help? You can buy bikes here, just say {trade}.

## Arlie

- message_greet - 'she' for island
  - was: Visit our island well, she's wonderful!
  - now: Explore our island well, it's wonderful!

## Arlo Fulke

- message_greet - 'let's battle?' awkward
  - was: Hello |PLAYERNAME|! I'm Arlo Fulke, let's {battle}?
  - now: Hello |PLAYERNAME|! I'm Arlo Fulke, shall we {battle}?

## Arold

- npc/scripts/quest_arold.lua - Awkward phrasing
  - was: Ahh! It's a nice place and full of cute {Pokemon}. It is a group of islands... I do not know the total... but they are quite large and full of experienced trainers.
  - now: Ahh! It's a nice place, full of cute {Pokemon}. It's a group of islands... I don't know how many... but they are quite large and full of experienced trainers.
- npc/scripts/quest_arold.lua - Garbled grammar
  - was: Cool your interest in Pokemon. They come in a huge {variety} and some I know nothing. It has many strengths, in fact, especially one that is called Kingdra. I heard he is the dragon type... that scares you?
  - now: I like your interest in Pokemon. They come in a huge {variety}, and some I know nothing about. There are many strong ones, especially one called Kingdra. I heard it's a dragon type... does that scare you?
- npc/scripts/quest_arold.lua - Garbled grammar
  - was: You are very curious! How about asking more about it to my friend Juhn? I was going over the business in the islands, he attended the most mysterious places... think about it, want to buy a trinket? Do not tell anyone. Hehe!
  - now: You are very curious! Why not ask my friend Juhn about it? While I was doing business on the islands, he visited the most mysterious places... Think about it. Want to buy a trinket? Don't tell anyone. Hehe!

## Arron Deforest

- quest 8727 talk_questStarting - Awkward tense
  - was: Err... Actually I still have not got my first Pokemon, could you help me?
  - now: Err... Actually I still haven't got my first Pokemon, could you help me?
- quest 8727 talk_questFinished - Portuguese-ism 'now yes'
  - was: Beautiful! Thank you very much! I'll take good care of him... now yes I will become a {Pokemon} trainer.
  - now: Beautiful! Thank you very much! I'll take good care of him... now I will really become a {Pokemon} trainer.
- quest 8727 talk_questFinishFail - Unnatural 'Looks like no'
  - was: Looks like no.
  - now: Looks like you didn't.
- quest 8728 talk_questStarting - Broken question word order
  - was: Errr! You are available? I need your help one more time.
  - now: Errr! Are you available? I need your help one more time.
- quest 8728 talk_questStarted - Wrong tense
  - was: I do not know what I do wrong, but no Pokemon wants to get into the Pokeballs I throw! Could you catch a Zubat for me?
  - now: I don't know what I'm doing wrong, but no Pokemon wants to get into the Pokeballs I throw! Could you catch a Zubat for me?
- quest 8728 talk_questFinishing - Awkward question
  - was: The Zubat? You did it?
  - now: The Zubat? Did you do it?
- quest 8728 talk_questFinished - 'already realize' wrong
  - was: Exactly! That's what I needed, thank you very much. Take your reward. You already realize that I'm a {Pokemon} trainer, right?
  - now: Exactly! That's what I needed, thank you very much. Take your reward. You can tell I'm a real {Pokemon} trainer, right?
- quest 8729 talk_questStarted - Broken grammar
  - was: Do you believe he never wanted to give me a Pokemon? Thanks to you I got now, but... can you bring a Poliwag for me? Thank you.
  - now: Can you believe he never wanted to give me a Pokemon? Thanks to you I have some now, but... can you bring a Poliwag for me? Thank you.
- quest 8730 talk_questFinished - 'how I became' wrong
  - was: Wow! You're awesome, thank you! My mother will not even believe how I became the greatest {Pokemon} trainer in the world.
  - now: Wow! You're awesome, thank you! My mother won't even believe I became the greatest {Pokemon} trainer in the world.
- quest 8731 talk_questStarting - Portuguese-ism 'then yes'
  - was: Okay, actually, I still need more Pokemon, then yes I'll become the best of all.
  - now: Okay, actually, I still need more Pokemon, then I'll really become the best of all.
- quest 8731 talk_questFinished - Garbled 'Do not you dare'
  - was: Wow! thank you! Err. Do not you dare defy me in a duel, ever. Now I'm going to show Oak what I am.
  - now: Wow! Thank you! Err... Don't you ever dare challenge me to a duel. Now I'm going to show Oak who I am.

## Ash Ketchum

- message_greet - Broken question word order
  - was: Hey, hello |PLAYERNAME|! You are a Pokemon trainer too?
  - now: Hey, hello |PLAYERNAME|! Are you a Pokemon trainer too?
- npc/scripts/quest_ashKetchum.lua - Awkward 'We have not much time'
  - was: Thank you. We have not much time before they come after us with everything again. I'll hide for a while. Tell Bill and Gary that I will be in the usual place. Thanks again, trainer.
  - now: Thank you. We don't have much time before they come after us with everything again. I'll hide for a while. Tell Bill and Gary that I will be in the usual place. Thanks again, trainer.
- npc/scripts/quest_ashKetchum.lua - 'I am some days without' Portuguese-ism
  - was: Finally... someone got here. It was a very long and exhausting journey. They kidnapped me and held me here. I am some days without eating or drinking... we need to get out of here quickly. Please {help} me.
  - now: Finally... someone got here. It was a very long and exhausting journey. They kidnapped me and held me here. I've gone days without eating or drinking... we need to get out of here quickly. Please {help} me.
- npc/scripts/quest_ashKetchum.lua - 'I am some days without' Portuguese-ism
  - was: Finally ... someone got here. It was a very long and exhausting journey. They kidnapped me and held me here. I am some days without eating or drinking ... we need to get out of here quickly. Please {help} me.
  - now: Finally ... someone got here. It was a very long and exhausting journey. They kidnapped me and held me here. I've gone days without eating or drinking ... we need to get out of here quickly. Please {help} me.
- quest 8659 talk_questStarting - Unclear 'it took Pikachu'
  - was: Pikachu! I can not believe it took Pikachu <crying>...
  - now: Pikachu! I can't believe they took Pikachu <crying>...
- quest 8659 talk_questStarted - Awkward 'must have some key'
  - was: We have to recover our Pokemon, please go ahead, the body of the nurse must have some key.
  - now: We have to recover our Pokemon, please go ahead. The nurse's body must have a key.
- quest 8659 talk_questFinished - 'I do not believe!' unnatural
  - was: I do not believe! You did it! Thank you!
  - now: I can't believe it! You did it! Thank you!
- quest 8659 talk_questFinishFail - Unnatural 'Looks like no'
  - was: Looks like no.
  - now: Looks like you didn't.
- quest 8378 talk_questFinishing - Broken question
  - was: You brought the honey pot?
  - now: Did you bring the honey pot?
- quest 8378 talk_questFinished - 'where is Brock and Misty'
  - was: Thank you! This will be very useful in order to {save} those Pokemon! But where is Brock and Misty !? Grr!
  - now: Thank you! This will be very useful to {save} those Pokemon! But where are Brock and Misty?! Grr!
- quest 8379 talk_questStarted - Awkward 'go behind you'
  - was: Go to east of Fuchsia at route 15, on top of a mountain you will find a special tree. Use this honey on the tree and take good care, a hungry Beedrill will go behind you. Defeat this Beedrill and bring a special mushroom for us.
  - now: Go east of Fuchsia to route 15; on top of a mountain you will find a special tree. Use this honey on the tree and be careful, a hungry Beedrill will come after you. Defeat this Beedrill and bring a special mushroom back for us.
- quest 8379 talk_questFinishing - Broken question
  - was: You could find the mushroom?
  - now: Were you able to find the mushroom?
- quest 8379 talk_questFinished - 'Pokemons' plural; word order
  - was: Thank you! Brock now will be able to complete the recipe and save those poor Pokemons, thanks! Take this reward, you deserve it.
  - now: Thank you! Now Brock will be able to complete the recipe and save those poor Pokemon, thanks! Take this reward, you deserve it.
- quest 8523 talk_questStarted - 'I am some days without' Portuguese-ism
  - was: It was a very long and exhausting journey. They kidnapped me and held me here. I am some days without eating or drinking ... we need to get out of here quickly. Come on!
  - now: It was a very long and exhausting journey. They kidnapped me and held me here. I've gone days without eating or drinking ... we need to get out of here quickly. Come on!
- quest 8523 talk_questFinishing - Broken question word order
  - was: We are safe now?
  - now: Are we safe now?
- quest 8523 talk_questFinished - 'its usual place'; grammar
  - was: Thank you. We have not much time before they come after us with everything again. I'll hide for a while. Tell Bill and Gary that I will be in its usual place. Thanks again trainer.
  - now: Thank you. We don't have much time before they come after us with everything again. I'll hide for a while. Tell Bill and Gary that I will be in the usual place. Thanks again, trainer.

## Ashton

- message_greet - Missing subject
  - was: Need potions and balls? Came to the right place.
  - now: Need potions and balls? You came to the right place.

## Assistant Guyli

- message_greet - Typo What' up
  - was: Hey, hey! What' up?
  - now: Hey, hey! What's up?
- quest 8410 talk_questStarting - Broken question
  - was: Hello trainer, I see the Poke Ball... congratulations. The professor sent you?
  - now: Hello trainer, I see the Poke Ball... congratulations. Did the professor send you?
- quest 8410 talk_questStarted - 'his name' for girl; awkward
  - was: I made him a request because I need help. Some Pokemon from our reserves are stressed lately, and we do not know how to handle it. Can you get help? We can not leave the lab for long. I'm sure there's someone who can help us in Pallet. A girl, yes! I do not remember his name... ask for {Pokemon stress}. Take a look on Pallet and return with good news!
  - now: I asked him for help. Some Pokemon from our reserves have been stressed lately, and we don't know how to handle it. Can you find help? We can't leave the lab for long. I'm sure someone in Pallet can help us. A girl, yes! I don't remember her name... ask about {Pokemon stress}. Take a look around Pallet and return with good news!
- quest 8410 talk_questFinishing - 'Did you got'
  - was: Did you got the help?
  - now: Did you get the help?
- quest 8410 talk_questFinished - Missing 'it'
  - was: I knew that was a girl. Do not tell the professor that I forgot her granddaughter! Hehehe. Take this reward for your effort. And please, next time do not take so long... we were concerned.
  - now: I knew it was a girl. Don't tell the professor that I forgot his granddaughter's name! Hehehe. Take this reward for your effort. And please, next time don't take so long... we were worried.

## Assistant Jofrey

- message_greet - 'I'm trouble'; missing object
  - was: Hi |PLAYERNAME|! I'm trouble, surely. I forgot to pack the catalog that the {Professor} asked.
  - now: Hi |PLAYERNAME|! I'm in trouble, for sure. I forgot to pack the catalog the {Professor} asked for.
- quest 8501 talk_questStarting - Broken question
  - was: The Professor sent you?
  - now: Did the Professor send you?
- quest 8501 talk_questStarted - 'Go back to talk' awkward
  - was: I'm here to teach you about fishing. Take this little Oddish and use the fishing rod on the water. Then you must hook 5 Pokemon and defeat them. Go back to talk to me when you're done.
  - now: I'm here to teach you about fishing. Take this little Oddish and use the fishing rod on the water. Then you must hook 5 Pokemon and defeat them. Come back and talk to me when you're done.
- quest 8501 talk_questFinished - 'teach you fishing on trees'
  - was: I see that you did well. Take these rewards. Now I will teach you fishing on trees! Hahaha, I mean... The {Headbutting} skill.
  - now: I see that you did well. Take these rewards. Now I will teach you to fish in trees! Hahaha, I mean... the {Headbutting} skill.
- quest 8501 talk_questFinishFail - Typo 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.
- quest 8502 talk_questStarting - Broken question word order
  - was: Yes, today I will teach you about Headbutting, you are ready?
  - now: Yes, today I will teach you about Headbutting, are you ready?
- quest 8502 talk_questStarted - Awkward 'go there on the east'
  - was: Ok, Headbutt works like fishing, but instead of using a rod on the water, you will use your Pokemon Headbutt ability against a nest tree! Take this Caterpie and go there on the east, you will find some Nest Trees. Just release your Pokemon and use the Order command over the Nest Tree.
  - now: Ok, Headbutt works like fishing, but instead of using a rod on the water, you will use your Pokemon's Headbutt ability on a nest tree! Take this Caterpie and go east, you will find some Nest Trees. Just release your Pokemon and use the Order command on the Nest Tree.
- quest 8502 talk_questFinished - Missing article
  - was: Yup! Nice. Now you must talk to Dorothy. She will teach you more about Pokeballs. You can find her inside Oak Lab.
  - now: Yup! Nice. Now you must talk to Dorothy. She will teach you more about Pokeballs. You can find her inside the Oak Lab.

## Aura Roslyn

- message_greet - Awkward 'wake him or wait'
  - was: A Pokemon can not attack if he is sleeping. Use any method to wake him or wait.
  - now: A Pokemon can't attack while it is sleeping. Use any method to wake it up, or wait.

## Aylmer Len

- message_greet - 'exchange into' wrong
  - was: Welcome to the Blaze Mastery! Here you can exchange your blaze tokens into rewards. Type {options} to see.
  - now: Welcome to the Blaze Mastery! Here you can exchange your blaze tokens for rewards. Type {options} to see.

## Barrie Sheard

- message_greet - 'let's battle?' awkward
  - was: Hello |PLAYERNAME|! I'm Barrie Sheard, let's {battle}?
  - now: Hello |PLAYERNAME|! I'm Barrie Sheard, shall we {battle}?

## Basam

- message_greet - Word order
  - was: What a kid is doing here?
  - now: What is a kid doing here?

## Beatriz

- message_greet - Missing 'do'
  - was: Hello dear, what you want?
  - now: Hello dear, what do you want?
- npc/scripts/quest_beatriz.lua - Garbled name/grammar
  - was: Oh! My dear Courts Ted writes me? Great, tell also that I miss him.
  - now: Oh! My dear Ted Courts wrote to me? Great, tell him I miss him too.

## Beau

- message_greet - Garbled grammar
  - was: Patience buddy, patience. Need only seek some teeth, fur... lots of stuff.
  - now: Patience buddy, patience. I just need to find some teeth, fur... lots of stuff.
- quest 8080 talk_questFinishing - Broken question
  - was: You got the items?
  - now: Did you get the items?

## Bertina Stacy

- quest 8737 talk_questStarting - Garbled cause/grammar
  - was: This is all the fault of these filthy sewers of the city. That's why I don't like Pokemon, destroy all my flowers. Can you help me?
  - now: It's all the fault of the city's filthy sewers. That's why I don't like Pokemon, they destroy all my flowers. Can you help me?
- quest 8737 talk_questFinished - 'one more help' Portuguese-ism
  - was: Thank you very much, take a reward here. When you are available, I need one more {help}.
  - now: Thank you very much, here's a reward. When you are available, I need a little more {help}.
- quest 8737 talk_questFinishFail - Unnatural 'Looks like no'
  - was: Looks like no.
  - now: Looks like you haven't.
- quest 8738 talk_questStarted - Garbled grammar
  - was: Are those Zubats who are eating all my flowers, could you defeat 5x Zubat?
  - now: It's those Zubats that are eating all my flowers, could you defeat 5x Zubat?
- quest 8738 talk_questFinishing - 'surprise' wrong word
  - was: Did you surprise them??
  - now: Did you defeat them?
- quest 8739 talk_questFinishing - Broken question
  - was: You took them out of my yard?
  - now: Did you get them out of my yard?
- quest 8740 talk_questStarting - Awkward 'get into' nuance
  - was: My biggest fear is these horrible snakes that have appeared, I can not get into my house any more.
  - now: My biggest fear is these horrible snakes that have appeared, I can't even get into my house anymore.

## Biff

- message_greet - 'Here will be guided' broken
  - was: Hello, welcome to the PokeVerse Pokemon world! Here will be guided within your first game steps. Some dialogs will contain blue words, you just need to repeat them to {CONTINUE} the dialogue. [You can {skip} this tutorial whenever you want.]
  - now: Hello, welcome to the PokeVerse Pokemon world! Here you will be guided through your first steps in the game. Some dialogs contain blue words, you just need to repeat them to {CONTINUE} the dialogue. [You can {skip} this tutorial whenever you want.]

## Bill

- npc/scripts/quest_bill.lua - Misspelling trasform
  - was: Give me a doll of any Pokemon you have in your PokeDex and I can trasform you into this Pokemon for 30 minutes. That's my new machine.
  - now: Give me a doll of any Pokemon you have in your PokeDex and I can transform you into that Pokemon for 30 minutes. That's my new machine.
- npc/scripts/quest_bill.lua - Awkward 'called me giving'
  - was: Ivy called me giving this information. Look, try this special banana... this can work. The thief Aipom is on Valencia Island.
  - now: Ivy called me with this information. Look, try this special banana... it might work. The thief Aipom is on Valencia Island.
- npc/scripts/quest_bill.lua - 'hook' unclear
  - was: You must now use the special bananas to hook the Thief Aipom!
  - now: You must now use the special bananas to lure the Thief Aipom!
- quest 8421 talk_questStarting - Broken sentence
  - was: So are you the trainer that Gary has spoken... I understand.
  - now: So you are the trainer Gary told me about... I see.
- quest 8421 talk_questStarted - Garbled grammar
  - was: I have new information on the whereabouts of Ash. I sent him to the Sevii Islands a few time ago to collect data for my current research. Once he returned, he told me about maybe he was being followed. He was with my equipment, and luckily I put a tracking device inside. I need to track him. Meanwhile, go to Cerulean and warn the authorities about this case. When you do this, return.
  - now: I have new information on Ash's whereabouts. I sent him to the Sevii Islands a while ago to collect data for my research. When he came back, he told me he might be being followed. He had my equipment, and luckily I put a tracking device inside. I need to track him. Meanwhile, go to Cerulean and warn the authorities about this case. Come back when you've done it.
- quest 8421 talk_questFinishing - 'Did you notified'
  - was: Did you notified the authorities?
  - now: Did you notify the authorities?
- quest 8421 talk_questFinishFail - Typo 'Likes no'
  - was: Likes no.
  - now: Looks like you haven't.
- quest 8431 talk_questStarting - Awkward tense
  - was: My device sends some signals from Vermilion. Go investigate.
  - now: My device is sending signals from Vermilion. Go investigate.
- quest 8431 talk_questStarted - Awkward 'which is'
  - was: It is the city which is south of Saffron.
  - now: It's the city south of Saffron.
- quest 8431 talk_questFinishing - Broken question
  - was: You've found the device?
  - now: Did you find the device?
- quest 8431 talk_questFinished - Garbled, unclear instructions
  - was: I can not believe it! So the rumors may be true. Does he exist? Thanks for the help, I think the next step is to follow the meaning of this message. Try rummaging through some town, I bet that must be it. Take this ticket to S.S. Anne. Also investigate it to seek whereabouts of Ash. It's the boat that is at Vermilion. You need a ticket to enter.
  - now: I can't believe it! So the rumors may be true. Does he exist? Thanks for the help. I think the next step is to follow the meaning of this message. Try searching the town, I bet that's it. Take this ticket to the S.S. Anne and investigate it for clues about Ash. It's the ship docked at Vermilion. You need a ticket to board.
- quest 8510 talk_questStarting - Minor grammar
  - was: I see you found a lot of things! Are you saying that you saw the legendary Mew? You're the only person so far I know who saw him! I need to know more details in the future. For now we have a big problem.
  - now: I see you found a lot of things! Are you saying you saw the legendary Mew? You're the only person I know who has seen it! I'll need more details later. For now we have a big problem.
- quest 8510 talk_questStarted - Garbled; 'were', 'orphans Pokemon'
  - was: Dr. Fuji has been a great Pokemon researcher on the Cinnabar island. He was currently living in Lavender were he took care of orphans Pokemon. He was kidnapped for some reason and is being maintained by Team Rocket at the top of the tower. Please help him. Rescue him from the clutches of these criminals, maybe we can find something with this... everything is very strange within this story.
  - now: Dr. Fuji was a great Pokemon researcher on Cinnabar Island. He was living in Lavender, where he took care of orphaned Pokemon. He was kidnapped for some reason and is being held by Team Rocket at the top of the tower. Please rescue him from the clutches of these criminals, maybe we can learn something from this... everything about this story is very strange.
- quest 8510 talk_questFinishing - 'Did you helped'
  - was: Did you helped Dr. Fuji?
  - now: Did you help Dr. Fuji?
- quest 8510 talk_questFinished - Awkward 'when you get ready'
  - was: Very nice, thanks! I got another {task} for you when you get ready.
  - now: Very nice, thanks! I've got another {task} for you when you're ready.
- quest 8517 talk_questStarted - Garbled, unclear instructions
  - was: It can not be true! We must find Ash's Pikachu quickly, he must be scared! I have to think of a way... the work now begins trainer! You look for information on the balloon seen by Mr. Fuji and I talk to Gary on our findings, we need to find a way to find Pikachu. Go to Celadon, maybe we can help there. Contact with the owner of the hotel there, Briscoe Len. An old friend of mine. Good luck.
  - now: It can't be true! We must find Ash's Pikachu quickly, he must be scared! I have to think of a way... the real work begins now, trainer! You look for information on the balloon Mr. Fuji saw, and I'll tell Gary about our findings, we need a way to find Pikachu. Go to Celadon, maybe someone can help there. Contact the owner of the hotel there, Briscoe Len. He's an old friend of mine. Good luck.
- quest 8517 talk_questFinishing - 'I do not believe' unnatural
  - was: I do not believe... this organization is going too far. We will need all the help we can to stop them. You mean you found Ash's Pikachu?
  - now: I can't believe it... this organization is going too far. We will need all the help we can get to stop them. You mean you found Ash's Pikachu?
- quest 8517 talk_questFinished - Garbled, 'mals bits' gibberish
  - was: That's great. Give him to me... this. I'll put him to rest. He underwent mals bits. I need you to talk to Gary in this next step. I believe we are making progress on the whereabouts of Ash. When Pikachu wake want to extract from him what I can ... once again, congratulations. Take this Doll Case I developed, it can store all your dolls without taking up space in your backpack.
  - now: That's great. Give him to me... there. I'll let him rest. He's been through a lot. I need you to talk to Gary for the next step. I believe we are getting closer to finding Ash. When Pikachu wakes up I'll learn what I can from him... once again, congratulations. Take this Doll Case I developed, it can store all your dolls without taking up space in your backpack.
- quest 8526 talk_questFinishing - 'history' for 'story'; awkward
  - was: Finally! Congratulations trainer. Now I must meet Ash to clarify all this history and we count on you for the next step. Ok?
  - now: Finally! Congratulations trainer. Now I must meet Ash to clear up this whole story, and we're counting on you for the next step. Ok?
- quest 8527 talk_questStarting - Awkward grammar
  - was: We found a strange figure walking by the other day. With a coat and hood. We need to know his intentions... and most of all, who is this being. Maybe you could look it.
  - now: We saw a strange figure walking by the other day, wearing a coat and hood. We need to know his intentions... and above all, who he is. Maybe you could look into it.
- quest 8527 talk_questStarted - Broken grammar
  - was: Okay, so as soon you got something come to me!
  - now: Okay, as soon as you find something, come to me!
- quest 8527 talk_questFinished - Garbled run-on, unclear
  - was: Amazing! Then the masked supposedly is on our side. If the team rocket is behind it all then we must return to the base of the team rocket in Celadon, try to destroy the doors closed. Go there and look for more clues about it all the meantime I will find out more about this island mentioned in the book.
  - now: Amazing! So the masked one is supposedly on our side. If Team Rocket is behind all this, then we must return to the Team Rocket base in Celadon and try to break down the closed doors. Go there and look for more clues; meanwhile I will find out more about this island mentioned in the book.
- quest 8542 talk_questStarting - 'the masked supposedly' broken
  - was: Amazing! Then the masked supposedly is on our side.
  - now: Amazing! So the masked one is supposedly on our side.
- quest 8542 talk_questStarted - Garbled run-on
  - was: If the team rocket is behind it all then we must return to the base of the team rocket in Celadon, try to destroy the closed doors. Go there and look for more clues about it all the meantime I will find out more about this island mentioned in the book.
  - now: If Team Rocket is behind all this, then we must return to the Team Rocket base in Celadon and try to break down the closed doors. Go there and look for more clues; meanwhile I will find out more about this island mentioned in the book.
- quest 8542 talk_questFinishing - Wrong tense
  - was: Can you find something there?
  - now: Did you find anything there?
- quest 8542 talk_questFinished - Awkward grammar
  - was: I knew I could still count on my dear friend Briscoe Len! So we will find out more about the team rocket, come back in one hour because I'll find out everything about this HD.
  - now: I knew I could still count on my dear friend Briscoe Len! Now we'll find out more about Team Rocket. Come back in one hour, I'll find out everything on this HD.
- quest 8550 talk_questFinished - Missing article 'the team rocket'
  - was: I discovered that the team rocket is in possession of a very powerful pokeball and they intend to recapture Mewtwo, we need to {capture} Mewtwo before them!
  - now: I discovered that Team Rocket has a very powerful pokeball and they intend to recapture Mewtwo, we need to {capture} Mewtwo before them!
- quest 8551 talk_questStarting - 'that is with them' Portuguese-ism
  - was: First we need the Master Ball that is with them.
  - now: First we need the Master Ball they have.
- quest 8551 talk_questStarted - 'ask for the responsible scientist'
  - was: Go to Silph Co. again and ask for the responsible scientist if he knows something, his name is Charley Aden.
  - now: Go to Silph Co. again and ask the scientist in charge if he knows something, his name is Charley Aden.
- quest 8551 talk_questFinished - Garbled grammar
  - was: Great now with the Master Ball can have a chance. I found out where is this island that Dr. Fuji cited, it is southwest of Kanto, according to him the laboratory that existed was destroyed there, go there and look for more clues about the Mewtwo.
  - now: Great, now with the Master Ball we have a chance. I found out where the island Dr. Fuji mentioned is: it's southwest of Kanto. According to him, the laboratory there was destroyed. Go there and look for more clues about Mewtwo.
- quest 8555 talk_questFinished - Garbled, nearly incomprehensible
  - was: I do not believe that we can not capture Mewtwo, but at least the rocket equip stood aside an hour. I still can not believe all this happened ... I almost forgot, I have a gift to you is the way and found to reward you for this great help, thank you trainer.
  - now: I can't believe we couldn't capture Mewtwo, but at least Team Rocket is out of the way for now. I still can't believe all this happened... I almost forgot, I have a gift for you, it's the way I found to reward you for this great help. Thank you, trainer.

## Bill's Assistant

- npc/scripts/quest_billAssistant.lua - Awkward grammar
  - was: How do you know about my secret artifact? Look it does not matter... want to help me to test it?
  - now: How do you know about my secret artifact? Well, it doesn't matter... want to help me test it?
- npc/scripts/quest_billAssistant.lua - 'Do you want?' incomplete
  - was: It will cost you a bit. Hehe... 100,000 dollars. I need money to fund my research... Do you want?
  - now: It will cost you a bit. Hehe... 100,000 dollars. I need money to fund my research... Do you want it?
- npc/scripts/quest_billAssistant.lua - Unclear 'see the results here'
  - was: Take good advantage of it. But it will only work with Pokemon that have an average level of intelligence. I developed this prototype for Pokemon living in society. I can see the results here, go ahead!
  - now: Make good use of it. But it will only work with Pokemon of average intelligence. I developed this prototype for Pokemon living in society. I'll watch the results from here, go ahead!

## Blaine

- npc/scripts/npcbattle_blaine.lua - Missing 'you'; verb form
  - was: You must defeat me before receive your reward.
  - now: You must defeat me before receiving your reward.
- npc/scripts/npcbattle_blaine.lua - Incomplete 'here is'
  - was: Oh, here is!
  - now: Oh, here it is!

## Blaze

- message_greet - 'win you' wrong verb
  - was: I can win you!
  - now: I can beat you!

## Bob Lop

- quest 8007 talk_questStarting - Awkward 'since'
  - was: Well, since I collect little things from the beach and need help to find some items, are you willing to help me?
  - now: Well, I collect little things from the beach and need help finding some items, are you willing to help me?
- quest 8007 talk_questStarted - 'back when you are with them'
  - was: Ok, the items that I need are 10 crab claws, back when you are with them.
  - now: Ok, the items I need are 10 crab claws, come back when you have them.
- quest 8007 talk_questFinishing - Broken question word order
  - was: You've got what I asked?
  - now: Have you got what I asked for?
- quest 8007 talk_questFinishFail - Broken grammar; 'ingredients' mismatch
  - was: No..You do not have, go get the ingredients and return back to me.
  - now: No... You don't have them, go get the items and come back to me.

## Branson Kip

- message_greet - Garbled 'guards Magmar'
  - was: Safes here are sealed well and kept by guards Magmar! Your options are: {balance}, {deposit}, {deposit all}, {withdraw}, {withdraw all} and {transfer}.
  - now: Safes here are well sealed and guarded by Magmar! Your options are: {balance}, {deposit}, {deposit all}, {withdraw}, {withdraw all} and {transfer}.

## Briscoe Len

- quest 8518 talk_questStarting - Missing 'about'
  - was: You are the trainer that Bill told me. Let's meet in my room downstairs.
  - now: You are the trainer Bill told me about. Let's meet in my room downstairs.
- quest 8518 talk_questFinished - Broken tense/grammar
  - was: I'm sorry, they forced me to do this. That was my secret room to save money and they turn into a dungeon. I had nothing to do with it. They took my son... I do not know how to retrieve him, I need {help}.
  - now: I'm sorry, they forced me to do this. That was my secret room for saving money and they turned it into a dungeon. I had nothing to do with it. They took my son... I don't know how to get him back, I need {help}.
- quest 8518 talk_questFinishFail - Typo 'Likes no'
  - was: Likes no.
  - now: Looks like you haven't.
- quest 8519 talk_questStarting - Fine voice but missing 'Are'
  - was: Y-You gonna help me?
  - now: Y-You're gonna help me?
- quest 8519 talk_questStarted - Broken grammar
  - was: They made me keep quiet because kidnapped my dear son. I do not know where he is... my hopes have not died. Return it to me as soon as possible. OK?
  - now: They made me keep quiet because they kidnapped my dear son. I don't know where he is... but I haven't lost hope. Bring him back to me as soon as possible. OK?
- quest 8544 talk_questStarting - Broken grammar 'you can me help'
  - was: MY son was trying to destroy the team rocket? I'm so proud! But he was caught again?? Oh my God, you have to help me save my son, I have something that can be useful, but I am old for this, you can me help.
  - now: MY son was trying to destroy Team Rocket? I'm so proud! But he was caught again?? Oh my God, you have to help me save my son. I have something that can be useful, but I'm too old for this, can you help me?
- quest 8544 talk_questStarted - Garbled, unclear
  - was: Since our last meeting the rockets not suspected that I knew something and they are still there... for fear I would not have given them, but now it gonna be useful. I just send the data about the secret base at the casino for the police. Go back quickly and save my son before the police arrest him too!
  - now: Since our last meeting the Rockets haven't suspected I knew anything, and they are still there... out of fear I never handed this over, but now it'll be useful. I just sent the data about the secret base at the casino to the police. Go back quickly and save my son before the police arrest him too!
- quest 8544 talk_questFinishing - 'Did you saved'
  - was: Did you saved my son?
  - now: Did you save my son?

## Brock

- npc/scripts/npcbattle_brock.lua - Verb form 'before receive'
  - was: You must defeat me before receive your reward.
  - now: You must defeat me before receiving your reward.
- npc/scripts/npcbattle_brock.lua - Incomplete 'here is'
  - was: Oh, here is!
  - now: Oh, here it is!
- quest 8456 talk_questStarting - 'in need of a help'
  - was: My brother Forrest is in our house in need of a help. Today I must stay in the gym for long and I do not have time to help him. Would you do that for me?
  - now: My brother Forrest is at our house and needs help. Today I must stay at the gym for a long time and don't have time to help him. Would you do that for me?
- quest 8456 talk_questFinishFail - Typo 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.
- quest 8663 talk_questFinishFail - Unnatural 'Looks like no'
  - was: Looks like no.
  - now: Looks like you didn't.

## Brockling Cindy

- message_greet - Stray punctuation
  - was: Hiho! How are you?.
  - now: Hiho! How are you?

## Brockling Forrest

- quest 8457 talk_questStarting - 'Did Brock sent'
  - was: Did Brock sent you?
  - now: Did Brock send you?
- quest 8457 talk_questStarted - Broken grammar
  - was: That's great. I'm kinda ill today... coff, coff... and some of my brothers are needing help. I'll tell what to do. Okay? First helps Salvadore. He is the eldest after me... you'll know who it is.
  - now: That's great. I'm kinda ill today... coff, coff... and some of my brothers need help. I'll tell you what to do. Okay? First, help Salvadore. He is the eldest after me... you'll know who he is.
- quest 8457 talk_questFinishing - 'Did you helped'
  - was: Did you helped my brothers?
  - now: Did you help my brothers?
- quest 8457 talk_questFinished - Missing 'to'
  - was: Thank you for helping us today. We hope we have not caused many problems. When you want to prepare your Onigiri, talk Salvadore. He will sell you the sauce. It is a great alternative to regenerate your Pokemon. Tell Brock about what happened here today.
  - now: Thank you for helping us today. We hope we didn't cause too many problems. When you want to prepare your Onigiri, talk to Salvadore. He will sell you the sauce. It's a great way to restore your Pokemon. Tell Brock about what happened here today.
- quest 8457 talk_questFinishFail - Typo 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.

## Brockling Salvadore

- quest 8458 talk_questStarting - Question ends with period
  - was: Can you help me with the food for today.
  - now: Can you help me with the food for today?
- quest 8458 talk_questStarted - Missing object
  - was: We need to prepare 40 cooked onigiri. Now take this sauce and place on them.
  - now: We need to prepare 40 cooked onigiri. Now take this sauce and put it on them.
- quest 8458 talk_questFinished - Garbled grammar
  - was: Great. Now take to the stove and serve two for each brother. The left over you can stay as they are great for regaining energy.
  - now: Great. Now take them to the stove and serve two to each brother. You can keep the leftovers, they're great for regaining energy.
- quest 8458 talk_questFinishFail - Typo 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.
- quest 8459 talk_questFinished - 'the my father Golem' broken
  - was: Phew, what a job... go see my sister Yolanda. She said something about the my father Golem.
  - now: Phew, what a job... go see my sister Yolanda. She said something about my father's Golem.
- quest 8508 talk_questStarting - Missing 'do'
  - was: Hey, you want to buy a sauce for Onigiri?
  - now: Hey, do you want to buy a sauce for Onigiri?

## Brockling Timmy

- quest 8461 talk_questStarting - Garbled grammar
  - was: Our toy is in the basement and we forget that our brother Brock's Zubat is sleeping right now. He does not like being woken up and we're afraid. Can you take for us?
  - now: Our toy is in the basement and we forgot that our brother Brock's Zubat is sleeping right now. He doesn't like being woken up and we're afraid. Can you get it for us?
- quest 8461 talk_questStarted - Pronoun he/she mismatch
  - was: Thank you. Be careful not to make noise there. He becomes a beast when she wakes up!
  - now: Thank you. Be careful not to make noise there. He becomes a beast when he wakes up!
- quest 8461 talk_questFinishing - Broken question
  - was: You got the toy?
  - now: Did you get the toy?
- quest 8461 talk_questFinishFail - Typo 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.

## Brockling Yolanda

- quest 8460 talk_questStarting - Broken question word order
  - was: You can help me take care of my father's Golem?
  - now: Can you help me take care of my father's Golem?
- quest 8460 talk_questStarted - Garbled, unclear instructions
  - was: My father went to find my mother in another town and left his old friend to rest here. Go to him and deliver this nugget that he loves. Then use this tool to polish the ends to let him faster in the battle. And lastly fill his pot of food with it.
  - now: My father went to meet my mother in another town and left his old friend to rest here. Go to him and give him this nugget he loves. Then use this tool to polish his edges so he's faster in battle. And lastly, fill his food pot with it.
- quest 8460 talk_questFinishing - 'Did you helped'
  - was: Did you helped my friend?
  - now: Did you help my friend?
- quest 8460 talk_questFinishFail - Typo 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.

## Bronson

- message_greet - Missing 'Do'
  - was: You think you can deal with such power? It's not like surfing or skiing...
  - now: Do you think you can handle such power? It's not like surfing or skiing...

## Bud Jude

- npc/scripts/quest_budJude.lua - Missing 'will'
  - was: Oh, thanks. Take the key with you, maybe one day you find what you need.
  - now: Oh, thanks. Take the key with you, maybe one day you'll find what you need.

## Caelan Thorley

- message_greet - Garbled 'Well keep your money'
  - was: Well keep your money. Trust us! Your options are: {balance}, {deposit}, {deposit all}, {withdraw}, {withdraw all} and {transfer}.
  - now: We keep your money well. Trust us! Your options are: {balance}, {deposit}, {deposit all}, {withdraw}, {withdraw all} and {transfer}.

## Cairo

- message_greet - 'let's trade...?' awkward
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, shall we trade your soul coins?

## Captain Abraham Crofton

- message_greet - 'where to flow'; missing 'do'
  - was: The city has a lot of things. Enjoy everything and travel a lot. Trovitopolis! Where you want to go? If you don't know where to flow, say {travel}.
  - now: The city has a lot to offer. Enjoy everything and travel a lot. Trovitopolis! Where do you want to go? If you don't know where to sail, say {travel}.

## Captain Crispian Osborne

- message_greet - Garbled; 'where to flow'
  - was: Do not go getting sick comrade, or will clear the decks! If you don't know where to flow, say {travel}.
  - now: Don't go getting sick, comrade, or you'll be swabbing the decks! If you don't know where to sail, say {travel}.

## Captain Elliot Kaden

- message_greet - Garbled, incomprehensible
  - was: The sun strengthens those who live on the sea. Our headquarters is great bravery. And it has a sailor stretching members... good guy. Where you want to go? If you don't know where to flow, say {travel}.
  - now: The sun strengthens those who live on the sea. Our crew is full of bravery. And we have a sailor who stretches members... good guy. Where do you want to go? If you don't know where to sail, say {travel}.

## Captain Elton Frank

- message_greet - 'His eyes'; garbled
  - was: Yoo friend! His eyes overflow thirst for adventure! Boarding and let's go! If you don't know where to flow, say {travel}.
  - now: Yoo friend! Your eyes overflow with thirst for adventure! Climb aboard and let's go! If you don't know where to sail, say {travel}.

## Captain Evelyn Scottie

- message_greet - 'where to flow' wrong word
  - was: Hello matey, what you looking at my quarters? If you don't know where to flow, say {travel}.
  - now: Hello matey, what you lookin' at in my quarters? If you don't know where to sail, say {travel}.

## Captain Hamilton Justice

- message_greet - Garbled 'Justice of honored'
  - was: Justice of honored. Justice to the brave. Justice is my motto, my pride sailor. Where are you going? If you don't know where to flow, say {travel}.
  - now: Justice for the honored. Justice for the brave. Justice is my motto, my pride, sailor. Where are you going? If you don't know where to sail, say {travel}.

## Captain Herman Gerry

- message_greet - Word order; 'where to flow'
  - was: Here in Cinnabar much we respect the fire. But we captains fear the sea. What is your destination? If you don't know where to flow, say {travel}.
  - now: Here in Cinnabar we greatly respect fire. But we captains fear the sea. What is your destination? If you don't know where to sail, say {travel}.

## Captain Jefferson Wilson

- message_greet - 'where to flow' wrong word
  - was: Hello matey, what you looking at my quarters? If you don't know where to flow, say {travel}.
  - now: Hello matey, what you lookin' at in my quarters? If you don't know where to sail, say {travel}.

## Captain Jim Denzil

- message_greet - Garbled 'You will already?!'
  - was: Hello buddy! Since I came to this island I can not leave. You will already?! Tangelo is wonderful. If you don't know where to flow, say {travel}.
  - now: Hello buddy! Since I came to this island I can't leave. Leaving already?! Tangelo is wonderful. If you don't know where to sail, say {travel}.

## Captain Lennie Leyton

- message_greet - Word order; 'where to flow'
  - was: Ascorbia is not beautiful? Want to travel? Pay! If you don't know where to flow, say {travel}.
  - now: Isn't Ascorbia beautiful? Want to travel? Pay! If you don't know where to sail, say {travel}.

## Captain Lincoln Joey

- message_greet - Garbled; 'where to flow'
  - was: It's sad life. It's sad the sea... this reminds me of my wife. She was devoured by the sea. What is your destination? If you don't know where to flow, say {travel}.
  - now: It's a sad life. The sea is sad... it reminds me of my wife. She was swallowed by the sea. What is your destination? If you don't know where to sail, say {travel}.

## Captain Mackenzie Duke

- message_greet - 'where to flow' wrong word
  - was: Duke is my name |PLAYERNAME|. Remember this name! I'll take you safely across the seas. What is your destination? If you don't know where to flow, say {travel}.
  - now: Duke is my name, |PLAYERNAME|. Remember this name! I'll take you safely across the seas. What is your destination? If you don't know where to sail, say {travel}.

## Captain Neil Pace

- message_greet - 'where to flow' wrong word
  - was: Hello matey, what you looking at my quarters? If you don't know where to flow, say {travel}.
  - now: Hello matey, what you lookin' at in my quarters? If you don't know where to sail, say {travel}.
- quest 8433 talk_questStarting - Broken tense/grammar
  - was: Aha! You're the new recruit! We were waiting for you. Before I tell the place where you will sleep and handed the broom to clean the boat, you must show confidence in front of the entire crew. Can you do that?
  - now: Aha! You're the new recruit! We were waiting for you. Before I show you where you'll sleep and hand you the broom to clean the ship, you must prove yourself in front of the entire crew. Can you do that?
- quest 8433 talk_questStarted - Wrong preposition
  - was: Go and prove your worth against my sailors. Defeat them all and then you will have your place in our ship!
  - now: Go and prove your worth against my sailors. Defeat them all and then you will have your place on our ship!
- quest 8433 talk_questFinishing - Broken question
  - was: You defeated all our brave and valiant sailors?
  - now: Did you defeat all our brave and valiant sailors?
- quest 8433 talk_questFinishFail - Typo 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.
- quest 8435 talk_questStarted - Garbled, unclear instructions
  - was: They fled with the ship ignition key, talk to First Mate and to see where they go! Please go fast!
  - now: They fled with the ship's ignition key! Talk to the First Mate to find out where they went! Please hurry!
- quest 8435 talk_questFinishing - Broken question
  - was: You recovered the ignition key?
  - now: Did you recover the ignition key?
- quest 8435 talk_questFinished - Garbled grammar
  - was: You did a very good thing my lad. Sorry to confuse you with a Recruiter for our craft. You were a true hero today, deserves to be rewarded. Oh, I had forgotten... upstairs you will find my trunk with a reward. Make good use, you will have our eternal gratitude! Damn Rockets! I do not know what they wanted with my ship. I recently heard rumors that there is a secret facility at Celadon.
  - now: You did a very good thing, my lad. Sorry for mistaking you for a recruit for our ship. You were a true hero today and deserve to be rewarded. Oh, I almost forgot... upstairs you will find my trunk with a reward. Make good use of it, you have our eternal gratitude! Damn Rockets! I don't know what they wanted with my ship. I recently heard rumors of a secret facility in Celadon.

## Captain Sean Brand

- message_greet - 'where to flow' wrong word
  - was: Hello matey, what you looking at my quarters? If you don't know where to flow, say {travel}.
  - now: Hello matey, what you lookin' at in my quarters? If you don't know where to sail, say {travel}.

## Captain Stanley Brent

- message_greet - 'where to flow' wrong word
  - was: Hello matey, what you looking at my quarters? If you don't know where to flow, say {travel}.
  - now: Hello matey, what you lookin' at in my quarters? If you don't know where to sail, say {travel}.

## Captain Tristen Coby

- message_greet - 'where to flow' wrong word
  - was: Hello matey, what you looking at my quarters? If you don't know where to flow, say {travel}.
  - now: Hello matey, what you lookin' at in my quarters? If you don't know where to sail, say {travel}.

## Carlisle

- message_greet - 'let's trade...?' awkward
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, shall we trade your soul coins?

## Carlton

- message_greet - Missing 'Do'
  - was: Hello |PLAYERNAME|. You know the {POKEMON DAYCARE}?
  - now: Hello |PLAYERNAME|. Do you know about the {POKEMON DAYCARE}?

## Catherin Dana

- message_greet - Misspelling Technichal; apostrophe
  - was: Hello |PLAYERNAME|. Do you want to sell Technichal Machines? Here you can also {remove} or {change} your Pokemon TM's!
  - now: Hello |PLAYERNAME|. Do you want to sell Technical Machines? Here you can also {remove} or {change} your Pokemon TMs!

## Cayl

- message_greet - Missing 'for'
  - was: Watch out the skies and sand. And be quick man!
  - now: Watch out for the skies and sand. And be quick, man!
- quest 8102 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is catch 2 Pidgey and bring them to me.
  - now: Thanks! Your task is to catch 2 Pidgey and bring them to me.
- quest 8102 talk_questFinishing - Broken question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8103 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is catch 2 Spearow and bring them to me.
  - now: Thanks! Your task is to catch 2 Spearow and bring them to me.
- quest 8104 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is catch 3 Zubat and bring them to me.
  - now: Thanks! Your task is to catch 3 Zubat and bring them to me.

## Ceazar

- message_greet - 'used to do' should be 'doing'
  - was: You are not used to do any exercise, right? You're so skinny, dude!
  - now: You're not used to doing any exercise, right? You're so skinny, dude!

## Charity

- quest 8220 talk_questStarting - Wrong word 'polymerize'; grammar
  - was: You're so beautf... I mean you can do me a personal favor? I always wanted a Sunkern to help me polymerize our lands, can you catch one for me?
  - now: You're so beautif... I mean, can you do me a personal favor? I always wanted a Sunkern to help me fertilize our lands, can you catch one for me?
- quest 8220 talk_questFinishing - 'one Sunkern' awkward
  - was: Did you catch one Sunkern for me?
  - now: Did you catch a Sunkern for me?
- quest 8220 talk_questFinished - 'such a beautiful' broken
  - was: Thank you! You're such a beautiful! Go see my other sisters!
  - now: Thank you! You're so beautiful! Go see my other sisters!

## Charley Aden

- quest 8552 talk_questStarting - Garbled; 'she' for ball
  - was: Do you want to know about the Master Ball? I am responsible for its creation, but unfortunately team rocket took possession of the single prototype, but quickly destroy all the research and hid until she was safe.
  - now: Do you want to know about the Master Ball? I am responsible for its creation, but unfortunately Team Rocket took the only prototype, quickly destroyed all the research and hid it away somewhere safe.
- quest 8552 talk_questStarted - Garbled, near-gibberish
  - was: I can create try to create another prototype, but do not guarantee it will work, the Master Ball is extremely complex. To create-there is necessary money in the Silph Cop. we have, as you know team rocket caused us many problems, you could {help} us with 130k?
  - now: I can try to create another prototype, but I can't guarantee it will work, the Master Ball is extremely complex. Creating it takes money we don't have at Silph Co.; as you know, Team Rocket caused us many problems. Could you {help} us with 130k?
- quest 8552 talk_questFinishing - Unclear question
  - was: You will help us with the prototype?
  - now: Will you help us fund the prototype?
- quest 8552 talk_questFinishFail - Typo 'Likes no'
  - was: Likes no.
  - now: Looks like you won't.
- quest 8553 talk_questFinished - 'Here is'; 'greet Bill'
  - was: Here is, good luck trying to stop the team rocket. Please greet Bill for me.
  - now: Here it is, good luck trying to stop Team Rocket. Please say hello to Bill for me.

## Charlotte

- message_greet - Missing 'do'
  - was: Hello! What you know about {berries}? They have an amazing rejuvenating power.
  - now: Hello! What do you know about {berries}? They have an amazing rejuvenating power.

## Chester Shayne

- message_greet - Word order
  - was: Hello |PLAYERNAME|. You can buy here all the necessary equipment to start planting your Pokemon berries.
  - now: Hello |PLAYERNAME|. Here you can buy all the equipment you need to start planting your Pokemon berries.

## Chewba

- quest 8447 talk_questStarting - Broken question
  - was: Hey, Rick sent you?
  - now: Hey, did Rick send you?
- quest 8447 talk_questStarted - 'They are eight' Portuguese-ism
  - was: I need you to plant these berries for me. They are eight. Go to the ground outside my house and use the tools there.
  - now: I need you to plant these berries for me. There are eight of them. Go to the ground outside my house and use the tools there.
- quest 8447 talk_questFinishing - Broken question grammar
  - was: Hah do you already plant all?!
  - now: Hah, did you already plant them all?!
- quest 8447 talk_questFinished - Garbled 'Rick goes like this'
  - was: Thank you, Rick goes like this.
  - now: Thank you, Rick will like this.
- quest 8447 talk_questFinishFail - Typo 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.

## Chief Piloswine

- message_greet - Broken question grammar
  - was: Hey |PLAYERNAME|, it is hot? This desert is getting worse.
  - now: Hey |PLAYERNAME|, is it hot? This desert is getting worse.
- npc/scripts/quest_chiefPiloswine.lua - Garbled 'You know what I mean'
  - was: By the beard PILOSS of the King! You know SWINEE what I mean! What brings you here?
  - now: By the PILOSS beard of the King! You know SWINEE what I mean! What brings you here?
- npc/scripts/quest_chiefPiloswine.lua - Broken question
  - was: What do you LOSSWI want with that damn stone? You want to do something with it? Think about PILOSWINEEE it in your reply!
  - now: What do you LOSSWI want with that damn stone? Do you want to do something with it? Think about PILOSWINEEE your answer!
- npc/scripts/quest_chiefPiloswine.lua - Garbled grammar
  - was: You want to help PILOSS strengthen the protection of stone? First then you have to pick one of the {Restore} Stones that resides in this mountain. We Pokemon PILOSSW could not get near it because reverberate too much negative energy, then maybe you can.
  - now: You want to help PILOSS strengthen the stone's protection? Then first you have to get one of the {Restore} Stones that lie in this mountain. We Pokemon PILOSSW can't get near it because it gives off too much negative energy, but maybe you can.
- npc/scripts/quest_chiefPiloswine.lua - 'She' for stone
  - was: She sits WINEE on one of the lower PILLL floors. Good luck.
  - now: It sits WINEE on one of the lower PILLL floors. Good luck.
- npc/scripts/quest_chiefPiloswine.lua - Unclear sentence
  - was: You are insistent, PILOSS you will not {understand} WINEE me...
  - now: You are insistent, PILOSS but you will not {understand} WINEE me...
- npc/scripts/quest_chiefPiloswine.lua - Awkward phrasing
  - was: The first human PILLS to visit us! It would be wasting my time WINEEE trying to communicate with you...
  - now: The first human PILLS to visit us! But it would be a waste of my time WINEEE trying to talk with you...

## Chief Skarmory

- message_greet - Broken question grammar
  - was: Hey |PLAYERNAME|, it is hot? This desert is getting worse.
  - now: Hey |PLAYERNAME|, is it hot? This desert is getting worse.
- npc/scripts/quest_chiefSkarmory.lua - Garbled grammar
  - was: Are you saying that this MORRYY device makes us understand? Impressive. You could... wants to help strengthen the {Deepsoul Stone}?
  - now: Are you saying that this MORRYY device lets us understand each other? Impressive. Would you... want to help strengthen the {Deepsoul Stone}?
- npc/scripts/quest_chiefSkarmory.lua - Awkward; 'have her'
  - was: So grab the Restore Stone residing at sea, SKARRM protected by my guardian. You have to prove your worth to have her. Good luck...
  - now: Then go get the Restore Stone at sea, SKARRM protected by my guardian. You have to prove your worth to claim it. Good luck...

## Chief Vaporeon

- message_greet - Broken question grammar
  - was: Hey |PLAYERNAME|, it is hot? This desert is getting worse.
  - now: Hey |PLAYERNAME|, is it hot? This desert is getting worse.
- npc/scripts/quest_chiefVaporeon.lua - 'tribe reviewer' wrong word
  - was: This is PPOREN amazing! And VAAPP what brings you to VAPOREONN our tribe reviewer?
  - now: This is PPOREN amazing! And VAAPP what brings you to VAPOREONN our tribe, visitor?
- npc/scripts/quest_chiefVaporeon.lua - Garbled grammar
  - was: You would not dare VAPP go after this REONN evil thing! I will not VAPPP allow! Our king has sacrificed VAPOREONN for it. You want to use it for evil?
  - now: Don't you dare VAPP go after this REONN evil thing! I will not VAPPP allow it! Our king sacrificed himself VAPOREONN for it. Do you want to use it for evil?
- npc/scripts/quest_chiefVaporeon.lua - Unneeded articles before islands
  - was: You can find the Mountain Tribe at the Kumquat Island and the Sky Tribe at the Fairchild Island.
  - now: You can find the Mountain Tribe on Kumquat Island and the Sky Tribe on Fairchild Island.
- npc/scripts/quest_chiefVaporeon.lua - Broken question word order
  - was: A human! Speaking with me! You can understand me? VAPOREONN
  - now: A human! Speaking with me! Can you understand me? VAPOREONN
- quest 8243 talk_questStarting - 'she'/'their' unclear; grammar
  - was: We know she is weakening VAPPPOR and we are thinking of a way VAPPORE to strengthen their protection. While... you could help us! Do you agree?
  - now: We know the stone is weakening VAPPPOR and we are thinking of a way VAPPORE to strengthen its protection. Meanwhile... you could help us! Do you agree?
- quest 8243 talk_questStarted - Garbled, unclear instructions
  - was: Great. We need two other Stones called Restore Stones. VAPOREONN They will help distribute the evil that supports Deepsoul Stone. Go talk to the other VAPPOR two {Chief}'s and know where are Restore Stones. Get back here later.
  - now: Great. We need two other Stones called Restore Stones. VAPOREONN They will help disperse the evil that weighs on the Deepsoul Stone. Go talk to the other VAPPOR two {Chief}'s and find out where the Restore Stones are. Come back here later.
- quest 8243 talk_questFinishing - Broken question
  - was: You get REONN the Restore Stones?
  - now: Did you get REONN the Restore Stones?

## Chris Chrissie

- message_greet - 'exchange into' wrong
  - was: Welcome to the Avalanche Mastery! Here you can exchange your avalanche tokens into rewards. Type {options} to see.
  - now: Welcome to the Avalanche Mastery! Here you can exchange your avalanche tokens for rewards. Type {options} to see.

## Christian Tone

- message_greet - Wrong preposition
  - was: Will you survive seven days into the ocean?
  - now: Will you survive seven days on the ocean?

## Clayton Bibeau

- message_greet - Garbled 'spores numb'
  - was: Beware of spores numb! My Bulbasaur will leave you caught!
  - now: Beware of my numbing spores! My Bulbasaur will leave you paralyzed!

## Clayton Giltner

- message_greet - Garbled phrasing
  - was: The beam comes where least expected Boy! Hahaha!
  - now: The beam comes when you least expect it, boy! Hahaha!

## Clemency Pamela

- message_greet - Broken question word order
  - was: Poke Balls are not amazing?
  - now: Aren't Poke Balls amazing?

## Cletis

- message_greet - Missing 'Do'
  - was: Hello |PLAYERNAME|. You know the {TMS} or {VITAMINS}?
  - now: Hello |PLAYERNAME|. Do you know about {TMS} or {VITAMINS}?

## Clinton Dahlke

- message_greet - Broken grammar
  - was: It's beautiful control your entire brain, no?
  - now: Isn't it beautiful to control your entire brain?

## Clinton Elton

- message_greet - Garbled grammar
  - was: Our strength is underestimated, but are the fool who do this.
  - now: Our strength is underestimated, but only fools do that.

## Clinton Gautreaux

- message_greet - Unclear 'endure Sabrina'
  - was: You will not endure Sabrina inside your head.
  - now: You won't be able to stand Sabrina inside your head.

## Clinton Shuttleworth

- message_greet - Awkward phrasing
  - was: You will feel that the poison is an evil which you will not get rid of.
  - now: You will feel that poison is an evil you can't get rid of.

## Coby Fallon

- message_greet - 'exchange into' wrong
  - was: Welcome to the Zen Mastery! Here you can exchange your zen tokens into rewards. Type {options} to see.
  - now: Welcome to the Zen Mastery! Here you can exchange your zen tokens for rewards. Type {options} to see.

## Cody Tschida

- message_greet - Awkward 'not ever...with'
  - was: You will not ever wake up with my spores!
  - now: You will never wake up from my spores!

## Cohen Dacre

- message_greet - 'So' should be 'Then'
  - was: Hello |PLAYERNAME|. Thirsty? So you came to the right place.
  - now: Hello |PLAYERNAME|. Thirsty? Then you came to the right place.

## Conner Wilfrid

- message_greet - Awkward word order
  - was: Hello |PLAYERNAME|. You can buy here all the necessary equipment to start planting your Pokemon berries.
  - now: Hello |PLAYERNAME|. Here you can buy all the equipment you need to start planting your Pokemon berries.

## Corey

- quest 8660 talk_questStarting - Unclear quest offer, no request
  - was: Nooo! My Pokemon!
  - now: Nooo! My Pokemon! Someone took them! Will you help me?
- quest 8660 talk_questStarted - Our vs my inconsistency
  - was: Can you help me get my Pokemon?
  - now: Can you help me get my Pokemon back?
- quest 8660 talk_questFinishing - Our vs my inconsistency
  - was: Did you find our Pokemon?
  - now: Did you find my Pokemon?
- quest 8660 talk_questFinishFail - Unnatural phrase
  - was: Looks like no.
  - now: Looks like you didn't.

## Coy

- message_greet - Missing 'to'
  - was: I need train! I'm busy!
  - now: I need to train! I'm busy!

## Cree

- message_greet - Awkward question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, shall we trade your soul coins?

## Curt Raeburn

- message_greet - Misspelling; awkward phrasing
  - was: Hello |PLAYERNAME|. Do you want to sell Technichal Machines? Here you can also {remove} or {change} your Pokemon TM's!
  - now: Hello |PLAYERNAME|. Do you want to sell Technical Machines? Here you can also {remove} or {change} your Pokemon's TMs!

## Curtis

- message_greet - Awkward question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, shall we trade your soul coins?

## Curtis Sacheverell

- quest 8246 talk_questStarting - Missing auxiliary
  - was: Hey, you got something for me?
  - now: Hey, have you got something for me?
- quest 8246 talk_questFinished - Missing subject; unclear 'him'
  - was: Thanks buddy, was waiting for them. Give him this letter please.
  - now: Thanks buddy, I was waiting for them. Please give Gord Scottie this letter.

## Cyrus Egbert

- message_greet - Missing subject
  - was: Are you hungry my friend? Wait... make a hotdog for you!
  - now: Are you hungry, my friend? Wait... I'll make a hotdog for you!

## Daisy Oak

- quest 8411 talk_questStarting - Broken grammar
  - was: I take care of Pokemon emotional with some treatments, how did you've discovered?
  - now: I treat Pokemon's emotional problems with special treatments. How did you find out about me?
- quest 8411 talk_questStarted - Broken grammar; unclear
  - was: Oh yes, the Pokemon feels tight within the reserve and end up getting stressed. I'll see what I can do. I was going to see my brother Gary, he called me with a look of concern. You can check it for me while I go to the lab? Please back here after talking with him. He is at Viridian City.
  - now: Oh yes, the Pokemon feel cramped in the reserve and end up stressed. I'll see what I can do. I was going to see my brother Gary; he called me sounding worried. Can you check on him while I go to the lab? Please come back after talking to him. He is in Viridian City.
- quest 8411 talk_questFinishing - Awkward question
  - was: I see that you returned. News from my brother?
  - now: I see you're back. Any news from my brother?
- quest 8411 talk_questFinished - Broken grammar
  - was: Hmmm... His suspicions were confirmed. We are facing something bigger than we imagined. Be sure to help my brother. I need that you take an herb on the {mountain} for me, so I can make some Pokemon tea.
  - now: Hmmm... His suspicions were confirmed. We are facing something bigger than we imagined. Be sure to help my brother. I need you to get an herb from the {mountain} for me, so I can make some Pokemon tea.
- quest 8411 talk_questFinishFail - Nonsense phrase
  - was: Likes no.
  - now: Looks like you didn't.
- quest 8412 talk_questStarting - Broken grammar
  - was: I need that you take an herb on the mountain for me, so I can make some Pokemon tea.
  - now: I need you to get an herb from the mountain for me, so I can make some Pokemon tea.
- quest 8412 talk_questStarted - 'She' for a plant; awkward
  - was: She has a powerful sedative. Take this knife. Use it in the plant and return with a piece for me.
  - now: It has a powerful sedative. Take this knife, use it on the plant and bring me back a piece.
- quest 8412 talk_questFinishing - Broken grammar
  - was: Did you got the plant extraction?
  - now: Did you get the plant extract?
- quest 8412 talk_questFinished - Broken grammar
  - was: Great, talk to Assistant Guyli that I am already on the way. Thanks for all your help.
  - now: Great, tell Assistant Guyli that I'm already on my way. Thanks for all your help.

## Dale Clay

- message_greet - Awkward phrasing
  - was: Burger Krabby is only here! True!
  - now: Burger Krabby is only found here! It's true!

## Darion Clive

- quest 8396 talk_questStarting - Awkward phrasing
  - was: Seems to me that you already proved your worth in our club. I propose you a new challenge, something really special. What do you think?
  - now: It seems you've already proven your worth in our club. I have a new challenge for you, something really special. What do you think?
- quest 8396 talk_questStarted - Unclear, awkward
  - was: There is a passage over that tile. Go there and follow the instructions of the dungeon. I'll be here waiting for your news.
  - now: There is a passage on that tile. Go through it and follow the dungeon's instructions. I'll wait here for your news.
- quest 8396 talk_questFinishing - Broken grammar
  - was: Did you finished the dungeon?
  - now: Did you finish the dungeon?

## Darius Chas

- message_greet - Subject-verb agreement
  - was: Pokemon Center do not charge to heal your Pokemon, you know?
  - now: The Pokemon Center doesn't charge to heal your Pokemon, you know?

## Darrian

- message_greet - Missing auxiliary
  - was: What you want?
  - now: What do you want?

## Darus

- npc/scripts/mastery_avalanche.lua - Unnatural 'join into'
  - was: Do you want to join into the %s Mastery?
  - now: Do you want to join the %s Mastery?
- npc/scripts/mastery_avalanche.lua - Broken grammar
  - was: You already has a mastery, if you want to join here first you need to dismiss with your mastery leader.
  - now: You already have a mastery. If you want to join this one, you first need to leave it by talking to your mastery leader.
- npc/scripts/mastery_avalanche.lua - Wrong preposition
  - was: Are you ready to the next level?
  - now: Are you ready for the next level?
- npc/scripts/mastery_avalanche.lua - Wrong preposition
  - was: Are you ready to the dungeon?
  - now: Are you ready for the dungeon?
- npc/scripts/mastery_avalanche.lua - Unclear 'dismiss with'
  - was: You need to dismiss with your mastery leader, not here.
  - now: You need to leave through your own mastery leader, not here.
- npc/scripts/mastery_avalanche.lua - Awkward phrasing
  - was: Your account must be with the premium days to join here.
  - now: Your account must have premium days to join here.
- npc/scripts/mastery_avalanche.lua - Unnatural 'join into'
  - was: Do you really want to join into the %s Mastery?
  - now: Do you really want to join the %s Mastery?
- npc/scripts/mastery_avalanche.lua - 'Win' instead of 'beat'
  - was: You have already paid the necessary plates, now you need to win my assistant %s.
  - now: You have already paid the necessary plates, now you need to defeat my assistant %s.
- npc/scripts/mastery_avalanche.lua - Broken grammar
  - was: To join into %s Mastery you will need %s. You're with them?
  - now: To join the %s Mastery you will need %s. Do you have them?
- npc/scripts/mastery_avalanche.lua - Awkward 'win a battle with'
  - was: To complete your initiation, you must win a battle with my assistant %s.
  - now: To complete your initiation, you must win a battle against my assistant %s.
- npc/scripts/mastery_avalanche.lua - Broken grammar
  - was: You do not have the necessary plates, come back here when you're with them. Remember that you must achieve %s points through our element plates.
  - now: You do not have the necessary plates, come back when you have them. Remember that you must reach %s points with our element plates.
- npc/scripts/mastery_avalanche.lua - 'Win the dungeon' unnatural
  - was: You have already paid the necessary tokens, now you need to win the {dungeon}.
  - now: You have already paid the necessary tokens, now you need to complete the {dungeon}.
- npc/scripts/mastery_avalanche.lua - Broken grammar, confusing
  - was: To advance in rank within the Mastery you need to prove that you're dominating it, joining %s tokens, you can get them by completing missions with the inhabitants of this base. You are already with the %s %s tokens?
  - now: To advance in rank within the Mastery you must prove you've mastered it by collecting %s tokens. You can get them by completing missions for the people of this base. Do you have the %s %s tokens?
- npc/scripts/mastery_avalanche.lua - Awkward 'make the dungeon'
  - was: Now you're ready to make the {dungeon} and prove that you are able to advance. When you are ready come talk to me.
  - now: Now you're ready to do the {dungeon} and prove you are able to advance. When you are ready, come talk to me.
- npc/scripts/mastery_avalanche.lua - Broken grammar
  - was: You do not have the necessary tokens, come back here when you're with them.
  - now: You do not have the necessary tokens, come back when you have them.
- npc/scripts/mastery_avalanche.lua - Broken grammar
  - was: Before to this dungeon you need pay the necessary tokens.
  - now: Before entering this dungeon you need to pay the necessary tokens.
- npc/scripts/mastery_avalanche.lua - Misspelling
  - was: There is no dungeon avaiable, please try again later.
  - now: There is no dungeon available, please try again later.
- npc/scripts/mastery_avalanche.lua - Unclear phrasing
  - was: You can only enter the dungeon carrying Pokemon with Mastery %s types and without Ditto!
  - now: You can only enter the dungeon carrying Pokemon of the %s Mastery types, and no Ditto!

## Dax

- npc/scripts/mastery_gaia.lua - 'join into' unnatural
  - was: Do you want to join into the %s Mastery?
  - now: Do you want to join the %s Mastery?
- npc/scripts/mastery_gaia.lua - Grammar: 'has'; 'dismiss with'
  - was: You already has a mastery, if you want to join here first you need to dismiss with your mastery leader.
  - now: You already have a mastery. If you want to join here, you first need to leave it with your mastery leader.
- npc/scripts/mastery_gaia.lua - Wrong preposition
  - was: Are you ready to the next level?
  - now: Are you ready for the next level?
- npc/scripts/mastery_gaia.lua - Wrong preposition
  - was: Are you ready to the dungeon?
  - now: Are you ready for the dungeon?
- npc/scripts/mastery_gaia.lua - 'dismiss with' unclear
  - was: You need to dismiss with your mastery leader, not here.
  - now: You need to leave your mastery through your own mastery leader, not here.
- npc/scripts/mastery_gaia.lua - Unnatural Portuguese-ism
  - was: Your account must be with the premium days to join here.
  - now: Your account must have premium days to join here.
- npc/scripts/mastery_gaia.lua - 'join into' unnatural
  - was: Do you really want to join into the %s Mastery?
  - now: Do you really want to join the %s Mastery?
- npc/scripts/mastery_gaia.lua - 'win my assistant' wrong
  - was: You have already paid the necessary plates, now you need to win my assistant %s.
  - now: You have already paid the necessary plates, now you need to defeat my assistant %s.
- npc/scripts/mastery_gaia.lua - 'You're with them?' Portuguese-ism
  - was: To join into %s Mastery you will need %s. You're with them?
  - now: To join the %s Mastery you will need %s. Do you have them?
- npc/scripts/mastery_gaia.lua - 'win a battle with' ambiguous
  - was: To complete your initiation, you must win a battle with my assistant %s.
  - now: To complete your initiation, you must win a battle against my assistant %s.
- npc/scripts/mastery_gaia.lua - 'when you're with them' Portuguese-ism
  - was: You do not have the necessary plates, come back here when you're with them. Remember that you must achieve %s points through our element plates.
  - now: You do not have the necessary plates, come back when you have them. Remember that you must reach %s points with our element plates.
- npc/scripts/mastery_gaia.lua - Missing article
  - was: Congratulations! You are now part of %s Mastery! Honor your Mastery!
  - now: Congratulations! You are now part of the %s Mastery! Honor your Mastery!
- npc/scripts/mastery_gaia.lua - Missing article
  - was: Congratulations! You were promoted in %s Mastery!
  - now: Congratulations! You were promoted in the %s Mastery!
- npc/scripts/mastery_gaia.lua - 'win the dungeon' wrong
  - was: You have already paid the necessary tokens, now you need to win the {dungeon}.
  - now: You have already paid the necessary tokens, now you need to complete the {dungeon}.
- npc/scripts/mastery_gaia.lua - Garbled grammar, Portuguese-isms
  - was: To advance in rank within the Mastery you need to prove that you're dominating it, joining %s tokens, you can get them by completing missions with the inhabitants of this base. You are already with the %s %s tokens?
  - now: To advance in rank within the Mastery you need to prove you've mastered it by collecting %s tokens. You can get them by completing missions for the inhabitants of this base. Do you already have the %s %s tokens?
- npc/scripts/mastery_gaia.lua - 'make the dungeon' wrong verb
  - was: Now you're ready to make the {dungeon} and prove that you are able to advance. When you are ready come talk to me.
  - now: Now you're ready to do the {dungeon} and prove that you are able to advance. When you are ready, come talk to me.
- npc/scripts/mastery_gaia.lua - 'when you're with them' Portuguese-ism
  - was: You do not have the necessary tokens, come back here when you're with them.
  - now: You do not have the necessary tokens, come back when you have them.
- npc/scripts/mastery_gaia.lua - Broken grammar
  - was: Before to this dungeon you need pay the necessary tokens.
  - now: Before entering this dungeon you need to pay the necessary tokens.
- npc/scripts/mastery_gaia.lua - Misspelling avaiable
  - was: There is no dungeon avaiable, please try again later.
  - now: There is no dungeon available, please try again later.
- npc/scripts/mastery_gaia.lua - Awkward 'Mastery %s types'
  - was: You can only enter the dungeon carrying Pokemon with Mastery %s types and without Ditto!
  - now: You can only enter the dungeon carrying Pokemon of the %s Mastery types and no Ditto!

## Dax Dane

- message_greet - Word order
  - was: Hello |PLAYERNAME|. How I can help you? Are you hungry or thirsty?
  - now: Hello |PLAYERNAME|. How can I help you? Are you hungry or thirsty?

## Delaney Dinah

- message_greet - Confusing question
  - was: You can wake up and have coffee in the morning? I prefer milk.
  - now: Do you like to wake up and have coffee in the morning? I prefer milk.

## Delia Ketchum

- quest 8418 talk_questStarting - Word order
  - was: Oh, I'm so worried! You and Gary have had any progress?
  - now: Oh, I'm so worried! Have you and Gary made any progress?
- quest 8418 talk_questFinishing - Missing auxiliary
  - was: You read the letter?
  - now: Did you read the letter?
- quest 8418 talk_questFinished - Confusing phrasing
  - was: I'm sure someone got this information. I think Ash has been kidnapped! Gary asked to go see him in Pewter. Please find Ash!
  - now: I'm sure someone got hold of this information. I think Ash has been kidnapped! Gary asked you to go see him in Pewter. Please find Ash!
- quest 8418 talk_questFinishFail - Nonsense phrase
  - was: Likes no.
  - now: Looks like you didn't.
- quest 8377 talk_questStarting - Awkward question
  - was: Are you too busy? I need a big favor!
  - now: Are you very busy? I need a big favor!
- quest 8377 talk_questStarted - Broken grammar
  - was: My Ash need this honey pot to save sick Pokemon, please take it up. You will find him next to the boat S.S. Anne in Vermilion.
  - now: My Ash needs this honey pot to save a sick Pokemon, please take it to him. You will find him next to the S.S. Anne boat in Vermilion.
- quest 8377 talk_questFinishing - Word order
  - was: You could find Ash?
  - now: Did you find Ash?
- quest 8377 talk_questFinishFail - Unnatural phrase
  - was: Looks like no.
  - now: Looks like you didn't.

## Demetrius

- message_greet - Misspelled contraction
  - was: Hold'n a second, gonna get an armor for ya!
  - now: Hold on a second, gonna get an armor for ya!
- quest 8192 talk_questStarting - Awkward phrasing
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8192 talk_questStarted - Missing 'to'; them for one
  - was: Thanks! Your task is catch 1 Sandshrew and bring them to me.
  - now: Thanks! Your task is to catch 1 Sandshrew and bring it to me.
- quest 8192 talk_questFinishing - Word order
  - was: The task is done?
  - now: Is the task done?
- quest 8192 talk_questFinished - Awkward phrasing
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.
- quest 8193 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is catch 2 Diglett and bring them to me.
  - now: Thanks! Your task is to catch 2 Diglett and bring them to me.
- quest 8194 talk_questStarted - Missing 'to'; them for one
  - was: Thanks! Your task is catch 1 Geodude and bring them to me.
  - now: Thanks! Your task is to catch 1 Geodude and bring it to me.
- quest 8195 talk_questStarted - Missing 'to'; them for one
  - was: Thanks! Your task is catch 1 Cubone and bring them to me.
  - now: Thanks! Your task is to catch 1 Cubone and bring it to me.

## Den Quincey

- message_greet - Garbled phrasing
  - was: All protected, security and delivery to envy! Your options are: {balance}, {deposit}, {deposit all}, {withdraw}, {withdraw all} and {transfer}.
  - now: Fully protected, with security and service to envy! Your options are: {balance}, {deposit}, {deposit all}, {withdraw}, {withdraw all} and {transfer}.

## Denis

- message_greet - Word order
  - was: Get out! You did not see the {warnings} at the entrance?
  - now: Get out! Didn't you see the {warnings} at the entrance?
- npc/scripts/quest_denis.lua - Awkward phrasing
  - was: That's right, they are why I do not want company... that day still haunts me. That {monster}!
  - now: That's right, they're why I don't want company... that day still haunts me. That {monster}!
- npc/scripts/quest_denis.lua - Broken grammar
  - was: Tyranitar is his name. I remember when captured in its first form... the Larvitar. So beautiful and so cute... then he turned that bloody thing! And just when we were about to {find} out about that...
  - now: Tyranitar is its name. I remember when I captured it in its first form... Larvitar. So beautiful and so cute... then it turned into that bloody thing! And just when we were about to {find} out about that...
- npc/scripts/quest_denis.lua - Broken grammar
  - was: Yes, yes... we were to discover something, but fear does not help me remember. How about talking to Aleb, he was also there. Get out of here soon, you may be being followed! Go...
  - now: Yes, yes... we were about to discover something, but fear clouds my memory. Try talking to Aleb, he was there too. Get out of here now, you may be followed! Go...

## Deven Rusty

- message_greet - Odd word
  - was: Everything's good here. Clean and harvested by our Pokemon!
  - now: Everything's good here. Cleaned and harvested by our Pokemon!

## Doroty

- quest 8503 talk_questStarted - Minor: seals 'in' balls
  - was: I'll show you how to use seals in Poke Balls. Take this Weedle and this seal. Use the seal on the Poke Ball before releasing your Pokemon and see what happens. Then come back to talk to me.
  - now: I'll show you how to use seals on Poke Balls. Take this Weedle and this seal. Use the seal on the Poke Ball before releasing your Pokemon and see what happens. Then come back and talk to me.
- quest 8503 talk_questFinishing - Broken grammar
  - was: Did attached the seal to the poke ball?
  - now: Did you attach the seal to the Poke Ball?
- quest 8503 talk_questFinished - Misspellings; grammar
  - was: That's right! Now you have learned about the seals. To use TMs, Vitamins and Held Itens in your Pokemon is simple as the seals. Select the desired TM and use at the Poke Ball. There are three types of Poke Balls: Poke Ball, Great Ball and Ultra Ball. These are purchased at any PokeMart. There are other especias balls for decoration and events. There is also the coveted Master Ball... but I must research more about it. Take these Poke Balls to help you.
  - now: That's right! Now you have learned about seals. Using TMs, Vitamins and Held Items on your Pokemon is as simple as seals. Select the desired TM and use it on the Poke Ball. There are three types of Poke Balls: Poke Ball, Great Ball and Ultra Ball. These are sold at any PokeMart. There are other special balls for decoration and events. There is also the coveted Master Ball... but I must research it more. Take these Poke Balls to help you.
- quest 8503 talk_questFinishFail - Nonsense phrase
  - was: Likes no.
  - now: Looks like you didn't.

## Dr. Alan Grant

- message_greet - Awkward phrasing
  - was: Hi |PLAYERNAME|, I like fossils! Aerodactyl is awesome! I heard yesterday some trainers talking about a ship in the depths of the sea, seems to be there a long time.
  - now: Hi |PLAYERNAME|, I like fossils! Aerodactyl is awesome! Yesterday I heard some trainers talking about a ship in the depths of the sea that seems to have been there a long time.
- quest 8383 talk_questStarting - Misspelling Ember for Amber
  - was: Oh MY GOD! You found an Old Ember?
  - now: Oh MY GOD! You found an Old Amber?
- quest 8383 talk_questStarted - Broken grammar
  - was: I'm looking for it for years! Listen, I developed this resynthesizer, with it we can try extract the DNA that is in the Old Amber. Take it, use in the Old Amber and return here once he is 100% charged.
  - now: I've been looking for it for years! Listen, I developed this resynthesizer; with it we can try to extract the DNA in the Old Amber. Take it, use it on the Old Amber and come back once it is 100% charged.
- quest 8383 talk_questFinishing - Word order
  - was: You brought the resynthesizer charged?
  - now: Did you bring the charged resynthesizer?
- quest 8383 talk_questFinishFail - Unnatural phrase
  - was: Looks like no.
  - now: Looks like you didn't.

## Dr. Oravaf

- message_greet - Word order
  - was: Hey |PLAYERNAME|, it is hot? This desert is getting worse.
  - now: Hey |PLAYERNAME|, is it hot for you? This desert is getting worse.
- quest 8332 talk_questStarting - Misspelling Updrager; punctuation
  - was: What? you're saying that the Pokedex Updrager is broken? Never thought it would happen, but do not worry because I'll fix it. I have all the tools necessary for repair.
  - now: What? You're saying the Pokedex Upgrader is broken? Never thought it would happen, but don't worry, I'll fix it. I have all the tools needed for the repair.
- quest 8332 talk_questStarted - Grammar errors
  - was: Well.. this is not a common repair, that machine has a high-tech parts. I'm gonna need you to go to the Power Plant and bring me a Codex Motor, an Energy Transformer and a Bignose Gear. To get these parts you'll scour the machines there. Many of them are ruined, but some machines still have fully functional parts. Good luck!
  - now: Well... this is not a common repair, that machine has high-tech parts. I'm gonna need you to go to the Power Plant and bring me a Codex Motor, an Energy Transformer and a Bignose Gear. To get these parts you'll have to search the machines there. Many of them are ruined, but some still have fully functional parts. Good luck!
- quest 8332 talk_questFinishing - Tense error
  - was: Did you bring what I've asked?
  - now: Did you bring what I asked for?
- quest 8332 talk_questFinished - Awkward phrasing
  - was: Great! Now I'll just need one more task.
  - now: Great! Now I just need you for one more task.
- quest 8333 talk_questStarting - Word order
  - was: You will help me in the last task?
  - now: Will you help me with the last task?
- quest 8333 talk_questStarted - Awkward phrasing
  - was: Bring me an Electrode, I need electricity for repairing the machine.
  - now: Bring me an Electrode, I need electricity to repair the machine.

## Drake

- message_greet - Missing 'for'
  - was: Everything is better with Drake. What are you looking brother?
  - now: Everything is better with Drake. What are you looking for, brother?

## Dreda Roni

- message_greet - Word order
  - was: Hello |PLAYERNAME|. How I can help you? Are you hungry or thirsty?
  - now: Hello |PLAYERNAME|. How can I help you? Are you hungry or thirsty?

## Drew Wisdom

- message_greet - Awkward phrasing
  - was: Hello |PLAYERNAME|! How about skiing? Hahaha! I think you're cold in this {outfit}.
  - now: Hello |PLAYERNAME|! How about skiing? Hahaha! You must be cold in that {outfit}.
- quest 8391 talk_questStarting - Broken grammar
  - was: I've been studying on the ski clothing and finally figure out the best way to be doing this clothing manufacturing. It is not easy making this outfit because it requires time and dedication, but if you bring me the necessary resources I can make one for you.
  - now: I've been studying ski clothing and finally figured out the best way to make it. It's not easy to make this outfit because it takes time and dedication, but if you bring me the necessary resources I can make one for you.
- quest 8391 talk_questStarted - Wrong apostrophes
  - was: First 200 fur's, 30 jynx clothes, 40 frozen heart's and 60 shard's will be needed.
  - now: First, I'll need 200 furs, 30 jynx clothes, 40 frozen hearts and 60 shards.
- quest 8391 talk_questFinishing - Broken grammar; misspelling
  - was: Did you got the itens?
  - now: Did you get the items?
- quest 8392 talk_questStarted - Unclear phrasing
  - was: Ok, you can find my house to the south! Good luck.
  - now: Ok, you'll find my house to the south! Good luck.
- quest 8392 talk_questFinishing - Word order
  - was: You brought the special piece of cloth?
  - now: Did you bring the special piece of cloth?
- quest 8392 talk_questFinished - Awkward phrasing
  - was: Congratulations, you have completed the second part successfully! But before handing over your ski clothing, I need your {help} once again.
  - now: Congratulations, you have completed the second part successfully! But before I hand over your ski clothing, I need your {help} once again.
- quest 8393 talk_questStarting - 'She' for stone; broken grammar
  - was: There is a very rare stone called the ice yolk stone, she is at the end of a large cave and guarded by powerful ice pokemon. If you bring it to me so I will give you the ski clothing.
  - now: There is a very rare stone called the ice yolk stone; it's at the end of a large cave, guarded by powerful ice Pokemon. If you bring it to me, I will give you the ski clothing.
- quest 8393 talk_questStarted - Unclear instruction
  - was: Look for the cave, good luck.
  - now: Look for the large cave with the stone, good luck.
- quest 8393 talk_questFinishing - Word order
  - was: You brought the stone?
  - now: Did you bring the stone?

## Drogo Toby

- npc/scripts/elitefour_enter.lua - Confusing reply
  - was: Yes, yes. Maybe when you get ready.
  - now: No, no. Maybe when you are ready.

## Dusty Kaylyn

- message_greet - Pronoun mismatch
  - was: Hello |PLAYERNAME|! Welcome to our Casino! If you have got some {poke coins} I can exchange it for you.
  - now: Hello |PLAYERNAME|! Welcome to our Casino! If you have some {poke coins} I can exchange them for you.

## Dylan Amos

- message_greet - Awkward word order
  - was: Hello |PLAYERNAME|. You can buy here all the necessary equipment to start planting your Pokemon berries.
  - now: Hello |PLAYERNAME|. Here you can buy all the equipment you need to start planting your Pokemon berries.

## Earnestine Veale

- message_greet - Broken grammar
  - was: The Lt. Surge has been to war, were the electric Pokemon in battle that saved him.
  - now: Lt. Surge has been to war, and it was electric Pokemon that saved him in battle.

## Easton

- message_greet - Awkward question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, shall we trade your soul coins?

## Eddie

- npc/scripts/mastery_heremit.lua - Unnatural 'join into'
  - was: Do you want to join into the %s Mastery?
  - now: Do you want to join the %s Mastery?
- npc/scripts/mastery_heremit.lua - Broken grammar
  - was: You already has a mastery, if you want to join here first you need to dismiss with your mastery leader.
  - now: You already have a mastery. If you want to join this one, you first need to leave it by talking to your mastery leader.
- npc/scripts/mastery_heremit.lua - Wrong preposition
  - was: Are you ready to the next level?
  - now: Are you ready for the next level?
- npc/scripts/mastery_heremit.lua - Wrong preposition
  - was: Are you ready to the dungeon?
  - now: Are you ready for the dungeon?
- npc/scripts/mastery_heremit.lua - Unclear 'dismiss with'
  - was: You need to dismiss with your mastery leader, not here.
  - now: You need to leave through your own mastery leader, not here.
- npc/scripts/mastery_heremit.lua - Awkward phrasing
  - was: Your account must be with the premium days to join here.
  - now: Your account must have premium days to join here.
- npc/scripts/mastery_heremit.lua - Unnatural 'join into'
  - was: Do you really want to join into the %s Mastery?
  - now: Do you really want to join the %s Mastery?
- npc/scripts/mastery_heremit.lua - 'Win' instead of 'beat'
  - was: You have already paid the necessary plates, now you need to win my assistant %s.
  - now: You have already paid the necessary plates, now you need to defeat my assistant %s.
- npc/scripts/mastery_heremit.lua - Broken grammar
  - was: To join into %s Mastery you will need %s. You're with them?
  - now: To join the %s Mastery you will need %s. Do you have them?
- npc/scripts/mastery_heremit.lua - Awkward 'win a battle with'
  - was: To complete your initiation, you must win a battle with my assistant %s.
  - now: To complete your initiation, you must win a battle against my assistant %s.
- npc/scripts/mastery_heremit.lua - Broken grammar
  - was: You do not have the necessary plates, come back here when you're with them. Remember that you must achieve %s points through our element plates.
  - now: You do not have the necessary plates, come back when you have them. Remember that you must reach %s points with our element plates.
- npc/scripts/mastery_heremit.lua - 'Win the dungeon' unnatural
  - was: You have already paid the necessary tokens, now you need to win the {dungeon}.
  - now: You have already paid the necessary tokens, now you need to complete the {dungeon}.
- npc/scripts/mastery_heremit.lua - Broken grammar, confusing
  - was: To advance in rank within the Mastery you need to prove that you're dominating it, joining %s tokens, you can get them by completing missions with the inhabitants of this base. You are already with the %s %s tokens?
  - now: To advance in rank within the Mastery you must prove you've mastered it by collecting %s tokens. You can get them by completing missions for the people of this base. Do you have the %s %s tokens?
- npc/scripts/mastery_heremit.lua - Awkward 'make the dungeon'
  - was: Now you're ready to make the {dungeon} and prove that you are able to advance. When you are ready come talk to me.
  - now: Now you're ready to do the {dungeon} and prove you are able to advance. When you are ready, come talk to me.
- npc/scripts/mastery_heremit.lua - Broken grammar
  - was: You do not have the necessary tokens, come back here when you're with them.
  - now: You do not have the necessary tokens, come back when you have them.
- npc/scripts/mastery_heremit.lua - Broken grammar
  - was: Before to this dungeon you need pay the necessary tokens.
  - now: Before entering this dungeon you need to pay the necessary tokens.
- npc/scripts/mastery_heremit.lua - Misspelling
  - was: There is no dungeon avaiable, please try again later.
  - now: There is no dungeon available, please try again later.
- npc/scripts/mastery_heremit.lua - Unclear phrasing
  - was: You can only enter the dungeon carrying Pokemon with Mastery %s types and without Ditto!
  - now: You can only enter the dungeon carrying Pokemon of the %s Mastery types, and no Ditto!

## Eden

- message_greet - Missing article
  - was: How good it is to feel the breeze in your hair and admire the earth from heights.
  - now: How good it is to feel the breeze in your hair and admire the earth from up high.
- quest 8099 talk_questStarting - Awkward phrasing
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8099 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Magneton.
  - now: Thanks! Your task is to defeat 30 Magneton.
- quest 8099 talk_questFinishing - Word order
  - was: The task is done?
  - now: Is the task done?
- quest 8099 talk_questFinished - Awkward phrasing
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.
- quest 8100 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Electrode.
  - now: Thanks! Your task is to defeat 30 Electrode.
- quest 8101 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 15 Electabuzz.
  - now: Thanks! Your task is to defeat 15 Electabuzz.

## Elihu Jesse

- message_greet - Broken grammar
  - was: Accepts a refreshment my friend? We lemonade and coconut water!
  - now: Would you like a refreshment, my friend? We have lemonade and coconut water!

## Elinor Rameau

- message_greet - Awkward phrasing
  - was: The soil is our home, and our defenses are amazing. You will not pass me by!
  - now: The soil is our home, and our defenses are amazing. You will not get past me!

## Elliot

- message_greet - Awkward question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, shall we trade your soul coins?

## Elwood Marvin

- message_greet - Missing auxiliary
  - was: Hello |PLAYERNAME|, you need something to brighten your home?
  - now: Hello |PLAYERNAME|, do you need something to brighten your home?

## Enzo

- message_greet - Awkward 'the mother nature'
  - was: This school is a message from the mother nature to all of you, are you capable of decrypting it?
  - now: This school is a message from Mother Nature to all of you. Are you capable of decoding it?

## Eric Garinson

- quest 8009 talk_questStarting - Broken grammar, confusing
  - was: My family is very frustrated with me lately because I do not have much talent to be a trainer of Pokemon, they do not know what my dream is another..Then I need some help, what you think?
  - now: My family is very frustrated with me lately because I don't have much talent as a Pokemon trainer; they don't know my dream is something else... So I need some help, what do you think?
- quest 8009 talk_questStarted - Missing 'come'
  - was: Ok, catch a Pidgey and back here.
  - now: Ok, catch a Pidgey and come back here.
- quest 8009 talk_questFinishing - Broken grammar
  - was: You've got what I asked?
  - now: Did you get what I asked for?
- quest 8009 talk_questFinishFail - Broken grammar
  - was: No..You do not have, catch a Pidgey and return here.
  - now: No... You don't have it. Catch a Pidgey and come back here.

## Erik

- message_greet - Awkward question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, shall we trade your soul coins?

## Erika

- message_greet - Misspelling flowing/flower
  - was: ...Oh dear... I must have dozed off. Welcome. My name is Erika. I am the leader of Celadon Gym. I teach the art of flowing arranging. My Pokemon are of the grass-type.
  - now: ...Oh dear... I must have dozed off. Welcome. My name is Erika. I am the leader of Celadon Gym. I teach the art of flower arranging. My Pokemon are of the grass-type.
- npc/scripts/npcbattle_erika.lua - Broken grammar
  - was: You must defeat me before receive your reward.
  - now: You must defeat me before receiving your reward.
- npc/scripts/npcbattle_erika.lua - Broken grammar
  - was: Oh, here is!
  - now: Oh, here it is!
- quest 8472 talk_questStarting - Pronoun mismatch
  - was: My Pokemon are in need of a special juice that I prepare for him to restore their energies. Can you help?
  - now: My Pokemon need a special juice that I prepare to restore their energy. Can you help?
- quest 8472 talk_questStarted - Broken grammar, confusing
  - was: I need you to prepare a berries juice for them. I developed a machine to extract the juice here in the gym. I need you to do 5 juices for me. It is the combination of five berries: Sitrus, Pecha, Leppa, Oran and Chesto. But there is a correct order, and this is my challenge to you. Try to find the correct order and use these flask to collect the juice. He is very special and with this tempered glass it is free of any virus like Pokerus. When performing the right mix, just so get collecting it. Get back to me with 5 full flasks and be careful with them.
  - now: I need you to prepare a berry juice for them. I built a machine in the gym to extract the juice. I need you to make 5 juices for me. It's a combination of five berries: Sitrus, Pecha, Leppa, Oran and Chesto. But there is a correct order, and that is my challenge to you. Find the correct order and use these flasks to collect the juice. It's very special, and this tempered glass keeps it free of any virus like Pokerus. Once you get the mix right, just collect it. Come back to me with 5 full flasks and be careful with them.
- quest 8472 talk_questFinished - Broken grammar
  - was: Very well. This was a beautiful test. Give me 3 bottles and stick with 2. This juice enhances HP and Energy regeneration  of your Pokemon for 30 minutes. Make good use. Take over this for all the work.
  - now: Very well. This was a beautiful test. Give me 3 bottles and keep 2. This juice boosts your Pokemon's HP and Energy regeneration for 30 minutes. Use it well. Take this for all your work.
- quest 8472 talk_questFinishFail - Nonsense phrase
  - was: Likes no.
  - now: Looks like you didn't.

## Ernest Upper

- quest 8262 talk_questStarting - Broken grammar
  - was: Thanks for the concern! My Pokemon lost in the middle of these woods, I need you to find him. I'm tired of yelling, I can't find him. You can do this for me?
  - now: Thanks for your concern! My Pokemon got lost in the middle of these woods and I need you to find him. I'm tired of yelling, I can't find him. Can you do this for me?

## Eugene Oliver

- message_greet - Pronoun mismatch
  - was: Hello |PLAYERNAME|! Welcome to our Casino! If you have got some {poke coins} I can exchange it for you.
  - now: Hello |PLAYERNAME|! Welcome to our Casino! If you have some {poke coins} I can exchange them for you.

## Eve Morelock

- message_greet - Unclear meaning
  - was: I can hold my breath for 10 minutes with my Goldeen!
  - now: I can hold my breath for 10 minutes swimming with my Goldeen!

## Faith

- quest 8224 talk_questStarting - Broken grammar
  - was: Do you can buy a crystal statue for me?
  - now: Can you buy a crystal statue for me?
- quest 8224 talk_questStarted - Wrong, unintended meaning
  - was: Thank you, I want your beautiful body.
  - now: Thank you, I just love how beautiful they are.
- quest 8224 talk_questFinishing - Missing auxiliary
  - was: You got the crystal statue?
  - now: Did you get the crystal statue?

## Farmer Steve

- quest 8263 talk_questStarting - Broken grammar
  - was: I'm need help to plant some berries, what you think?
  - now: I need help planting some berries, what do you think?
- quest 8263 talk_questStarted - Awkward phrasing
  - was: Do the following: plant 5 seeds for me in my field. Take it.
  - now: Do the following: plant 5 seeds in my field for me. Here, take these.

## Farrel

- message_greet - Confusing grammar
  - was: Everything is light in a bird, but the amount is huge... and dragons are extremely hard to be found, dude.
  - now: Birds are light, but there are tons of them... and dragons are extremely hard to find, dude.
- quest 8080 talk_questStarting - Awkward phrasing
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8080 talk_questFinishing - Missing auxiliary
  - was: You got the items?
  - now: Did you get the items?
- quest 8080 talk_questFinished - Awkward phrasing
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.

## Fergus

- quest 8664 talk_questFinishFail - Unnatural phrase
  - was: Looks like no.
  - now: Looks like you didn't.

## First Mate

- message_greet - Unclear pronoun 'they'
  - was: Hello recruit, they were toward the engine room, our sailors pursued them there. Go on, I'm calling the authorities!
  - now: Hello recruit, the intruders went toward the engine room and our sailors chased them there. Go on, I'm calling the authorities!

## Flanagan

- quest 8489 talk_questStarting - Broken grammar
  - was: Great. First "Use" the Reward Chest right there to receive a Pikachu. Remembering that he will be with you only on the tutorial, later you will choose your first Pokemon. Go and get him, once you finished you will see that your QUEST LOG will be updated. This window shows your current quests. Okay?
  - now: Great. First "Use" the Reward Chest right there to receive a Pikachu. Remember that he will only be with you during the tutorial; later you will choose your first Pokemon. Go and get him. Once you're done, you will see your QUEST LOG update. This window shows your current quests. Okay?
- quest 8489 talk_questStarted - Awkward phrasing
  - was: Once you perform the {action}, get back here.
  - now: Once you've done the {action}, come back here.
- quest 8489 talk_questFinishing - Grammar errors
  - was: In some dialogs you will have the choice of YES or NO. Pay close attention before you speak and read everything that a NPC tell you. You got the Pikachu?
  - now: In some dialogs you will have the choice of YES or NO. Pay close attention before you answer and read everything an NPC tells you. Did you get the Pikachu?
- quest 8489 talk_questFinishFail - Nonsense phrase
  - was: Likes no.
  - now: Looks like you didn't.
- quest 8490 talk_questStarting - Broken grammar
  - was: Great! Now you'll notice that in your Inventory was a specific place for the Poke Ball, we call it Ball Slot.
  - now: Great! Now you'll notice that your Inventory has a specific place for the Poke Ball; we call it the Ball Slot.
- quest 8490 talk_questStarted - Awkward phrasing
  - was: Place the Poke Ball there and "Use" the Ball Slot to call your Pokemon out. Once finished I will give you further {instructions}.
  - now: Place the Poke Ball there and "Use" the Ball Slot to call your Pokemon out. Once you're done I will give you further {instructions}.
- quest 8490 talk_questFinishing - Broken grammar
  - was: You could call your Pokemon?
  - now: Were you able to call your Pokemon?
- quest 8491 talk_questStarting - Wrong preposition
  - was: You will also notice that at your Inventory there is another button called "Order". Use it and a selection cursor will appear.
  - now: You will also notice that your Inventory has another button called "Order". Use it and a selection cursor will appear.
- quest 8491 talk_questStarted - Awkward phrasing
  - was: Now click anywhere on the floor to move your Pokemon. Once finished I will give you further {INSTRUCTIONS}.
  - now: Now click anywhere on the floor to move your Pokemon. Once you're done I will give you further {INSTRUCTIONS}.
- quest 8491 talk_questFinishing - Broken grammar
  - was: You could order your Pokemon?
  - now: Were you able to order your Pokemon?
- quest 8491 talk_questFinished - Minor grammar
  - was: This works to position your Pokemon to battle and also to perform a specific attack. Note that in the inventory menu there are also other buttons that you can explore to perform actions. Ok, when you feel ready, let's {CONTINUE}.
  - now: This is used to position your Pokemon for battle and also to perform specific attacks. Note that the inventory menu has other buttons you can explore to perform actions. Ok, when you feel ready, let's {CONTINUE}.
- quest 8492 talk_questStarted - Broken grammar
  - was: All you need to do is keep your Pokemon out of Poke Ball at the battle time. To attack we have two possibilities: the window with the moves icons, or putting "m1", "m2", etc., in your Hotkeys (Ctrl + K). If you need a more detailed explanation look at the Help Channel. Say {BATTLE} when you feel ready.
  - now: All you need to do is keep your Pokemon out of its Poke Ball during the battle. To attack you have two options: the window with the move icons, or putting "m1", "m2", etc. in your Hotkeys (Ctrl + K). If you need a more detailed explanation, check the Help Channel. Say {BATTLE} when you feel ready.
- quest 8492 talk_questFinishing - Confusing question
  - was: Oh, the {BATTLE}?
  - now: So, ready for the {BATTLE}?
- quest 8492 talk_questFinished - Awkward phrasing
  - was: Congratulations! With the moves window we also have the possibility to see all the detailed description of each move of your Pokemon. Just use Shift + Click over the move icon. Go through the door and go talk to the next NPC.
  - now: Congratulations! The moves window also lets you see the detailed description of each of your Pokemon's moves. Just Shift + Click on the move icon. Go through the door and talk to the next NPC.

## Flavia

- message_greet - Broken tag question
  - was: Beautiful day is not it?
  - now: Beautiful day, isn't it?
- quest 8346 talk_questStarted - Awkward order
  - was: Take this shovel, dig and find it for me! Thank you.
  - now: Take this shovel, dig around and find it for me! Thank you.
- quest 8346 talk_questFinishing - Broken grammar
  - was: Do you bring what I've asked?
  - now: Did you bring what I asked for?

## Florence Blanch

- message_greet - Wrong preposition
  - was: Welcome to the Gaia Mastery! Here you can exchange your gaia tokens into rewards. Type {options} to see.
  - now: Welcome to the Gaia Mastery! Here you can exchange your gaia tokens for rewards. Say {options} to see them.

## Forrest Jed

- message_greet - Wrong word
  - was: Run and run, always moisturizing!
  - now: Run and run, always staying hydrated!

## Gabriel Wright

- message_greet - Broken grammar
  - was: Will a hot-dog out there brother?
  - now: Want a hot-dog, brother?

## Garret Redd

- message_greet - Garbled phrase
  - was: The best bank Moro! I mean, the only... Your options are: {balance}, {deposit}, {deposit all}, {withdraw}, {withdraw all} and {transfer}.
  - now: The best bank in Moro! I mean, the only one... Your options are: {balance}, {deposit}, {deposit all}, {withdraw}, {withdraw all} and {transfer}.

## Gary Oak

- message_greet - Missing auxiliary
  - was: Hey! Know any {Pokemon trainer}? I'm looking for talent!
  - now: Hey! Do you know any {Pokemon trainer}? I'm looking for talent!
- npc/scripts/quest_garyOak.lua - Awkward question
  - was: Let's {battle}?
  - now: Shall we {battle}?
- quest 8413 talk_questStarting - Broken grammar
  - was: My sister will not come? Great, and sent an unknown trainer to help me. Do not bother me, I'm on a mission... Since you're so interested, might help.
  - now: My sister isn't coming? Great, she sent a trainer I don't know to help me. Don't bother me, I'm on a mission... But since you're so interested, you might be useful.
- quest 8413 talk_questStarted - Broken grammar
  - was: I'm investigating a case of disappearance. I need to see some places west from here. You will help me. Take this magnifier, you may need. Use the magnifier in suspicious places. Report to me when you find something.
  - now: I'm investigating a disappearance. I need to check some places west of here. You will help me. Take this magnifier, you may need it. Use it on suspicious places. Report to me when you find something.
- quest 8413 talk_questFinished - Confusing phrasing
  - was: I found signs of battle here too. But it seems that stretched away from here. I'll keep looking. But first, I want to test you. Let's {battle}.
  - now: I found signs of battle here too. But it seems the fight moved away from here. I'll keep looking. But first, I want to test you. Let's {battle}.
- quest 8414 talk_questFinishing - Confusing question
  - was: Hah and the battle huh?
  - now: Hah, what about our battle, huh?
- quest 8414 talk_questFinished - Minor grammar
  - was: Beautiful battle. Tell my sister that I'm fine and that my suspicions were confirmed. I see that I can trust you. Meet me again in Mt. Moon. Before that you may visit Pewter and see the city. Some people may need help. But be sure to talk to my sister Daisy first.
  - now: Beautiful battle. Tell my sister that I'm fine and that my suspicions were confirmed. I see I can trust you. Meet me again at Mt. Moon. Before that you can visit Pewter and see the city. Some people may need help. But be sure to talk to my sister Daisy first.
- quest 8417 talk_questStarted - Broken grammar, confusing
  - was: Now there's no turning back. I'll tell you everything. Ash Ketchum from Pallet Town is gone. The last contact we had was when his getting back home from a visit to another continent with info about new Pokemon. He emailed me telling  the location of his arrival, but I couldn't find him myself. The battle signs that we saw in Viridian are indications that he was there. We would meet there. I talked to his mother and she did not know anything. My grandfather cannot contact him, and since he is the league champion... everyone is concerned. He may have been ambushed. The clues that I follow brought me here. Everything indicates that he was taken by someone. Ash kept a diary in which he wrote his achievements and some notes. I found one of the pages torn near here. If we could find more about this diary... so we need to get divide. Go with this magnifier. See what you can do. I will mark on your map the location where you must begin the search, use the magnifier at all. The track can be anywhere.
  - now: Now there's no turning back. I'll tell you everything. Ash Ketchum from Pallet Town is gone. Our last contact was when he was coming home from a visit to another continent with info about new Pokemon. He emailed me the location of his arrival, but I couldn't find him myself. The battle signs we saw in Viridian show he was there. We were supposed to meet there. I talked to his mother and she knew nothing. My grandfather can't contact him, and since he is the league champion... everyone is concerned. He may have been ambushed. The clues I followed brought me here. Everything indicates he was taken by someone. Ash kept a diary where he wrote his achievements and some notes. I found one of its torn pages near here. If we could find more of this diary... so we need to split up. Take this magnifier and see what you can do. I will mark on your map where you must begin the search; use the magnifier everywhere. The trail could be anywhere.
- quest 8417 talk_questFinished - Grammar errors
  - was: Now it does not matter. I found a piece of torn page that might give me some information. Go to Pallet Town and talk to Delia, Ash's mom. Tell her we're making progress. When I need you I call. Now go!
  - now: It doesn't matter now. I found a piece of torn page that might give me some information. Go to Pallet Town and talk to Delia, Ash's mom. Tell her we're making progress. I'll call you when I need you. Now go!
- quest 8417 talk_questFinishFail - Nonsense phrase
  - was: Likes no.
  - now: Looks like you didn't.
- quest 8419 talk_questFinishing - Word order
  - was: You already spoke to Delia?
  - now: Have you already spoken to Delia?
- quest 8419 talk_questFinished - Broken grammar
  - was: I had more progress, this time you should go alone. I need to take care of some of my subjects. Talk to Bill, he is informed about everything. He is at north of Cerulean in his tower.
  - now: I've made more progress; this time you should go alone. I need to take care of some of my own business. Talk to Bill, he knows everything. He is in his tower north of Cerulean.
- quest 8520 talk_questStarting - Broken grammar, confusing
  - was: Good to see you again. We are grateful for your help so far trainer. My recent research and with their findings lead me to believe that Ash is locked inside the building Silph Co. That keeps many secrets and everything leads me to believe that it is the lair of Team Rocket. All you need to do is enter without knocking and unmask all. You think you can?
  - now: Good to see you again. We are grateful for your help so far, trainer. My recent research and your findings lead me to believe that Ash is locked inside the Silph Co. building. It keeps many secrets and everything suggests it is Team Rocket's lair. All you need to do is get in unnoticed and expose them all. Do you think you can?
- quest 8520 talk_questStarted - Awkward phrasing
  - was: Beware of any kind of trap on site. Pay attention to the flooring, doors, and remember not to make too much noise. If you find a Rocket, fight him. I think Ash is there. Take this access card to the elevator. Good luck.
  - now: Beware of any kind of trap there. Pay attention to the floors and doors, and remember not to make too much noise. If you find a Rocket, fight him. I think Ash is there. Take this elevator access card. Good luck.
- quest 8520 talk_questFinishing - Missing auxiliary
  - was: You found him?
  - now: Did you find him?
- quest 8520 talk_questFinished - Awkward phrasing
  - was: You found him! Very good! We need to be discreet now. We must put an end to Team Rocket and go after those responsible for it all. Ash needs to recover and we count on you to expose all this! Tell Bill about the events and let's start!
  - now: You found him! Very good! We need to be discreet now. We must put an end to Team Rocket and go after those responsible for all this. Ash needs to recover and we're counting on you to expose everything! Tell Bill what happened and let's begin!

## Gary's Assistant

- quest 8030 talk_questStarting - Wrong word 'get'
  - was: I am seeking the best Pokemon trainers! If you think you are talented I'll get you a test.
  - now: I am seeking the best Pokemon trainers! If you think you are talented I'll give you a test.
- quest 8030 talk_questFinishing - Missing auxiliary
  - was: You got the items?
  - now: Did you get the items?
- quest 8030 talk_questFinished - Broken grammar
  - was: Congratulations kid, get your reward. I have more missions for you, when you want to come talk to me.
  - now: Congratulations kid, here is your reward. I have more missions for you; come talk to me whenever you want.
- quest 8030 talk_questFinishFail - Awkward
  - was: No, you did not.
  - now: No, you didn't.
- quest 8031 talk_questStarting - Word order
  - was: You're prepared for the second test?
  - now: Are you prepared for the second test?
- quest 8031 talk_questFinished - Broken grammar
  - was: Congratulations, get your reward. I have more missions for you, when you want to come talk to me.
  - now: Congratulations, here is your reward. I have more missions for you; come talk to me whenever you want.
- quest 8032 talk_questStarting - Word order
  - was: You're prepared for the third test?
  - now: Are you prepared for the third test?
- quest 8033 talk_questStarting - Word order
  - was: You're prepared for the fourth and final test?
  - now: Are you prepared for the fourth and final test?
- quest 8033 talk_questFinished - Broken grammar
  - was: Congratulations, get your reward. I liked the your results, I keep doing my tests and maybe someday I'll call you. Haha.
  - now: Congratulations, here is your reward. I liked your results. I'll keep doing my tests and maybe someday I'll call you. Haha.

## George Carter

- message_greet - Misspelling
  - was: Hello! I'm George Carter, an archeologist. I'm in Pewter to do {research} and excavations!
  - now: Hello! I'm George Carter, an archaeologist. I'm in Pewter to do {research} and excavations!
- quest 8025 talk_questStarting - Redundant phrasing
  - was: Well, I am looking for people interested in helping me in my research I'm doing on Mt Moon. Are you interested in helping me?
  - now: Well, I am looking for people interested in helping me with the research I'm doing on Mt Moon. Are you interested in helping me?
- quest 8025 talk_questStarted - Awkward phrasing
  - was: Great! So let's get the job, we'll need some equipment to start our research. You will need: a Pick, a Flashlight and a Rope. The Pick you can buy from a blacksmith who lives in Mt Moon. Come back when you get the tools.
  - now: Great! So let's get to work, we'll need some equipment to start our research. You will need: a Pick, a Flashlight and a Rope. You can buy the Pick from a blacksmith who lives in Mt Moon. Come back when you have the tools.
- quest 8025 talk_questFinishing - Missing auxiliary
  - was: You have the tools?
  - now: Do you have the tools?
- quest 8025 talk_questFinishFail - Awkward
  - was: No, you did not.
  - now: No, you don't.
- quest 8026 talk_questStarted - Awkward phrasing
  - was: Alright, now you need to train your skills with these tools! Haha! Go to Mt Moon and look for the entry of the old mines, there go north until you find Earth Piles. Then use your Pick on the Earth Piles until you get 10 Iron Ores.
  - now: Alright, now you need to train your skills with these tools! Haha! Go to Mt Moon and look for the entrance to the old mines. From there go north until you find Earth Piles. Then use your Pick on the Earth Piles until you get 10 Iron Ores.
- quest 8026 talk_questFinishing - Missing auxiliary
  - was: You got 10 Iron Ores?
  - now: Did you get 10 Iron Ores?
- quest 8027 talk_questStarting - Broken grammar
  - was: I have heard rumors that here in this mountain you can find the famous Moon Stone, wants to continue the research?
  - now: I have heard rumors that the famous Moon Stone can be found in this mountain. Do you want to continue the research?
- quest 8027 talk_questStarted - Awkward phrasing
  - was: Trawl through the old mine at Mt Moon and look for maps that are out there, they can lead us to secret paths used by the miners.
  - now: Search through the old mine at Mt Moon and look for the maps left there; they can lead us to secret paths used by the miners.
- quest 8027 talk_questFinishing - Word order
  - was: You've found the maps?
  - now: Have you found the maps?
- quest 8028 talk_questStarting - Awkward question
  - was: I checked the maps and think I found something very interesting, perhaps the way to the Moon Stone! Want to make this work for me?
  - now: I checked the maps and I think I found something very interesting, perhaps the way to the Moon Stone! Want to do this for me?
- quest 8028 talk_questStarted - Minor grammar
  - was: Look for a hole in the mines of Mt Moon, there you will find a door and some paths. You should explore the area and find the Moon Stone fragment!
  - now: Look for a hole in the mines of Mt Moon; there you will find a door and some paths. Explore the area and find the Moon Stone fragment!
- quest 8028 talk_questFinishing - Missing auxiliary
  - was: You got the Moon Stone fragment?
  - now: Did you get the Moon Stone fragment?
- quest 8028 talk_questFinished - Awkward 'in thanks'
  - was: Thanks for everything. In thanks I'll give you something special, a good reward. You can choose a {Fire Stone} or a {Water Stone} or a {Leaf Stone}. What is your choice?
  - now: Thanks for everything. As thanks I'll give you something special, a good reward. You can choose a {Fire Stone} or a {Water Stone} or a {Leaf Stone}. What is your choice?
- quest 8665 talk_questStarted - Its/it's; preposition
  - was: Its a reward of your previous {mission}.
  - now: It's a reward for your previous {mission}.
- quest 8665 talk_questFinishing - Word order
  - was: You are ready to take it?
  - now: Are you ready to take it?

## Gerry

- message_greet - Broken grammar
  - was: An insect like you know how to walk on fire without getting burnt?
  - now: Does an insect like you know how to walk on fire without getting burnt?
- quest 8154 talk_questStarting - Awkward phrasing
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8154 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Machamp.
  - now: Thanks! Your task is to defeat 30 Machamp.
- quest 8154 talk_questFinishing - Word order
  - was: The task is done?
  - now: Is the task done?
- quest 8154 talk_questFinished - Awkward phrasing
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.
- quest 8155 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Primeape.
  - now: Thanks! Your task is to defeat 30 Primeape.
- quest 8156 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Arbok.
  - now: Thanks! Your task is to defeat 30 Arbok.
- quest 8157 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Venomoth.
  - now: Thanks! Your task is to defeat 30 Venomoth.
- quest 8158 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Muk.
  - now: Thanks! Your task is to defeat 30 Muk.
- quest 8159 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Gengar.
  - now: Thanks! Your task is to defeat 30 Gengar.
- quest 8160 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Pidgeot.
  - now: Thanks! Your task is to defeat 30 Pidgeot.
- quest 8161 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Fearow.
  - now: Thanks! Your task is to defeat 30 Fearow.
- quest 8162 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Charizard.
  - now: Thanks! Your task is to defeat 30 Charizard.
- quest 8163 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Ninetales.
  - now: Thanks! Your task is to defeat 30 Ninetales.
- quest 8164 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Arcanine.
  - now: Thanks! Your task is to defeat 30 Arcanine.
- quest 8165 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is defeat 30 Rapidash.
  - now: Thanks! Your task is to defeat 30 Rapidash.

## Giles Shaw

- message_greet - Unclear phrasing
  - was: I came here with some friends to battle! They went around... I think I'm lost.
  - now: I came here with some friends to battle! They wandered off... I think I'm lost.

## Giovanni

- message_greet - Lowercase team name
  - was: Fwahahaha! This is my hideout! I planned to resurrect team rocket here! But, you have caught me again! So be it! This time, I'm not holding back! Once more, you shall face Giovanni, the greatest trainer!
  - now: Fwahahaha! This is my hideout! I planned to resurrect Team Rocket here! But, you have caught me again! So be it! This time, I'm not holding back! Once more, you shall face Giovanni, the greatest trainer!
- npc/scripts/npcbattle_giovanni.lua - Broken grammar
  - was: So you're a friend of Bill? Wait a minute I will confirm this... Looks like Bill know you, I will let you go, but I do not want to see you getting into the affairs of the police without permission, OK?
  - now: So you're a friend of Bill's? Wait a minute, I'll confirm this... Looks like Bill knows you. I'll let you go, but I don't want to see you meddling in police affairs without permission, OK?
- npc/scripts/npcbattle_giovanni.lua - Broken grammar
  - was: That's right trainer, thank you, meet me at my father.
  - now: That's right trainer, thank you. Meet me at my father's.
- npc/scripts/npcbattle_giovanni.lua - Unclear pronoun
  - was: Oh, I almost forgot. Guards! Bring him.
  - now: Oh, I almost forgot. Guards! Bring him in.
- npc/scripts/npcbattle_giovanni.lua - Wrong preposition
  - was: ESCAPE MY FRIEND, RUN AWAY, GET HELP WITH MY FATHER! BRISCOE LEN!
  - now: ESCAPE MY FRIEND, RUN AWAY, GET HELP FROM MY FATHER! BRISCOE LEN!
- npc/scripts/npcbattle_giovanni.lua - Broken grammar
  - was: Now boy, you made me feel something I have not felt for many years. I had completely forgotten how to have that euphoria during duels pokemon, how it feels as one with your pokemon and I ended up turning it into a {business} only.
  - now: Now boy, you made me feel something I haven't felt in many years. I had completely forgotten the euphoria of Pokemon duels, how it feels to be one with your Pokemon, and I ended up turning it into just a {business}.
- npc/scripts/npcbattle_giovanni.lua - Broken grammar
  - was: So you are the kid who is messing me? Your {friend} told me a lot about you.
  - now: So you're the kid who's been messing with me? Your {friend} told me a lot about you.
- npc/scripts/npcbattle_giovanni.lua - Garbled, incomprehensible
  - was: I do not regret having facilitated the creation of Mewtwo, but I will let him free he will decide what is best for you, now I and my subordinates of {team rocket} will from this island.
  - now: I don't regret helping create Mewtwo, but I will set him free; he will decide what is best for himself. Now my subordinates of {team rocket} and I will leave this island.
- npc/scripts/npcbattle_giovanni.lua - Garbled grammar
  - was: The team rocket will continue with their activities, more than a different way ... Wait and see with their own eyes boy. See you some other day.
  - now: Team Rocket will continue its activities, but in a different way... Wait and see with your own eyes, boy. See you some other day.
- npc/scripts/npcbattle_giovanni.lua - Broken grammar
  - was: Your damn kid promise that this will be the last time you will annoy me! Let's {duel}!
  - now: You damn kid, promise this will be the last time you annoy me! Let's {duel}!
- npc/scripts/npcbattle_giovanni.lua - Broken grammar
  - was: You must defeat me before receive your reward.
  - now: You must defeat me before receiving your reward.
- npc/scripts/npcbattle_giovanni.lua - Broken grammar
  - was: Oh, here is!
  - now: Oh, here it is!
- npc/scripts/npcbattle_giovanni.lua - 'Your' for 'You'
  - was: Your damn kid, I'll stop you now! Ready or not, it's time to duel!
  - now: You damn kid, I'll stop you now! Ready or not, it's time to duel!

## Glen

- message_greet - Awkward phrasing
  - was: Everything here is so lonely friend. Want to be my friend and help me in sales? No...? What a shame...
  - now: Everything here is so lonely, friend. Want to be my friend and help me with sales? No...? What a shame...

## Godfrey Stephen

- message_greet - Broken grammar
  - was: Looking for chairs? We have all my friend.
  - now: Looking for chairs? We have them all, my friend.

## Gollum

- quest 8260 talk_questStarting - Misspelled Ledyba; awkward
  - was: I was packing my picnic when Pinsir and Ledyans came and ate all my food. Could you help me to collect food for the picnic?
  - now: I was packing my picnic when Pinsir and Ledyba came and ate all my food. Could you help me collect food for the picnic?
- quest 8260 talk_questStarted - Misspelling, plurals
  - was: Bring me 15x Red Apples, 15x Oranges, 15x Blueberrys, 15x Melon, 15x Pears and 15x Strawberry.
  - now: Bring me 15x Red Apples, 15x Oranges, 15x Blueberries, 15x Melons, 15x Pears and 15x Strawberries.

## Gord Scottie

- message_greet - Missing auxiliary
  - was: Hello buddy, you like bananas?
  - now: Hello buddy, do you like bananas?
- quest 8244 talk_questStarting - Plural
  - was: Can you bring me 20 grape fruit?
  - now: Can you bring me 20 grape fruits?
- quest 8244 talk_questStarted - Instruction unclear
  - was: Good luck!
  - now: Good luck finding them!
- quest 8244 talk_questFinishing - Tense error
  - was: Did you bring what I've asked?
  - now: Did you bring what I asked for?
- quest 8244 talk_questFinished - Broken grammar
  - was: I'll stick with 10. Go to the Curtis Sacheverell and delivered the other 10.
  - now: I'll keep 10. Go to Curtis Sacheverell and deliver the other 10.

## Gosse

- message_greet - Word order
  - was: Hello |PLAYERNAME|. How your {MISSIONS} are going? [You can {skip} this tutorial whenever you want.]
  - now: Hello |PLAYERNAME|. How are your {MISSIONS} going? [You can {skip} this tutorial whenever you want.]
- quest 8493 talk_questStarting - Awkward phrasing
  - was: Here you will learn how to capture a Pokemon using an empty Poke Ball. I see that you already have a Pokemon with you, that's a very important part of this task. All you need to do is defeat the wild Pokemon and "Use" the empty Poke Ball in your Backpack over the body lying on the floor. Ya?
  - now: Here you will learn how to capture a Pokemon using an empty Poke Ball. I see you already have a Pokemon with you, which is a very important part of this task. All you need to do is defeat the wild Pokemon and "Use" the empty Poke Ball from your Backpack on the body lying on the floor. Got it?
- quest 8493 talk_questStarted - Awkward phrasing
  - was: Great, go through that door and catch one Magikarp. Take these empty Poke Balls. Remember that all items obtained in this tutorial will not be with you after the exit.
  - now: Great, go through that door and catch one Magikarp. Take these empty Poke Balls. Remember that items obtained in this tutorial will not stay with you after you leave.
- quest 8493 talk_questFinishing - Broken grammar
  - was: Do you caught the Magikarp?
  - now: Did you catch the Magikarp?
- quest 8493 talk_questFinished - Garbled 'effectivities catch rates'
  - was: Congratulations, you are learning the basics to become a real trainer. Know that there are different types of Poke Ball with different effectivities catch rates, all you need to do is to study a little more. Let's {CONTINUE}.
  - now: Congratulations, you are learning the basics of becoming a real trainer. Know that there are different types of Poke Ball with different catch rates; all you need to do is study a little more. Let's {CONTINUE}.
- quest 8493 talk_questFinishFail - Nonsense phrase
  - was: Likes no.
  - now: Looks like you didn't.
- quest 8494 talk_questStarting - Misspelling Safari; grammar
  - was: The only place where you do not need to defeat the Pokemon to catch is the Saffari Zone in Fuchsia.
  - now: The only place where you don't need to defeat a Pokemon to catch it is the Safari Zone in Fuchsia.
- quest 8494 talk_questStarted - Confusing fragment
  - was: There is {DIFFERENT}...
  - now: It works {DIFFERENT} there...
- quest 8494 talk_questFinishing - Misspelling; broken grammar
  - was: Ok! At the Saffari Zone its necessary to use some items to make the Pokemon submit an exclamation (!), and thus releasing the catch. Right at this moment you can throw the Poke Ball at him directly. Roger That?
  - now: Ok! In the Safari Zone you need to use some items to make the Pokemon show an exclamation mark (!), which allows the catch. At that moment you can throw the Poke Ball at it directly. Roger that?

## Gray

- message_greet - Missing auxiliary
  - was: Hello |PLAYERNAME|. You want to hear about the {FRONTIER ISLAND} or the {RANGER CLUB}?
  - now: Hello |PLAYERNAME|. Do you want to hear about the {FRONTIER ISLAND} or the {RANGER CLUB}?

## Grayson Eliot

- message_greet - Wrong preposition
  - was: Welcome to the Voltagic Mastery! Here you can exchange your voltagic tokens into rewards. Type {options} to see.
  - now: Welcome to the Voltagic Mastery! Here you can exchange your voltagic tokens for rewards. Say {options} to see them.

## Greyson Tranter

- message_greet - Awkward question
  - was: Hello |PLAYERNAME|! I'm Greyson Tranter, let's {battle}?
  - now: Hello |PLAYERNAME|! I'm Greyson Tranter, shall we {battle}?

## Guardian Mantine

- message_greet - Missing auxiliary
  - was: What you want?
  - now: What do you want?
- npc/scripts/quest_guardianMantine.lua - Broken grammar
  - was: You that will help MANTT strengthen Deepsoul Stone?
  - now: Are you the one who will help MANTT strengthen the Deepsoul Stone?
- npc/scripts/quest_guardianMantine.lua - Garbled riddle
  - was: I am simple and efficient... I have improved but INEEE still believe in me. I have several MANN types and properties, and believe me you will be the best. What is it?
  - now: I am simple and efficient... I've been improved, but INEEE people still trust me. I come in many MANN types and properties, and believe me, I'll make you the best. What am I?
- npc/scripts/quest_guardianMantine.lua - Missing object
  - was: Then answer my three questions and I will give it. {Ready}?
  - now: Then answer my three questions and I will give it to you. {Ready}?
- npc/scripts/quest_guardianMantine.lua - Garbled riddle
  - was: Correct! Second question... Sometimes I'm strange MANTII and misunderstood. I am the key to what it means and I can TINEE express what you think. Who am I?
  - now: Correct! Second question... Sometimes I'm strange MANTII and misunderstood. I am the key to meaning and I can TINEE express what you think. What am I?
- npc/scripts/quest_guardianMantine.lua - Garbled riddle
  - was: I am simple and efficient... I have improved but still believe in me. I have MANTIIN several types and properties, and believe me INEEE you will be the best. What is it?
  - now: I am simple and efficient... I've been improved, but people still trust me. I come in MANTIIN many types and properties, and believe me INEEE, I'll make you the best. What am I?
- npc/scripts/quest_guardianMantine.lua - Garbled riddle
  - was: Correct! Third and last question... On the journey does nothing without them. They TINN will always be by your side when you need MANTII support you and what you want. But they do not give the order, it is disrespectful.
  - now: Correct! Third and last question... On a journey you can do nothing without them. They TINN will always be by your side to MANTII support you when you need it. But you don't give them orders, that is disrespectful. What are they?
- npc/scripts/quest_guardianMantine.lua - Garbled riddle
  - was: Sometimes I'm strange and MANTIINE misunderstood. I am the key to what it means and MANN I can express what you think. Who am I?
  - now: Sometimes I'm strange and MANTIINE misunderstood. I am the key to meaning and MANN I can express what you think. What am I?
- npc/scripts/quest_guardianMantine.lua - Awkward phrasing
  - was: Please, check your backpack for space.
  - now: Please make sure you have space in your backpack.
- npc/scripts/quest_guardianMantine.lua - Garbled riddle
  - was: On the journey does nothing without them. They will always MANTINN be by your side when you need support you and what you want. But they MANTINNE do not give the order, it is disrespectful.
  - now: On a journey you can do nothing without them. They will always MANTINN be by your side to support you when you need it. But you MANTINNE don't give them orders, that is disrespectful. What are they?

## Guide Andie

- message_greet - Awkward word order
  - was: Welcome to Saffron! I can {mark} on your map the locations of the city.
  - now: Welcome to Saffron! I can {mark} the city's locations on your map.

## Guide Augustine

- message_greet - Awkward word order
  - was: Welcome to Celadon! I can {mark} on your map the locations of the city.
  - now: Welcome to Celadon! I can {mark} the city's locations on your map.

## Guide Brendan

- message_greet - Awkward word order
  - was: Welcome to Sunburst Island! I can {mark} on your map the locations of the island.
  - now: Welcome to Sunburst Island! I can {mark} the island's locations on your map.

## Guide Cary

- message_greet - Awkward word order
  - was: Welcome to Tangelo Island! I can {mark} on your map the locations of the island.
  - now: Welcome to Tangelo Island! I can {mark} the island's locations on your map.

## Guide Chesley

- message_greet - Awkward word order
  - was: Welcome to Viridian! I can {mark} on your map the locations of the city.
  - now: Welcome to Viridian! I can {mark} the city's locations on your map.

## Guide Darby

- message_greet - Awkward word order
  - was: Welcome to Lavender! I can {mark} on your map the locations of the city.
  - now: Welcome to Lavender! I can {mark} the city's locations on your map.

## Guide David

- message_greet - Awkward word order
  - was: Welcome to Ascorbia Island! I can {mark} on your map the locations of the island.
  - now: Welcome to Ascorbia Island! I can {mark} the island's locations on your map.

## Guide Emil

- message_greet - Awkward word order
  - was: Welcome to Pewter! I can {mark} on your map the locations of the city.
  - now: Welcome to Pewter! I can {mark} the city's locations on your map.

## Guide Emmerson

- message_greet - Awkward word order
  - was: Welcome to Trovitopolis Island! I can {mark} on your map the locations of the island.
  - now: Welcome to Trovitopolis Island! I can {mark} the island's locations on your map.

## Guide Everitt

- message_greet - Awkward word order
  - was: Welcome to Mikan Island! I can {mark} on your map the locations of the island.
  - now: Welcome to Mikan Island! I can {mark} the island's locations on your map.

## Guide Jay

- message_greet - Awkward word order
  - was: Welcome to Kumquat Island! I can {mark} on your map the locations of the island.
  - now: Welcome to Kumquat Island! I can {mark} the island's locations on your map.

## Guide Jocelyn

- message_greet - Awkward word order
  - was: Welcome to Pummelo Island! I can {mark} on your map the locations of the island.
  - now: Welcome to Pummelo Island! I can {mark} the island's locations on your map.

## Guide Maddox

- message_greet - Awkward word order
  - was: Welcome to Cerulean! I can {mark} on your map the locations of the city.
  - now: Welcome to Cerulean! I can {mark} the city's locations on your map.

## Guide Ron

- message_greet - Awkward word order
  - was: Welcome to Vermilion! I can {mark} on your map the locations of the city.
  - now: Welcome to Vermilion! I can {mark} the city's locations on your map.

## Guide Ross

- message_greet - Awkward word order
  - was: Welcome to Mandarin North Island! I can {mark} on your map the locations of the island.
  - now: Welcome to Mandarin North Island! I can {mark} the island's locations on your map.

## Guide Thurstan

- message_greet - Awkward word order
  - was: Welcome to Moro Island! I can {mark} on your map the locations of the island.
  - now: Welcome to Moro Island! I can {mark} the island's locations on your map.

## Guide Weldon

- message_greet - Awkward word order
  - was: Welcome to Fuchsia! I can {mark} on your map the locations of the city.
  - now: Welcome to Fuchsia! I can {mark} the city's locations on your map.

## Gurtab

- quest 8080 talk_questStarting - Awkward phrasing
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8080 talk_questFinishing - Missing auxiliary
  - was: You got the items?
  - now: Did you get the items?
- quest 8080 talk_questFinished - Awkward phrasing
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.

## Guy Choquette

- message_greet - Garbled sentence
  - was: Blaine said he is waiting for you even watch the flames...
  - now: Blaine said he's waiting for you, even while watching the flames...

## Gyles

- message_greet - Awkward question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, shall we trade your soul coins?

## Hall Bronte

- message_greet - Missing auxiliary
  - was: Hello |PLAYERNAME|, you need something to brighten your home?
  - now: Hello |PLAYERNAME|, do you need something to brighten your home?

## Hanzo Hasashi

- quest 8454 talk_questStarting - Awkward phrasing
  - was: My Charizard is angry with something I did for him and fled to the caves near here. Can you help me with this?
  - now: My Charizard got angry about something I did and fled to the caves near here. Can you help me with this?
- quest 8454 talk_questStarted - Garbled, incomprehensible ending
  - was: All you need to do is return him to his PokeBall. We'll have to put him to sleep. Try this device that I recently created. All you need to do is use it on the floor to make it work. But be aware of the time, he is not able to function very dee've found in testing.
  - now: All you need to do is return him to his PokeBall. We'll have to put him to sleep. Try this device I recently created; just use it on the floor to make it work. But watch the time: in my tests it didn't work for very long.
- quest 8454 talk_questFinishFail - Nonsense phrase
  - was: Likes no.
  - now: Looks like you didn't.

## Harley

- quest 8166 talk_questStarting - Awkward phrasing
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8166 talk_questStarted - Missing 'to'; them for one
  - was: Thanks! Your task is catch 1 Bulbasaur and bring them to me.
  - now: Thanks! Your task is to catch 1 Bulbasaur and bring it to me.
- quest 8166 talk_questFinishing - Word order
  - was: The task is done?
  - now: Is the task done?
- quest 8166 talk_questFinished - Awkward phrasing
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.
- quest 8167 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is catch 3 Caterpie and bring them to me.
  - now: Thanks! Your task is to catch 3 Caterpie and bring them to me.
- quest 8168 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is catch 3 Weedle and bring them to me.
  - now: Thanks! Your task is to catch 3 Weedle and bring them to me.
- quest 8169 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is catch 2 Oddish and bring them to me.
  - now: Thanks! Your task is to catch 2 Oddish and bring them to me.
- quest 8170 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is catch 2 Paras and bring them to me.
  - now: Thanks! Your task is to catch 2 Paras and bring them to me.
- quest 8171 talk_questStarted - Missing 'to'
  - was: Thanks! Your task is catch 2 Bellsprout and bring them to me.
  - now: Thanks! Your task is to catch 2 Bellsprout and bring them to me.

## Harold Sheen

- message_greet - broken word order
  - was: Hello trainer, how you are? I have work to do...
  - now: Hello trainer, how are you? I have work to do...
- quest 8339 talk_questStarting - wrong preposition
  - was: Are you willing to help me in our new machinery?
  - now: Are you willing to help me with our new machinery?
- quest 8339 talk_questStarted - unclear instructions after accepting
  - was: Cool. We need three fearless trainers to enter our challenge and win a cool prize. What do you think?
  - now: Cool. We need three fearless trainers to enter our challenge and win a cool prize. Get the ticket and come back!
- quest 8339 talk_questFinishing - broken question form
  - was: Great, you got it. You took the ticket?
  - now: Great, you made it. Did you get the ticket?

## Haywood Grady

- npc/scripts/eggmove_regenerator.lua - wrong preposition
  - was: Please, put the poke ball at the ball slot!
  - now: Please, put the poke ball in the ball slot!
- npc/scripts/eggmove_regenerator.lua - broken grammar
  - was: This is not a Pokemon from egg!
  - now: This Pokemon did not hatch from an egg!
- npc/scripts/eggmove_regenerator.lua - wrong verb form
  - was: Your Pokemon already tried to regenerate an Egg Move recently, he must wait %s before try again.
  - now: Your Pokemon already tried to regenerate an Egg Move recently, it must wait %s before trying again.
- npc/scripts/eggmove_regenerator.lua - broken grammar
  - was: Your Pokemon doesn't have regenerated an Egg Move!
  - now: Your Pokemon hasn't regenerated an Egg Move!
- npc/scripts/eggmove_regenerator.lua - wrong pronoun 'your'
  - was: Do you really want to accept the regenerated Egg Move %s? If you accept, your Pokemon will forget your current Egg Move and will learn the Egg Move %s. You can only start the process again if you use another Egg Move Capsule.
  - now: Do you really want to accept the regenerated Egg Move %s? If you accept, your Pokemon will forget its current Egg Move and will learn the Egg Move %s. You can only start the process again if you use another Egg Move Capsule.
- npc/scripts/eggmove_regenerator.lua - duplicated word 'will will'
  - was: Do you really want to reject the regenerated Egg Move %s? If you reject, your Pokemon will will not be able to learn the Egg Move %s. You can only start the process again if you use another Egg Move Capsule.
  - now: Do you really want to reject the regenerated Egg Move %s? If you reject, your Pokemon will not be able to learn the Egg Move %s. You can only start the process again if you use another Egg Move Capsule.
- npc/scripts/eggmove_regenerator.lua - misspelling 'din't'
  - was: I din't understand. Do you want to {ACCEPT} or {REJECT} the regenerated Egg Move?
  - now: I didn't understand. Do you want to {ACCEPT} or {REJECT} the regenerated Egg Move?

## Hermitwo

- npc/scripts/event_halloween_hermitwo.lua - awkward wording
  - was: Errr! You have already generated many potions today! Please try again tomorrow!
  - now: Errr! You have already made too many potions today! Please try again tomorrow!
- npc/scripts/event_halloween_hermitwo.lua - broken grammar
  - was: Here is, thanks!
  - now: Here it is, thanks!
- npc/scripts/event_halloween_hermitwo.lua - missing article
  - was: You do not have reagents for it.
  - now: You do not have the reagents for it.
- message_greet - broken question form
  - was: Hello my dear! You are already helping us to collect the necessary {ingredients}? I need them all to make the potion to defeat Suramoon, hurry up!
  - now: Hello my dear! Are you already helping us collect the necessary {ingredients}? I need them all to make the potion to defeat Suramoon, hurry up!
- npc/scripts/quest_halloweenHermitwo.lua - misspelling 'Remaing'
  - was: Remaing ingredients: %s
  - now: Remaining ingredients: %s

## Hilari

- message_greet - broken question form
  - was: Hey |PLAYERNAME|, it is hot? This desert is getting worse.
  - now: Hey |PLAYERNAME|, hot, isn't it? This desert is getting worse.
- npc/scripts/quest_hilari.lua - broken, unclear sentence
  - was: We need help here. Talk to those who are to receive mission offers.
  - now: We need help here. Talk to the people around here to receive mission offers.

## Hope

- message_greet - broken word order
  - was: Hello, how I can help you?
  - now: Hello, how can I help you?
- quest 8221 talk_questStarting - missing articles, wrong pronoun
  - was: We have problem right here in the lab... the roof. Will you be able to ask Sir John to fix for us? Be careful it's kinda grumpy.
  - now: We have a problem right here in the lab... the roof. Could you ask Sir John to fix it for us? Be careful, he's kinda grumpy.
- quest 8221 talk_questFinishing - broken question form
  - was: You could talk with Sir John?
  - now: Did you manage to talk with Sir John?

## Hugh

- npc/scripts/saffariZoneLeave.lua - broken, confusing sentence
  - was: Safari the largest of these lands, here you will find many species of Pokemon, many of the same, so be very careful!
  - now: The Safari is the largest place in these lands. Here you will find many species of Pokemon, some in great numbers, so be very careful!
- npc/scripts/saffariZoneLeave.lua - missing verb 'go'
  - was: Alright, do you want to back to Fuchsia City?
  - now: Alright, do you want to go back to Fuchsia City?

## Indiana Graeme

- message_greet - lowercase sentence start
  - was: Hello |PLAYERNAME|. want to sell Stones? Just say {trade}.
  - now: Hello |PLAYERNAME|. Want to sell Stones? Just say {trade}.

## Isak

- npc/scripts/mastery_spectrum.lua - 'join into' is wrong
  - was: Do you want to join into the %s Mastery?
  - now: Do you want to join the %s Mastery?
- npc/scripts/mastery_spectrum.lua - broken grammar, unclear 'dismiss with'
  - was: You already has a mastery, if you want to join here first you need to dismiss with your mastery leader.
  - now: You already have a mastery. If you want to join here, you first need to leave it by talking to your mastery leader.
- npc/scripts/mastery_spectrum.lua - wrong preposition
  - was: Are you ready to the next level?
  - now: Are you ready for the next level?
- npc/scripts/mastery_spectrum.lua - wrong preposition
  - was: Are you ready to the dungeon?
  - now: Are you ready for the dungeon?
- npc/scripts/mastery_spectrum.lua - unclear 'dismiss with'
  - was: You need to dismiss with your mastery leader, not here.
  - now: You need to leave through your own mastery leader, not here.
- npc/scripts/mastery_spectrum.lua - Portuguese-ism
  - was: Your account must be with the premium days to join here.
  - now: Your account must have premium days to join here.
- npc/scripts/mastery_spectrum.lua - 'join into' is wrong
  - was: Do you really want to join into the %s Mastery?
  - now: Do you really want to join the %s Mastery?
- npc/scripts/mastery_spectrum.lua - 'win my assistant' wrong
  - was: You have already paid the necessary plates, now you need to win my assistant %s.
  - now: You have already paid the necessary plates, now you need to defeat my assistant %s.
- npc/scripts/mastery_spectrum.lua - Portuguese-ism question
  - was: To join into %s Mastery you will need %s. You're with them?
  - now: To join the %s Mastery you will need %s. Do you have them?
- npc/scripts/mastery_spectrum.lua - Portuguese-ism 'you're with them'
  - was: You do not have the necessary plates, come back here when you're with them. Remember that you must achieve %s points through our element plates.
  - now: You do not have the necessary plates, come back when you have them. Remember that you must reach %s points with our element plates.
- npc/scripts/mastery_spectrum.lua - 'win the dungeon' wrong
  - was: You have already paid the necessary tokens, now you need to win the {dungeon}.
  - now: You have already paid the necessary tokens, now you need to complete the {dungeon}.
- npc/scripts/mastery_spectrum.lua - broken grammar, Portuguese-isms
  - was: To advance in rank within the Mastery you need to prove that you're dominating it, joining %s tokens, you can get them by completing missions with the inhabitants of this base. You are already with the %s %s tokens?
  - now: To advance in rank within the Mastery you need to prove that you're mastering it by collecting %s tokens. You can get them by completing missions for the inhabitants of this base. Do you already have the %s %s tokens?
- npc/scripts/mastery_spectrum.lua - 'make the dungeon' wrong
  - was: Now you're ready to make the {dungeon} and prove that you are able to advance. When you are ready come talk to me.
  - now: Now you're ready to do the {dungeon} and prove that you are able to advance. When you are ready, come talk to me.
- npc/scripts/mastery_spectrum.lua - Portuguese-ism 'you're with them'
  - was: You do not have the necessary tokens, come back here when you're with them.
  - now: You do not have the necessary tokens, come back when you have them.
- npc/scripts/mastery_spectrum.lua - broken grammar
  - was: Before to this dungeon you need pay the necessary tokens.
  - now: Before entering this dungeon you need to pay the necessary tokens.
- npc/scripts/mastery_spectrum.lua - misspelling 'avaiable'
  - was: There is no dungeon avaiable, please try again later.
  - now: There is no dungeon available, please try again later.

## Jack Simps

- quest 8001 talk_questStarting - missing 'to'
  - was: Well, I'm doing some experiments and I need a few ingredients, do you want help me?
  - now: Well, I'm doing some experiments and I need a few ingredients, do you want to help me?
- quest 8001 talk_questStarted - broken, Portuguese-ism
  - was: Ok, the ingredients that I need are 25 bitten apples, back when you are with them.
  - now: Ok, the ingredients that I need are 25 bitten apples, come back when you have them.
- quest 8001 talk_questFinishing - broken question form
  - was: You've got what I asked?
  - now: Have you got what I asked for?
- quest 8001 talk_questFinished - 'experiences' should be 'experiments'
  - was: Oh yeah, thank you, now I can finally finish my experiences.
  - now: Oh yeah, thank you, now I can finally finish my experiments.
- quest 8001 talk_questFinishFail - broken grammar, missing object
  - was: No..You do not have, go get the ingredients and return back to me.
  - now: No... You don't have them. Go get the ingredients and come back to me.

## Jacob

- npc/scripts/mastery_voltagic.lua - 'join into' is wrong
  - was: Do you want to join into the %s Mastery?
  - now: Do you want to join the %s Mastery?
- npc/scripts/mastery_voltagic.lua - broken grammar, unclear 'dismiss with'
  - was: You already has a mastery, if you want to join here first you need to dismiss with your mastery leader.
  - now: You already have a mastery. If you want to join here, you first need to leave it by talking to your mastery leader.
- npc/scripts/mastery_voltagic.lua - wrong preposition
  - was: Are you ready to the next level?
  - now: Are you ready for the next level?
- npc/scripts/mastery_voltagic.lua - wrong preposition
  - was: Are you ready to the dungeon?
  - now: Are you ready for the dungeon?
- npc/scripts/mastery_voltagic.lua - unclear 'dismiss with'
  - was: You need to dismiss with your mastery leader, not here.
  - now: You need to leave through your own mastery leader, not here.
- npc/scripts/mastery_voltagic.lua - Portuguese-ism
  - was: Your account must be with the premium days to join here.
  - now: Your account must have premium days to join here.
- npc/scripts/mastery_voltagic.lua - 'join into' is wrong
  - was: Do you really want to join into the %s Mastery?
  - now: Do you really want to join the %s Mastery?
- npc/scripts/mastery_voltagic.lua - 'win my assistant' wrong
  - was: You have already paid the necessary plates, now you need to win my assistant %s.
  - now: You have already paid the necessary plates, now you need to defeat my assistant %s.
- npc/scripts/mastery_voltagic.lua - Portuguese-ism question
  - was: To join into %s Mastery you will need %s. You're with them?
  - now: To join the %s Mastery you will need %s. Do you have them?
- npc/scripts/mastery_voltagic.lua - Portuguese-ism 'you're with them'
  - was: You do not have the necessary plates, come back here when you're with them. Remember that you must achieve %s points through our element plates.
  - now: You do not have the necessary plates, come back when you have them. Remember that you must reach %s points with our element plates.
- npc/scripts/mastery_voltagic.lua - 'win the dungeon' wrong
  - was: You have already paid the necessary tokens, now you need to win the {dungeon}.
  - now: You have already paid the necessary tokens, now you need to complete the {dungeon}.
- npc/scripts/mastery_voltagic.lua - broken grammar, Portuguese-isms
  - was: To advance in rank within the Mastery you need to prove that you're dominating it, joining %s tokens, you can get them by completing missions with the inhabitants of this base. You are already with the %s %s tokens?
  - now: To advance in rank within the Mastery you need to prove that you're mastering it by collecting %s tokens. You can get them by completing missions for the inhabitants of this base. Do you already have the %s %s tokens?
- npc/scripts/mastery_voltagic.lua - 'make the dungeon' wrong
  - was: Now you're ready to make the {dungeon} and prove that you are able to advance. When you are ready come talk to me.
  - now: Now you're ready to do the {dungeon} and prove that you are able to advance. When you are ready, come talk to me.
- npc/scripts/mastery_voltagic.lua - Portuguese-ism 'you're with them'
  - was: You do not have the necessary tokens, come back here when you're with them.
  - now: You do not have the necessary tokens, come back when you have them.
- npc/scripts/mastery_voltagic.lua - broken grammar
  - was: Before to this dungeon you need pay the necessary tokens.
  - now: Before entering this dungeon you need to pay the necessary tokens.
- npc/scripts/mastery_voltagic.lua - misspelling 'avaiable'
  - was: There is no dungeon avaiable, please try again later.
  - now: There is no dungeon available, please try again later.

## Jami Stainback

- message_greet - wrong word 'hold', missing comma
  - was: You will not hold my Tsunami kid!
  - now: You won't withstand my Tsunami, kid!

## Jane Hills

- message_greet - broken sentence, wrong question mark
  - was: Whenever you can visit unusual places. There is always something hidden there?
  - now: Whenever you can, visit unusual places. There is always something hidden there!
- quest 8291 talk_questStarting - broken question form
  - was: Hey, you can bring some food for my Pokemon?
  - now: Hey, can you bring some food for my Pokemon?
- quest 8291 talk_questFinishing - wrong tense
  - was: Do you bring what I've asked?
  - now: Did you bring what I asked for?

## Janel Briony

- message_greet - 'let's ...?' awkward
  - was: Hello |PLAYERNAME|! I'm Janel Briony, let's {battle}?
  - now: Hello |PLAYERNAME|! I'm Janel Briony, shall we {battle}?

## Jarom

- npc/scripts/mastery_hurricane.lua - 'join into' is wrong
  - was: Do you want to join into the %s Mastery?
  - now: Do you want to join the %s Mastery?
- npc/scripts/mastery_hurricane.lua - broken grammar, unclear 'dismiss with'
  - was: You already has a mastery, if you want to join here first you need to dismiss with your mastery leader.
  - now: You already have a mastery. If you want to join here, you first need to leave it by talking to your mastery leader.
- npc/scripts/mastery_hurricane.lua - wrong preposition
  - was: Are you ready to the next level?
  - now: Are you ready for the next level?
- npc/scripts/mastery_hurricane.lua - wrong preposition
  - was: Are you ready to the dungeon?
  - now: Are you ready for the dungeon?
- npc/scripts/mastery_hurricane.lua - unclear 'dismiss with'
  - was: You need to dismiss with your mastery leader, not here.
  - now: You need to leave through your own mastery leader, not here.
- npc/scripts/mastery_hurricane.lua - Portuguese-ism
  - was: Your account must be with the premium days to join here.
  - now: Your account must have premium days to join here.
- npc/scripts/mastery_hurricane.lua - 'join into' is wrong
  - was: Do you really want to join into the %s Mastery?
  - now: Do you really want to join the %s Mastery?
- npc/scripts/mastery_hurricane.lua - 'win my assistant' wrong
  - was: You have already paid the necessary plates, now you need to win my assistant %s.
  - now: You have already paid the necessary plates, now you need to defeat my assistant %s.
- npc/scripts/mastery_hurricane.lua - Portuguese-ism question
  - was: To join into %s Mastery you will need %s. You're with them?
  - now: To join the %s Mastery you will need %s. Do you have them?
- npc/scripts/mastery_hurricane.lua - Portuguese-ism 'you're with them'
  - was: You do not have the necessary plates, come back here when you're with them. Remember that you must achieve %s points through our element plates.
  - now: You do not have the necessary plates, come back when you have them. Remember that you must reach %s points with our element plates.
- npc/scripts/mastery_hurricane.lua - 'win the dungeon' wrong
  - was: You have already paid the necessary tokens, now you need to win the {dungeon}.
  - now: You have already paid the necessary tokens, now you need to complete the {dungeon}.
- npc/scripts/mastery_hurricane.lua - broken grammar, Portuguese-isms
  - was: To advance in rank within the Mastery you need to prove that you're dominating it, joining %s tokens, you can get them by completing missions with the inhabitants of this base. You are already with the %s %s tokens?
  - now: To advance in rank within the Mastery you need to prove that you're mastering it by collecting %s tokens. You can get them by completing missions for the inhabitants of this base. Do you already have the %s %s tokens?
- npc/scripts/mastery_hurricane.lua - 'make the dungeon' wrong
  - was: Now you're ready to make the {dungeon} and prove that you are able to advance. When you are ready come talk to me.
  - now: Now you're ready to do the {dungeon} and prove that you are able to advance. When you are ready, come talk to me.
- npc/scripts/mastery_hurricane.lua - Portuguese-ism 'you're with them'
  - was: You do not have the necessary tokens, come back here when you're with them.
  - now: You do not have the necessary tokens, come back when you have them.
- npc/scripts/mastery_hurricane.lua - broken grammar
  - was: Before to this dungeon you need pay the necessary tokens.
  - now: Before entering this dungeon you need to pay the necessary tokens.
- npc/scripts/mastery_hurricane.lua - misspelling 'avaiable'
  - was: There is no dungeon avaiable, please try again later.
  - now: There is no dungeon available, please try again later.

## Jarrod

- quest 8310 talk_questStarting - awkward phrasing
  - was: Great, we are looking for trainers who can test our new inventions. How about you help us?
  - now: Great, we are looking for trainers who can test our new inventions. How about helping us?
- quest 8310 talk_questStarted - ambiguous 'throw them', run-on
  - was: Take the new poke balls and try to capture the Pokemon of our laboratory. What you need to do is get their attention and then throw them. You do not need to hurt them. When you're ready go through the door to the back of our lab, there are those poke balls and baits. Good luck!
  - now: Take the new poke balls and try to capture the Pokemon in our laboratory. Get their attention and then throw the balls. You do not need to hurt them. When you're ready, go through the door at the back of our lab; the poke balls and baits are there. Good luck!
- quest 8311 talk_questStarting - broken grammar
  - was: What do you think to help us again?
  - now: How about helping us again?
- quest 8311 talk_questStarted - broken grammar, unclear
  - was: Cool. All you need to do is bring the items to us. As soon as you bring some we manufacture for you! Items: 10x Electrizer, 5x Metal Spike, 50x Gear Wheel and 10x Magnet.
  - now: Cool. All you need to do is bring the items to us. As soon as you bring them, we'll make something for you! Items: 10x Electrizer, 5x Metal Spike, 50x Gear Wheel and 10x Magnet.

## Jaxon Amias

- message_greet - broken, confusing
  - was: Will not need it? We did. Which items to sell?
  - now: Don't need it anymore? We buy it. Which items do you want to sell?

## Jayla Nonie

- message_greet - wrong word, missing subject
  - was: I am creating Pokemon! When they become too strong will protect me!
  - now: I am raising Pokemon! When they become strong enough, they will protect me!

## Jayma Deniece

- message_greet - wrong verb form
  - was: Give nicknames to your Pokemon can be fun and an easy way to remember them!
  - now: Giving nicknames to your Pokemon can be fun and an easy way to remember them!

## Jeana Maxene

- message_greet - wrong tag question
  - was: Hello |PLAYERNAME|, Lichi fruits are very tasty, does not it?
  - now: Hello |PLAYERNAME|, Lichi fruits are very tasty, aren't they?
- quest 8230 talk_questFinished - wrong tense, missing comma
  - was: Thank you I'm so glad you bring me this wonderful Heracross! Here is the Lichi fruit.
  - now: Thank you, I'm so glad you brought me this wonderful Heracross! Here is the Lichi fruit.

## Jed Kaden

- message_greet - wrong words 'destiny', 'flow'
  - was: Hello, welcome to Pewter central trains! Tell your destiny! If you don't know where to flow, say {travel}.
  - now: Hello, welcome to Pewter central trains! Tell me your destination! If you don't know where to go, say {travel}.

## Jeffrey

- message_greet - broken word order
  - was: Welcome to the {Safari} Zone center, how I can help you?
  - now: Welcome to the {Safari} Zone center, how can I help you?
- npc/scripts/saffariZoneEnter.lua - incomplete question
  - was: Uh! The Safari Zone! I can take you there for %s dollars. Do you want?
  - now: Uh! The Safari Zone! I can take you there for %s dollars. Do you want to go?
- npc/scripts/saffariZoneEnter.lua - awkward grammar
  - was: Sorry, you can not enter in the Safari zone with any type of ball and small stones.
  - now: Sorry, you can not enter the Safari Zone carrying any type of ball or small stones.
- npc/scripts/saffariZoneEnter.lua - missing verb 'have'
  - was: You do not enough money.
  - now: You do not have enough money.

## Jenny

- message_greet - Portuguese-ism 'lose my time'
  - was: Please do not make me lose my time, give me your Pokemon!
  - now: Please do not waste my time, give me your Pokemon!

## Jess Dennis

- message_greet - misspelling 'exhcange', wrong preposition
  - was: Welcome to the Frontier Island! I'm here to exhcange your {frontier tokens} into {rewards}! Just type {options} to see.
  - now: Welcome to the Frontier Island! I'm here to exchange your {frontier tokens} for {rewards}! Just type {options} to see.
- npc/scripts/shop_frontierIsland.lua - broken grammar
  - was: Here is, thanks!
  - now: Here it is, thanks!

## Jessie Gambrel

- message_greet - awkward wording
  - was: My Onix and Rhydon will end any Pokemon that you can use! Hahaha!
  - now: My Onix and Rhydon will crush any Pokemon you use! Hahaha!

## Jett

- message_greet - wrong pronoun 'it'
  - was: Don't confuse it with some vine or weed man!
  - now: Don't confuse me with some vine or weed man!
- quest 8080 talk_questFinishing - broken question form
  - was: You got the items?
  - now: Did you get the items?

## Jewel Annice

- quest 8258 talk_questFinishing - broken question form
  - was: You find my Pokemon???
  - now: Did you find my Pokemon???

## Jimi

- message_greet - wrong word order
  - was: Hello |PLAYERNAME|. Do you know what is a {SOUL COIN}?
  - now: Hello |PLAYERNAME|. Do you know what a {SOUL COIN} is?

## Joe Tiff

- quest 8006 talk_questStarting - awkward phrasing
  - was: Uh, I need some items that contain a smell of nature, want to help me?
  - now: Uh, I need some items that smell of nature, want to help me?
- quest 8006 talk_questStarted - broken, Portuguese-ism
  - was: Alright, the items that I need are 13 pot of moss mug, back when you are with them.
  - now: Alright, the items that I need are 13 pot of moss mug, come back when you have them.
- quest 8006 talk_questFinishing - broken question form
  - was: You've got what I asked?
  - now: Have you got what I asked for?
- quest 8006 talk_questFinishFail - broken grammar, missing object
  - was: No..You do not have, go get the ingredients and return back to me.
  - now: No... You don't have them. Go get the ingredients and come back to me.

## Joel Morris

- message_greet - broken, confusing
  - was: Bought all the Pokemon. If you can not take care, we can help.
  - now: We buy all kinds of Pokemon. If you can't take care of them, we can help.

## Joetta Davina

- message_greet - 'let's ...?' awkward
  - was: Hello |PLAYERNAME|! I'm Joetta Davina, let's {battle}?
  - now: Hello |PLAYERNAME|! I'm Joetta Davina, shall we {battle}?

## Joey

- message_greet - broken question, wrong preposition
  - was: Hi |PLAYERNAME|, already made your {inscription} on the {tournaments}? If so, you can try to {enter} now or {exchange} your tournament tokens!
  - now: Hi |PLAYERNAME|, have you already made your {inscription} for the {tournaments}? If so, you can try to {enter} now or {exchange} your tournament tokens!
- npc/scripts/tournament.lua - wrong preposition, 'especial'
  - was: Here you can also exchange tournament tokens into especial items, you can see the {options}.
  - now: Here you can also exchange tournament tokens for special items, you can see the {options}.
- npc/scripts/tournament.lua - broken 'Here is!'
  - was: Here is! {NOTE: Every item that you buy here will be unique, this means that only you can use!}
  - now: Here it is! {NOTE: Every item that you buy here will be unique, this means that only you can use!}
- npc/scripts/tournament.lua - broken question form
  - was: In which tournament you want to sign up? (You can see the options saying {tournaments})
  - now: Which tournament do you want to sign up for? (You can see the options by saying {tournaments})
- npc/scripts/tournament.lua - wrong preposition
  - was: You really want to unsubscribe to the tournament?
  - now: Do you really want to unsubscribe from the tournament?
- npc/scripts/tournament.lua - wrong tense
  - was: This tournament already started!
  - now: This tournament has already started!
- npc/scripts/tournament.lua - 'enter in' wrong
  - was: You cannot enter in the tournament room while you are carrying Pokemon!
  - now: You cannot enter the tournament room while you are carrying Pokemon!
- npc/scripts/tournament.lua - 'enter in' wrong
  - was: You need at least %s Pokemon to enter in the tournament!
  - now: You need at least %s Pokemon to enter the tournament!
- npc/scripts/tournament.lua - wrong word order
  - was: Your team can not have Pokemon early evolved! (%s)
  - now: Your team can not have early-evolved Pokemon! (%s)
- npc/scripts/tournament.lua - awkward phrasing
  - was: Your team can not have two Pokemon alike!
  - now: Your team can not have two identical Pokemon!
- npc/scripts/tournament.lua - awkward grammar
  - was: You have Pokemon with low level for this tournament, the minimum is level %s.
  - now: Some of your Pokemon are below the level for this tournament, the minimum is level %s.
- npc/scripts/tournament.lua - awkward grammar
  - was: You have Pokemon with high level for this tournament, the maximum is level %s.
  - now: Some of your Pokemon are above the level for this tournament, the maximum is level %s.
- npc/scripts/tournament.lua - broken grammar
  - was: You can only take Pokemon that makes the type of your Mastery!
  - now: You can only take Pokemon of your Mastery's type!
- npc/scripts/tournament.lua - broken question form
  - was: You really want to join the %s tournament? (This will cost you %s dollars)
  - now: Do you really want to join the %s tournament? (This will cost you %s dollars)
- npc/scripts/tournament.lua - missing 'in'
  - was: Sorry, you do not have the minimum level to participate this tournament.
  - now: Sorry, you do not have the minimum level to participate in this tournament.
- npc/scripts/tournament.lua - Portuguese-ism 'inscribed'
  - was: You are already inscribed in a tournament, you can only inscribe in one tournament at a time. If you want to change the tournament, first {leave} your subscription.
  - now: You are already signed up for a tournament, you can only sign up for one tournament at a time. If you want to change tournaments, first {leave} your subscription.
- npc/scripts/tournament.lua - 'members players' redundant
  - was: Only Mastery members players can join this tournament!
  - now: Only Mastery members can join this tournament!
- npc/scripts/tournament.lua - awkward phrasing
  - was: It is done! You are subscribed, so stay tuned to the date of the tournament! Do not miss it.
  - now: It is done! You are subscribed, so keep an eye on the tournament date! Do not miss it.

## John Rouver

- quest 8002 talk_questStarting - broken grammar
  - was: I'm doing a collection of items and I having trouble finding some things, do you want help me?
  - now: I'm building a collection of items and I'm having trouble finding some things, do you want to help me?
- quest 8002 talk_questStarted - broken, Portuguese-ism
  - was: Ok, the items that I need are 10 bat wings, back when you are with them.
  - now: Ok, the items that I need are 10 bat wings, come back when you have them.
- quest 8002 talk_questFinishing - broken question form
  - was: You've got what I asked?
  - now: Have you got what I asked for?
- quest 8002 talk_questFinishFail - 'ingredients' wrong for a collection
  - was: First get the ingredients and later return here.
  - now: First get the items and then come back here.

## Josh Pillberg

- npc/scripts/vitamin_reset.lua - wrong apostrophe
  - was: I can reset your Pokemon vitamin's. Do you want that? This will cost %s soul coin.
  - now: I can reset your Pokemon's vitamins. Do you want that? This will cost %s soul coin.
- npc/scripts/vitamin_reset.lua - wrong tense, plural
  - was: Your Pokemon didn't have any vitamin.
  - now: Your Pokemon doesn't have any vitamins.

## Joss Wil

- message_greet - lowercase sentence start
  - was: Hello |PLAYERNAME|. want to sell plates? Just say {trade}.
  - now: Hello |PLAYERNAME|. Want to sell plates? Just say {trade}.

## Juanito Cruz

- message_greet - broken question form
  - was: Hello... you found my {letters}?
  - now: Hello... did you find my {letters}?
- npc/scripts/quest_juanitoCruz.lua - broken question, tense
  - was: You understand my dilemma? She did not want me anymore... and nothing I do can {help} me.
  - now: Do you understand my dilemma? She doesn't want me anymore... and nothing I do can {help} me.
- quest 8248 talk_questStarting - confusing phrasing
  - was: You want to find a reason for my life?
  - now: Will you help me find a reason to live?
- quest 8248 talk_questStarted - unclear instructions
  - was: I need a new reason to live... maybe a new person. Tereza is a great person...
  - now: I need a new reason to live... maybe a new person. Tereza is a great person... could you talk to her for me?
- quest 8248 talk_questFinishing - awkward phrasing
  - was: Did you find a reason for my life?
  - now: Did you find me a reason to live?
- quest 8248 talk_questFinished - missing comma
  - was: Thanks, here take this gift.
  - now: Thanks, here, take this gift.

## Juhn

- message_greet - 'little' missing noun
  - was: Hello little, brought my beer?
  - now: Hello little one, brought my beer?
- npc/scripts/quest_juhn.lua - broken word order
  - was: What? Ah, you say the islands south? Hicks! They are a tremendous young {adventure}! Hicks!
  - now: What? Ah, you mean the islands to the south? Hicks! They are a tremendous {adventure}, young one! Hicks!
- npc/scripts/quest_juhn.lua - broken grammar
  - was: There are many that I do not even like to talk about... I experienced every wonder that place. Are mountains, submerged islands, clouds, fire, water! Ya Ya! Me and my {Pokemon}... Hicks!
  - now: There are many I do not even like to talk about... I experienced every wonder of that place. Mountains, submerged islands, clouds, fire, water! Ya Ya! Me and my {Pokemon}... Hicks!
- npc/scripts/quest_juhn.lua - broken grammar
  - was: Hicks! There are many! They are quite different from those found here and many of them are not cataloged... Hicks! They are incredible powers and {evolutions}... My first one was captured Spinarak.
  - now: Hicks! There are many! They are quite different from those found here and many of them are not cataloged... Hicks! They have incredible powers and {evolutions}... The first one I captured was a Spinarak.
- npc/scripts/quest_juhn.lua - broken, confusing grammar
  - was: Look buddy... Hicks! Who understands... Hicks!... this is more about Denis. You can search it out there. I heard he... Hicks!... was afraid of things he saw there. You brought my beer?
  - now: Look buddy... Hicks! Who knows... Hicks!... that's more Denis's thing. You can look for him out there. I heard he... Hicks!... was afraid of the things he saw there. Did you bring my beer?

## Julia

- message_greet - wrong word order
  - was: Hey |PLAYERNAME|, how are you? Pokemon insects are part of my life, I want to collect them all!
  - now: Hey |PLAYERNAME|, how are you? Insect Pokemon are part of my life, I want to collect them all!
- quest 8046 talk_questStarting - wrong plural 'insects Pokemon'
  - was: The insects Pokemon are very slippery, I have a net to capture them! I can build one for you.
  - now: Insect Pokemon are very slippery, I use a net to capture them! I can build one for you.
- quest 8047 talk_questStarting - broken grammar, Portuguese-isms
  - was: The great hunters of insects spend days in a forest, for that they need to take a heavy equipment. You will not take everything in your arms, I can get you a backpack for it. Let's make a deal.
  - now: Great insect hunters spend days in the forest, so they need to carry heavy equipment. You can't carry everything in your arms, but I can get you a backpack for it. Let's make a deal.
- quest 8047 talk_questStarted - awkward 'give me back'
  - was: You give me back some rare items and I build a backpack for you. Bring me 100x Insect Skins and 150x Hard Nails.
  - now: You bring me some rare items and I'll build a backpack for you. Bring me 100x Insect Skins and 150x Hard Nails.
- quest 8047 talk_questFinished - broken 'here is'
  - was: Congratulations, here is.
  - now: Congratulations, here it is.

## Justin Flowers

- quest 8439 talk_questFinishing - broken question form
  - was: You could find the flute and wake up my Pokemon?
  - now: Did you find the flute and wake up my Pokemon?
- quest 8439 talk_questFinished - broken closing sentence
  - was: Thanks, now he can eat before going back to sleep and meditate. Thanks again, keep this to be a very nice trainer.
  - now: Thanks, now he can eat before going back to sleep and meditating. Thanks again, keep this for being a very nice trainer.
- quest 8439 talk_questFinishFail - nonsensical
  - was: Likes no.
  - now: Doesn't look like it.

## Kade Leland

- message_greet - 'let's ...?' awkward
  - was: Hello |PLAYERNAME|! I'm Kade Leland, let's {battle}?
  - now: Hello |PLAYERNAME|! I'm Kade Leland, shall we {battle}?

## Kane

- message_greet - unnatural phrasing
  - was: Take another underwear in your backpack, you're gonna need it! Hahahahahahha.
  - now: Pack some spare underwear in your backpack, you're gonna need it! Hahahahahahha.
- quest 8134 talk_questStarted - missing 'to'
  - was: Thanks! Your task is catch 2 Ekans and bring them to me.
  - now: Thanks! Your task is to catch 2 Ekans and bring them to me.
- quest 8134 talk_questFinishing - broken question form
  - was: The task is done?
  - now: Is the task done?
- quest 8135 talk_questStarted - missing 'to'
  - was: Thanks! Your task is catch 2 Nidorana and bring them to me.
  - now: Thanks! Your task is to catch 2 Nidorana and bring them to me.
- quest 8136 talk_questStarted - missing 'to'
  - was: Thanks! Your task is catch 2 Nidorano and bring them to me.
  - now: Thanks! Your task is to catch 2 Nidorano and bring them to me.
- quest 8137 talk_questStarted - missing 'to', wrong pronoun
  - was: Thanks! Your task is catch 1 Grimer and bring them to me.
  - now: Thanks! Your task is to catch 1 Grimer and bring it to me.
- quest 8138 talk_questStarted - missing 'to', wrong pronoun
  - was: Thanks! Your task is catch 1 Gastly and bring them to me.
  - now: Thanks! Your task is to catch 1 Gastly and bring it to me.

## Karaugh Janae

- message_greet - typo 'your' for 'you'
  - was: If a wild Pokemon appears your can try to fight it.
  - now: If a wild Pokemon appears you can try to fight it.

## Kate

- message_greet - broken grammar, no subject
  - was: Is aware of where you are? Haha!
  - now: Are you aware of where you are? Haha!

## Keir Jez

- message_greet - broken question form
  - was: Will not need this Stone?
  - now: Don't need this Stone anymore?

## Keira Toria

- message_greet - broken word order
  - was: Hello |PLAYERNAME|. How I can help you? Are you hungry or thirsty?
  - now: Hello |PLAYERNAME|. How can I help you? Are you hungry or thirsty?

## Keith Wiggs

- message_greet - 'after' should be 'later'
  - was: Hey |PLAYERNAME|, shhhh! I'm very busy now, talk to me after... unless you want to buy something.
  - now: Hey |PLAYERNAME|, shhhh! I'm very busy now, talk to me later... unless you want to buy something.

## Kelly Klemm

- message_greet - broken imperative
  - was: We are the most opportunistic, not lower your guard child.
  - now: We are the most opportunistic, don't lower your guard, child.

## Kemp Drummond

- message_greet - wrong preposition 'to'
  - was: Hello |PLAYERNAME|. Here you can {remove}, {change}, {recover} or {fix} your Pokemon Egg move! Also you can {generate} an Egg Move to an old Pokemon egg!
  - now: Hello |PLAYERNAME|. Here you can {remove}, {change}, {recover} or {fix} your Pokemon Egg move! You can also {generate} an Egg Move for an old Pokemon egg!
- npc/scripts/eggmove_remover.lua - broken grammar, 'it name'
  - was: Your Pokemon doesn't learned such move, please type again. Remember to type it name exactly!
  - now: Your Pokemon hasn't learned that move, please type it again. Remember to type its name exactly!
- npc/scripts/eggmove_remover.lua - broken question form
  - was: You really want to move the Egg Move %s from your %s to replace the move %s?
  - now: Do you really want to use the Egg Move %s of your %s to replace the move %s?
- npc/scripts/eggmove_remover.lua - broken, confusing grammar
  - was: Yes, I can change the move that your Pokemon forgot to learn a Egg move. What is your Pokemon move that you want to replace with that Egg Move? Type the name exactly!
  - now: Yes, I can change which move your Pokemon forgot to learn an Egg Move. Which of your Pokemon's moves do you want to replace with the Egg Move? Type the name exactly!
- npc/scripts/eggmove_remover.lua - awkward grammar
  - was: Here you can also generate an Egg Move to an old Pokemon from egg that you have. Do you want to do that?
  - now: Here you can also generate an Egg Move for an old Pokemon of yours hatched from an egg. Do you want to do that?
- npc/scripts/eggmove_remover.lua - missing 'one'
  - was: Yes, I can fix an Egg Move lost due to PokeVerse update changes. In this case, you will generate a new Egg Move if your Pokemon can't use the currently generated. Do you want to do that?
  - now: Yes, I can fix an Egg Move lost due to PokeVerse update changes. In this case, you will generate a new Egg Move if your Pokemon can't use the current one. Do you want to do that?
- npc/scripts/eggmove_remover.lua - broken question form
  - was: This will cost you %s dollars, you are sure?
  - now: This will cost you %s dollars, are you sure?
- npc/scripts/eggmove_remover.lua - wrong preposition
  - was: Please, put the poke ball at the ball slot!
  - now: Please, put the poke ball in the ball slot!
- npc/scripts/eggmove_remover.lua - broken grammar
  - was: This is not a Pokemon from egg!
  - now: This Pokemon did not hatch from an egg!
- npc/scripts/eggmove_remover.lua - verb agreement
  - was: Your Pokemon already have an Egg Move!
  - now: Your Pokemon already has an Egg Move!
- npc/scripts/eggmove_remover.lua - 'Pokemon ball at' wrong
  - was: Ya! First, put your Pokemon ball at the right ball slot. Ok, if you want to use a Plate to influence the generated Egg Move, type the Plate name. If you do not want to use a Plate, just type {none}.
  - now: Ya! First, put your poke ball in the right ball slot. Ok, if you want to use a Plate to influence the generated Egg Move, type the Plate name. If you do not want to use a Plate, just type {none}.
- npc/scripts/eggmove_remover.lua - 'carefully' should be 'careful'
  - was: Ok, be carefully now! DO YOU REALLY WANT TO TRY TO GENERATE AN EGG MOVE TO YOUR POKEMON USING A {%s} PLATE?
  - now: Ok, be careful now! DO YOU REALLY WANT TO TRY TO GENERATE AN EGG MOVE FOR YOUR POKEMON USING A {%s} PLATE?
- npc/scripts/eggmove_remover.lua - 'carefully' should be 'careful'
  - was: Ok, be carefully now! DO YOU REALLY WANT TO TRY TO GENERATE AN EGG MOVE TO YOUR POKEMON USING {NO} PLATE?
  - now: Ok, be careful now! DO YOU REALLY WANT TO TRY TO GENERATE AN EGG MOVE FOR YOUR POKEMON USING {NO} PLATE?
- npc/scripts/eggmove_remover.lua - broken question form
  - was: YOU REALLY WANT TO REMOVE YOUR POKEMON EGG MOVE? HE WILL NEVER BE ABLE TO LEARN ANOTHER EGG MOVE!
  - now: DO YOU REALLY WANT TO REMOVE YOUR POKEMON'S EGG MOVE? HE WILL NEVER BE ABLE TO LEARN ANOTHER EGG MOVE!
- npc/scripts/eggmove_remover.lua - missing article
  - was: You aren't owner of this item.
  - now: You aren't the owner of this item.
- npc/scripts/eggmove_remover.lua - missing plural
  - was: Here you can {remove}, {change} and {recover} Egg move from your Pokemon!
  - now: Here you can {remove}, {change} and {recover} Egg moves of your Pokemon!

## Kenelm Reilly

- message_greet - Portuguese-ism, wrong word order
  - was: Hello |PLAYERNAME|! All right? Uepa! I am a world-renowned scientist for my {research}! Yes! Yes!
  - now: Hello |PLAYERNAME|! How are you? Uepa! I am a scientist world-renowned for my {research}! Yes! Yes!
- quest 8723 talk_questStarted - awkward word order
  - was: Very cool! That's right! Look for me the following: 5x Bitten Apple and 5x Mouldy Cheese.
  - now: Very cool! That's right! Find me the following: 5x Bitten Apple and 5x Mouldy Cheese.
- quest 8723 talk_questFinished - Portuguese-ism 'That!'
  - was: That! Thank you, take your reward. My {research} will be a success!
  - now: That's it! Thank you, take your reward. My {research} will be a success!
- quest 8723 talk_questFinishFail - broken phrasing
  - was: Looks like no.
  - now: Looks like you don't.
- quest 8724 talk_questStarting - broken question form
  - was: Since you have so much interest, I will tell you. But before that, do one more favor?
  - now: Since you have so much interest, I will tell you. But before that, could you do me one more favor?
- quest 8724 talk_questFinishing - broken question form
  - was: So fast, you got it all?
  - now: So fast, did you get it all?
- quest 8725 talk_questStarted - awkward 'they are'
  - was: Actually they are two things, haha! 40x Water Gem and 40x Bottle of Poison.
  - now: Actually it's two things, haha! 40x Water Gem and 40x Bottle of Poison.
- quest 8725 talk_questFinishing - broken question form
  - was: My friend, you have everything there?
  - now: My friend, do you have everything there?

## Kimberly Downson

- quest 8329 talk_questStarting - broken grammar
  - was: You can help me with something that come bothering my family?
  - now: Can you help me with something that's been bothering my family?
- quest 8329 talk_questStarted - awkward prepositions
  - was: Great. Our residence is suffering from an infestation of some Rattatas. I know you can handle it. I need you to go down in the basement and turn on the machine that is there, the key is inside one of the trunks.
  - now: Great. Our house is suffering from a Rattata infestation. I know you can handle it. I need you to go down to the basement and turn on the machine there, the key is inside one of the trunks.
- quest 8329 talk_questFinishing - contradicts 'turn on' instructions
  - was: Did you fix my machine?
  - now: Did you turn on my machine?

## Koby

- npc/scripts/mastery_zen.lua - 'join into' is wrong
  - was: Do you want to join into the %s Mastery?
  - now: Do you want to join the %s Mastery?
- npc/scripts/mastery_zen.lua - broken grammar, unclear 'dismiss with'
  - was: You already has a mastery, if you want to join here first you need to dismiss with your mastery leader.
  - now: You already have a mastery. If you want to join here, you first need to leave it by talking to your mastery leader.
- npc/scripts/mastery_zen.lua - wrong preposition
  - was: Are you ready to the next level?
  - now: Are you ready for the next level?
- npc/scripts/mastery_zen.lua - wrong preposition
  - was: Are you ready to the dungeon?
  - now: Are you ready for the dungeon?
- npc/scripts/mastery_zen.lua - unclear 'dismiss with'
  - was: You need to dismiss with your mastery leader, not here.
  - now: You need to leave through your own mastery leader, not here.
- npc/scripts/mastery_zen.lua - Portuguese-ism
  - was: Your account must be with the premium days to join here.
  - now: Your account must have premium days to join here.
- npc/scripts/mastery_zen.lua - 'join into' is wrong
  - was: Do you really want to join into the %s Mastery?
  - now: Do you really want to join the %s Mastery?
- npc/scripts/mastery_zen.lua - 'win my assistant' wrong
  - was: You have already paid the necessary plates, now you need to win my assistant %s.
  - now: You have already paid the necessary plates, now you need to defeat my assistant %s.
- npc/scripts/mastery_zen.lua - Portuguese-ism question
  - was: To join into %s Mastery you will need %s. You're with them?
  - now: To join the %s Mastery you will need %s. Do you have them?
- npc/scripts/mastery_zen.lua - Portuguese-ism 'you're with them'
  - was: You do not have the necessary plates, come back here when you're with them. Remember that you must achieve %s points through our element plates.
  - now: You do not have the necessary plates, come back when you have them. Remember that you must reach %s points with our element plates.
- npc/scripts/mastery_zen.lua - 'win the dungeon' wrong
  - was: You have already paid the necessary tokens, now you need to win the {dungeon}.
  - now: You have already paid the necessary tokens, now you need to complete the {dungeon}.
- npc/scripts/mastery_zen.lua - broken grammar, Portuguese-isms
  - was: To advance in rank within the Mastery you need to prove that you're dominating it, joining %s tokens, you can get them by completing missions with the inhabitants of this base. You are already with the %s %s tokens?
  - now: To advance in rank within the Mastery you need to prove that you're mastering it by collecting %s tokens. You can get them by completing missions for the inhabitants of this base. Do you already have the %s %s tokens?
- npc/scripts/mastery_zen.lua - 'make the dungeon' wrong
  - was: Now you're ready to make the {dungeon} and prove that you are able to advance. When you are ready come talk to me.
  - now: Now you're ready to do the {dungeon} and prove that you are able to advance. When you are ready, come talk to me.
- npc/scripts/mastery_zen.lua - Portuguese-ism 'you're with them'
  - was: You do not have the necessary tokens, come back here when you're with them.
  - now: You do not have the necessary tokens, come back when you have them.
- npc/scripts/mastery_zen.lua - broken grammar
  - was: Before to this dungeon you need pay the necessary tokens.
  - now: Before entering this dungeon you need to pay the necessary tokens.
- npc/scripts/mastery_zen.lua - misspelling 'avaiable'
  - was: There is no dungeon avaiable, please try again later.
  - now: There is no dungeon available, please try again later.

## Koga

- npc/scripts/npcbattle_koga.lua - wrong verb form
  - was: You must defeat me before receive your reward.
  - now: You must defeat me before receiving your reward.
- npc/scripts/npcbattle_koga.lua - broken 'here is'
  - was: Oh, here is!
  - now: Oh, here it is!
- quest 8473 talk_questStarting - missing object 'it'
  - was: I need to recover some Blue Pollen for an experiment. Can you collect for me?
  - now: I need to gather some Blue Pollen for an experiment. Can you collect it for me?
- quest 8473 talk_questFinishFail - nonsensical
  - was: Likes no.
  - now: Doesn't look like it.

## Kris Sandy

- message_greet - broken word order
  - was: Hello |PLAYERNAME|. How I can help you? Are you hungry or thirsty?
  - now: Hello |PLAYERNAME|. How can I help you? Are you hungry or thirsty?

## Kurt Bufford

- message_greet - broken, confusing sentence
  - was: Whenever I need to come to energize Gym, the best place for electric Pokemon!
  - now: Whenever I need energy I come to this Gym, the best place for electric Pokemon!

## Kurt Fastman McGaryson

- quest 8295 talk_questStarting - Portuguese-ism
  - was: Cool on your part, you want to earn some money helping me?
  - now: Cool of you, do you want to earn some money helping me?
- quest 8295 talk_questStarted - wrong preposition, fragment
  - was: Cool! You have to deliver newspapers for 10 people. In the Orange Archipelago, do not forget. The names are in this list. Are you ready? Go, go!
  - now: Cool! You have to deliver newspapers to 10 people in the Orange Archipelago, don't forget. The names are on this list. Are you ready? Go, go!
- quest 8295 talk_questFinished - awkward phrasing
  - was: Yup! You could perform all deliveries! Take your money. Incidentally, I always need help. Come back tomorrow and you can help me again.
  - now: Yup! You made all the deliveries! Take your money. By the way, I always need help. Come back tomorrow and you can help me again.
- quest 8296 talk_questStarting - broken 'This time is important'
  - was: You completed your 10th delivery! Cool, now you can do another favor for me! This time is important, and I'll tell you something very important. You in?
  - now: You completed your 10th delivery! Cool, now you can do another favor for me! This one is important, and I'll tell you something very important. You in?
- quest 8296 talk_questStarted - wrong prepositions and articles
  - was: Great. Give this special newspaper for a great client. He lives on the Butwal Island inside a underground house. Once finished, return. Oh, his name is Bud Jude.
  - now: Great. Give this special newspaper to a great client. He lives on Butwal Island in an underground house. Once finished, come back. Oh, his name is Bud Jude.
- quest 8296 talk_questFinishing - wrong tense
  - was: Do you bring what I've asked?
  - now: Did you bring what I asked for?

## Kurt Petrillose

- npc/scripts/fi_stadiumarena.lua - awkward 'to test for'
  - was: You're in the Frontier Island, an appropriate location to test for the continent's greatest Pokemon trainers. Prove your strength here and you will be rewarded.
  - now: You're on the Frontier Island, the right place to test the continent's greatest Pokemon trainers. Prove your strength here and you will be rewarded.
- npc/scripts/fi_stadiumarena.lua - awkward phrasing
  - was: In Gladiator mode you face several challenges in the best singleplayer mode. If you want this challenge, say 'enter'.
  - now: In Gladiator mode you face several challenges alone, in singleplayer mode. If you want this challenge, say 'enter'.
- npc/scripts/fi_stadiumarena.lua - broken question form
  - was: Right! What Cooperative mode you want? Your options are: {Elite}(4 players) and {Titan}(6 players).
  - now: Right! Which Cooperative mode do you want? Your options are: {Elite}(4 players) and {Titan}(6 players).
- npc/scripts/fi_stadiumarena.lua - broken question form
  - was: What Survive mode you want? Your options are: {Challenge}(PvP - %s players) and {Hardcore}(PvP and PvE - %s players).
  - now: Which Survive mode do you want? Your options are: {Challenge}(PvP - %s players) and {Hardcore}(PvP and PvE - %s players).
- npc/scripts/fi_stadiumarena.lua - awkward word order
  - was: Sorry, there is no arena free now. Please, try again later.
  - now: Sorry, there is no free arena right now. Please, try again later.
- npc/scripts/fi_stadiumarena.lua - misspelling 'Premmium'
  - was: Sorry, only Premmium Accounts can join this challenge.
  - now: Sorry, only Premium Accounts can join this challenge.
- npc/scripts/fi_stadiumarena.lua - 'got wrong' should be 'went wrong'
  - was: Something got wrong, please try again later.
  - now: Something went wrong, please try again later.
- npc/scripts/fi_stadiumarena.lua - broken grammar
  - was: You are not the leader of your Party! Only the group leader who can enroll in cooperative mode.
  - now: You are not the leader of your Party! Only the group leader can enroll in cooperative mode.
- npc/scripts/fi_stadiumarena.lua - broken grammar
  - was: Your group haven't 4 members! You can only enroll in cooperative mode with 4 members in the Party.
  - now: Your group doesn't have 4 members! You can only enroll in cooperative mode with 4 members in the Party.
- npc/scripts/fi_stadiumarena.lua - awkward grammar
  - was: You can't enter while you or your Party members aren't at least level %s.
  - now: You can't enter unless you and your Party members are at least level %s.
- npc/scripts/fi_stadiumarena.lua - broken grammar
  - was: You can't enter while you or your Party members haven't a Premium Account.
  - now: You can't enter unless you and your Party members have a Premium Account.
- npc/scripts/fi_stadiumarena.lua - verb agreement
  - was: You can't enter while one of your party members are too far from you!
  - now: You can't enter while one of your party members is too far from you!
- npc/scripts/fi_stadiumarena.lua - grammar; contradicts 6 vs 4
  - was: Your group haven't 6 members! You can only enroll in cooperative mode with 4 members in the Party.
  - now: Your group doesn't have 6 members! You can only enroll in this cooperative mode with 6 members in the Party.

## Lake Dan

- message_greet - 'exchange into' wrong preposition
  - was: Welcome to the Hurricane Mastery! Here you can exchange your hurricane tokens into rewards. Type {options} to see.
  - now: Welcome to the Hurricane Mastery! Here you can exchange your hurricane tokens for rewards. Type {options} to see.

## Lance Trevathan

- message_greet - 'Do not you dare' wrong word order
  - was: Do not you dare underestimate the power of fire.
  - now: Don't you dare underestimate the power of fire.

## Larry

- message_greet - question word order
  - was: Hello |PLAYERNAME|. What I can do for you?
  - now: Hello |PLAYERNAME|. What can I do for you?

## Layne Izzy

- message_greet - 'Tell dear' unnatural
  - was: Tell dear, Layne has what you need. Remember that only premium account players can wear these clothes!
  - now: Tell me, dear, Layne has what you need. Remember that only premium account players can wear these clothes!

## Lenard

- message_greet - 'let's ... ?' unnatural question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, want to trade your soul coins?

## Leon

- message_greet - question word order
  - was: Hello |PLAYERNAME|. What I can do for you?
  - now: Hello |PLAYERNAME|. What can I do for you?

## Leroi Bradley

- npc/scripts/wavearena.lua - broken phrasing
  - was: You have reached the maximum daily attempt of %s times! Try again tomorrow.
  - now: You have reached the maximum of %s attempts for today! Try again tomorrow.
- npc/scripts/wavearena.lua - awkward phrasing
  - was: Sorry, there is no arena free now. Please, try again later.
  - now: Sorry, there is no free arena right now. Please try again later.
- npc/scripts/wavearena.lua - misspelling 'Premmium'
  - was: Sorry, only Premmium Accounts can join this game.
  - now: Sorry, only Premium Accounts can join this game.
- npc/scripts/wavearena.lua - wrong apostrophe, awkward
  - was: One of your account character's already played the Colosseum Arena today! Please try again tomorrow.
  - now: One of the characters on your account already played the Colosseum Arena today! Please try again tomorrow.
- npc/scripts/wavearena.lua - 'got wrong' should be 'went wrong'
  - was: Something got wrong, please try again later.
  - now: Something went wrong, please try again later.

## Lia

- quest 8450 talk_questFinishing - 'Did you destroyed' grammar
  - was: Did you destroyed the wardrobes?
  - now: Did you destroy the wardrobes?
- quest 8450 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you don't have it yet.

## Lonnie Boedeker

- message_greet - confusing, nonsensical sentence
  - was: Do you think that supports the strength of an entire mountain cockerel?
  - now: Do you think you can withstand the strength of an entire mountain?

## Lonnie Lasko

- message_greet - nonsensical sentence
  - was: Do not cover much, we know you can not.
  - now: Don't push yourself too hard, we know you can't do it.

## Lonnie Pretti

- message_greet - missing subject, broken grammar
  - was: Are mere illusions, but are large and confuses your inner self.
  - now: They are mere illusions, but they are great and confuse your inner self.

## Lonnie Wooton

- message_greet - missing comma
  - was: Watch your step |PLAYERNAME| you're so careless.
  - now: Watch your step, |PLAYERNAME|, you're so careless.

## Lou

- message_greet - 'let's ... ?' unnatural question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, want to trade your soul coins?

## Lt. Surge

- npc/scripts/npcbattle_ltsurge.lua - 'before receive' grammar
  - was: You must defeat me before receive your reward.
  - now: You must defeat me before you receive your reward.
- npc/scripts/npcbattle_ltsurge.lua - 'here is' incomplete
  - was: Oh, here is!
  - now: Oh, here it is!
- quest 8471 talk_questStarting - broken grammar throughout
  - was: One of my main batteries are presenting a low level of energy to continue operating here in the gym. I got one to replace, but it is not as strong as this. You think that can help me?
  - now: One of my main batteries has too little energy to keep running here in the gym. I got a replacement, but it's not as strong as this one. Do you think you can help me?
- quest 8471 talk_questStarted - broken grammar, unclear
  - was: The task is simple soldier! You need to defeat the Electric type Pokemon to energize my battery, use the battery on them after defeat. Note that as greater the Pokemon level, greater the energy absorbed! When you finish the task you will receive a message about your success. Return to me and receive something in return for this task.
  - now: The task is simple, soldier! Defeat Electric type Pokemon and use the battery on them after they faint to energize it. The higher the Pokemon's level, the more energy absorbed! You'll get a message when you're done. Then return to me for your reward.
- quest 8471 talk_questFinishing - 'Did you got' grammar
  - was: Did you got the energy?
  - now: Did you get the energy?
- quest 8471 talk_questFinished - broken grammar
  - was: That is it soldier, we need efficient people in this way. Take reward is and use it wisely.
  - now: That's it, soldier, we need efficient people like you. Take your reward and use it wisely.
- quest 8471 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you don't have it yet.

## Ludwik Bishan

- message_greet - question word order
  - was: Hey |PLAYERNAME|, how I can help? You can buy bikes here, just say {trade}.
  - now: Hey |PLAYERNAME|, how can I help? You can buy bikes here, just say {trade}.

## Luis

- message_greet - question word order
  - was: Hello |PLAYERNAME|. What I can do for you?
  - now: Hello |PLAYERNAME|. What can I do for you?

## Luka

- message_greet - misspelling 'conection'
  - was: This conection we all use is so interesting. Ah, I adore seeing the powers of the mind.
  - now: This connection we all use is so interesting. Ah, I adore seeing the powers of the mind.

## Luke

- message_greet - lowercase sentence start
  - was: Hello |PLAYERNAME|. want to sell plates? Just say {trade}.
  - now: Hello |PLAYERNAME|. Want to sell plates? Just say {trade}.

## Luken

- message_greet - stray punctuation
  - was: Yes?.
  - now: Yes?
- quest 8449 talk_questStarted - 'basement floors' unclear
  - was: Some Haunters are living in my basement floors. Light all the torches down there with some of your Fire Pokemon and I will be very grateful.
  - now: Some Haunters are living in my basement. Light all the torches down there with one of your Fire Pokemon and I will be very grateful.
- quest 8449 talk_questFinishing - question lacks auxiliary
  - was: You lit the torches?
  - now: Did you light the torches?
- quest 8449 talk_questFinished - misspelling 'Thankss'
  - was: Thankss!
  - now: Thanks!
- quest 8449 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you don't have it yet.

## Luther Lacey

- quest 8468 talk_questFinishing - tense, word choice
  - was: Ah yes, Misty had made me a bow order. Very well. You brought all necessary items?
  - now: Ah yes, Misty ordered a bow from me. Very well. Did you bring all the necessary items?
- quest 8468 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you don't have it yet.
- quest 8469 talk_questFinishFail - slightly unnatural
  - was: The bow isn't ready.
  - now: The bow isn't ready yet.

## Lyle

- message_greet - question word order
  - was: Hello |PLAYERNAME|. What I can do for you?
  - now: Hello |PLAYERNAME|. What can I do for you?

## Mack

- message_greet - question word order
  - was: Hello |PLAYERNAME|. What I can do for you?
  - now: Hello |PLAYERNAME|. What can I do for you?

## Mack Edmund

- message_greet - broken grammar
  - was: Like trinket house! It has everything!
  - now: Welcome to the trinket house! It has everything!

## Madelyn Fawn

- message_greet - 'let's ... ?' unnatural
  - was: Hello |PLAYERNAME|! I'm Madelyn Fawn, let's {battle}?
  - now: Hello |PLAYERNAME|! I'm Madelyn Fawn, want to {battle}?

## Margery Meidinger

- message_greet - 'if it pass me' broken
  - was: The leader awaits... if it pass me by. Hahahaha!
  - now: The leader awaits... if you get past me. Hahahaha!

## Martha May

- npc/scripts/quest_marthaMay.lua - many grammar errors, run-on
  - was: Then he wrote a letter to me? He still loves me, why he never sent me the letter? ... Well I will tell you about the Grinch, he was born different but it was always affectionate, we fell in love, but people did not like the situation pro he was different, then at Christmas made a bad joke with him that ended up hurting his feelings, he ran away and was never seen again, you know where he {hides}?
  - now: So he wrote me a letter? He still loves me, why did he never send it? ... Well, I'll tell you about the Grinch. He was born different but was always affectionate, and we fell in love, but people didn't like it because he was different. Then one Christmas they played a cruel joke on him that hurt his feelings, and he ran away and was never seen again. Do you know where he {hides}?
- quest 8568 talk_questStarting - garbled sentence
  - was: Then I will tell him some secrets and you can help me recover and the real Grinch. Well he likes walnut cake with strawberry, could you bring me the ingredients for me to make a cake for him, would you help me?
  - now: Then I'll tell you some of his secrets so you can help me bring back the real Grinch. He loves walnut cake with strawberries. Could you bring me the ingredients so I can bake him one?
- quest 8568 talk_questFinished - broken grammar
  - was: Well, now has another secret about him.
  - now: Well, now here's another secret about him.
- quest 8568 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you don't have it yet.
- quest 8569 talk_questStarting - '5 sample' plural, run-on
  - was: He is very fond of lemonade with honey, could you bring me 5 lemons and 5 sample of sand wasp honey?
  - now: He is very fond of lemonade with honey. Could you bring me 5 lemons and 5 samples of sand wasp honey?
- quest 8569 talk_questStarted - '5 sample' plural
  - was: So bring me 5 lemons and 5 sample of sand wasp honey.
  - now: So bring me 5 lemons and 5 samples of sand wasp honey.
- quest 8569 talk_questFinished - awkward tense
  - was: Wow, you are amazing, we'll need another favor.
  - now: Wow, you are amazing! I'll need another favor.
- quest 8570 talk_questStarting - question word order
  - was: You could help me?
  - now: Could you help me?
- quest 8570 talk_questStarted - broken grammar
  - was: The Grinch loved toasty warm socks made of exclusive materials, will need to 5 balls of wool and 2 spider silks, you can get me that?
  - now: The Grinch loves toasty warm socks made of exclusive materials. I'll need 5 balls of wool and 2 spider silks. Can you get me those?
- quest 8571 talk_questStarting - broken grammar
  - was: This letter must give it to him, along with the cake, juice and socks, you can do this?
  - now: You must give him this letter, along with the cake, the lemonade and the socks. Can you do this?
- quest 8571 talk_questStarted - garbled sentence
  - was: I would be very grateful for that, and you would be helping the poor Grinch that is so sad that cave, take this key here, I have always seen him without him noticing me and I saw him take down this key once.
  - now: I would be very grateful, and you'd be helping the poor Grinch who is so sad in that cave. Take this key. I've watched him without him noticing, and once I saw him drop this key.
- quest 8571 talk_questFinishing - garbled question
  - was: So he likes and is repentant of his wickedness?
  - now: So he liked it and regrets his wickedness?
- quest 8571 talk_questFinished - run-on, awkward
  - was: I knew he was good after all, he'll wait anxiously, thanks again, you helped a lot, now go find him as agreed.
  - now: I knew he was good after all! He'll be waiting anxiously. Thanks again, you helped a lot. Now go find him as agreed.

## Mary Nady

- quest 8005 talk_questStarting - 'experience' for experiment, grammar
  - was: Uh, I do not usually do this but .. I'm running a science event and I need some items to finish my experience, do you want help me?
  - now: Uh, I don't usually do this but... I'm running a science event and I need some items to finish my experiment. Do you want to help me?
- quest 8005 talk_questStarted - 'back when you are' broken
  - was: Ok, the items that I need are 50 water gems and 50 bottles of poison, back when you are with them.
  - now: Ok, the items I need are 50 water gems and 50 bottles of poison. Come back when you have them.
- quest 8005 talk_questFinishing - question word order
  - was: You've got what I asked?
  - now: Have you got what I asked for?
- quest 8005 talk_questFinishFail - broken grammar
  - was: No..You do not have, go get the ingredients and return back to me.
  - now: No... you don't have them. Go get the ingredients and come back to me.

## Mary Vinn

- quest 8003 talk_questStarting - run-on, awkward
  - was: My family was famous for having an extensive collection of Pokemon teeth, I'm very busy lately and I need help to collect some teeth..want to join me in this journey? Maybe I will reward you.
  - now: My family was famous for its extensive collection of Pokemon teeth. I'm very busy lately and need help collecting some teeth... want to join me on this journey? Maybe I will reward you.
- quest 8003 talk_questStarted - 'back when you are' broken
  - was: Ok, the items that I need are 15 teeth, back when you are with them.
  - now: Ok, the item I need is 15 teeth. Come back when you have them.
- quest 8003 talk_questFinishing - question word order
  - was: You've got what I asked?
  - now: Have you got what I asked for?
- quest 8003 talk_questFinishFail - broken grammar
  - was: No.. you do not have, back when you are with them.
  - now: No... you don't have them. Come back when you do.

## Marylou Whitbeck

- message_greet - '...you?' unclear
  - was: I like to explore caves and hidden grottoes... you?
  - now: I like to explore caves and hidden grottoes... do you?

## Mateo

- npc/scripts/quest_mateo.lua - 'Here is' incomplete
  - was: Here is! When you finish what you're doing, come talk to me!
  - now: Here it is! When you finish what you're doing, come talk to me!
- npc/scripts/quest_mateo.lua - missing period
  - was: I can't sell you this right now, please check your backpack
  - now: I can't sell you this right now, please check your backpack.
- quest 8326 talk_questStarting - garbled instruction
  - was: They say that the Crystal Onix actually exists. If you can find it back here and talk to me, ok?
  - now: They say the Crystal Onix actually exists. If you find it, come back here and talk to me, ok?
- quest 8326 talk_questStarted - awkward, unclear
  - was: Take this camera to prove that it even exists. Have you ever heard of a Pokemon researcher named Merv Kelley? It would be nice to know new information with him.
  - now: Take this camera to prove that it really exists. Have you ever heard of a Pokemon researcher named Merv Kelley? He might have some new information for you.
- quest 8326 talk_questFinishing - 'Do you bring' tense
  - was: Do you bring what I've asked?
  - now: Did you bring what I asked for?

## Matt

- message_greet - 'suppliers' should be 'supplies'
  - was: My suppliers arrived today, enjoy!
  - now: My supplies arrived today, enjoy!

## Maurice

- npc/scripts/quest_maurice.lua - 'You already done', 'do you want?'
  - was: You already done this mission. If you need I can sell you another TV Camera for 1000 dollars, do you want?
  - now: You already did this mission. If you need, I can sell you another TV Camera for 1000 dollars. Do you want it?
- npc/scripts/quest_maurice.lua - 'Here is' incomplete
  - was: Here is.
  - now: Here it is.
- quest 8034 talk_questStarting - 'only one' for 'only thing', grammar
  - was: I can build a TV camera for you. The only one that you need to do is get some parts for me. Do you want?
  - now: I can build a TV camera for you. The only thing you need to do is get some parts for me. Do you want that?
- quest 8034 talk_questFinishing - question word order
  - was: You got the parts that I need?
  - now: Did you get the parts that I need?
- quest 8034 talk_questFinished - 'Make good use' incomplete
  - was: Well done! Here's your camera! Make good use.
  - now: Well done! Here's your camera! Make good use of it.

## Max Fegan

- message_greet - missing subject 'could come'
  - was: Hello |PLAYERNAME|, I'm going through some difficulties right now, could come back another time?
  - now: Hello |PLAYERNAME|, I'm going through some difficulties right now, could you come back another time?
- quest 8315 talk_questStarting - garbled; names inconsistent
  - was: The enclosure where my Miltanks was broke and I was going to the Mikan island take the tablets with Courtes Ted joiner to make the new fence, but I'm afraid to leave my Miltanks alone. You could go there and pick up the boards for me?
  - now: The enclosure for my Miltanks broke, and I was going to Mikan Island to pick up boards from Woodworker Courts Ted to make a new fence, but I'm afraid to leave my Miltanks alone. Could you go there and pick up the boards for me?
- quest 8315 talk_questStarted - unclear instruction
  - was: His name is Woodworker Courts Ted.
  - now: Go to Mikan Island and see the woodworker. His name is Woodworker Courts Ted.
- quest 8319 talk_questStarting - question word order
  - was: You will make another delivery?
  - now: Will you make another delivery?
- quest 8319 talk_questFinished - 'deliver' should be 'delivery'
  - was: Now you need to do one more deliver.
  - now: Now you need to do one more delivery.
- quest 8322 talk_questStarted - 'in your back' wrong phrase
  - was: Cool, I think I have a surprise for you in your back. Go in peace.
  - now: Cool, I think I'll have a surprise for you when you're back. Go in peace.
- quest 8322 talk_questFinished - broken grammar, run-on
  - was: Great! Thanks for helping me in this. As a reward I will give you the chance to win one of Miltank eggs we produce here. Every 24 hours bring me 50 oranges, they like a lot. Once you bring the oranges, come back in 24 hours and I'll tell you if got your egg. We agree? Great, good luck!
  - now: Great! Thanks for helping me with this. As a reward, I'll give you the chance to win one of the Miltank eggs we produce here. Every 24 hours, bring me 50 oranges, they love them. Once you bring the oranges, come back in 24 hours and I'll tell you if you got your egg. Deal? Great, good luck!
- quest 8324 talk_questStarting - question word order
  - was: You want to bring some oranges for my Miltanks?
  - now: Do you want to bring some oranges for my Miltanks?
- quest 8324 talk_questFinishing - question word order
  - was: You got the oranges?
  - now: Did you get the oranges?

## Max Tippins

- message_greet - missing comma, unclear
  - was: Look around |PLAYERNAME|, it will consume you all soon!
  - now: Look around, |PLAYERNAME|, it will consume you all soon!

## Mel

- message_greet - broken grammar
  - was: Welcome to Tangelo. What will need comrade?
  - now: Welcome to Tangelo. What do you need, comrade?

## Melisa Atkin

- message_greet - '24h followed' Portuguese-ism
  - was: I am able to surf 24h followed!
  - now: I can surf 24 hours straight!

## Merv Kelley

- npc/scripts/quest_mervKelley.lua - broken grammar
  - was: Hello |PLAYERNAME|, my name is Merv Kelley, I'm a Pokemon researcher, currently study on the behavior of Pokemon insects when feed with fruits, but I'm now experiencing terrible {problems}.
  - now: Hello |PLAYERNAME|, my name is Merv Kelley, I'm a Pokemon researcher. I'm currently studying the behavior of bug Pokemon when fed with fruits, but now I'm having terrible {problems}.
- npc/scripts/quest_mervKelley.lua - 'behind it' Portuguese-ism
  - was: Hey! Have you heard the latest rumors? There is a mysterious legend in the Orange Archipelago, my friend Adventurer Lucy has not slept in days behind it.
  - now: Hey! Have you heard the latest rumors? There is a mysterious legend in the Orange Archipelago. My friend Adventurer Lucy hasn't slept in days chasing it.
- quest 8226 talk_questStarting - misspelling 'Saffari', word order
  - was: My father, who started this research a long time ago, had hidden one fruit recipe inside a secret place in the Kanto Saffari Zone, I don't know where is the secret area. You want to look for that recipe for me?
  - now: My father, who started this research a long time ago, hid a fruit recipe in a secret place in the Kanto Safari Zone, but I don't know where the secret area is. Do you want to look for that recipe for me?
- quest 8226 talk_questFinished - 'seed' unclear, singular
  - was: Great, you got the recipe! Now with the recipe I will produce enough seed to complete the study that my father started. I'm just a bit puzzled by the {ingredients}.
  - now: Great, you got the recipe! Now with it I can produce enough seeds to complete the study my father started. I'm just a bit puzzled by the {ingredients}.
- quest 8227 talk_questStarting - run-on, awkward
  - was: I have a good part of the ingredients, but there are three that will be difficult for me to get because they are in other islands and I can not leave here, I need to continue my study. Would you like to help me get the three ingredients that remain?
  - now: I have most of the ingredients, but three will be hard for me to get because they're on other islands, and I can't leave here, I need to continue my study. Would you like to help me get the three remaining ingredients?
- quest 8227 talk_questStarted - 'elderly trees', awkward
  - was: Well, the ingredients that remain are a result of three elderly trees from Orange Archipelago. These trees are well known for having a delicious fruit and are still alive after a long time. Your first mission will be to bring the Lichi fruit, located in Wayne family land north of the Ascorbia Island.
  - now: Well, the remaining ingredients come from three ancient trees in the Orange Archipelago. These trees are famous for their delicious fruit and have lived for a very long time. Your first mission is to bring the Lichi fruit, found on the Wayne family land north of Ascorbia Island.
- quest 8227 talk_questFinished - word order
  - was: Very good, I need now the {second} fruit.
  - now: Very good, now I need the {second} fruit.
- quest 8228 talk_questFinished - misspelling 'remaing'
  - was: Wow, you got it! Now there's only one {fruit} remaing.
  - now: Wow, you got it! Now there's only one {fruit} remaining.
- quest 8229 talk_questStarting - question word order
  - was: You will help me find the last fruit?
  - now: Will you help me find the last fruit?
- quest 8229 talk_questStarted - broken grammar, run-on
  - was: Your third mission is to find the tree that bears the Wampi fruit, no one knows for sure where is this tree, many people tell stories about this fruit, some say it is the best fruit we already ate, others say that if a Pokemon eat this fruit will become invincible. If you bring me this fruit, I will be able to finish my study. I count on your help.
  - now: Your third mission is to find the tree that bears the Wampi fruit. No one knows for sure where this tree is. Many people tell stories about this fruit: some say it is the best fruit they ever ate, others say a Pokemon that eats it becomes invincible. If you bring me this fruit, I will be able to finish my study. I'm counting on you.

## Mikko

- message_greet - 'clear up our mind' awkward
  - was: Let's clear up our mind and start looking... what do you think?
  - now: Let's clear our minds and start looking... what do you think?
- quest 8080 talk_questStarting - 'some task' singular
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8080 talk_questFinishing - question word order
  - was: You got the items?
  - now: Did you get the items?
- quest 8080 talk_questFinished - 'get your reward' awkward
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.

## Mistery Guy

- npc/scripts/quest_misteryGuy.lua - 'I already know!' confusing
  - was: Mm... I'm just a pokemon trainer, my dream is to be the greatest Pokemon trainer of all time! I already know! Let's {duel}!
  - now: Mm... I'm just a Pokemon trainer, my dream is to be the greatest Pokemon trainer of all time! I know! Let's {duel}!
- npc/scripts/quest_misteryGuy.lua - embedded question word order
  - was: So you found me! Haha! So you want to {know} who am I?
  - now: So you found me! Haha! So you want to {know} who I am?
- npc/scripts/quest_misteryGuy.lua - broken grammar
  - was: You are insistent on, but since you and your friends have helped me in a way I will tell... From a long time ago the team rocket controls the illegal pokemon trade and my mission is to stop them, they are very wicked and do more {terrible} things.
  - now: You're insistent, but since you and your friends have helped me in a way, I'll tell you... For a long time, Team Rocket has controlled the illegal Pokemon trade, and my mission is to stop them. They are very wicked and do even more {terrible} things.
- npc/scripts/quest_misteryGuy.lua - garbled 'great future master pokemon'
  - was: Wow, you are very good, I see a great future master pokemon. Now I'm going back to my {journey}, see you later.
  - now: Wow, you are very good, I see a great future Pokemon master in you. Now I'm going back to my {journey}, see you later.
- npc/scripts/quest_misteryGuy.lua - badly garbled, unclear
  - was: ...I spoke too much... So... You know my father, he is the owner of Celadon Hotel, a long time the team rocket kidnapped me to force my father to help them, but there met a man who taught me everything I know, but unfortunately he died for the greater good, today I fight for the cause of it being free the world from the clutches of the rocket team. Do not tell my father about me, please! Returning to the subject, go talk to Professor Bill about what you discovered, but not remember who I tell anyone!
  - now: ...I've said too much... So... you know my father, he owns the Celadon Hotel. Long ago Team Rocket kidnapped me to force my father to help them, but there I met a man who taught me everything I know. Sadly he died for the greater good, and today I fight for his cause: freeing the world from Team Rocket's clutches. Please don't tell my father about me! Back to the subject: go talk to Professor Bill about what you discovered, but remember, don't tell anyone who I am!
- quest 8529 talk_questStarting - garbled question
  - was: Rumor has it that they managed to create a pokemon genetically modified, can you believe that this may cause in the world pokemon if true?
  - now: Rumor has it they managed to create a genetically modified Pokemon. Can you imagine what that could do to the Pokemon world if it's true?
- quest 8529 talk_questStarted - run-on, broken grammar
  - was: We need to discover the truth about Mewtwo! I need more information about this pokemon, I learned that there was a lab in Cinnabar that was where it all started, but I did not find the secret door, take, take this access card that I found hidden inside a book in the Pokemon Mansion, try to find a secret area and look into the files that you may found there, when done back here.
  - now: We need to discover the truth about Mewtwo! I need more information about this Pokemon. I learned that a lab in Cinnabar is where it all started, but I couldn't find the secret door. Here, take this access card I found hidden inside a book in the Pokemon Mansion. Try to find a secret area and look into any files you find there. Come back here when you're done.
- quest 8529 talk_questFinishing - question word order
  - was: You found something?
  - now: Did you find something?
- quest 8529 talk_questFinished - garbled, 'Thank player'
  - was: So probably the Mewtwo was created ... Damn I was afraid of that, at least we know more about it and the original. Thank player so I can return as soon as my {dad}.
  - now: So Mewtwo really was created... Damn, I was afraid of that. At least we know more about it and its origin. Thank you, now I can go back to my {dad} as soon as possible.
- quest 8529 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you don't have it yet.
- quest 8546 talk_questFinishing - question word order
  - was: You spoke to my father?
  - now: Did you speak to my father?
- quest 8546 talk_questFinished - broken grammar, 'HD', 'rocket equip'
  - was: Thanks again for saving me. My father gathered the data from the team rocket and put these HD, get it, it contains all the information that the rocket equip was working at this site, it might be useful to you and the friend Bill, I'm weak and I can not pursue this mission with you, but I have confidence in you.
  - now: Thanks again for saving me. My father gathered Team Rocket's data and put it on this hard drive. Take it, it contains everything Team Rocket was working on at this site. It might be useful to you and our friend Bill. I'm weak and can't continue this mission with you, but I have faith in you.

## Misty

- message_greet - 'policy about Pokemon' awkward
  - was: Hi, you're a new face! Trainers who want to turn pro have to have a policy about Pokemon! What is your approach when you catch Pokemon? My policy is an all-out offensive with water-type Pokemon!
  - now: Hi, you're a new face! Trainers who want to turn pro need a strategy for their Pokemon! What is your approach when you catch Pokemon? My strategy is an all-out offensive with water-type Pokemon!
- npc/scripts/npcbattle_misty.lua - 'before receive' grammar
  - was: You must defeat me before receive your reward.
  - now: You must defeat me before you receive your reward.
- npc/scripts/npcbattle_misty.lua - 'here is' incomplete
  - was: Oh, here is!
  - now: Oh, here it is!
- quest 8466 talk_questStarting - awkward grammar
  - was: Thanks trainer. My boyfriend J. Fox is having a birthday in a few days and I need to find a suitable gift for him. The problem is that I do not have time to leave the gym lately with the duties to care for and still battling with Pokemon trainers. My sisters do not help me at all and traveled on vacation again. He is a good professional archer and likes to test his skills in tournaments. I want to present him with a very good bow. Can you help me?
  - now: Thanks, trainer. My boyfriend J. Fox has a birthday in a few days and I need to find a suitable gift for him. The problem is that I haven't had time to leave the gym lately, with all my duties and battles with Pokemon trainers. My sisters don't help me at all and went on vacation again. He is a skilled archer and likes to test his skills in tournaments. I want to give him a very good bow. Can you help me?
- quest 8466 talk_questStarted - tense, unclear what items
  - was: Great. The manufacturer gave me a list of materials that I needed to collect. Get them for me and you will have your reward.
  - now: Great. The bow maker gave me a list of materials I need to collect. Get them for me and you will have your reward.
- quest 8466 talk_questFinished - 'Once he does' unclear
  - was: Great. Put them in this bag. Hand it to the bow manufacturer in Lavender. Once he does, return to me! Thank you!
  - now: Great. Put them in this bag and hand it to the bow maker in Lavender. Once he has it, return to me! Thank you!
- quest 8466 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you don't have it yet.
- quest 8467 talk_questFinishing - 'Did you got' grammar
  - was: Did you got the bow?
  - now: Did you get the bow?
- quest 8205 talk_questFinishing - question word order
  - was: You rescued my Unknown Egg?
  - now: Did you rescue my Unknown Egg?
- quest 8205 talk_questFinished - run-on, 'had something to do'
  - was: Wow! Thank you do not know what I'd do without your help. Incidentally, Prof. Oak asked you to go back there. He said he had something to do on the Orange Archipelago.
  - now: Wow! Thank you, I don't know what I'd do without your help. By the way, Prof. Oak asked you to go back to him. He said he has something for you to do in the Orange Archipelago.
- quest 8205 talk_questFinishFail - 'you could not' wrong tense
  - was: No you could not. Please help me!
  - now: No, you couldn't do it yet. Please help me!
- quest 8662 talk_questStarted - 'He' vs 'them' mismatch
  - was: He's still a baby, please save them.
  - now: He's still a baby, please save him.
- quest 8662 talk_questFinishing - 'our Pokemon' unclear
  - was: Did you find our Pokemon?
  - now: Did you find my Togepi?
- quest 8662 talk_questFinished - 'Oh they are' nonsensical
  - was: Ohh! Oh they are.
  - now: Ohh! There he is!
- quest 8662 talk_questFinishFail - 'Looks like no' unnatural
  - was: Looks like no.
  - now: Looks like you didn't find him yet.

## Mitchell Meade

- message_greet - 'helds' wrong plural
  - was: Hello |PLAYERNAME|. I can {remove} your Pokemon helds!
  - now: Hello |PLAYERNAME|. I can {remove} your Pokemon's held items!
- npc/scripts/held_remove.lua - slightly awkward
  - was: You can not do it while you have a Pokemon out of the ball.
  - now: You can't do that while your Pokemon is out of its ball.
- npc/scripts/held_remove.lua - 'inventory slot' unclear
  - was: Please, first put a poke ball in your inventory slot.
  - now: Please put a Poke Ball in your ball slot first.
- npc/scripts/held_remove.lua - tense, 'Held' noun
  - was: Your Pokemon didn't have any Held.
  - now: Your Pokemon doesn't have any held item.

## Monroe Lynwood

- npc/scripts/npcbattle_monroeLynwood.lua - 'if you won' tense
  - was: So you're interested in the Orenji fruit? I can give you one if you won a {battle} against me.
  - now: So you're interested in the Orenji fruit? I can give you one if you win a {battle} against me.

## Mr. Fuji

- npc/scripts/quest_mrFuji.lua - fragmented, unclear
  - was: My daughter Amber. She left a long time ago, my cloning studies have only led me to total failure. Except with Mewtwo.
  - now: My daughter Amber left a long time ago. My cloning studies have led only to total failure. Except for Mewtwo.
- quest 8511 talk_questStarting - 'would be met' wrong word
  - was: Thanks for coming to save me. I knew my message to Bill would be met. I am just a little stunned by all this. I'll tell you how it all happened.
  - now: Thanks for coming to save me. I knew Bill would get my message. I'm just a little stunned by all this. I'll tell you how it all happened.
- quest 8511 talk_questStarted - broken grammar, unclear request
  - was: I was in my house here in Lavender when a loud noise woke my attention. I ran to the window and saw several lights, many lanterns. A boy was being taken by these hooded thieves, was a kidnapping. I take care of Pokemon abandoned by their trainers, and I could not see such the scene. I left home and went running to help the boy, but my Pokemon are afraid of battles and was soon captured and brought here. I do not know who the boy was, but he shouted: 'Run Pikachu! Escape to safety!' Through the window I could only see them fading into the horizon with a balloon. I need you to do a favor for me bringing my lost Pokemon. You think you can do it?
  - now: I was at my house here in Lavender when a loud noise caught my attention. I ran to the window and saw many lights and lanterns. A boy was being taken by hooded thieves, it was a kidnapping. I take care of Pokemon abandoned by their trainers, and I couldn't stand by and watch. I ran out to help the boy, but my Pokemon are afraid of battles, and I was soon captured and brought here. I don't know who the boy was, but he shouted: 'Run Pikachu! Escape to safety!' Through the window I could only see them fading into the horizon in a balloon. I need you to do me a favor and bring back my lost Pokemon. Do you think you can do it?
- quest 8511 talk_questFinished - garbled sentences
  - was: Thanks buddy, you were a great help. For now I'll stick around, I think I can help these evildoers to find the light at the end of the tunnel. They should know me, but I know that was a long time ago and hung me from the past. I miss my {Amber}. I did many wrong things, I know. Help me find and fix {Mewtwo} what I started. Good luck in finding the boy.
  - now: Thanks, buddy, you were a great help. For now I'll stick around, I think I can help these evildoers find the light at the end of the tunnel. They should know me, but that was a long time ago and my past haunts me. I miss my {Amber}. I did many wrong things, I know. Help me fix what I started with {Mewtwo}. Good luck finding the boy.
- quest 8511 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you don't have it yet.

## Murray Aaron

- message_greet - 'exchange into' wrong preposition
  - was: Hello |PLAYERNAME|! I can exchange your {anniversary tokens} into {gifts}.
  - now: Hello |PLAYERNAME|! I can exchange your {anniversary tokens} for {gifts}.
- npc/scripts/event_anniversary.lua - question lacks auxiliary
  - was: You want to exchange %s %s for a %s?
  - now: Do you want to exchange %s %s for a %s?
- npc/scripts/event_anniversary.lua - question lacks auxiliary
  - was: You want to exchange %s anniversary token for a %s?
  - now: Do you want to exchange %s anniversary token for a %s?
- npc/scripts/event_anniversary.lua - 'exchange into' wrong preposition
  - was: Here you can exchange anniversary tokens into gifts, you can see the {options}.
  - now: Here you can exchange anniversary tokens for gifts. You can see the {options}.

## Nate

- message_greet - word order
  - was: Hello |PLAYERNAME|. You can buy here all the necessary equipment to start planting your Pokemon berries.
  - now: Hello |PLAYERNAME|. Here you can buy all the equipment you need to start planting your Pokemon berries.

## Neesha

- quest 8661 talk_questStarting - 'And now?' unnatural
  - was: My Pokemon! And now?
  - now: My Pokemon! What do I do now?
- quest 8661 talk_questFinishing - 'our Pokemon' wrong pronoun
  - was: Did you find our Pokemon?
  - now: Did you find my Pokemon?
- quest 8661 talk_questFinishFail - 'Looks like no' unnatural
  - was: Looks like no.
  - now: Looks like you haven't found them yet.

## Neil

- message_greet - word order
  - was: Hello |PLAYERNAME|. You can buy here all the necessary equipment to start planting your Pokemon berries.
  - now: Hello |PLAYERNAME|. Here you can buy all the equipment you need to start planting your Pokemon berries.

## Neil Plath

- message_greet - broken grammar
  - was: You seem static, is fear?
  - now: You seem frozen, is it fear?

## Nevaeh Gwendoline

- message_greet - 'We are fashion too' broken
  - was: Hello baby, we have everything you need. We are fashion too! Remember that only premium account players can wear these clothes!
  - now: Hello baby, we have everything you need. We're fashionable too! Remember that only premium account players can wear these clothes!

## Noah

- message_greet - 'the fire' article
  - was: Perhaps you're the one who is going to prove that the fire is supreme.
  - now: Perhaps you're the one who is going to prove that fire is supreme.
- quest 8085 talk_questStarting - 'some task' singular
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8085 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Golem.
  - now: Thanks! Your task is to defeat 30 Golem.
- quest 8085 talk_questFinishing - question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8085 talk_questFinished - 'get your reward' awkward
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.
- quest 8086 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Onix.
  - now: Thanks! Your task is to defeat 30 Onix.
- quest 8087 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Charizard.
  - now: Thanks! Your task is to defeat 30 Charizard.
- quest 8088 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Ninetales.
  - now: Thanks! Your task is to defeat 30 Ninetales.
- quest 8089 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Arcanine.
  - now: Thanks! Your task is to defeat 30 Arcanine.
- quest 8090 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Rapidash.
  - now: Thanks! Your task is to defeat 30 Rapidash.
- quest 8091 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Blastoise.
  - now: Thanks! Your task is to defeat 30 Blastoise.
- quest 8092 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Golduck.
  - now: Thanks! Your task is to defeat 30 Golduck.
- quest 8093 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Tentacruel.
  - now: Thanks! Your task is to defeat 30 Tentacruel.
- quest 8094 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Dewgong.
  - now: Thanks! Your task is to defeat 30 Dewgong.

## Noemi Retherford

- message_greet - word order, missing 'against'
  - was: Even if you pass me by, you never will win Brock!
  - now: Even if you get past me, you will never beat Brock!

## Nurse Joy

- npc/scripts/nurse_joy.lua - slightly awkward
  - was: You can not do it while you have a Pokemon out of the ball.
  - now: You can't do that while your Pokemon is out of its ball.
- npc/scripts/nurse_joy.lua - 'enough access' unclear
  - was: You do not have enough access to heal your Pokemon here!
  - now: You don't have access to heal your Pokemon here!
- npc/scripts/nurse_joy.lua - 'it's here' unclear
  - was: One second... Alright, it's here. Remember that you can also change your {hometown} here. If you want to restore your pokemon again, just say {heal}.
  - now: One second... Alright, all done. Remember that you can also change your {hometown} here. If you want to restore your Pokemon again, just say {heal}.
- npc/scripts/nurse_joy.lua - 'it's here' unclear
  - was: One second... Alright, it's here. If you want to restore your pokemon again, just say {heal}.
  - now: One second... Alright, all done. If you want to restore your Pokemon again, just say {heal}.
- npc/scripts/nurse_joy.lua - question lacks auxiliary
  - was: You really want to live in %s?
  - now: Do you really want to live in %s?

## Oak's Assistant

- quest 8008 talk_questStarting - 'do you want help me' grammar
  - was: I am collecting information about Pokemon and need you to collect some for me, do you want help me?
  - now: I am collecting information about Pokemon and need you to collect some for me. Do you want to help me?
- quest 8008 talk_questStarted - 'back to me' missing verb
  - was: Ok, I need you to collect information about 30 Pokemon, use your pokedex on them and back to me.
  - now: Ok, I need you to collect information about 30 Pokemon. Use your Pokedex on them and come back to me.
- quest 8008 talk_questFinishing - question word order
  - was: You've got what I asked?
  - now: Have you got what I asked for?
- quest 8008 talk_questFinishFail - misspelling, broken grammar
  - was: No.. you do not have, colect the informations and return back to me.
  - now: No... you don't have it. Collect the information and come back to me.
- quest 8010 talk_questStarting - broken grammar
  - was: Well, not yet finished my research...I'm just beginning, I need help to collect more information about Pokemon, you can help me?
  - now: Well, my research isn't finished yet... I'm just beginning. I need help collecting more information about Pokemon. Can you help me?
- quest 8010 talk_questStarted - 'collect 50 Pokemon' unclear
  - was: Alright, I need more information, collect a total of 50 Pokemon with your pokedex and then back to me.
  - now: Alright, I need more information. Register a total of 50 Pokemon with your Pokedex and then come back to me.
- quest 8011 talk_questStarting - question word order
  - was: I need more information to complete my research, you want to help me?
  - now: I need more information to complete my research. Do you want to help me?
- quest 8011 talk_questStarted - broken grammar
  - was: Collect a total of 100 Pokemon information with your pokedex and then back to me.
  - now: Register a total of 100 Pokemon with your Pokedex and then come back to me.
- quest 8011 talk_questFinishing - 'Are you with' Portuguese-ism
  - was: Are you with the information for the research?
  - now: Do you have the information for the research?
- quest 8012 talk_questStarting - 'wants to help' grammar
  - was: I have another task for you, wants to help?
  - now: I have another task for you, want to help?
- quest 8012 talk_questStarted - broken grammar
  - was: The task is collect a total of 140 Pokemon information with your pokedex, good luck!
  - now: The task is to register a total of 140 Pokemon with your Pokedex, good luck!
- quest 8012 talk_questFinishing - question word order
  - was: You completed the task?
  - now: Did you complete the task?
- quest 8012 talk_questFinishFail - 'Back when you are with' broken
  - was: Back when you are with the information...
  - now: Come back when you have the information...
- quest 8013 talk_questStarting - 'its', 'the my' errors
  - was: This is the last task, its a very important step for the my research. Do you want to help me?
  - now: This is the last task, it's a very important step for my research. Do you want to help me?
- quest 8013 talk_questStarted - broken grammar
  - was: This is the last step, collect a total of 151 Pokemon information with your pokedex and then back to me.
  - now: This is the last step: register a total of 151 Pokemon with your Pokedex and then come back to me.
- quest 8013 talk_questFinishing - question word order
  - was: You completed the research?
  - now: Did you complete the research?
- quest 8013 talk_questFinished - run-on, awkward
  - was: Thanks! Thanks! You are a hero to the Pokemon world, now based on the information you have collected, I can create better technology to improve the Pokemon life.
  - now: Thanks! Thanks! You are a hero to the Pokemon world! Based on the information you collected, I can create better technology to improve Pokemon life.

## Oak's Assistant Brenny

- message_greet - question word order
  - was: Hello trainer. You are ready to leave the Tutorial Island? ({YES} or {NO})
  - now: Hello trainer. Are you ready to leave the Tutorial Island? ({YES} or {NO})

## Officer Jeny

- message_greet - run-on, 'excuse' incomplete
  - was: Hello |PLAYERNAME|, I'm a police officer in this area if you saw something strange come talk to me. But now I'm doing some missions, excuse.
  - now: Hello |PLAYERNAME|, I'm a police officer in this area. If you see something strange, come talk to me. But right now I'm on some missions, excuse me.
- npc/scripts/quest_officerJeny.lua - broken grammar
  - was: You've done this mission and has the old reward, I can renew your reward. Do you want it?
  - now: You've done this mission and have the old reward. I can renew your reward. Do you want it?
- npc/scripts/quest_officerJeny.lua - 'Bill know' grammar
  - was: So you're a friend of Bill? Wait a minute I will confirm this... Looks like Bill know you, I will let you go, but I do not want to see you getting into the affairs of the police without permission, OK?
  - now: So you're a friend of Bill? Wait a minute, I'll confirm this... Looks like Bill knows you. I'll let you go, but I don't want to see you getting into police affairs without permission, OK?
- npc/scripts/quest_officerJeny.lua - run-on, 'take my time'
  - was: Sorry I'm here to investigate something suspicious, if you do not have information about something strange going on here do not take my time.
  - now: Sorry, I'm here to investigate something suspicious. If you don't have information about something strange going on here, don't waste my time.
- quest 8422 talk_questStarting - statement instead of question
  - was: I understand! You will help me with this problem!
  - now: I understand! Will you help me with this problem?
- quest 8422 talk_questStarted - broken grammar throughout
  - was: Take to Cerulean and Pewter and paste these posters. I will inform the authorities of other cities to do the same. Take these 8 posters. I'll mark on your map the locations that need to glue them. Will be 4 in each city. Go!
  - now: Take these 8 posters to Cerulean and Pewter and put them up. I will tell the authorities in other cities to do the same. I'll mark on your map the spots where you need to put them up, 4 in each city. Go!
- quest 8422 talk_questFinishing - 'Did you pasted' grammar
  - was: Did you pasted all the posters?
  - now: Did you put up all the posters?
- quest 8422 talk_questFinished - 'new track' wrong word, awkward
  - was: Great. For now this is what we do. We are putting all efforts to find the Pokemon League Champion. Let us know about any new track! Take this money for the effort.
  - now: Great. That's all we can do for now. We are putting all our efforts into finding the Pokemon League Champion. Let us know about any new leads! Take this money for your effort.
- quest 8422 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you don't have it yet.
- quest 8017 talk_questStarting - 'whether you help us' broken
  - was: We are in a very strange case, Nurse Joy's Chanseys are simply disappearing from the Pokemon centers... We are accepting help from everyone, whether you help us?
  - now: We're on a very strange case: Nurse Joy's Chanseys are simply disappearing from the Pokemon centers... We are accepting help from everyone. Will you help us?
- quest 8017 talk_questStarted - broken grammar
  - was: Thanks! We know it's Team Rocket is involved in this, so we need to find them. We have information that one of their bases located in Celadon. Take these special balls, if you find the Chanseys, use in them.
  - now: Thanks! We know Team Rocket is involved in this, so we need to find them. We have information that one of their bases is in Celadon. Take these special balls, and if you find the Chanseys, use them on them.
- quest 8017 talk_questFinishing - question word order, capitalization
  - was: You've found the team rocket? The chanseys?
  - now: Did you find Team Rocket? The Chanseys?
- quest 8017 talk_questFinished - missing 'the'
  - was: Thank you! You helped us a lot. Hmm? It seems that one of Chanseys liked you, take care of it!
  - now: Thank you! You helped us a lot. Hmm? It seems one of the Chanseys likes you, take care of it!

## Old Lady

- message_greet - question word order
  - was: Heelloooo! You already know our {daycare}? We handle all kinds of {Pokemon}. If you have a Pokemon here you can see its {status}, otherwise you can {leave} a Pokemon here. And if you need to buy incubators, just say {trade}. Also you can {deposit} and {remove} plates.
  - now: Heelloooo! Do you already know our {daycare}? We handle all kinds of {Pokemon}. If you have a Pokemon here you can see its {status}, otherwise you can {leave} a Pokemon here. And if you need to buy incubators, just say {trade}. Also you can {deposit} and {remove} plates.
- npc/scripts/daycareFemale.lua - question lacks auxiliary
  - was: You really want to deposit %s %s?
  - now: Do you really want to deposit %s %s?
- npc/scripts/daycareFemale.lua - 'any of this plate' awkward
  - was: You don't have any of this plate!
  - now: You don't have this plate!
- npc/scripts/daycareFemale.lua - 'goes wrong' tense
  - was: Something goes wrong! Please try again later.
  - now: Something went wrong! Please try again later.
- npc/scripts/daycareFemale.lua - misspelling 'Remeber', plural
  - was:  Remeber that I have one of your %s plate here.
  - now:  Remember that I have one of your %s plates here.
- npc/scripts/daycareFemale.lua - broken grammar, 'Remaing' misspelled
  - was: Egg status: You have already generated an egg recently, you must wait fifteen days after produce an egg to generate another. Remaing %s.
  - now: Egg status: You have already generated an egg recently. You must wait fifteen days after producing an egg to generate another. Remaining %s.
- npc/scripts/daycareFemale.lua - confusing 'as well'
  - was: Egg status: You don't have a male Pokemon being trained as well.
  - now: Egg status: You don't have a male Pokemon being trained too.
- npc/scripts/daycareFemale.lua - 'take chances' wrong phrase
  - was: Egg status: The two need to be training for at least %s minutes (24 hours) to take chances to breed.
  - now: Egg status: The two need to be training for at least %s minutes (24 hours) to have a chance to breed.
- npc/scripts/daycareFemale.lua - slightly awkward
  - was: You can not do it while you have a Pokemon out of the ball.
  - now: You can't do that while your Pokemon is out of its ball.
- npc/scripts/daycareFemale.lua - 'and generate eggs' wrong negation
  - was: Do you really want to cancel your Pokemon training? He will not gain any experience points and generate eggs, but you still have to pay the amount.
  - now: Do you really want to cancel your Pokemon's training? It will not gain any experience points or generate eggs, but you still have to pay the fee.
- npc/scripts/daycareFemale.lua - awkward 'is with you'
  - was: You do not have this Pokemon! Please tell the name of a Pokemon that is with you.
  - now: You don't have this Pokemon! Please tell me the name of a Pokemon you are carrying.
- npc/scripts/daycareFemale.lua - 'I care only' word order
  - was: Sorry, I care only female and sexless Pokemon.
  - now: Sorry, I only care for female and genderless Pokemon.
- npc/scripts/daycareFemale.lua - misspelling 'remaing', 'trainment'
  - was: You can't withdraw your Pokemon right now. There's remaing %s minutes of training. If you really want, you can {cancel} the trainment.
  - now: You can't withdraw your Pokemon right now. There are %s minutes of training remaining. If you really want, you can {cancel} the training.
- npc/scripts/daycareFemale.lua - 'What the name' broken
  - was: Please, say the name of a Pokemon! What the name of your Pokemon that you want to leave here?
  - now: Please say the name of a Pokemon! What's the name of the Pokemon you want to leave here?
- npc/scripts/daycareFemale.lua - 'how much train time' awkward
  - was: And how much train time do you want? The options are: %s
  - now: And how long do you want it to train? The options are: %s
- npc/scripts/daycareFemale.lua - 'he stay' grammar
  - was: Do you want to leave your %s here for %s minutes? This will cost 100 dollars to enter and an additional 1, 2 or 4 dollars per minute that he stay here (depends on the level of your Pokemon).
  - now: Do you want to leave your %s here for %s minutes? This will cost 100 dollars to enter plus 1, 2 or 4 dollars for every minute it stays here (depending on your Pokemon's level).

## Old Man

- message_greet - question word order
  - was: Hello! You already know our {daycare}? We handle all types of {Pokemon}. If you have a Pokemon here you can see his {status}, otherwise you can {leave} a Pokemon here.
  - now: Hello! Do you already know our {daycare}? We handle all types of {Pokemon}. If you have a Pokemon here you can see his {status}, otherwise you can {leave} a Pokemon here.
- npc/scripts/daycareMale.lua - slightly awkward
  - was: You can not do it while you have a Pokemon out of the ball.
  - now: You can't do that while your Pokemon is out of its ball.
- npc/scripts/daycareMale.lua - 'and generate eggs' wrong negation
  - was: Do you really want to cancel your Pokemon training? He will not gain any experience points and generate eggs, but you still have to pay the amount.
  - now: Do you really want to cancel your Pokemon's training? It will not gain any experience points or generate eggs, but you still have to pay the fee.
- npc/scripts/daycareMale.lua - awkward 'is with you'
  - was: You do not have this Pokemon! Please tell the name of a Pokemon that is with you.
  - now: You don't have this Pokemon! Please tell me the name of a Pokemon you are carrying.
- npc/scripts/daycareMale.lua - 'I care only' word order
  - was: Sorry, I care only male and sexless Pokemon.
  - now: Sorry, I only care for male and genderless Pokemon.
- npc/scripts/daycareMale.lua - misspelling 'remaing', 'trainment'
  - was: You can't withdraw your Pokemon right now. There's remaing %s minutes of training. If you really want, you can {cancel} the trainment.
  - now: You can't withdraw your Pokemon right now. There are %s minutes of training remaining. If you really want, you can {cancel} the training.
- npc/scripts/daycareMale.lua - 'What the name' broken
  - was: Please, say the name of a Pokemon! What the name of your Pokemon that you want to leave here?
  - now: Please say the name of a Pokemon! What's the name of the Pokemon you want to leave here?
- npc/scripts/daycareMale.lua - 'how much train time' awkward
  - was: And how much train time do you want? The options are: %s
  - now: And how long do you want it to train? The options are: %s
- npc/scripts/daycareMale.lua - 'he stay' grammar
  - was: Do you want to leave your %s here for %s minutes? This will cost 100 dollars to enter and an additional 1, 2 or 4 dollars per minute that he stay here (depends on the level of your Pokemon).
  - now: Do you want to leave your %s here for %s minutes? This will cost 100 dollars to enter plus 1, 2 or 4 dollars for every minute it stays here (depending on your Pokemon's level).

## Oliver Davin

- message_greet - 'Churros parish' nonsensical
  - was: Churros parish, enjoy!
  - now: Fresh churros, enjoy!

## Oliver Terrel

- npc/scripts/quest_oliverTerrel.lua - question word order
  - was: What reward you want? Your options are: {TM 05} (Mega Kick), {TM 25} (Earthquake) and {TM 37} (Skull Bash).
  - now: Which reward do you want? Your options are: {TM 05} (Mega Kick), {TM 25} (Earthquake) and {TM 37} (Skull Bash).
- npc/scripts/quest_oliverTerrel.lua - 'Here is' incomplete
  - was: Great choice! Here is.
  - now: Great choice! Here it is.
- quest 8313 talk_questStarting - food vs revives contradiction, tense
  - was: I was running out of food... can you help me?
  - now: I've run out of supplies... can you help me?
- quest 8313 talk_questStarted - 'bring it to me 6' broken
  - was: Great, bring it to me 6 revives. My Pokemon are fainted and I have no way out of here. When you come back I'll give you some information.
  - now: Great, bring me 6 revives. My Pokemon have fainted and I have no way out of here. When you come back I'll give you some information.
- quest 8313 talk_questFinished - 'help me on' preposition
  - was: Great, but you also have to {help} me on something else.
  - now: Great, but you also have to {help} me with something else.
- quest 8314 talk_questStarted - 'Retrieve me' awkward
  - was: Retrieve me the backpack and come back here! He should not have gone far...
  - now: Get my backpack back and return here! He can't have gone far...
- quest 8314 talk_questFinished - garbled sentences
  - was: You are very brave, thank you for making this great favor to my family. My grandfather in his last days was gathered with his Pokemon that house and stayed there. One day be able to get there... take, this should help you.
  - now: You are very brave, thank you for doing my family this great favor. In his last days, my grandfather gathered his Pokemon in that house and stayed there. Maybe one day I'll be able to get there... here, take this, it should help you.
- quest 8350 talk_questFinished - 'Technical Machine' plural
  - was: You are incredible! I do not know how to thank you, how about choosing one of my Technical Machine? Your options are: {TM 05} (Mega Kick), {TM 25} (Earthquake) and {TM 37} (Skull Bash).
  - now: You are incredible! I don't know how to thank you. How about choosing one of my Technical Machines? Your options are: {TM 05} (Mega Kick), {TM 25} (Earthquake) and {TM 37} (Skull Bash).

## Oscar

- message_greet - word order
  - was: Hello |PLAYERNAME|. You can buy here all the necessary equipment to start planting your Pokemon berries.
  - now: Hello |PLAYERNAME|. Here you can buy all the equipment you need to start planting your Pokemon berries.

## Owen

- message_greet - garbled sentence
  - was: Hello |PLAYERNAME|. Here you go find the best churros of all the town, hu?
  - now: Hello |PLAYERNAME|. Here you'll find the best churros in town, huh?

## Ozias

- message_greet - 'Brought' missing auxiliary
  - was: Brought the wetsuit?
  - now: Did you bring the wetsuit?
- quest 8116 talk_questStarting - 'some task' singular
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8116 talk_questStarted - 'task is catch', 'them' for 1
  - was: Thanks! Your task is catch 1 Pikachu and bring them to me.
  - now: Thanks! Your task is to catch 1 Pikachu and bring it to me.
- quest 8116 talk_questFinishing - question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8116 talk_questFinished - 'get your reward' awkward
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.
- quest 8117 talk_questStarted - 'task is catch', 'them' for 1
  - was: Thanks! Your task is catch 1 Magnemite and bring them to me.
  - now: Thanks! Your task is to catch 1 Magnemite and bring it to me.
- quest 8118 talk_questStarted - 'task is catch', 'them' for 1
  - was: Thanks! Your task is catch 1 Voltorb and bring them to me.
  - now: Thanks! Your task is to catch 1 Voltorb and bring it to me.

## Ozy

- message_greet - misspelling 'kock'
  - was: Take it easy, only gotta kock them out, no need to hurt.
  - now: Take it easy, you only gotta knock them out, no need to hurt them.
- quest 8195 talk_questStarting - 'some task' singular
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8195 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Raichu.
  - now: Thanks! Your task is to defeat 30 Raichu.
- quest 8195 talk_questFinishing - question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8195 talk_questFinished - 'get your reward' awkward
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.
- quest 8196 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Magneton.
  - now: Thanks! Your task is to defeat 30 Magneton.
- quest 8197 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 30 Electrode.
  - now: Thanks! Your task is to defeat 30 Electrode.
- quest 8198 talk_questStarted - 'task is defeat' missing 'to'
  - was: Thanks! Your task is defeat 15 Electabuzz.
  - now: Thanks! Your task is to defeat 15 Electabuzz.

## Patrick

- message_greet - word order
  - was: Hello |PLAYERNAME|. You can buy here all the necessary equipment to start planting your Pokemon berries.
  - now: Hello |PLAYERNAME|. Here you can buy all the equipment you need to start planting your Pokemon berries.

## Patton

- quest 8500 talk_questFinishing - 'the Oak pupil' awkward
  - was: Oh, you are the Oak pupil?
  - now: Oh, you are Oak's pupil?
- quest 8500 talk_questFinished - 'Take, here it is' awkward
  - was: The order arrived this morning. Take, here it is. Keep in mind that we merchants are always in need of help. When you get to a new city try to look for missions.
  - now: The order arrived this morning. Here it is. Keep in mind that we merchants are always in need of help. When you get to a new city, try looking for missions.
- quest 8500 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you don't have it yet.

## Paul

- message_greet - word order
  - was: Hello |PLAYERNAME|. You can buy here all the necessary equipment to start planting your Pokemon berries.
  - now: Hello |PLAYERNAME|. Here you can buy all the equipment you need to start planting your Pokemon berries.

## Pepper Denis

- quest 8250 talk_questStarted - 'say hidden to discover' unclear
  - was: You'll have to find my five friends! They can be anyone in the city! Hahahahahaha! Say {hidden} to discover them.
  - now: You'll have to find my five friends! They could be anyone in the city! Hahahahahaha! Say {hidden} to the people you suspect to find them.

## Percy Page

- message_greet - missing comma
  - was: What will it be today friend?
  - now: What will it be today, friend?

## Peter Paul

- npc/scripts/quest_halloween_peter_paul.lua - 'Has interest?' Portuguese-ism
  - was: I'm looking for adventurers who can help me with a {problem}! Has interest?
  - now: I'm looking for adventurers who can help me with a {problem}! Interested?
- npc/scripts/quest_halloween_peter_paul.lua - run-on, awkward
  - was: A few days ago, one of my most reliable sailors told me that he saw a {ghost ship}, I did not believe it, I thought he was drunk or with the madness of the sea, but when I went to the place, I saw it with my own eyes.
  - now: A few days ago, one of my most reliable sailors told me he saw a {ghost ship}. I didn't believe him, I thought he was drunk or gone mad from the sea, but when I went to the place, I saw it with my own eyes.
- npc/scripts/quest_halloween_peter_paul.lua - garbled clause
  - was: It was Exile, a Japanese ship belonging to the {Alliance of the 4 Seas}, a group of pirates formed by four factions, who united dominated the seas of the earth for decades, but were defeated 200 years ago.
  - now: It was the Exile, a Japanese ship belonging to the {Alliance of the 4 Seas}, a group of pirates made up of four factions who, united, dominated the seas of the world for decades, but were defeated 200 years ago.
- npc/scripts/quest_halloween_peter_paul.lua - 'alias' for alliance, run-on
  - was: As I said, it was an alias of four great pirate captains, Nagumo, Javy Dones, Jack Spearow and Ed Blackhood, the four commanded pirate groups, Sea Dragons, Guns And Roses, Lunatticus and Cold Waters, were feared By all 4 corners of the planet, but were defeated in the battle of {Black Water}.
  - now: As I said, it was an alliance of four great pirate captains, Nagumo, Javy Dones, Jack Spearow and Ed Blackhood. The four commanded the pirate groups Sea Dragons, Guns And Roses, Lunatticus and Cold Waters, and were feared in all 4 corners of the planet, but were defeated in the battle of {Black Water}.
- npc/scripts/quest_halloween_peter_paul.lua - garbled 'side Two pirates'
  - was: This battle was between the Alliance of the 4 Seas and an alliance of Lords who thought of putting an end to all the pirates that existed, some say that the victory of the lords would be impossible if it were not an act of treason on the part of someone on the side Two pirates. But these are legends of the seas, the problem here is that this occurred 200 years ago and these {factions} no longer exist, well at least until a few days ago.
  - now: This battle was between the Alliance of the 4 Seas and an alliance of Lords who wanted to put an end to all pirates. Some say the Lords could never have won without an act of treason by someone on the pirates' side. But these are legends of the sea. The problem is that this happened 200 years ago and these {factions} no longer exist, well, at least until a few days ago.
- npc/scripts/quest_halloween_peter_paul.lua - awkward 'crazy with the sea'
  - was: I know the {location} of each one of them, you could go check all and prove that I'm not crazy with the sea, but be careful, each faction has its peculiarities.
  - now: I know the {location} of each one of them. You could go check them all and prove that I haven't gone mad from the sea, but be careful, each faction has its peculiarities.
- npc/scripts/quest_halloween_peter_paul.lua - garbled sentence
  - was: Before I tell you where they need to tell you about each of them, do you want to know which faction first? {Sea Dragons}, {Guns and Roses}, {Lunatticus} or {Cold Waters}?
  - now: Before I tell you where they are, I need to tell you about each of them. Which faction do you want to know about first? {Sea Dragons}, {Guns and Roses}, {Lunatticus} or {Cold Waters}?
- npc/scripts/quest_halloween_peter_paul.lua - garbled, wrong pronouns
  - was: This faction is commanded by Captain Nagumo Harbor, she is aided by the first Sailor Sotashi, she is considered the greatest strategist of the seas, they are pirates but they are disciplined and honored, if you prove their honor to them, perhaps they win the respect of them.
  - now: This faction is commanded by Captain Nagumo Harbor, aided by her first mate Sotashi. She is considered the greatest strategist of the seas. They are pirates, but disciplined and honorable. If you prove your honor to them, perhaps you'll win their respect.
- npc/scripts/quest_halloween_peter_paul.lua - 'know' needs 'about'
  - was: What other faction do you want to know? {Guns and Roses}, {Lunatticus} or {Cold Waters}?
  - now: Which other faction do you want to know about? {Guns and Roses}, {Lunatticus} or {Cold Waters}?
- npc/scripts/quest_halloween_peter_paul.lua - garbled sentence
  - was: Led by Javy Dones, this faction is the most aggressive of all, despite their aggressiveness they may hear adventurers, but beware, Javy Dones loves to do business, but if he does not make a profit he'll ask for Redbeard to make some profit from some way.
  - now: Led by Javy Dones, this faction is the most aggressive of all. Despite their aggressiveness, they may listen to adventurers. But beware, Javy Dones loves doing business, and if he doesn't make a profit he'll ask Redbeard to get it some other way.
- npc/scripts/quest_halloween_peter_paul.lua - 'know' needs 'about'
  - was: What other faction do you want to know? {Sea Dragons}, {Lunatticus} or {Cold Waters}?
  - now: Which other faction do you want to know about? {Sea Dragons}, {Lunatticus} or {Cold Waters}?
- npc/scripts/quest_halloween_peter_paul.lua - garbled, 'close the face'
  - was: This faction is in this branch for adventure, but they are still pirates, they usually risk in the improbable and are famous for being successful, its leader Captain Jack Spearow, likes to have fun, but will close the face in case you do not call him Captain, Brother Calico only runs the business and is usually more sensible.
  - now: This faction is in this business for adventure, but they are still pirates. They usually bet on the improbable and are famous for succeeding. Its leader, Captain Jack Spearow, likes to have fun, but he'll frown if you don't call him Captain. Brother Calico only runs the business and is usually more sensible.
- npc/scripts/quest_halloween_peter_paul.lua - 'the Bill's' article
  - was: It is located north of Cerulean, next to the Bill's Laboratory.
  - now: It is located north of Cerulean, next to Bill's Laboratory.
- npc/scripts/quest_halloween_peter_paul.lua - 'know' needs 'about'
  - was: What other faction do you want to know? {Sea Dragons}, {Guns And Roses} or {Cold Waters}?
  - now: Which other faction do you want to know about? {Sea Dragons}, {Guns And Roses} or {Cold Waters}?
- npc/scripts/quest_halloween_peter_paul.lua - run-on, stray capital
  - was: I would not say it's a faction, as they are only 2, Ed Blackhood and Will Kid, it seems they seek revenge for Rickon, Ed's eldest son, Will's brother, I can only say that they have no interest in anything that You want to offer them.
  - now: I wouldn't call it a faction, as there are only 2 of them, Ed Blackhood and Will Kid. It seems they seek revenge for Rickon, Ed's eldest son and Will's brother. I can only say they have no interest in anything you want to offer them.
- npc/scripts/quest_halloween_peter_paul.lua - missing article
  - was: It is located to the east of Cerulean, near Power Plant, on the coast.
  - now: It is located east of Cerulean, near the Power Plant, on the coast.
- npc/scripts/quest_halloween_peter_paul.lua - 'know' needs 'about'
  - was: What other faction do you want to know? {Sea Dragons}, {Guns And Roses} or {Lunatticus}?
  - now: Which other faction do you want to know about? {Sea Dragons}, {Guns And Roses} or {Lunatticus}?
- npc/scripts/quest_halloween_peter_paul.lua - garbled, confusing story
  - was: You're a damn!! I saw everything, you were fantastic, fought those aberrations and survived, well I healed you, but you stayed alive until I arrived ... I was looking for you, you forgot to tell me if it was true that they had returned .. Then I saw with my eyes Will Kid shooting at you ... lucky that I got there in time, the sleeping dose was high and you almost went the other way ... When I took you home, I boarded a boat near the ship of Nagumo to see more closely, when Nagumo told me to stop ... she wanted to know what I had done to you, I got caught, and they took care of you ... I explained Everything I saw ... so I thought I'd better get you to the city ... I think you'd better go and thank Nagumo, she defended you, that's an honor for the few.
  - now: You're one tough cookie!! I saw everything, you were fantastic, you fought those aberrations and survived. Well, I healed you, but you stayed alive until I arrived... I was looking for you, you forgot to tell me if it was true that they had returned... Then I saw Will Kid shooting at you with my own eyes... lucky I got there in time, the sleeping dose was high and you almost didn't make it... While taking you home, I boarded a boat near Nagumo's ship to get a closer look, when Nagumo told me to stop... she wanted to know what I had done to you. I got caught, and they took care of you... I explained everything I saw... so I thought I'd better get you to the city... I think you should go and thank Nagumo, she defended you, and that's an honor few get.

## Pistachio

- quest 8208 talk_questStarting - 'like to help me?', 'will never have'
  - was: I am in need of some items to make some experiments, like to help me? If you do not help me, will never have the map! MUAHAHAHAHA!
  - now: I need some items for my experiments, would you like to help me? If you don't help me, you will never have the map! MUAHAHAHAHA!
- quest 8208 talk_questFinishing - question word order
  - was: You've got what I asked?
  - now: Have you got what I asked for?
- quest 8209 talk_questStarting - question word order
  - was: You will help me again?
  - now: Will you help me again?
- quest 8209 talk_questFinishing - 'ordered' wrong word
  - was: So you brought the items I ordered?
  - now: So you brought the items I asked for?
- quest 8210 talk_questStarting - question word order
  - was: I need more stuff, you will continue helping me?
  - now: I need more stuff, will you keep helping me?
- quest 8211 talk_questFinished - repeats previous line, contradictory
  - was: Wow! You're pretty good! But I'll ask you one last favor. You thought that was the last job? Muahahaha! I still have one more.
  - now: Wow! You're pretty good! You thought that was the last job? Muahahaha! I still have one more.
- quest 8212 talk_questStarted - 'you will bring me' awkward
  - was: For this last task you will bring me 1x Box Gloves and 1x Yellow Tail.
  - now: For this last task, bring me 1x Box Gloves and 1x Yellow Tail.
- quest 8212 talk_questFinished - 'you bring' tense
  - was: Thank you! I'm very glad you bring all of these items for me. You know what I'm gonna do with them? Absolutely NOTHING! Muahahaha! Here, here's your map.
  - now: Thank you! I'm very glad you brought me all of these items. You know what I'm gonna do with them? Absolutely NOTHING! Muahahaha! Here, here's your map.

## Possessed Joy

- message_greet - missing 'for'; broken question
  - was: Hello |PLAYERNAME|, we were waiting you. You brought the {invitation}?
  - now: Hello |PLAYERNAME|, we were waiting for you. Did you bring the {invitation}?

## Professor Ivy

- message_greet - broken word order
  - was: Hello |PLAYERNAME|, how you are going on your journey?
  - now: Hello |PLAYERNAME|, how is your journey going?
- quest 8231 talk_questStarting - 'to attracts'; unclear 'seek the bait'
  - was: I would give you a GS Ball, but it was stolen by an Aipom! Unfortunately no one can reach him. My friend Bill is preparing a bait to attracts the Aipom, I ask you to go to him and seek the bait.
  - now: I would give you a GS Ball, but it was stolen by an Aipom! Unfortunately no one can reach him. My friend Bill is preparing a bait to attract the Aipom. Please go to him and get the bait.
- quest 8231 talk_questFinishing - broken question
  - was: You could find the GS ball?
  - now: Did you find the GS Ball?
- quest 8214 talk_questStarting - 'newborns Pokemon'; broken question
  - was: Cool! Here in my lab we performed some research including the development of new rations to feed the Pokemon. I recently discovered that a plant native to Tangelo Island may have a property that will help the newborns Pokemon develop better. You can try to find it for me?
  - now: Cool! Here in my lab we do research, including developing new rations to feed Pokemon. I recently discovered that a plant native to Tangelo Island may have a property that helps newborn Pokemon develop better. Can you try to find it for me?
- quest 8214 talk_questStarted - broken grammar
  - was: Great, I hope your return successfully!
  - now: Great, I hope you return successfully!
- quest 8214 talk_questFinishing - broken question
  - was: You found the plant?
  - now: Did you find the plant?
- quest 8214 talk_questFinished - awkward 'Except that'
  - was: Thank you! Except that we have a small {problem}.
  - now: Thank you! But we have a small {problem}.
- quest 8215 talk_questStarting - garbled instructions, broken question
  - was: I can not use plants for research with Pokemon until I have the approval of the ECP (Ethics Committee Pokemon) and they are in Mandarin Island. Do the following: take the plant up to catalog them so that the database and extract the plant essence for me. You can do it?
  - now: I can not use plants in research with Pokemon until I have approval from the ECP (Pokemon Ethics Committee), and they are on Mandarin Island. Do this: take the plant there so they can catalog it in their database, and extract the plant essence for me. Can you do it?
- quest 8215 talk_questFinishing - broken question
  - was: You brought my extraction?
  - now: Did you bring my extract?
- quest 8218 talk_questStarting - 'feed me some Pokemon' wrong
  - was: I finished the formula, take these cookies and try to feed me some Pokemon! Can you...?
  - now: I finished the formula! Take these cookies and try feeding them to some Pokemon for me! Can you...?
- quest 8218 talk_questFinishing - broken question
  - was: You tested the cookies?
  - now: Did you test the cookies?
- quest 8218 talk_questFinished - broken grammar, garbled sentence
  - was: Great! You have helped me a lot, thanks. You remind me of a big kid who came here three years ago, was a magnificent trainer... where is he now? Do not think that will be the last time I will help! My assistants want to talk to you. Go and good luck.
  - now: Great! You have helped me a lot, thanks. You remind me of a kid who came here three years ago, a magnificent trainer... where is he now? Don't think this is the last time I'll need your help! My assistants want to talk to you. Go, and good luck.

## Professor Josh Rock

- message_greet - missing comma
  - was: Hi, I'm Josh Rock a researcher of {fossils}.
  - now: Hi, I'm Josh Rock, a {fossils} researcher.
- npc/scripts/quest_professorJoshRock.lua - 'want help me', 'for him'
  - was: I've been searching the fossil Pokemon for a long time, but could never get close to one. My brother William is doing an excavation in Mt Moon and said he was close to finding them, I need you to deliver a letter for him and help him find the fossils. Do you want help me?
  - now: I've been searching for fossil Pokemon for a long time, but could never get close to one. My brother William is doing an excavation in Mt Moon and said he was close to finding them. I need you to deliver a letter to him and help him find the fossils. Do you want to help me?
- npc/scripts/quest_professorJoshRock.lua - broken question
  - was: You could find a fossil?
  - now: Did you find a fossil?
- npc/scripts/quest_professorJoshRock.lua - missing article
  - was: I managed to extract DNA from fossil and produce an egg! Here, take good care of it!
  - now: I managed to extract DNA from the fossil and produce an egg! Here, take good care of it!
- npc/scripts/quest_professorJoshRock.lua - run-on, missing 'and'
  - was: My brother is in a dig at Mt Moon, go there find him, deliver this letter and ask about the fossils.
  - now: My brother is at a dig in Mt Moon. Go there, find him, deliver this letter and ask about the fossils.
- npc/scripts/quest_professorJoshRock.lua - 'come back 24 hours'
  - was: You really did it! Congratulations! I'm seeing a real fossil! Thank you! I will start studying it now, come back 24 hours to see if there was any news.
  - now: You really did it! Congratulations! I'm seeing a real fossil! Thank you! I will start studying it now, come back in 24 hours to see if there is any news.
- npc/scripts/quest_professorJoshRock.lua - incomplete sentence
  - was: No.. you have not found.
  - now: No... you haven't found it.
- npc/scripts/quest_professorJoshRock.lua - missing subject
  - was: Sorry, do not know what you're talking about.
  - now: Sorry, I don't know what you're talking about.

## Professor Mark

- npc/scripts/quest_professorMark.lua - broken grammar 'has'
  - was: You've done this mission and has the old reward, I can renew your reward. Do you want it?
  - now: You've done this mission and have the old reward. I can renew your reward. Do you want it?
- quest 8016 talk_questStarted - missing object; 'within the'
  - was: Ok, I do not remember where I lost, but be careful there. The Pokemon mansion is within the Cinnabar Island.
  - now: Ok, I don't remember where I lost them, but be careful there. The Pokemon mansion is on Cinnabar Island.
- quest 8016 talk_questFinishing - nonsense question
  - was: You're in my notes? My book?
  - now: Do you have my notes? My book?
- quest 8016 talk_questFinished - 'one of my research'
  - was: Thank you. Now as promised, I'll give you your reward. I found this box in one of my research, it is very special.
  - now: Thank you. Now, as promised, here is your reward. I found this box during one of my research trips, it is very special.
- quest 8016 talk_questFinishFail - nonsense sentence
  - was: No you're not my notes. Please do not make me waste my time!
  - now: No, you don't have my notes. Please do not waste my time!

## Professor Oak

- message_greet - question word order
  - was: Hello |PLAYERNAME|, how are you? You're taking good care of your {Pokemon}?
  - now: Hello |PLAYERNAME|, how are you? Are you taking good care of your {Pokemon}?
- npc/scripts/quest_professorOak.lua - wrong preposition
  - was: Please, put the poke ball at the ball slot!
  - now: Please put the poke ball in the ball slot!
- npc/scripts/quest_professorOak.lua - unclear meaning
  - was: This is a Pokemon from egg!
  - now: This Pokemon already came from an egg!
- npc/scripts/quest_professorOak.lua - word order
  - was: You aren't the Pokemon original trainer.
  - now: You aren't this Pokemon's original trainer.
- npc/scripts/quest_professorOak.lua - question word order
  - was: You really want a Charmander?
  - now: Do you really want a Charmander?
- npc/scripts/quest_professorOak.lua - question word order
  - was: You really want a Squirtle?
  - now: Do you really want a Squirtle?
- npc/scripts/quest_professorOak.lua - question word order
  - was: You really want a Bulbasaur?
  - now: Do you really want a Bulbasaur?
- npc/scripts/quest_professorOak.lua - question word order
  - was: Your Pokemon will be {female} or {male}?
  - now: Should your Pokemon be {female} or {male}?
- quest 8751 talk_questFinishFail - incomplete sentence
  - was: No.. you do not have.
  - now: No... you haven't done it yet.
- quest 8752 talk_questFinishing - 'Did you used'
  - was: Did you used your Pokedex?
  - now: Did you use your Pokedex?
- quest 8752 talk_questFinished - awkward punctuation
  - was: I see you are doing very well, right, now you will have a harder task...
  - now: I see you are doing very well. Right, now you will have a harder task...
- quest 8753 talk_questFinishing - missing 'the'/plural
  - was: Did you defeat all Rattata?
  - now: Did you defeat all the Rattatas?
- quest 8753 talk_questFinished - wrong preposition 'in PokeMart'
  - was: All right, take this reward. You must bring these items in PokeMart, there you can sell them for a fair price. Just head north until you find the blue building.
  - now: All right, take this reward. You can bring these items to the PokeMart and sell them there for a fair price. Just head north until you find the blue building.
- quest 8498 talk_questStarted - unclear instruction
  - was: I made an order with the Pallet PokeMart. We will see if you are a good trainer.
  - now: I placed an order at the Pallet PokeMart. Please pick it up for me. We will see if you are a good trainer.
- quest 8498 talk_questFinishing - broken question
  - was: My order arrived?
  - now: Did my order arrive?
- quest 8204 talk_questStarting - awkward 'in an emergency now'
  - was: How nice to see you again! I'm in an emergency now.
  - now: How nice to see you again! I have an emergency right now.
- quest 8204 talk_questStarted - awkward possessive
  - was: The Gym Leader of Cerulean's in trouble. Go help her!
  - now: The Cerulean Gym Leader is in trouble. Go help her!
- quest 8204 talk_questFinishing - broken question
  - was: You helped Cerulean Gym Leader?
  - now: Did you help the Cerulean Gym Leader?
- quest 8204 talk_questFinished - garbled sentence
  - was: You dealt well with the situation of Cerulean. I'm curious what will come out of Pokemon inside that egg found in a canyon... Incidentally, I have news, come talk to me when you're ready.
  - now: You handled the situation in Cerulean well. I'm curious what Pokemon will come out of that egg found in a canyon... By the way, I have news, come talk to me when you're ready.
- quest 8338 talk_questStarted - garbled grammar throughout
  - was: Oh, it's true! But we have a problem... the last trainer who came here to upgrade just spoiling my device. Can you go talk to my friend Dr. Oravaf to come fix it? The last news I have of him is of his house facing the sea. I do not remember where...
  - now: Oh, that's right! But we have a problem... the last trainer who came here to upgrade broke my device. Can you go ask my friend Dr. Oravaf to come fix it? The last I heard, his house faces the sea. I do not remember where...
- quest 8338 talk_questFinishing - 'Did you found'
  - was: Did you found Dr. Oravaf?
  - now: Did you find Dr. Oravaf?
- quest 8338 talk_questFinished - 'Here is!'
  - was: Very well! Now I will upgrade your Pokedex. A moment... 3... 2... 1... Done! Here is!
  - now: Very well! Now I will upgrade your Pokedex. A moment... 3... 2... 1... Done! Here it is!
- quest 8206 talk_questStarting - missing 'it'; 'They are called'
  - was: As you know there is a group of islands south of the continent. They are called Orange Archipelago and from what I know is a fascinating place. How about investigating more about that?
  - now: As you know there is a group of islands south of the continent. They are called the Orange Archipelago and from what I know it is a fascinating place. How about investigating it further?
- quest 8206 talk_questStarted - garbled grammar; 'it' for person
  - was: Sweet! Now you need to prepare is to gather information with a friend of mine who has visited the islands. Look for Arold and it will give you some answers. Hmmm, just do not remember where he lives.
  - now: Sweet! First, you need to gather information from a friend of mine who has visited the islands. Look for Arold, he will give you some answers. Hmmm, I just do not remember where he lives.
- quest 8206 talk_questFinishing - broken question
  - was: You've got enough information about the Orange Archipelago?
  - now: Did you get enough information about the Orange Archipelago?
- quest 8353 talk_questFinishing - broken question
  - was: You found Runford?
  - now: Did you find Runford?
- quest 8213 talk_questStarting - broken question
  - was: Hello, you made your preparations correct? I need your help again. Are you prepared to travel to the Orange Archipelago?
  - now: Hello, did you make your preparations? I need your help again. Are you prepared to travel to the Orange Archipelago?
- quest 8213 talk_questStarted - garbled sentence structure
  - was: Great. Professor Ivy inhabiting the archipelago is in possession of a new type of Pokeball what she calls the GS Ball. She still could not open the Pokeball and asked my help to continue the research. I need you to fetch it for me. Go ahead champion! Tip: start at Vermilion ship and reach Valencia Island.
  - now: Great. Professor Ivy, who lives in the archipelago, has a new type of Pokeball she calls the GS Ball. She still could not open it and asked for my help to continue the research. I need you to fetch it for me. Go ahead champion! Tip: take the ship at Vermilion and reach Valencia Island.
- quest 8213 talk_questFinishing - broken question
  - was: You brought the GS ball?
  - now: Did you bring the GS ball?
- quest 8213 talk_questFinished - 'opening research' wrong
  - was: Thank you! I'm opening research on this mysterious artifact. Go see Ivy again, maybe she needs your help.
  - now: Thank you! I'm starting research on this mysterious artifact. Go see Ivy again, maybe she needs your help.
- quest 8328 talk_questStarting - awkward 'It's time to run'
  - was: Ok, I was informed of everything. It's time to run. You must listen to me right now.
  - now: Ok, I've been informed of everything. There's no time to lose. Listen to me carefully right now.
- quest 8328 talk_questStarted - 'bottom of' unclear
  - was: This stone is being kept on the Shamouti island. Run to the bottom of the main island and find the way. Go!
  - now: This stone is being kept on Shamouti Island. Run to the south end of the main island and find the way. Go!
- quest 8328 talk_questFinishing - broken question
  - was: You found the Deepsoul Stone?
  - now: Did you find the Deepsoul Stone?

## Professor Tommy

- npc/scripts/professorTommy.lua - awkward 'Anytime you can'
  - was: You are on this island to capture your first Pokemon, try to capture a wild one with your special small stones and your empty soul ball. After that come to talk about your {journey}. Anytime you can get off this island, just say '{skip}'.
  - now: You are on this island to capture your first Pokemon. Try to catch a wild one with your special small stones and your empty soul ball. After that, come talk to me about your {journey}. If you want to leave this island at any time, just say '{skip}'.

## Prophet Slowking

- npc/scripts/quest_prophetSlowking.lua - 'coming in harmony' wrong
  - was: Please do not interrupt, I'm coming in harmony with nature now.
  - now: Please do not interrupt, I'm communing with nature right now.
- npc/scripts/quest_prophetSlowking.lua - question word order
  - was: What reward you want? Your options are: {Dragon Scale}, {King's Rock} or {Metal Coat}.
  - now: What reward do you want? Your options are: {Dragon Scale}, {King's Rock} or {Metal Coat}.
- npc/scripts/quest_prophetSlowking.lua - 'Here is.'
  - was: Great choice! Here is.
  - now: Great choice! Here it is.
- npc/scripts/quest_prophetSlowking.lua - 'look my friend' unclear
  - was: You will need to look my friend, I suggest you to start looking in Navel. Also talk to a scientist of your kind and get a translator to talk to the Pokemon that live there. The machine is under construction I think. Good luck
  - now: You will need to look for my friend. I suggest you start looking in Navel. Also talk to a scientist of your kind and get a translator to talk to the Pokemon that live there. I think the machine is still under construction. Good luck!
- npc/scripts/quest_prophetSlowking.lua - garbled; 'her' for stone
  - was: Great, you got a great stage of your adventure. As of now there is no return... the Deepsoul Stone was recently removed from its original location and is now guarded by a large Pokemon. You need to go after a new treasure to get to her. Go talk to your professor, he is already aware of the situation. At the end go back to my presence. Good luck!
  - now: Great, you have reached an important stage of your adventure. From now on there is no turning back... the Deepsoul Stone was recently removed from its original location and is now guarded by a large Pokemon. You need to go after a new treasure to reach it. Go talk to your professor, he is already aware of the situation. Then come back to me. Good luck!
- quest 8242 talk_questStarting - 'predicted this prophecy' odd
  - was: Yes, I'm the elder. Some time ago I predicted this prophecy even before the three kings were born. Are you ready for this journey?
  - now: Yes, I'm the elder. Long ago I made this prophecy, even before the three kings were born. Are you ready for this journey?
- quest 8242 talk_questStarted - nonsense 'My value is none'
  - was: You need to help the three tribes to regain the balance that is breaking. My value is none far from my house. First go to the {Sea Tribe} and talk to the Chief, ask for {Deepsoul Stone}.
  - now: You need to help the three tribes restore the balance that is breaking. They are not far from my house. First go to the {Sea Tribe} and talk to the Chief, ask for the {Deepsoul Stone}.
- quest 8242 talk_questFinishing - 'Do you find'; mismatched item
  - was: Do you find the Chief Vaporeon and get the restore stones?
  - now: Did you find Chief Vaporeon and get the restore stones?
- quest 8368 talk_questStarting - garbled sentence
  - was: Great, you got a great stage of your adventure. As of now there is no return... 
  - now: Great, you have reached an important stage of your adventure. From now on there is no turning back... 
- quest 8368 talk_questStarted - 'her' for stone; 'go back to my presence'
  - was: The Deepsoul Stone was recently removed from its original location and is now guarded by a large Pokemon. You need to go after a new treasure to get to her. Go talk to your professor, he is already aware of the situation. At the end go back to my presence. Good luck!
  - now: The Deepsoul Stone was recently removed from its original location and is now guarded by a large Pokemon. You need to go after a new treasure to reach it. Go talk to your professor, he is already aware of the situation. Then come back to me. Good luck!
- quest 8368 talk_questFinished - question word order
  - was: Thank you trainer. For now our mission is accomplished. Now enjoy a period of peace. Be sure to talk with your professor. What reward you want? Your options are: {Dragon Scale}, {King's Rock} or {Metal Coat}.
  - now: Thank you trainer. For now our mission is accomplished. Enjoy a period of peace, and be sure to talk with your professor. What reward do you want? Your options are: {Dragon Scale}, {King's Rock} or {Metal Coat}.

## Queenie Jerrie

- quest 8245 talk_questFinishing - broken question
  - was: You get the grape flowers?
  - now: Did you get the grape flowers?

## Queter Phill

- quest 8667 talk_questStarting - contradiction past/future, unclear
  - was: Thanks to Bill's help now I can return to the past any time! So I created this battle simulator to prepare our young people for the future! Do you want to join us?
  - now: Thanks to Bill's help I can now return to the past any time! So I created this battle simulator to prepare our young people for the future! Do you want to join us?
- quest 8667 talk_questStarted - awkward 'bring to me'
  - was: Great, very good! Your task is simple, wait for the battle simulator to send the global message, enter the teleport and defeat the copy of Suramoon. To prove your feat, bring to me the essences that will be in his body.
  - now: Great, very good! Your task is simple: wait for the battle simulator to send the global message, enter the teleport and defeat the copy of Suramoon. To prove your feat, bring me the essences you find on his body.
- quest 8667 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you don't.
- quest 8668 talk_questStarting - awkward question
  - was: It's good to see you're ready! Let's continue?
  - now: It's good to see you're ready! Shall we continue?
- quest 8668 talk_questStarted - misspelled 'Surammon'
  - was: OK! You will now be on the second level of the simulator. Do the same thing, wait for the call, enter the teleport and defeat Surammon! Then bring me the essences.
  - now: OK! You will now be on the second level of the simulator. Do the same thing: wait for the call, enter the teleport and defeat Suramoon! Then bring me the essences.
- quest 8669 talk_questFinished - 'take your uniform here'
  - was: Very well! You did it! You are now part of the Allied Force! Congratulations, my friend, take your uniform here. Now watch out, for evil can be in every corner of this continent!
  - now: Very well! You did it! You are now part of the Allied Force! Congratulations, my friend, here is your uniform. Now watch out, for evil can lurk in every corner of this continent!

## Rafael Townson

- message_greet - unneeded 'the' before island
  - was: Hello |PLAYERNAME|, welcome to the {Frontier Island}! I am responsible for the {Battle Tower}.
  - now: Hello |PLAYERNAME|, welcome to {Frontier Island}! I am in charge of the {Battle Tower}.
- npc/scripts/fi_battletower.lua - 'test for' wrong; 'in the'
  - was: You're in the Frontier Island, an appropriate location to test for the continent's greatest Pokemon trainers. Prove your strength here and you will be rewarded.
  - now: You're on Frontier Island, the right place to test the continent's greatest Pokemon trainers. Prove your strength here and you will be rewarded.
- npc/scripts/fi_battletower.lua - unclear 'space to receive Pokemon'
  - was: You do not have enough space to receive Pokemon! Check your backpack.
  - now: You do not have enough space to receive the Pokemon! Check your backpack.

## Rafe

- message_greet - awkward question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, want to trade your soul coins?

## Rakin

- message_greet - missing subject
  - was: Bro, relax...  need only catch some Pokemon.
  - now: Bro, relax... I just need to catch some Pokemon.
- quest 8199 talk_questStarting - 'some task' awkward
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8199 talk_questStarted - 'is catch'; 'them' for one
  - was: Thanks! Your task is catch 1 Drowzee and bring them to me.
  - now: Thanks! Your task is to catch 1 Drowzee and bring it to me.
- quest 8199 talk_questFinishing - question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8200 talk_questStarted - 'is catch'; 'them' for one
  - was: Thanks! Your task is catch 1 Abra and bring them to me.
  - now: Thanks! Your task is to catch 1 Abra and bring it to me.

## Ralph Patton

- message_greet - garbled sentence
  - was: Valencia is a great place. Here are the goods in the store first, check!
  - now: Valencia is a great place. Check out the goods in the store first!

## Randy Hayden

- message_greet - 'planting your Pokemon berries' odd
  - was: Hello |PLAYERNAME|. You can buy here all the necessary equipment to start planting your Pokemon berries.
  - now: Hello |PLAYERNAME|. Here you can buy all the equipment you need to start planting berries for your Pokemon.

## Raphael

- message_greet - question word order
  - was: Hello |PLAYERNAME|. What I can do for you?
  - now: Hello |PLAYERNAME|. What can I do for you?

## Raynard Randell

- message_greet - missing 'do'
  - was: Hello |PLAYERNAME|, you need something to brighten your home?
  - now: Hello |PLAYERNAME|, do you need something to brighten your home?

## Reana

- message_greet - missing 'under'
  - was: I'll bury you underground lots of rocks and earth. HAHAHAHA!
  - now: I'll bury you under lots of rocks and earth. HAHAHAHA!

## Rebbeca

- message_greet - 'didn't saw'
  - was: Argh! I didn't saw you.
  - now: Argh! I didn't see you.
- quest 8453 talk_questStarted - 'preparing to'; 'They are five'
  - was: My Pokemon are free to walk around when they are not preparing to beauty contests. They all lost their special ribbons, this can only be a curse! Use every trick you know to try to find them, please. They are five.
  - now: My Pokemon are free to walk around when they are not preparing for beauty contests. They all lost their special ribbons, this can only be a curse! Use every trick you know to find them, please. There are five.
- quest 8453 talk_questFinished - 'look more relieved' wrong
  - was: Thanks, I'll look more relieved. Take this simple thank you for your effort. Thank you.
  - now: Thanks, I feel so relieved. Take this small token of thanks for your effort. Thank you.
- quest 8453 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.

## Red

- npc/scripts/quest_red.lua - question word order
  - was: Now which city you want to start out? {Viridian}, {Pewter}, {Cerulean}, {Saffron}, {Celadon}, {Vermilion} or {Fuchsia}.
  - now: Now, which city do you want to start in? {Viridian}, {Pewter}, {Cerulean}, {Saffron}, {Celadon}, {Vermilion} or {Fuchsia}.

## Red Hughie

- message_greet - nonsense greeting
  - was: Will not need it? We did. Which items to sell?
  - now: Got things you don't need? We buy them. What do you want to sell?

## Reese

- message_greet - garbled sentence, 'though'
  - was: Get them will be as though as hold water in your hands buddy.
  - now: Getting them is as hard as holding water in your hands, buddy.
- quest 8080 talk_questStarting - 'some task' awkward
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8080 talk_questFinishing - broken question
  - was: You got the items?
  - now: Did you get the items?

## Reg

- message_greet - missing words
  - was: What do you want the central island?
  - now: What do you want on the central island?

## Rhetta Verna

- message_greet - 'exchange into' wrong
  - was: Welcome to the Vital Mastery! Here you can exchange your vital tokens into rewards. Type {options} to see.
  - now: Welcome to the Vital Mastery! Here you can exchange your vital tokens for rewards. Type {options} to see them.

## Rian

- message_greet - question word order
  - was: Hello |PLAYERNAME|. How I can help you? Are you hungry or thirsty?
  - now: Hello |PLAYERNAME|. How can I help you? Are you hungry or thirsty?

## Richard

- message_greet - awkward question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, want to trade your soul coins?

## Rick

- quest 8446 talk_questStarting - garbled 'is like sitting beside me'
  - was: Oh! We have a new candidate! I invented a system where people leave messages on Mission Board for trainers to collect a job and earn rewards with it. The Mission Board is like sitting beside me, and all you have to do to use it is to show that you can respond to the requests. What do you think?
  - now: Oh! We have a new candidate! I invented a system where people post messages on the Mission Board so trainers can take jobs and earn rewards. The Mission Board is right beside me, and to use it you just have to show you can handle the requests. What do you think?
- quest 8446 talk_questStarted - 'are the name of three persons'
  - was: Ok. In this paper I gave you are the name of three persons here in Fuchsia who asked me for help. Complete these three tasks and then talk to me.
  - now: Ok. The paper I gave you has the names of three people here in Fuchsia who asked me for help. Complete these three tasks and then talk to me.
- quest 8446 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.

## Robert Jones

- message_greet - lowercase sentence start
  - was: Hello |PLAYERNAME|. want to buy new clothes? Just say {trade}. Remember that only premium account players can wear these clothes!
  - now: Hello |PLAYERNAME|. Want to buy new clothes? Just say {trade}. Remember that only premium account players can wear these clothes!

## Robin Theobald

- message_greet - missing 'for'
  - was: I like the style! We have what you're looking dude. Remember that only premium account players can wear these clothes!
  - now: I like the style! We have what you're looking for, dude. Remember that only premium account players can wear these clothes!

## Rock

- npc/scripts/quest_rock.lua - 'has the old reward'
  - was: You've done this mission and has the old reward, I can renew your reward. Do you want it?
  - now: You've done this mission and have the old reward. I can renew your reward. Do you want it?
- quest 8018 talk_questStarting - 'Before I want'; 'Accepted?'
  - was: Want to know the secret of the strength of Pokemon? I have many stories to tell. Before I want you to do something for me. Accepted?
  - now: Want to know the secret of Pokemon strength? I have many stories to tell. But first I want you to do something for me. Deal?
- quest 8018 talk_questStarted - missing 'and'
  - was: Now I'm a little hungry, bring me a burger I'll tell you something. Haha.
  - now: Now I'm a little hungry. Bring me a burger and I'll tell you something. Haha.
- quest 8018 talk_questFinished - missing 'you'
  - was: Thanks, I'm really hungry. I can give something valuable if you help me in some {tasks}...
  - now: Thanks, I'm really hungry. I can give you something valuable if you help me with some {tasks}...
- quest 8019 talk_questStarted - 'size of its force' wrong
  - was: Let's see the size of its force. Bring me 50 stone orbs and 4 fist plates. Easy, no?
  - now: Let's see how strong you are. Bring me 50 stone orbs and 4 fist plates. Easy, no?
- quest 8019 talk_questFinished - missing subjects, garbled
  - was: Hmm, is not as weak as thought. But not only that, we are just beginning, I have more {tasks} for you.
  - now: Hmm, you're not as weak as I thought. But that's not all, we are just beginning, I have more {tasks} for you.
- quest 8020 talk_questStarted - garbled; 'it' for friend
  - was: Ok, I have an old friend who does not see time, I want you to find it for me. You will be able to find it on the Ice Island. Bring something in there to prove that you were.
  - now: Ok, I have an old friend I haven't seen in a long time, I want you to find him for me. You will find him on Ice Island. Bring something back from there to prove you went.
- quest 8020 talk_questFinishing - missing auxiliary
  - was: Found my friend?
  - now: Did you find my friend?
- quest 8022 talk_questStarting - awkward fragment
  - was: Really want?
  - now: Do you really want it?
- quest 8022 talk_questStarted - capital after comma
  - was: I think this is too much for you! Haha! Simple, beat the three Lee brothers, You'll find them on the mountain northeast from Saffron.
  - now: I think this is too much for you! Haha! Simple: beat the three Lee brothers. You'll find them on the mountain northeast of Saffron.
- quest 8022 talk_questFinishing - broken question
  - was: You beat them?!
  - now: Did you beat them?!
- quest 8022 talk_questFinishFail - 'can not' wrong meaning
  - was: No, you can not.
  - now: No, you didn't.
- quest 8023 talk_questStarting - 'make the test'
  - was: Want to make the final test?
  - now: Want to take the final test?
- quest 8023 talk_questStarted - capitalization, 'bring to me'
  - was: Alright, Thousands of fighters have tried to do this mission and failed, so be careful. Go to the south of this mountain, there is a secret passage to the Natural Mountain. Go there and bring to me a special stone, called Ancient Rune.
  - now: Alright. Thousands of fighters have tried this mission and failed, so be careful. Go to the south of this mountain, there is a secret passage to the Natural Mountain. Go there and bring me a special stone called Ancient Rune.
- quest 8023 talk_questFinishing - broken question
  - was: You're with my special stone?
  - now: Do you have my special stone?
- quest 8023 talk_questFinishFail - incomplete sentence
  - was: No you do not have...
  - now: No, you don't have it...

## Rock Jhonson

- quest 8004 talk_questStarting - missing object 'find them'
  - was: Want to earn some reward? I need a few items and I'm not able to find.
  - now: Want to earn a reward? I need a few items and I can't find them.
- quest 8004 talk_questStarted - garbled 'back when you are with them'
  - was: Ok, the items that I need are 10 razor fangs, back when you are with them.
  - now: Ok, the items I need are 10 razor fangs. Come back when you have them.
- quest 8004 talk_questFinishing - broken question
  - was: You've got what I asked?
  - now: Did you get what I asked for?
- quest 8004 talk_questFinished - punctuation '..'
  - was: Thank you, here is your reward..Take care.
  - now: Thank you, here is your reward. Take care.
- quest 8004 talk_questFinishFail - garbled sentence
  - was: No.. you do not have, back when you are with them.
  - now: No... you don't have them. Come back when you do.

## Rocket Captain

- message_greet - question word order
  - was: Who you are?!
  - now: Who are you?!
- quest 8436 talk_questStarting - missing noun after 'useless'
  - was: That useless let you in. What do you want?!
  - now: That useless guard let you in. What do you want?!
- quest 8436 talk_questFinished - garbled sentences
  - was: Great, now that helped us look for what you want there. Do not enter the lab, it is a warning! To go there you need the card. We lost, try to find it too... now get lost!
  - now: Great, that helped. Now go look for whatever you came for. Do not enter the lab, this is a warning! To get in you need the card. We lost it, so try to find that too... now get lost!
- quest 8436 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.

## Rocket Glenda Pansy

- message_greet - misquote 'Steal or not'
  - was: Steal or not to steal? That's the question.
  - now: To steal or not to steal? That is the question.

## Rocket Grunt

- npc/scripts/quest_rocketGrunt.lua - unclear tile instruction
  - was: You're tough, I will not be able to hold you here anyway. I hope that others give you a lesson down there. Step the last right tile now... get out!
  - now: You're tough, I can't hold you here anyway. I hope the others teach you a lesson down there. Step on the last tile on the right now... get out!
- npc/scripts/quest_rocketGrunt.lua - garbled sentence
  - was: Am I alone here! Others are {down} there... I MEAN, are stealing Pokemon around!
  - now: I'm all alone here! The others are {down} there... I MEAN, they're out stealing Pokemon!
- npc/scripts/quest_rocketGrunt.lua - missing comma in tag question
  - was: You do not give up do you? I WANT A {BATTLE}!
  - now: You don't give up, do you? I WANT A {BATTLE}!
- npc/scripts/quest_rocketGrunt.lua - 'place for nosy'
  - was: Get out, this is no place for nosy. {We}'re... I mean, I'm busy!
  - now: Get out, this is no place for nosy people. {We}'re... I mean, I'm busy!

## Rocket Heidi Eartha

- message_greet - 'hurt you much' awkward
  - was: Sorry, but I will hurt you much.
  - now: Sorry, but I'm going to hurt you badly.

## Rofie

- npc/scripts/shop_ballPaint.lua - 'Here is!'
  - was: Here is! Thanks!
  - now: Here it is! Thanks!
- npc/scripts/shop_ballPaint.lua - missing subject
  - was: Sorry, do not know what you're talking about.
  - now: Sorry, I don't know what you're talking about.

## Roman

- message_greet - missing 'for'
  - was: Hey |PLAYERNAME|, are you searching flying Pokemon? I have the necessary equipment to deal with them!
  - now: Hey |PLAYERNAME|, are you searching for flying Pokemon? I have the necessary equipment to deal with them!
- quest 8044 talk_questFinishing - broken question
  - was: You brought the items I asked you?
  - now: Did you bring the items I asked for?
- quest 8044 talk_questFinishFail - question word order
  - was: Where they are?
  - now: Where are they?
- quest 8045 talk_questStarting - awkward 'like the cage?'
  - was: Oh! You again, like the cage? I hope so... because I have other equipment to give you.
  - now: Oh! You again! Did you like the cage? I hope so... because I have more equipment to give you.
- quest 8045 talk_questFinishing - 'Are you with' wrong
  - was: Are you with my items?
  - now: Do you have my items?
- quest 8045 talk_questFinished - misspelling 'joob'; 'here is'
  - was: Good joob, here is. Now you have all the necessary equipment to get your Pokemon!
  - now: Good job, here it is. Now you have all the equipment you need to catch your Pokemon!

## Ron

- message_greet - 'sell for me'; broken grammar
  - was: Hi |PLAYERNAME|, do you want to {sell} some Pokemon for me? Always good price here, you can trust.
  - now: Hi |PLAYERNAME|, do you want to {sell} me some Pokemon? Always a good price here, you can trust me.

## Roscoe

- message_greet - awkward question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, want to trade your soul coins?

## Ross Bobby

- message_greet - missing subject 'it was sold'
  - was: My friends and I had a home in Viridian, but was sold.
  - now: My friends and I had a home in Viridian, but it was sold.

## Roxy

- message_greet - 'don't curse me' unclear
  - was: Poison is like this fear that is spreading in your soul in this exact moment. But don't curse me.
  - now: Poison is like the fear spreading through your soul at this very moment. But don't blame me.

## Royston

- message_greet - garbled sentence
  - was: Came to seek an order? No one ever comes even...
  - now: Came to pick up an order? No one ever comes...

## Rukia

- message_greet - garbled 'Get the pick the shovel'
  - was: Get the pick the shovel, buddy, you're going to dig underground for a long time.
  - now: Grab the pick and the shovel, buddy, you're going to dig underground for a long time.
- quest 8080 talk_questStarting - 'some task' awkward
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8080 talk_questFinishing - broken question
  - was: You got the items?
  - now: Did you get the items?

## Runford

- quest 8207 talk_questStarted - garbled grammar throughout
  - was: Cool buddy, I hope you have fun there! But before, I fear that you already has a map right? No...? I think that Pistachio has one. You can get with him? Go behind this crazy old guy. But watch out! He bites!
  - now: Cool buddy, I hope you have fun there! But first, I guess you already have a map, right? No...? I think Pistachio has one. Can you get it from him? Go after that crazy old guy. But watch out! He bites!
- quest 8207 talk_questFinishing - broken question
  - was: You have the map?
  - now: Do you have the map?
- quest 8207 talk_questFinished - wrong preposition 'into'
  - was: Great! Good luck into your adventure! I think Professor Oak is looking for you.
  - now: Great! Good luck on your adventure! I think Professor Oak is looking for you.
- quest 8207 talk_questFinishFail - tense mismatch
  - was: No, you haven't.
  - now: No, you don't.

## Rusty Barret

- message_greet - missing punctuation after name
  - was: You there! Yes! |PLAYERNAME| Did you see the size of the {fish} I caught today? Hahahah
  - now: You there! Yes! |PLAYERNAME|! Did you see the size of the {fish} I caught today? Hahahah
- quest 8742 talk_questStarting - missing 'to'
  - was: You're just getting started, now let's go the next step.
  - now: You're just getting started, now let's go to the next step.
- quest 8742 talk_questFinished - 'come on to' awkward
  - was: You're doing well, but do not think you already know everything! We have a long way to go. When you're ready, come on to the next {mission}.
  - now: You're doing well, but do not think you already know everything! We have a long way to go. When you're ready, come back for the next {mission}.
- quest 8744 talk_questStarting - 'go on the' preposition
  - was: The best fish are caught early in the morning so you can not be lazy! Let's go on the next mission.
  - now: The best fish are caught early in the morning, so you can't be lazy! Let's move on to the next mission.
- quest 8745 talk_questStarting - 'going up' unclear
  - was: Now things are going up!
  - now: Now things are heating up!
- quest 8745 talk_questStarted - word order '30 level of fishing'
  - was: Show me what you are capable of, reach 30 level of fishing!
  - now: Show me what you are capable of, reach fishing level 30!
- quest 8746 talk_questStarted - word order
  - was: After this last step, you are officially a professional fisherman. Reach level 50 fishing.
  - now: After this last step, you'll officially be a professional fisherman. Reach fishing level 50.
- quest 8746 talk_questFinished - 'explore the life' awkward
  - was: Congratulations! You have proved that you are capable! Take your reward. Now go explore the life that exists outside this continent, maybe one day we'll talk again.
  - now: Congratulations! You have proved that you are capable! Take your reward. Now go explore the world beyond this continent, maybe one day we'll talk again.

## Ryne

- quest 8105 talk_questStarting - 'some task' awkward
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8105 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Raichu.
  - now: Thanks! Your task is to defeat 30 Raichu.
- quest 8105 talk_questFinishing - question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8106 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Magneton.
  - now: Thanks! Your task is to defeat 30 Magneton.
- quest 8107 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Electrode.
  - now: Thanks! Your task is to defeat 30 Electrode.
- quest 8108 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 15 Electabuzz.
  - now: Thanks! Your task is to defeat 15 Electabuzz.
- quest 8109 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Sandslash.
  - now: Thanks! Your task is to defeat 30 Sandslash.
- quest 8110 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Dugtrio.
  - now: Thanks! Your task is to defeat 30 Dugtrio.
- quest 8111 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Golem.
  - now: Thanks! Your task is to defeat 30 Golem.
- quest 8113 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Venusaur.
  - now: Thanks! Your task is to defeat 30 Venusaur.
- quest 8114 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Vileplume.
  - now: Thanks! Your task is to defeat 30 Vileplume.
- quest 8115 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Victreebel.
  - now: Thanks! Your task is to defeat 30 Victreebel.

## Sabrina

- npc/scripts/npcbattle_sabrina.lua - 'before receive'
  - was: You must defeat me before receive your reward.
  - now: You must defeat me before receiving your reward.
- npc/scripts/npcbattle_sabrina.lua - 'here is!'
  - was: Oh, here is!
  - now: Oh, here it is!
- npc/scripts/npcbattle_sabrina.lua - 'There are someone'
  - was: There are someone doing this right now, please try again later.
  - now: Someone is doing this right now, please try again later.
- quest 8474 talk_questStarting - garbled grammar, 'you will can'
  - was: I have a test for trainers with courage and determination. If you think you can, just confirm if you want. So get ready. You will be mesmerized by my Pokemon and you will be taken to the world of dreams. There, you will have to unravel the my mystery, all this thanks to recent advances in Devon Corporation. We will be connected to the Dream World, a world of Pokemon dreams. And there I created a challenge for trainers. Unravel the mystery and you will can. Are you ready?
  - now: I have a test for trainers with courage and determination. If you think you can do it, just confirm. Then get ready: you will be mesmerized by my Pokemon and taken to the world of dreams. There you will have to unravel my mystery, all thanks to recent advances by Devon Corporation. We will be connected to the Dream World, a world of Pokemon dreams, where I created a challenge for trainers. Unravel the mystery and you will succeed. Are you ready?
- quest 8474 talk_questFinishing - broken question
  - was: You complete my test?
  - now: Did you complete my test?
- quest 8474 talk_questFinished - 'passed on my test'
  - was: Okay, you passed on my test. Take this reward. I will soon have news about the Dream World, so stay tuned. See ya.
  - now: Okay, you passed my test. Take this reward. I will soon have news about the Dream World, so stay tuned. See ya.
- quest 8474 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.

## Sailor Whitaker Adolph

- message_greet - question word order
  - was: You are the new recruit? Go talk to the Captain!
  - now: Are you the new recruit? Go talk to the Captain!

## Sakura

- quest 8080 talk_questStarting - 'some task' awkward
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8080 talk_questFinishing - broken question
  - was: You got the items?
  - now: Did you get the items?

## Sam

- message_greet - 'So' misused
  - was: Hello |PLAYERNAME|. Thirsty? So you came to the right place.
  - now: Hello |PLAYERNAME|. Thirsty? Then you came to the right place.

## Samira

- message_greet - question word order
  - was: You should get warmed up and stretched out. Today will be a tough day... or you are the tough one... no idea...
  - now: You should warm up and stretch. Today will be a tough day... or are you the tough one... no idea...
- quest 8150 talk_questStarting - 'some task' awkward
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8150 talk_questStarted - 'is catch'; 'them' for one
  - was: Thanks! Your task is catch 1 Machop and bring them to me.
  - now: Thanks! Your task is to catch 1 Machop and bring it to me.
- quest 8150 talk_questFinishing - question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8151 talk_questStarted - missing 'to'
  - was: Thanks! Your task is catch 2 Mankey and bring them to me.
  - now: Thanks! Your task is to catch 2 Mankey and bring them to me.
- quest 8152 talk_questStarted - 'is catch'; 'them' for one
  - was: Thanks! Your task is catch 1 Clefairy and bring them to me.
  - now: Thanks! Your task is to catch 1 Clefairy and bring it to me.
- quest 8153 talk_questStarted - 'is catch'; 'them' for one
  - was: Thanks! Your task is catch 1 Jigglypuff and bring them to me.
  - now: Thanks! Your task is to catch 1 Jigglypuff and bring it to me.

## Sampson Trueman

- message_greet - missing 'it'
  - was: Planting, watering, harvesting... is not this a beautiful thing?
  - now: Planting, watering, harvesting... isn't it a beautiful thing?

## Saruman

- message_greet - 'You are hurry?'
  - was: I took my coffee and I feel great now. You are hurry?
  - now: I had my coffee and I feel great now. Are you in a hurry?
- quest 8259 talk_questStarting - 'You can find it anywhere' unclear
  - was: My Donphan lost his ball playing around. You can find it anywhere. Can you help us?
  - now: My Donphan lost his ball while playing around. It could be anywhere. Can you help us find it?
- quest 8259 talk_questFinishing - broken question
  - was: You find my Donphan ball?
  - now: Did you find my Donphan's ball?

## Satya

- message_greet - word order 'show for what'
  - was: I hope you have trained a lot, because today you will have to show for what you came.
  - now: I hope you have trained a lot, because today you will have to show what you came for.
- quest 8139 talk_questStarting - 'some task' awkward
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8139 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Machamp.
  - now: Thanks! Your task is to defeat 30 Machamp.
- quest 8139 talk_questFinishing - question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8140 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Wigglytuff.
  - now: Thanks! Your task is to defeat 30 Wigglytuff.
- quest 8141 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Clefable.
  - now: Thanks! Your task is to defeat 30 Clefable.
- quest 8142 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Persian.
  - now: Thanks! Your task is to defeat 30 Persian.
- quest 8143 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Primeape.
  - now: Thanks! Your task is to defeat 30 Primeape.
- quest 8144 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Arbok.
  - now: Thanks! Your task is to defeat 30 Arbok.
- quest 8145 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Venomoth.
  - now: Thanks! Your task is to defeat 30 Venomoth.
- quest 8146 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Muk.
  - now: Thanks! Your task is to defeat 30 Muk.
- quest 8147 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Gengar.
  - now: Thanks! Your task is to defeat 30 Gengar.
- quest 8148 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Pidgeot.
  - now: Thanks! Your task is to defeat 30 Pidgeot.
- quest 8149 talk_questStarted - missing 'to'
  - was: Thanks! Your task is defeat 30 Fearow.
  - now: Thanks! Your task is to defeat 30 Fearow.

## Saundra Goucher

- message_greet - nonsense sentence; 'The Misty'
  - was: The Misty will munch with their Pokemon, she is the greatest!
  - now: Misty will crush you with her Pokemon, she is the greatest!

## Saxon Ashton

- message_greet - misspelling 'Sketchs'
  - was: Hello |PLAYERNAME|. Do you want to {reset} your Smeargle Sketchs?
  - now: Hello |PLAYERNAME|. Do you want to {reset} your Smeargle's Sketches?
- npc/scripts/sketch_reset.lua - wrong slot name
  - was: Please, first put a poke ball in your inventory slot.
  - now: Please put a poke ball in your ball slot first.
- npc/scripts/sketch_reset.lua - 'didn't copied'
  - was: Your Pokemon didn't copied any move.
  - now: Your Pokemon hasn't copied any moves.
- npc/scripts/sketch_reset.lua - 'didn't copied'
  - was: Your Pokemon didn't copied this move.
  - now: Your Pokemon hasn't copied this move.
- npc/scripts/sketch_reset.lua - garbled 'that you your'
  - was: Here you can {reset} Sketch moves that you your Smeargle copies!
  - now: Here you can {reset} the Sketch moves your Smeargle copied!

## Sefton

- message_greet - garbled sentence
  - was: What are you thinking of Mandarin South? You can also buy with my cousin Dale.
  - now: What do you think of Mandarin South? You can also buy from my cousin Dale.

## Selam

- message_greet - plural 'Pokemons'
  - was: Yes, I can speak!! I can help you build magic {balls} to catch Halloween Pokemons!
  - now: Yes, I can speak!! I can help you build magic {balls} to catch Halloween Pokemon!
- npc/scripts/event_halloween_selam.lua - plural 'Pokemons'
  - was: I can help you build magic {balls} to catch Halloween Pokemons!
  - now: I can help you build magic {balls} to catch Halloween Pokemon!
- npc/scripts/event_halloween_selam.lua - 'Here is'
  - was: Here is, thanks!
  - now: Here you go, thanks!
- npc/scripts/event_halloween_selam.lua - missing 'enough'
  - was: You do not have reagents for it.
  - now: You do not have enough reagents for it.
- quest 8408 talk_questStarting - 'these poor' missing noun
  - was: Damn Suramoon is using poor creatures as his evil army. I need your help to rescue these poor.
  - now: That damn Suramoon is using poor creatures as his evil army. I need your help to rescue them.
- quest 8408 talk_questStarted - 'she' for wand; garbled
  - was: Take this wand, she will purify the evil creatures soul. But please, do very carefully, they have no guilt!
  - now: Take this wand, it will purify the evil creatures' souls. But please, be very careful, they are not to blame!
- quest 8408 talk_questFinishing - 'Did you purified'
  - was: Did you purified the poor creatures soul?
  - now: Did you purify the poor creatures' souls?
- message_greet - missing 'under'
  - was: Yes, I can speak!! I need your {help} to free these poor creatures that are Suramoon domain.
  - now: Yes, I can speak!! I need your {help} to free these poor creatures under Suramoon's control.

## Selby

- message_greet - awkward question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, want to trade your soul coins?

## Selwyn

- message_greet - awkward question
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, want to trade your soul coins?

## Shannen Rita

- message_greet - awkward 'let's battle?'
  - was: Hello |PLAYERNAME|! I'm Shannen Rita, let's {battle}?
  - now: Hello |PLAYERNAME|! I'm Shannen Rita, shall we {battle}?

## Shaw Norm

- message_greet - awkward word order
  - was: The largest store of dolls!
  - now: The biggest doll store around!

## Shelley

- message_greet - 'skill movements' wrong
  - was: I'm here to teach you the basics about the {POKEDEX} and skill movements (HM). [You can {skip} this tutorial whenever you want.]
  - now: I'm here to teach you the basics of the {POKEDEX} and special moves (HM). [You can {skip} this tutorial whenever you want.]
- quest 8495 talk_questStarting - 'and like'; awkward grammar
  - was: Note that at the tables next to me are the machines to catalog Pokemon, the Pokedex. When a trainer starts his journey he receives his own Pokedex. This is an important device to store all the information about the Pokemon that you own. Here you will find information on the Stats of your Pokemon, his attacks (Moves) and their advantages and disadvantages. The extra information such as: Egg Group, HM's, the Pokemon description and like are also very important and are explained in the Wiki tab of the Pokepedia (press P). Copy that?
  - now: Notice that on the tables next to me are the machines that catalog Pokemon: the Pokedex. When trainers start their journey, they receive their own Pokedex. It is an important device that stores all the information about the Pokemon you own. Here you will find your Pokemon's Stats, its attacks (Moves) and their strengths and weaknesses. Extra information such as Egg Group, HMs, the Pokemon description and so on is also very important and is explained in the Wiki tab of the Pokepedia (press M). Copy that?
- quest 8495 talk_questStarted - 'come back to talk'
  - was: Now take your Pokedex and use it on the Psyduck. Just "Use" the Pokedex and then select the Pokemon. See the details and come back to talk to me.
  - now: Now take your Pokedex and use it on the Psyduck. Just "Use" the Pokedex and then select the Pokemon. Check the details and come back to talk to me.
- quest 8495 talk_questFinishing - 'Did you got'
  - was: Did you got the Psyduck information?
  - now: Did you get the Psyduck's information?
- quest 8495 talk_questFinishFail - nonsense 'Likes no'
  - was: Likes no.
  - now: Looks like you didn't.
- quest 8496 talk_questStarted - 'try to talk to me'
  - was: He is the steel-gray bird. See what happens and try to talk to me.
  - now: He is the steel-gray bird. See what happens and come talk to me.
- quest 8496 talk_questFinishing - 'Did you got'
  - was: Did you got the Skarmory information?
  - now: Did you get the Skarmory's information?
- quest 8496 talk_questFinished - 'treinars'; 'let's on at'
  - was: No! This happens because your Pokedex is not updated yet. To find out information about second generation Pokemon, you need to update it first. You can also use the Pokedex in wild Pokemon or the tamed ones also. If you use the Pokedex at treinars, you will get some cool information. Now let's on at {HM}.
  - now: No! That's because your Pokedex isn't updated yet. To see information about second generation Pokemon, you need to update it first. You can use the Pokedex on wild Pokemon and tamed ones too. If you use the Pokedex on trainers, you will get some cool information. Now let's move on to {HM}.
- quest 8497 talk_questStarting - wrong prepositions
  - was: The HM are special moves that your Pokemon can use at the map to perform a specific action. If your Pokemon has the Surf HM, he can travel through water with you. Just use the ORDER button on the Inventory at water's edge.
  - now: HMs are special moves your Pokemon can use on the map to perform a specific action. If your Pokemon has the Surf HM, it can travel through water with you. Just use the ORDER button in the Inventory at the water's edge.
- quest 8497 talk_questStarted - 'speak out' awkward
  - was: To fly through the air, just use a Pokemon with Fly HM. Use ORDER on your character and your Pokemon will fly with you. To get up and down speak out "/up" and "/down". I can {continue} when you feel ready.
  - now: To fly through the air, just use a Pokemon with the Fly HM. Use ORDER on your character and your Pokemon will fly with you. To go up and down, say "/up" and "/down". I can {continue} when you feel ready.
- quest 8497 talk_questFinishing - wrong preposition 'at'
  - was: To view which HM your Pokemon has, use the Pokedex at your Pokemon. For a more detailed explanation, read the Wiki tab of the Pokepedia (press P).
  - now: To see which HMs your Pokemon has, use the Pokedex on your Pokemon. For a more detailed explanation, read the Wiki tab of the Pokepedia (press M).
- quest 8497 talk_questFinished - 'follow to' awkward
  - was: Now use the next door and follow to the next room. Your goal in the next room is to talk to all NPCs. Once you're done, talk to Oak's Assistant at the end and you'll be ready for your journey.
  - now: Now go through the next door into the next room. Your goal in the next room is to talk to all NPCs. Once you're done, talk to Oak's Assistant at the end and you'll be ready for your journey.

## Shirley Rocky

- message_greet - missing article
  - was: You know, the life of chef is not easy, but my meals are fabulous ehhh!
  - now: You know, the life of a chef is not easy, but my meals are fabulous ehhh!

## Sir John

- quest 8222 talk_questStarting - 'for free now' awkward
  - was: Those girls broke the roof again? Argh! I will not fix it for free now, you will help me with something. Yes or no?
  - now: Those girls broke the roof again? Argh! I won't fix it for free this time, you will help me with something. {Yes} or {no}?
- quest 8222 talk_questFinishing - missing comma before 'brat'
  - was: Got everything brat? I do not want excuses...
  - now: Got everything, brat? I don't want excuses...
- quest 8223 talk_questStarting - broken question
  - was: You will help me in one more task?
  - now: Will you help me with one more task?
- quest 8223 talk_questStarted - wrong preposition 'in'
  - was: Go buy a toolbox for me in Pummelo Island.
  - now: Go buy a toolbox for me on Pummelo Island.
- quest 8223 talk_questFinishing - broken question
  - was: You got the toolbox for me?
  - now: Did you get the toolbox for me?
- quest 8223 talk_questFinished - word order
  - was: I will as soon as possible repair the roof, thanks.
  - now: I will repair the roof as soon as possible, thanks.

## Slash

- quest 8261 talk_questFinishing - tense 'what I've asked'
  - was: Did you bring me what I've asked?
  - now: Did you bring me what I asked for?

## Stacy David

- message_greet - unclear fragment
  - was: Is not good? Want to trade places with me?!
  - now: Not good enough? Want to trade places with me?!

## Stiller

- quest 8042 talk_questStarting - 'when wear'; 'a good money'
  - was: People of high society stand out when wear nice clothes. With a good money and some items I can help you.
  - now: People of high society stand out when they wear nice clothes. With good money and some items, I can help you.
- quest 8042 talk_questStarted - 'look for me' awkward
  - was: Okay, look for me 200x Fancy Fabrics, 200x Long Silks and 5000 dollars.
  - now: Okay, bring me 200x Fancy Fabrics, 200x Long Silks and 5000 dollars.
- quest 8042 talk_questFinishing - broken question
  - was: It's what I asked?
  - now: Is that what I asked for?
- quest 8042 talk_questFinishFail - 'your time' should be 'my'
  - was: Do not waste your time! Go get the parts.
  - now: Do not waste my time! Go get the parts.
- quest 8043 talk_questStarting - missing subject 'they are'
  - was: Accessories are very important to create a beautiful sight, however, are not cheap. I can get you some accessories, but you will not get them with money.
  - now: Accessories are very important to create a beautiful look, but they are not cheap. I can get you some accessories, but you can't get them with money.
- quest 8043 talk_questStarted - 'look for me' awkward
  - was: I'll need rare gems, look for me 50x Fire Orbs, 50x White Orbs and 50x Black Diamonds.
  - now: I'll need rare gems. Bring me 50x Fire Orbs, 50x White Orbs and 50x Black Diamonds.
- quest 8043 talk_questFinished - capital after comma; awkward
  - was: Wonderful! Here, Now you're dressed.
  - now: Wonderful! Here, now you're all dressed up.

## Substitute

- message_greet - Odd punctuation, unclear
  - was: I'm a {robot}!??!
  - now: I'm a {robot}?!
- npc/scripts/substitute_robot.lua - 'the real' missing noun
  - was: You got me! I'm the real!
  - now: You got me! I'm the real one!
- npc/scripts/substitute_robot.lua - Missing 'one'
  - was: You already finished this step, please move to the next.
  - now: You already finished this step, please move on to the next one.

## Susie

- message_greet - 'feets' misspelling
  - was: Let's make them eat dust and bury them 7 feets underground.
  - now: Let's make them eat dust and bury them 7 feet underground.
- quest 8185 talk_questStarting - 'some task' unnatural
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8185 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Sandslash.
  - now: Thanks! Your task is to defeat 30 Sandslash.
- quest 8185 talk_questFinishing - Broken question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8185 talk_questFinished - Unnatural phrasing
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.
- quest 8186 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Dugtrio.
  - now: Thanks! Your task is to defeat 30 Dugtrio.
- quest 8187 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Golem.
  - now: Thanks! Your task is to defeat 30 Golem.
- quest 8188 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Onix.
  - now: Thanks! Your task is to defeat 30 Onix.
- quest 8189 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Marowak.
  - now: Thanks! Your task is to defeat 30 Marowak.
- quest 8190 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Machamp.
  - now: Thanks! Your task is to defeat 30 Machamp.
- quest 8191 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Primeape.
  - now: Thanks! Your task is to defeat 30 Primeape.

## Symmon

- message_greet - Missing 'do' in question
  - was: Hey |PLAYERNAME|, you have Pokemon dolls? I buy them all.
  - now: Hey |PLAYERNAME|, do you have Pokemon dolls? I buy them all.

## Tabatha Elizalde

- message_greet - Fragment question, double space
  - was: I like Starmie and Dewgong,  you?
  - now: I like Starmie and Dewgong, what about you?

## Tate

- message_greet - Unclear, missing articles
  - was: Not only nail and screw, there are lots of cutting things too!
  - now: Not only nails and screws, we have lots of cutting tools too!
- quest 8080 talk_questStarting - 'some task' unnatural
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8080 talk_questFinishing - Statement as question
  - was: You got the items?
  - now: Did you get the items?
- quest 8080 talk_questFinished - Unnatural phrasing
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.

## Taya

- message_greet - Incomplete idiom
  - was: Fear? You ain't seen nothing.
  - now: Fear? You ain't seen nothing yet.
- quest 8119 talk_questStarting - 'some task' unnatural
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8119 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Arbok.
  - now: Thanks! Your task is to defeat 30 Arbok.
- quest 8119 talk_questFinishing - Broken question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8119 talk_questFinished - Unnatural phrasing
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.
- quest 8120 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Venomoth.
  - now: Thanks! Your task is to defeat 30 Venomoth.
- quest 8121 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Muk.
  - now: Thanks! Your task is to defeat 30 Muk.
- quest 8122 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Gengar.
  - now: Thanks! Your task is to defeat 30 Gengar.
- quest 8123 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Raichu.
  - now: Thanks! Your task is to defeat 30 Raichu.
- quest 8124 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Magneton.
  - now: Thanks! Your task is to defeat 30 Magneton.
- quest 8125 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Electrode.
  - now: Thanks! Your task is to defeat 30 Electrode.
- quest 8126 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 15 Electabuzz.
  - now: Thanks! Your task is to defeat 15 Electabuzz.
- quest 8127 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Sandslash.
  - now: Thanks! Your task is to defeat 30 Sandslash.
- quest 8128 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Dugtrio.
  - now: Thanks! Your task is to defeat 30 Dugtrio.
- quest 8129 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Golem.
  - now: Thanks! Your task is to defeat 30 Golem.
- quest 8131 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Venusaur.
  - now: Thanks! Your task is to defeat 30 Venusaur.
- quest 8132 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Vileplume.
  - now: Thanks! Your task is to defeat 30 Vileplume.
- quest 8133 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Victreebel.
  - now: Thanks! Your task is to defeat 30 Victreebel.

## Tereza Mendes

- npc/scripts/quest_terezaMendes.lua - 'He's needing' unnatural
  - was: He's needing {help}? Oh my.
  - now: He needs {help}? Oh my.
- npc/scripts/quest_terezaMendes.lua - Wrong tense
  - was: Since our childhood I wait for it... does he want me now? I need a new {lipstick} first.
  - now: I've waited for this since our childhood... does he want me now? I need a new {lipstick} first.
- quest 8249 talk_questStarting - Broken question word order
  - was: You can find one lipstick for me?
  - now: Can you find a lipstick for me?
- quest 8249 talk_questFinishing - 'one lipstick' unnatural
  - was: Did you find one lipstick?
  - now: Did you find a lipstick?

## Tierney Florence

- message_greet - 'We are fashion' wrong
  - was: Hello baby, we have everything you need. We are fashion too! Remember that only premium account players can wear these clothes!
  - now: Hello baby, we have everything you need. We are fashionable too! Remember that only premium account players can wear these clothes!

## Tilly Dianna

- message_greet - 'can not' misspelling
  - was: Hello, I can not talk to you now.
  - now: Hello, I can't talk to you now.
- quest 8256 talk_questStarting - Broken tense and phrasing
  - was: A few days ago I've been having this big problem that I'm not getting resolved, could you help me stop this plague?
  - now: For a few days now I've had this big problem I can't solve. Could you help me stop this plague?
- quest 8256 talk_questStarted - Awkward closing sentence
  - was: Great, I need you to defeat 30 Spinaraks. That is enough.
  - now: Great, I need you to defeat 30 Spinaraks. That should be enough.
- quest 8256 talk_questFinishing - Broken question word order
  - was: The task is done?
  - now: Is the task done?

## Timothy Kelvin

- message_greet - 'exchange into' wrong preposition
  - was: Yoo |PLAYERNAME|! I can exchange your {letters} into {anniversary tokens}.
  - now: Yoo |PLAYERNAME|! I can exchange your {letters} for {anniversary tokens}.
- npc/scripts/event_anniversary_letters.lua - 'how much', 'do exchange' errors
  - was: And how much letters do you want do exchange?
  - now: And how many letters do you want to exchange?
- npc/scripts/event_anniversary_letters.lua - 'exchange into' wrong preposition
  - was: Here you can exchange the letters into anniversary tokens, you can see the {options}.
  - now: Here you can exchange the letters for anniversary tokens, you can see the {options}.

## Tobias

- message_greet - Statement as question, unclear
  - was: Hello |PLAYERNAME|, let's trade your soul coins?
  - now: Hello |PLAYERNAME|, shall we trade your soul coins?

## Tomy

- message_greet - 'of all towns, hu?' awkward
  - was: Hello |PLAYERNAME|. Here you will find the best churros of all towns, hu?
  - now: Hello |PLAYERNAME|. Here you will find the best churros in all the towns, huh?

## Trace Kaden

- message_greet - 'try your promotion' unclear
  - was: Hi |PLAYERNAME|, welcome to the Ranger Club! You can view the {task} list, try your {promotion} inside the club or challenge the {bosses}.
  - now: Hi |PLAYERNAME|, welcome to the Ranger Club! You can view the {task} list, attempt your {promotion} inside the club or challenge the {bosses}.

## Trevor

- npc/scripts/event_halloween.lua - 'exchange into' wrong preposition
  - was: Here you can exchange halloween tokens into halloween gifts, you can see the {options}.
  - now: Here you can exchange halloween tokens for halloween gifts, you can see the {options}.
- npc/scripts/event_halloween.lua - Coins contradicts tokens
  - was: You do not have enough halloween coins for it.
  - now: You do not have enough halloween tokens for it.

## Tristan

- message_greet - 'lose fair' nonsense
  - was: All cheap and lose fair!
  - now: All cheap and all fair!

## Triston Tibby

- message_greet - 'exchange into'; 'Type' odd
  - was: Welcome to the Spectrum Mastery! Here you can exchange your spectrum tokens into rewards. Type {options} to see.
  - now: Welcome to the Spectrum Mastery! Here you can exchange your spectrum tokens for rewards. Say {options} to see them.

## Trueman Reilly

- message_greet - Broken grammar, unclear meaning
  - was: Create your young Pokemon with battles. Is not it?
  - now: Raise your young Pokemon through battles. Isn't that right?

## Tucker

- message_greet - 'the water' article
  - was: Did you know the water is the fountain of life? How about you prove it to me?
  - now: Did you know water is the fountain of life? How about you prove it to me?
- quest 8172 talk_questStarting - 'some task' unnatural
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8172 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Blastoise.
  - now: Thanks! Your task is to defeat 30 Blastoise.
- quest 8172 talk_questFinishing - Broken question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8172 talk_questFinished - Unnatural phrasing
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.
- quest 8173 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Golduck.
  - now: Thanks! Your task is to defeat 30 Golduck.
- quest 8174 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Dewgong.
  - now: Thanks! Your task is to defeat 30 Dewgong.
- quest 8175 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Cloyster.
  - now: Thanks! Your task is to defeat 30 Cloyster.
- quest 8176 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Kingler.
  - now: Thanks! Your task is to defeat 30 Kingler.
- quest 8177 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Venusaur.
  - now: Thanks! Your task is to defeat 30 Venusaur.
- quest 8178 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Vileplume.
  - now: Thanks! Your task is to defeat 30 Vileplume.
- quest 8179 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is defeat 30 Victreebel.
  - now: Thanks! Your task is to defeat 30 Victreebel.

## Tyrone Reetz

- message_greet - 'wait for' should be 'expect'
  - was: Do not be surprised by anything, and wait for everything in here.
  - now: Do not be surprised by anything, and expect everything in here.

## Upton Gavin

- message_greet - 'of all towns, hu?' awkward
  - was: Hello |PLAYERNAME|. Here you will find the best churros of all towns, hu?
  - now: Hello |PLAYERNAME|. Here you will find the best churros in all the towns, huh?

## Upton Hale

- message_greet - 'try your promotion' unclear
  - was: Hi |PLAYERNAME|, welcome to the Ranger Club! You can view the {task} list, try your {promotion} inside the club or challenge the {bosses}.
  - now: Hi |PLAYERNAME|, welcome to the Ranger Club! You can view the {task} list, attempt your {promotion} inside the club or challenge the {bosses}.

## Walt Eldred

- message_greet - Missing 'do' in question
  - was: Hello |PLAYERNAME|, you need something to brighten your home?
  - now: Hello |PLAYERNAME|, do you need something to brighten your home?

## Warwick Howard

- message_greet - 'It's all right??' Portuguese-ism
  - was: Heeellooo! It's all right?? Have you seen any {Pokemon} out there?
  - now: Heeellooo! How's it going?? Have you seen any {Pokemon} out there?
- quest 8732 talk_questStarting - Unclear 'information from everyone'
  - was: Yes, I'm a Pokemon fan! I want to get information from everyone. Can you help me out a bit?
  - now: Yes, I'm a Pokemon fan! I want to get information on every Pokemon. Can you help me out a bit?
- quest 8732 talk_questFinishFail - Unnatural phrasing
  - was: Looks like no.
  - now: Looks like you didn't.
- quest 8733 talk_questFinished - Awkward word order
  - was: THIS! Thank you. This information I really needed, I love these {Pokemon}.
  - now: THIS! Thank you. I really needed this information, I love these {Pokemon}.
- quest 8734 talk_questStarted - '20 Pokemon information' broken
  - was: Now, I'm going to need 20 Pokemon information!
  - now: Now, I'm going to need information on 20 Pokemon!
- quest 8734 talk_questFinished - Missing subject, unclear
  - was: Very well! Yes! Yes! Yes! Want information on all types of {Pokemon}! Take your reward.
  - now: Very well! Yes! Yes! Yes! I want information on all types of {Pokemon}! Take your reward.
- quest 8735 talk_questStarting - Misused 'already', awkward
  - was: Since I was little I already wanted to be a Squirtle, but as a teenager I already wanted to be a Golduck. Oops! I mean... can you get some more information?
  - now: Since I was little I wanted to be a Squirtle, but as a teenager I wanted to be a Golduck. Oops! I mean... can you get some more information?
- quest 8735 talk_questStarted - Unclear: information on 30 Pokemon
  - was: Hehe! I need 30 Pokemon now.
  - now: Hehe! I need information on 30 Pokemon now.
- quest 8735 talk_questFinished - Missing subject; 'ordered' odd
  - was: Congratulations, you really impressed me. Got all the {Pokemon} I ordered. Thank you.
  - now: Congratulations, you really impressed me. You got all the {Pokemon} I asked for. Thank you.
- quest 8736 talk_questStarting - 'Did you know!?' misplaced
  - was: In fact Venusaur has always been my favorite Pokemon, but I never wanted to tell anyone. Did you know!? So, can you do one last task for me?
  - now: In fact, Venusaur has always been my favorite Pokemon, but I never told anyone. Now you know! So, can you do one last task for me?
- quest 8736 talk_questStarted - '50 Pokemon information' broken
  - was: Can you bring me... 50 Pokemon information?!
  - now: Can you bring me... information on 50 Pokemon?!
- quest 8736 talk_questFinished - Awkward phrasing
  - was: I have no words to thank you, you really were a person who helped me a lot. I will forever be grateful, take your reward.
  - now: I have no words to thank you, you really helped me a lot. I will be forever grateful, take your reward.

## Waylon Terrance

- message_greet - 'let's battle?' odd question
  - was: Hello |PLAYERNAME|! I'm Waylon Terrance, let's {battle}?
  - now: Hello |PLAYERNAME|! I'm Waylon Terrance, shall we {battle}?

## West

- message_greet - 'a electric' article error
  - was: You'll feel how it is to be in a electric chair!
  - now: You'll feel what it's like to be in an electric chair!

## Whitaker Upton

- message_greet - Awkward greeting
  - was: What's the news my friend? Your options are: {balance}, {deposit}, {deposit all}, {withdraw}, {withdraw all} and {transfer}.
  - now: What's new, my friend? Your options are: {balance}, {deposit}, {deposit all}, {withdraw}, {withdraw all} and {transfer}.

## Wilburn Clint

- message_greet - 'try your promotion' unclear
  - was: Hi |PLAYERNAME|, welcome to the Ranger Club! You can view the {task} list, try your {promotion} inside the club or challenge the {bosses}.
  - now: Hi |PLAYERNAME|, welcome to the Ranger Club! You can view the {task} list, attempt your {promotion} inside the club or challenge the {bosses}.

## Wilf Mortimer

- message_greet - 'try your promotion' unclear
  - was: Hi |PLAYERNAME|, welcome to the Ranger Club! You can view the {task} list, try your {promotion} inside the club or challenge the {bosses}.
  - now: Hi |PLAYERNAME|, welcome to the Ranger Club! You can view the {task} list, attempt your {promotion} inside the club or challenge the {bosses}.

## Wilkie Joshua

- message_greet - Broken word order, capitalization
  - was: Wilkie It's me! Best pizza ever!
  - now: It's me, Wilkie! Best pizza ever!

## William Rock

- npc/scripts/quest_williamRock.lua - Missing 'do'; 'in' wrong
  - was: You want to help me in my excavations?
  - now: Do you want to help me with my excavations?
- npc/scripts/quest_williamRock.lua - Broken question
  - was: You could find some fossil rock?
  - now: Could you find a fossil rock?
- npc/scripts/quest_williamRock.lua - 'him' for fossil; awkward
  - was: I have good news, you found a %s! Congratulations! Take him to my brother, he will help you to examine it.
  - now: I have good news, you found a %s! Congratulations! Take it to my brother, he will help you examine it.
- npc/scripts/quest_williamRock.lua - Run-on; 'for my brother'
  - was: Thank you for all the help I have no more missions for now. Give the fossil for my brother, he can help you.
  - now: Thank you for all the help, I have no more missions for now. Give the fossil to my brother, he can help you.
- npc/scripts/quest_williamRock.lua - 'in my excavations' wrong preposition
  - was: Oh, thanks! So you want to help me in my excavations?
  - now: Oh, thanks! So you want to help me with my excavations?
- npc/scripts/quest_williamRock.lua - Run-on sentence
  - was: Right! I think I'm very close to finding some fossils, I need your help. At the end of this cave there is a special rock, try to do some digging in it with this shovel. Good luck, be careful there!
  - now: Right! I think I'm very close to finding some fossils, and I need your help. At the end of this cave there is a special rock. Try digging in it with this shovel. Good luck, be careful there!
- npc/scripts/quest_williamRock.lua - Broken, missing object
  - was: No.. you have not found.
  - now: No... you haven't found it yet.
- npc/scripts/quest_williamRock.lua - Missing subject
  - was: Sorry, do not know what you're talking about.
  - now: Sorry, I don't know what you're talking about.

## Woodworker Courts Ted

- quest 8316 talk_questStarting - Broken tense, question order; tables vs fence
  - was: Oops! He would come today, I totally forgot the tables... You can do this for me?
  - now: Oops! He's coming today and I totally forgot the fence... Can you do this for me?
- quest 8316 talk_questStarted - Unclear 'Once finished'
  - was: Go, take my axe and cut some trees for me. I think 5 is enough. Once finished bring them to me and I'll work on them.
  - now: Go, take my axe and cut some trees for me. I think 5 is enough. Once you're done, bring the wood to me and I'll work on it.
- quest 8316 talk_questFinishing - Broken question
  - was: You could cut the trees?
  - now: Were you able to cut the trees?
- quest 8317 talk_questStarting - Confusing, broken grammar
  - was: I think you can not take them on a trip... I will give three amounts of lumber for you, which is equivalent to three trips. You can help me in some tasks while I prepare the boards?
  - now: I don't think you can carry them all in one trip... I will give you the lumber in three batches, which means three trips. Can you help me with some tasks while I prepare the boards?
- quest 8317 talk_questStarted - Broken question word order
  - was: You can take this message to my wife who is in Celadon? Her name is Beatriz.
  - now: Can you take this message to my wife in Celadon? Her name is Beatriz.
- quest 8317 talk_questFinishing - Statement as question
  - was: You delivered the message to my wife?
  - now: Did you deliver the message to my wife?
- quest 8317 talk_questFinished - Agreement error; 'take.' dangling
  - was: Thank you. The first amount of boards are ready, take.
  - now: Thank you. The first batch of boards is ready, take it.
- quest 8320 talk_questStarted - Unclear 'in the island'
  - was: He lives underground in the island. Take some fruit. I thank you immensely for it.
  - now: He lives underground on the island. Take some fruit. I thank you immensely for it.
- quest 8320 talk_questFinishing - Wrong meaning
  - was: Gotta feed my Pokemon?
  - now: Did you feed my Pokemon?
- quest 8320 talk_questFinished - 'secound' misspelling, agreement
  - was: Thank you. The secound amount of boards are ready, take.
  - now: Thank you. The second batch of boards is ready, take it.
- quest 8321 talk_questStarting - Broken question word order
  - was: That's great you're back... I'm in trouble. You can help me?
  - now: Great that you're back... I'm in trouble. Can you help me?
- quest 8321 talk_questStarted - Awkward phrasing
  - was: It seems that my Pokemon is being attacked! You can help him, I know that. When you get ready step in the teleport machine.
  - now: It seems my Pokemon is being attacked! I know you can help him. When you're ready, step into the teleport machine.
- quest 8321 talk_questFinished - Agreement error; 'take.' dangling
  - was: Thank you. The last amount of boards are ready, take. Good luck!
  - now: Thank you. The last batch of boards is ready, take it. Good luck!

## Xyler

- message_greet - 'wet ourselves' unintended meaning
  - was: Today we will have to wet ourselves comrade!
  - now: Today we're going to get soaked, comrade!
- quest 8180 talk_questStarting - 'some task' unnatural
  - was: Do you want to help me with some task?
  - now: Do you want to help me with a task?
- quest 8180 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is catch 1 Squirtle and bring them to me.
  - now: Thanks! Your task is to catch 1 Squirtle and bring it to me.
- quest 8180 talk_questFinishing - Broken question word order
  - was: The task is done?
  - now: Is the task done?
- quest 8180 talk_questFinished - Unnatural phrasing
  - was: Congratulations, get your reward.
  - now: Congratulations, here is your reward.
- quest 8181 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is catch 1 Psyduck and bring them to me.
  - now: Thanks! Your task is to catch 1 Psyduck and bring it to me.
- quest 8182 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is catch 2 Poliwag and bring them to me.
  - now: Thanks! Your task is to catch 2 Poliwag and bring them to me.
- quest 8183 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is catch 1 Seel and bring them to me.
  - now: Thanks! Your task is to catch 1 Seel and bring it to me.
- quest 8184 talk_questStarted - Missing 'to' before verb
  - was: Thanks! Your task is catch 2 Horsea and bring them to me.
  - now: Thanks! Your task is to catch 2 Horsea and bring them to me.

## Yorick Wat

- message_greet - 'Center Pokemon' word order
  - was: You can use the Center Pokemon computer to see various statistics.
  - now: You can use the Pokemon Center computer to see various statistics.

## Zazi

- message_greet - Name mismatch; 'from infancy'
  - was: Hello, I am Zazy, an old fisherman of this continent. I work with {fishing rods} from infancy.
  - now: Hello, I am Zazi, an old fisherman of this continent. I've worked with {fishing rods} since childhood.
- quest 8014 talk_questStarted - 'rubys' misspelling
  - was: Thank you! I'll need: 20 balls of wool, 10 stone orbs, 10 shell bells and 6 rubys.
  - now: Thank you! I'll need: 20 balls of wool, 10 stone orbs, 10 shell bells and 6 rubies.
- quest 8014 talk_questFinishing - Portuguese-ism 'You're with'
  - was: You're with the items I need? Please!
  - now: Do you have the items I need? Please!
- quest 8014 talk_questFinished - Wrong tense 'find'; dangling 'Take.'
  - was: Oh! I forgot to warn you, I find my fishing rod. But thanks for the help, I'll make one for you! Take.
  - now: Oh! I forgot to tell you, I found my fishing rod. But thanks for the help, I'll make one for you! Take it.
- quest 8014 talk_questFinishFail - Missing object
  - was: No you do not have...
  - now: No, you don't have them...
- quest 8035 talk_questStarting - Broken, confusing grammar
  - was: Hey! How long, how are you? I've been looking for you, I have not just thank you for your help, I want to make a best fishing rod for you. Do you want?
  - now: Hey! Long time no see, how are you? I've been looking for you. I never properly thanked you for your help, so I want to make a better fishing rod for you. Do you want it?
- quest 8035 talk_questStarted - 'ball of wools' wrong plural
  - was: I'll need: 500 water gems, 200 metal spikes, 50 ball of wools, 100 screws, 50 electrizers, 20 tangela hairs and a splash plate.
  - now: I'll need: 500 water gems, 200 metal spikes, 50 balls of wool, 100 screws, 50 electrizers, 20 tangela hairs and a splash plate.
- quest 8035 talk_questFinishing - Portuguese-ism 'You're with'
  - was: You're with the items I need?
  - now: Do you have the items I need?

## Zelda Kerrie

- message_greet - 'let's battle?' odd question
  - was: Hello |PLAYERNAME|! I'm Zelda Kerrie, let's {battle}?
  - now: Hello |PLAYERNAME|! I'm Zelda Kerrie, shall we {battle}?

## Zyon

- message_greet - Unclear offer
  - was: Hi |PLAYERNAME|, you can {leave} the tournament room.
  - now: Hi |PLAYERNAME|, I can help you {leave} the tournament room.
- npc/scripts/tournamentLeave.lua - Missing 'do'; 'for' wrong
  - was: You really want to leave this room? You can be disqualified for that tournament.
  - now: Do you really want to leave this room? You may be disqualified from the tournament.
- npc/scripts/tournamentLeave.lua - 'can not' misspelling
  - was: You can not do it while you have a Pokemon out of the ball.
  - now: You can't do that while you have a Pokemon out of its ball.

## lib/ps/systems/002-quest.lua

- Quests (every quest NPC) - Tense; awkward
  - was: You have done this mission in the last 24 hours, you must wait %s minutes to be able to do it again.
  - now: You already did this mission in the last 24 hours, you must wait %s minutes before you can do it again.

## npc/lib/npcsystem/modules.lua

- Travel module (every travel NPC) - Garbled meaning
  - was: Get out of there with this blood!
  - now: Come back when you're not covered in blood!
- Travel module (every travel NPC) - Broken grammar
  - was: I will not dress you with addon of outfit you cannot wear!
  - now: I will not dress you in an addon for an outfit you cannot wear!
- Travel module (every travel NPC) - 'alrady' misspelling
  - was: You alrady have this 
  - now: You already have this 
- Travel module (every travel NPC) - Awkward word order
  - was: Sorry, I dress only premium players.
  - now: Sorry, I only dress premium players.

## npc/scripts/bank.lua

- 10 NPCs - Wrong word order
  - was: Are you sure do you want to deposit all your money?
  - now: Are you sure you want to deposit all your money?
- 10 NPCs - Wrong word order
  - was: Are you sure do you want to withdraw all your money?
  - now: Are you sure you want to withdraw all your money?
- 10 NPCs - 'How much dollars', 'do you like'
  - was: How much dollars do you like to deposit?
  - now: How many dollars would you like to deposit?
- 10 NPCs - 'How much dollars', 'do you like'
  - was: How much dollars do you like to withdraw?
  - now: How many dollars would you like to withdraw?
- 10 NPCs - 'How much dollars', 'do you like'
  - was: How much dollars do you like to transfer?
  - now: How many dollars would you like to transfer?
- 10 NPCs - Missing final period
  - was: Sorry, you don't have %s dollar(s)
  - now: Sorry, you don't have %s dollar(s).
- 10 NPCs - Broken question
  - was: So you want to transfer %s dollar(s) to?
  - now: So you want to transfer %s dollar(s) to whom?
- 10 NPCs - Garbled meaning
  - was: Sorry, any account has founded with this name.
  - now: Sorry, no account was found with this name.
- 10 NPCs - Awkward, unclear
  - was: You do not have enough access to deal here!
  - now: You do not have enough access to trade here!

## npc/scripts/casinoMerchant.lua

- 2 NPCs - Statement as question
  - was: You want to exchange %s poke coins for a %s?
  - now: Do you want to exchange %s poke coins for a %s?
- 2 NPCs - 'Here is' incomplete
  - was: Here is, thanks!
  - now: Here it is, thanks!
- 2 NPCs - 'it' should be 'them'
  - was: Welcome to our Casino! If you have got some {poke coins} I can exchange it for you.
  - now: Welcome to our Casino! If you have some {poke coins} I can exchange them for you.

## npc/scripts/default_requirement.lua

- 46 NPCs - Awkward, unclear
  - was: You do not have enough access to deal here!
  - now: You do not have enough access to trade here!

## npc/scripts/quest_hiddenAndSeek.lua

- 5 NPCs - Wrong tense
  - was: You find me! Haha!
  - now: You found me! Haha!
- 5 NPCs - Missing 'one'
  - was: You already found me! Look for the next.
  - now: You already found me! Look for the next one.

## npc/scripts/quest_mastery.lua

- 27 NPCs - 'make my missions' wrong verb
  - was: Sorry, you do not have the requirements to make my missions.
  - now: Sorry, you do not meet the requirements to do my missions.

## npc/scripts/rangerClub.lua

- 23 NPCs - Tense: 'already joined'
  - was: You already joined our club!
  - now: You have already joined our club!
- 23 NPCs - Missing 'do' in question
  - was: You really want to be part of the Ranger Club?
  - now: Do you really want to be part of the Ranger Club?
- 23 NPCs - 'Good hunt' unnatural
  - was: Your task has been updated! Good hunt!
  - now: Your task has been updated! Good hunting!
- 23 NPCs - Missing 'do' in question
  - was: You really want to challenge this boss?
  - now: Do you really want to challenge this boss?
- 23 NPCs - 'try your promotion' unclear
  - was: Welcome to the Ranger Club! You can view the {task} list, try your {promotion} inside the club or challenge the {bosses}.
  - now: Welcome to the Ranger Club! You can view the {task} list, attempt your {promotion} inside the club or challenge the {bosses}.

## npc/scripts/shop_mastery.lua

- 9 NPCs - Awkward phrasing
  - was: Sorry, you are not able to deal with me! Only 3rd or greater rank members of our mastery can do this.
  - now: Sorry, you can't trade with me! Only members of rank 3 or higher in our mastery can do this.
- 9 NPCs - Awkward word order
  - was: You do not have all needed items for manufacturing! (%s)
  - now: You do not have all the items needed for manufacturing! (%s)
- 9 NPCs - 'Here is' incomplete
  - was: Here is, thanks!
  - now: Here it is, thanks!
- 9 NPCs - 'exhcange' typo, 'into' wrong
  - was: I'm here to exhcange your {mastery tokens} into {rewards}! Just type {options} to see.
  - now: I'm here to exchange your {mastery tokens} for {rewards}! Just type {options} to see.

## npc/scripts/shop_pokemonShop.lua

- 2 NPCs - 'offerts' misspelling
  - was: Yes, I can buy your Pokemon, show me your offerts. Say {sell}.
  - now: Yes, I can buy your Pokemon, show me your offers. Say {sell}.
- 2 NPCs - Broken question grammar
  - was: Alright, what Pokemon that you want to sell? If you want to sell all your Pokemon, say {all}.
  - now: Alright, which Pokemon do you want to sell? If you want to sell all your Pokemon, say {all}.
- 2 NPCs - 'can not'; 'the ball'
  - was: You can not do it while you have a Pokemon out of the ball.
  - now: You can't do that while you have a Pokemon out of its ball.
- 2 NPCs - 'can not'; unclear 'it'
  - was: You can not sell a Pokemon that has learned a TM, first remove it!
  - now: You can't sell a Pokemon that has learned a TM, remove the TM first!
- 2 NPCs - 'You haven't' unnatural
  - was: You haven't this Pokemon!
  - now: You don't have this Pokemon!
- 2 NPCs - Wrong capitalization mid-sentence
  - was: Do you want to sell: %s For %s dollars?
  - now: Do you want to sell: %s for %s dollars?
- 2 NPCs - 'before confirm' broken
  - was: ATTENTION! If you say YES you will sell all the Pokemon that you're carrying! Be sure before confirm.
  - now: ATTENTION! If you say YES you will sell all the Pokemon that you're carrying! Be sure before you confirm.
- 2 NPCs - Awkward, unclear
  - was: You do not have enough access to deal here!
  - now: You do not have enough access to trade here!

## npc/scripts/soulTrade.lua

- 16 NPCs - Awkward, unclear
  - was: You do not have enough access to deal here!
  - now: You do not have enough access to trade here!
- 16 NPCs - Broken word order
  - was: Thanks! Was credited 30 days of premium to your account.
  - now: Thanks! 30 days of premium were credited to your account.
- 16 NPCs - 'latter' misspelling
  - was: Maybe latter.
  - now: Maybe later.
- 16 NPCs - 'Souls Coins' typo
  - was: Do you want to change your sex? The price is 3 Souls Coins.
  - now: Do you want to change your sex? The price is 3 Soul Coins.
- 16 NPCs - 'exchanged' wrong word
  - was: Thanks! Your sex was exchanged.
  - now: Thanks! Your sex has been changed.
- 16 NPCs - Plural error; broken question
  - was: I can create or change your Pokemon nickname for 1 Soul Coins. What nickname you want?
  - now: I can create or change your Pokemon's nickname for 1 Soul Coin. What nickname do you want?
- 16 NPCs - Grammar: 'need be'
  - was: Sorry, your Pokemon nick can't contain invalid symbols and need be between 4 and 20 characters, please try again.
  - now: Sorry, your Pokemon's nickname can't contain invalid symbols and must be between 4 and 20 characters, please try again.
- 16 NPCs - 'do you want?' missing object
  - was: I can remove your Pokemon nickname for free, do you want?
  - now: I can remove your Pokemon's nickname for free, do you want that?
- 16 NPCs - 'How much' for countable
  - was: How much soul coins do you want to withdraw?
  - now: How many soul coins do you want to withdraw?
- 16 NPCs - Awkward phrasing
  - was: Alright, it's here.
  - now: Alright, here they are.
- 16 NPCs - Awkward word order
  - was: Your account soul coins balance is: %s.
  - now: Your account's soul coin balance is: %s.
- 16 NPCs - Plural error; 'do you want?'
  - was: I can sell you a stamina recover for 1 Soul Coins, do you want?
  - now: I can sell you a stamina recover for 1 Soul Coin, do you want it?
- 16 NPCs - 'Here is' incomplete
  - was: Thanks! Here is.
  - now: Thanks! Here it is.
- 16 NPCs - Awkward list, 'balance' as verb
  - was: Souls are valuable coins that can be exchanged for the following benefits: {premium account}, {exchange of sex}, {Pokemon nick change}, {Pokemon nick remove}, {stamina recover}, to form a {guild}, create a guild {rank}, buy {Egg Move Capsule} and {Pokemon Addon}. You can also {withdraw} or {balance} your account Soul Coins.
  - now: Souls are valuable coins that can be exchanged for the following benefits: {premium account}, {exchange of sex}, {Pokemon nick change}, {Pokemon nick remove}, {stamina recover}, forming a {guild}, creating a guild {rank}, buying an {Egg Move Capsule} and {Pokemon Addon}. You can also {withdraw} your Soul Coins or check your account {balance}.
- 16 NPCs - 'you guild' typo
  - was: You can create a new rank for you guild for 1 soul coin. What will be the name of the new rank?
  - now: You can create a new rank for your guild for 1 soul coin. What will be the name of the new rank?
- 16 NPCs - Missing possessive
  - was: Congratulations! Your guild rank has been created! You must use the command "/setrank[name,rank]" to change a member rank.
  - now: Congratulations! Your guild rank has been created! You must use the command "/setrank[name,rank]" to change a member's rank.
- 16 NPCs - 'exchange into' wrong preposition
  - was: Yes, here you can exchange your account referral points into rewards. These are the reward options. Just say the name of what you want.
  - now: Yes, here you can exchange your account referral points for rewards. These are the reward options. Just say the name of what you want.
- 16 NPCs - Missing 'do'; 'into' wrong
  - was: You really want to exchange %s referral points into a %s?
  - now: Do you really want to exchange %s referral points for a %s?
- 16 NPCs - 'Here is' incomplete
  - was: Thanks! Here is!
  - now: Thanks! Here it is!
- 16 NPCs - Wrong tense
  - was: Something went wrong! Please try again later. Did you have enough referral points?
  - now: Something went wrong! Please try again later. Do you have enough referral points?
- 16 NPCs - 'exchange into' wrong preposition
  - was: Yes, here you can exchange your soul coins into Pokemon addons. These are the options. Just say the name of what you want.
  - now: Yes, here you can exchange your soul coins for Pokemon addons. These are the options. Just say the name of what you want.
- 16 NPCs - Missing 'do'; 'into' wrong
  - was: You really want to exchange %s soul coin(s) into a %s?
  - now: Do you really want to exchange %s soul coin(s) for a %s?
- 16 NPCs - 'do you want?' missing object
  - was: I can sell you an Egg Move Capsule for 1 Soul Coin, do you want?
  - now: I can sell you an Egg Move Capsule for 1 Soul Coin, do you want it?

## npc/scripts/tm_remover.lua

- 2 NPCs - Garbled, confusing meaning
  - was: Yes, I can change the move that your Pokemon forgot to learn a TM move. What TM slot do you want to change? {1} or {2}.
  - now: Yes, I can restore the move your Pokemon forgot when it learned a TM move. Which TM slot do you want to change? {1} or {2}.
- 2 NPCs - Unclear slot name
  - was: Please, first put a poke ball in your inventory slot.
  - now: Please put a poke ball in your ball slot first.
- 2 NPCs - 'in such slot' unnatural
  - was: Your Pokemon doesn't have any TM in such slot.
  - now: Your Pokemon doesn't have a TM in that slot.
- 2 NPCs - Missing 'do' in question
  - was: You really want to remove the move %s from your %s?
  - now: Do you really want to remove the move %s from your %s?
- 2 NPCs - Awkward word order
  - was: Ok, now what is your Pokemon move that you want to replace with that TM? Type the name exactly!
  - now: Ok, now which of your Pokemon's moves do you want to replace with that TM? Type the name exactly!
- 2 NPCs - 'doesn't learned', 'it name'
  - was: Your Pokemon doesn't learned such move, please type again. Remember to type it name exactly!
  - now: Your Pokemon hasn't learned that move, please try again. Remember to type its name exactly!
- 2 NPCs - Missing 'do' in question
  - was: You really want to move the TM %s from your %s to replace the move %s?
  - now: Do you really want to move the TM %s from your %s to replace the move %s?
- 2 NPCs - Missing article
  - was: You aren't owner of this item.
  - now: You aren't the owner of this item.
- 2 NPCs - Wrong tense
  - was: Here you can {remove} and {change} TM moves that you teach to your Pokemon!
  - now: Here you can {remove} and {change} TM moves that you taught your Pokemon!

## npc/scripts/travels.lua

- 7 NPCs - 'leave you to' wrong verb
  - was: I can leave you to these destinations: %s
  - now: I can take you to these destinations: %s
- 7 NPCs - Missing 'to'
  - was: Do you really want go to %s? This will cost you %s dollars.
  - now: Do you really want to go to %s? This will cost you %s dollars.
- 7 NPCs - Awkward 'are with'
  - was: You can't travel while you are with a Pokemon out of the ball.
  - now: You can't travel while you have a Pokemon out of its ball.

## npc/scripts/tutorial_quests.lua

- 10 NPCs - 'can not'; 'the ball'
  - was: You can not do it while you have a Pokemon out of the ball.
  - now: You can't do that while you have a Pokemon out of its ball.
- 10 NPCs - Missing 'do' in question
  - was: You really want to skip the tutorial?
  - now: Do you really want to skip the tutorial?
- 10 NPCs - 'a exclamation'; awkward flow
  - was: Okay, that's a start. All quest NPCs will be indicated by a balloon with a exclamation mark (!). Then we go to our first mission. Remember that you can {SKIP} this tutorial whenever you want. Now, let's start your first mission? Just say {YES}.
  - now: Okay, that's a start. All quest NPCs are marked by a balloon with an exclamation mark (!). Now on to our first mission. Remember that you can {SKIP} this tutorial whenever you want. Shall we start your first mission? Just say {YES}.
- 10 NPCs - Stray 'if', awkward flow
  - was: Okay, that's a start. Then we go to our first mission. Remember that if you can {SKIP} this tutorial whenever you want. Now, let's start your first mission? Just say {YES}.
  - now: Okay, that's a start. Now on to our first mission. Remember that you can {SKIP} this tutorial whenever you want. Shall we start your first mission? Just say {YES}.
- 10 NPCs - Confusing instructions
  - was: Go through that door and "Use" to open it. You can do it using Shift + Click to open the context menu for interaction and click on "Use", or you can select the option to use the "Classic Control" menu to simply use the right mouse button. Once you open it, speak with the second NPC, Flanagan.
  - now: Go to that door and "Use" it to open it. You can Shift + Click to open the context menu and click "Use", or select the "Classic Control" option in the menu to simply use the right mouse button. Once it's open, speak with the second NPC, Flanagan.
- 10 NPCs - Awkward; 'repeat them' unclear
  - was: Some dialogs will contain blue words, you just need to repeat them to {CONTINUE} the dialogue.
  - now: Some dialogues contain blue words; just say them back to {CONTINUE} the dialogue.
- 10 NPCs - Many grammar errors throughout
  - was: The Pokemon Daycare is a place where you can leave your Pokemon to gain experience without it being in your current team. This place was designed for trainers who do not have much time or want to train other Pokemon besides the six that carries. You can leave two Pokemon in the Daycare what gives a second use for the system. If a trainer leave a female and a male Pokemon at the Daycare, which are compatible to relate, there is the possibility of generating a Pokemon Egg. If you generate an Egg, you must make he born. Once the process is finished you will have a very good Pokemon in your hands as well. To learn more, look for other players, the Help channel and the Wiki tab of the Pokepedia (press P). Good luck trainer!
  - now: The Pokemon Daycare is a place where you can leave your Pokemon to gain experience without having it in your current team. It was designed for trainers who don't have much time or want to train Pokemon besides the six they carry. You can leave two Pokemon in the Daycare, which gives the system a second use: if a trainer leaves a compatible male and female Pokemon at the Daycare, they may produce a Pokemon Egg. If you get an Egg, you must hatch it. Once it hatches you will have a very good Pokemon in your hands. To learn more, ask other players, the Help channel or the Wiki tab of the Pokepedia (press M). Good luck trainer!
- 10 NPCs - Missing 'do' in question
  - was: You know the {POKEMON DAYCARE}?
  - now: Do you know about the {POKEMON DAYCARE}?
- 10 NPCs - Many grammar errors, unclear
  - was: The TM (Technical Machine) are able to teach your Pokemon a new move that he did not learn normally. All you need to do is find a TM like this one besides me and use it at the Pokemon Poke Ball. After that, you will choose a move to replace by the TM move. Again remembering that the PokeVerse follows in fact the official data of Pokemon universe, and therefore this system also has some rules.
  - now: A TM (Technical Machine) can teach your Pokemon a move it can't normally learn. Just find a TM like this one beside me and use it on your Pokemon's Poke Ball. Then choose which move the TM move will replace. Remember that PokeVerse follows the official data of the Pokemon universe, so this system has some rules too.
- 10 NPCs - 'Defese' typo, unclear limits
  - was: Vitamins are designed to increase the Stats of your Pokemon. The Stats are: HP, Attack, Defense, Special Attack, Special Defese and Speed. Each Pokemon has a limit to Stat that can be modified by vitamins. Each Pokemon has a limit of 10 total vitamins and a 3 per vitamin. To learn more, visit the Help channel or the Wiki tab of the Pokepedia (press P).
  - now: Vitamins are designed to increase the Stats of your Pokemon. The Stats are: HP, Attack, Defense, Special Attack, Special Defense and Speed. Each Pokemon has a limit on how much a Stat can be raised by vitamins: 10 vitamins in total and 3 of each kind. To learn more, visit the Help channel or the Wiki tab of the Pokepedia (press M).
- 10 NPCs - Missing 'do' in question
  - was: You know the {TMS} or {VITAMINS}?
  - now: Do you know about {TMS} or {VITAMINS}?
- 10 NPCs - Broken grammar, unclear instructions
  - was: Berries are plants that any trainer can have at home. They are of different species and with different effects. There is a cooldown between each use, even in tournament battles! To plant a Berry, you need some tools like these behind me and use on a fertile land, normally found in homes or rental locations. You find these spaces by PokeVerse world. The tools are also found within shop NPCs in the cities.
  - now: Berries are plants that any trainer can grow at home. There are different species with different effects. There is a cooldown between each use, even in tournament battles! To plant a Berry, you need tools like the ones behind me, used on fertile land, usually found in homes or rented places. You can find these spots around the PokeVerse world. The tools are sold by shop NPCs in the cities.
- 10 NPCs - 'its' typo; 'opens' agreement
  - was: The Frontier Island gives trainers the opportunity to test their ability as a Pokemon Master with some challenges. It can be accessed directly from the Trading Area, its a place to visit with friends. There you can earn Frontier Tokens, which opens the possibility to purchase some unique items at the island.
  - now: The Frontier Island gives trainers the chance to test their skill as a Pokemon Master with some challenges. It can be reached directly from the Union Room, and it's a place to visit with friends. There you can earn Frontier Tokens, which let you buy some unique items on the island.
- 10 NPCs - Agreement errors; 'What you are waiting'
  - was: The Ranger Club is a place for trainers that seeks adventures. At the Ranger Club you will have the opportunity to advance on Ranks and be a successful Ranger. There you will have several missions that give you points to move up in ranks. Each mission will give you rewards and the possibility of facing a Pokemon Boss. What you are waiting for? Each city has a representative of the Ranger Club!
  - now: The Ranger Club is a place for trainers who seek adventure. At the Ranger Club you will have the chance to advance in Ranks and become a successful Ranger. There are several missions that give you points to move up in ranks. Each mission gives you rewards and the chance to face a Pokemon Boss. What are you waiting for? Each city has a representative of the Ranger Club!
- 10 NPCs - Missing 'do' in question
  - was: You want to hear about the {FRONTIER ISLAND} or the {RANGER CLUB}?
  - now: Do you want to hear about the {FRONTIER ISLAND} or the {RANGER CLUB}?
- 10 NPCs - Many grammar errors, 'account account'
  - was: These are the game virtual currency. With them you can make your Premium Account account to have access to various locations on the map and also the full use of your Pokemon. They are not required to play, but if you want a total experience for the game be sure to have them. You can buy directly from other players or by donating to the project through the official site. It is a symbolic way to keep PokeVerse online and your enjoyment. There are several uses for it, so if you want to see more detail read the Wiki tab of the Pokepedia (press P) or ask in the Help channel.
  - now: These are the game's virtual currency. With them you can get a Premium Account, which gives access to various locations on the map and full use of your Pokemon. They are not required to play, but if you want the full experience be sure to get some. You can buy them from other players or by donating to the project through the official site. It's a symbolic way to keep PokeVerse online for your enjoyment. They have several uses, so to see more details read the Wiki tab of the Pokepedia (press M) or ask in the Help channel.
- 10 NPCs - Wrong word order
  - was: Do you know what is a {SOUL COIN}?
  - now: Do you know what a {SOUL COIN} is?
- 10 NPCs - Broken grammar, garbled last sentences
  - was: Now I will take you to the laboratory of one of the greatest Pokemon researchers who have trod this land. There he will instruct you on how to do different things and you also have the possibility to receive your first Pokemon. Remembering that you are very vulnerable without a Pokemon, so perform the QUEST to begin your journey on the right foot. When {READY} take you to his lab, it will not take long. Just close your eyes...
  - now: Now I will take you to the laboratory of one of the greatest Pokemon researchers who have walked this land. There he will teach you how to do different things and you can also receive your first Pokemon. Remember that you are very vulnerable without a Pokemon, so do the QUEST to start your journey on the right foot. When you're {READY} I'll take you to his lab, it won't take long. Just close your eyes...
- 10 NPCs - Unclear response
  - was: It's fine.
  - now: That's fine.
