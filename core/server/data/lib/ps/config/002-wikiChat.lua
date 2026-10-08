WIKICHAT_GREETS = {
	"Welcome to the Wiki Chat! Through this channel you can get information about PokeVerse. Select a category to continue: 'essential', 'basic', 'intermediate' or 'advanced'. Say 'back' at any time to return to the previous menu.",
}

WIKICHAT_NODES = {
	{
        keywords = {'english'},
        parameters = {
            text = "Select a category to continue: 'essential', 'basic', 'intermediate' or 'advanced'."
        },
        childs = {
            {
                keywords = {'essential'},
                parameters = {
                    text = "Essential category - You can view any of these topics: 'Move Items', 'move character', 'release pokemon', 'use items', 'attack', 'using pokemon moves', 'order pokemon', 'gather loot' 'catch pokemon', 'pokemon center', 'heal', 'pokedex', 'deposit', 'looking the name of the items',' hotkeys', 'VIP list', 'private message', 'trade', 'soul coins', 'premium account' and 'rotate pokemon'. Say 'back' at any time to return to the previous menu."
                },
                childs = {
					{
						keywords = {'back'},
						parameters = {
							moveup = 2,
						}
					},
                    {
                        keywords = {'move items', 'move item', 'move iten'},
                        parameters = {
                            text = "To move the items simply hold the left mouse button over the item and move it to where you want. Note that your inventory is a backpack, so to save an item in your inventory move the item to the backpack. Items with the characteristic 'Unique' can not be thrown away."
                        }
                    },
                    {
                        keywords = {'move character', 'walk'},
                        parameters = {
                            text = "To move just click with the right mouse button to where you want to go or use the arrow keys on your keyboard."
                        }
                    },
                    {
                        keywords = {'release pokemon'},
                        parameters = {
                            text = "To release the Pokemon you must click the 'Pokes' icon with the right button, it will open a tab for the fastchange where you need only click on the Pokemon icon to call it or fastchange."
                        }
                    },
                    {
                        keywords = {'use itens', 'use item', 'use iten'},
                        parameters = {
                            text = "Click to use items with the right mouse button on the item, some items will generate a crosshair which you must choose where it will be used, such as healing potions."
                        }
                    },
                    {
                        keywords = {'attack'},
                        parameters = {
                            text = "To attack a Pokemon you can click with the left mouse button over his name in Battle list or click the right mouse button over the Pokemon in the game screen."
                        }
                    },
                    {
                        keywords = {'using pokemon moves', 'using pokemon move'},
                        parameters = {
                            text = "Just say m1 for move 1, m2 for move 2, 3 for the move m3 and so on. Or use the shortcuts, F1, F2, F3 ... To edit the shortcuts simply press Ctrl + K."
                        }
                    },
                    {
                        keywords = {'order pokemon'},
                        parameters = {
                            text = "Release the Pokemon, click the 'Order' button and click where you want the Pokemon go. To fly, swim, or ride upon it, release the Pokemon with the ability and use the 'Order' upon your character."
                        }
                    },
                    {
                        keywords = {'gather loot', 'loot'},
                        parameters = {
                            text = "Just click with the right mouse button over the body of the defeated Pokemon and move the items to your backpack, or leave activated /autoloot command to automatic gather."
                        }
                    },
                    {
                        keywords = {'catch pokemon', 'catch'},
                        parameters = {
                            text = "Right click on an empty Pokeball and click the left mouse button on the body of the defeated Pokemon, Pokeball that turns red means that the catch fails. If turns green means that the Pokemon was caught. Note that if you have 6 Pokemon with you, the caught Pokemon will be taken to the Pokemon Center."
                        }
                    },
                    {
                        keywords = {'pokemon center'},
                        parameters = {
                            text = "The Pokemon Center is where you can heal your Pokemon and deposit your items."
                        }
                    },
                    {
                        keywords = {'heal'},
                        parameters = {
                            text = {
							"Go to the Pokemon Center say 'hi' to Nurse Joy, all your Pokemons that are with you and you will be healed.",
							"If you are in the middle of a adventure use the potions purchased from the Pokemart store. To revive the Pokemon use the 'Revive'."
							}
                        }
                    },
                    {
                        keywords = {'pokedex', 'dex'},
                        parameters = {
                            text = "Right click on the 'dex' and click right on top of Pokemon. To review the dex, use the 'dex' upon you. Note that the information of the second generation of Pokemon will not be saved unless you upgrade your pokedex."
                        }
                    },
                    {
                        keywords = {'deposit'},
                        parameters = {
                            text = "In Pokemon center there is a place where you can store your items, click the right button on the machine and store your items and Pokemon. Note that the caught Pokemon will be deposited on that machine."
                        }
                    },
                    {
                        keywords = {'looking the name of the items'},
                        parameters = {
                            text = "Hold Shift and click the left button on the item or click the left and right button while over the item."
                        }
                    },
                    {
                        keywords = {'hotkeys', 'hotkey'},
                        parameters = {
                            text = {
								"Press Ctrl + K.",
								"Send automatically: Automatically uses the shortcut if this is text;",
								"Add: adds a shortcut to the selected item;",
								"Remove: removes the item from the shortcut;",
								"Use on yourself: use the selected item in yourself when using the shortcut;",
								"Use on target: use the item in the selected target by using the shortcut;",
								"With crosshair: opens the crosshair to where you wish to use."
							}
                        }
                    },
                    {
                        keywords = {'vip list'},
                        parameters = {
                            text = "Hold Ctrl and click the right mouse button on a player and select 'Add to VIP List' option. To see your friends list, click on the VIP List next your inventory."
                        }
                    },
                    {
                        keywords = {'private message'},
                        parameters = {
                            text = "To send a private message hold Ctrl and click the right mouse button on a player and select 'Message to <username>' option."
                        }
                    },
                    {
                        keywords = {'trade'},
                        parameters = {
                            text = "Hold Ctrl and click the right mouse button on the item in which you want to change and select the 'Trade With ...' option and click the left mouse button on the player in which you want to exchange. After that make sure the exchange will be made with the item you want and click OK."
                        }
                    },
                    {
                        keywords = {'soul coins', 'soul coin'},
                        parameters = {
                            text = "Soul Coins function as a special kind of currency. With them you can buy premmium account, name your Pokemons, create a guild and buy a regenerating stamina."
                        }
                    },
                    {
                        keywords = {'premium account', 'vip'},
                        parameters = {
                            text = "Premium Account is a form of reward for donating to the server, the server needs money to keep it operating. The advantage is that you can use all the skills of Pokemons, create a guild, purchase a home, use the Daycare, among others."
                        }
                    },
                    {
                        keywords = {'rotate pokemon'},
                        parameters = {
                            text = "Use the shortcut to turn the pokemon t1 north, turn east to t2, t3 to the south and t4 to the west."
                        }
                    },
                },
			},
			{			
				keywords = {'basic'},
                parameters = {
                    text = "Basic Category - You can view any of these topics: 'change clothes', 'fish', 'travel', 'evolve', 'duel npc' , 'missions', 'bank', 'special abilities', 'move description', 'shinys', 'rope', 'pokemart', 'potions', 'field remover', 'equipment', 'pokemon abilities', 'surf', 'dive', 'ride', 'teleport', 'fly', 'dig', 'transform', 'cut', 'rock smash', 'flash', 'find', 'headbutt', 'mark map', 'berrys', 'perfect pokemon', 'egg' and 'pokemon market'. Say 'back' at any time to return to the previous menu."
                },
                childs = {
					{
						keywords = {'back'},
						parameters = {
							moveup = 2,
						}
					},
					{
                        keywords = {'change clothes'},
                        parameters = {
                            text = "Hold Ctrl and click the right button on your character and choose 'Set Outfit' option."
                        }
                    },
					{
                        keywords = {'fish'},
                        parameters = {
                            text = "Right click on the fishing rod and click on water. Don't walk while fishing because the fishing action can be canceled."
                        }
                    },
					{
                        keywords = {'travel'},
                        parameters = {
                            text = "On Vermilion there is the boat SS Anne, where you can go to the Orange Arquipelago and Cinnabar."
                        }
                    },
					{
                        keywords = {'evolve'},
                        parameters = {
                            text = "Check your Pokedex and if you already have the requirements, click 'Evolve'."
                        }
                    },
					{
                        keywords = {'duel npc'},
                        parameters = {
                            text = "To duel with an NPC you must have money to bet with the NPC. Approach a duel NPC and say hi, duel, yes."
                        }
                    },
					{
                        keywords = {'missions', 'quest'},
                        parameters = {
                            text = "To investigate whether the NPC has a mission, say hi, mission, or hi, help."
                        }
                    },
					{
                        keywords = {'bank'},
                        parameters = {
                            text = "In every city there is a bank, there you can deposit your money to pay your house rent."
                        }
                    },
					{
                        keywords = {'special abilities'},
                        parameters = {
                            text = "Special Abilities are characteristics of which passively confers some advantage to your Pokemon."
                        }
                    },
					{
                        keywords = {'move description'},
                        parameters = {
                            text = "Hold the Shift key and click the left button on top of the move icon to see the description."
                        }
                    },
					{
                        keywords = {'shinys', 'shiny'},
                        parameters = {
                            text = "Pokemon shinys have exclusive colors, 10% more life and 100 more energy than common Pokemon."
                        }
                    },
					{
                        keywords = {'rope'},
                        parameters = {
                            text = "When descending into a hole you'll need a rope to climb. Use the rope with the right button and click the left button on top of a lighter circle on the floor."
                        }
                    },
					{
                        keywords = {'pokemart'},
                        parameters = {
                            text = "The Pokemart is a store where you can buy and sell your items. Also is your option to buy potions and pokeballs. All cities have a Pokemart shop. To start trading say hi and then trade."
                        }
                    },
					{
                        keywords = {'potions'},
                        parameters = {
                            text = "Items purchased through the Pokemart are used to heal your Pokemon or character. Note that only the healing potion +1 can be used in characters."
                        }
                    },
					{
                        keywords = {'field remover'},
                        parameters = {
                            text = "It is used to remove effects that occur in the soil resulting from the attacks of Pokemon. So it is possible you collect the loot from downed Pokemon or even retrieve some item from the ground."
                        }
                    },
					{
                        keywords = {'equipments'},
                        parameters = {
                            text = "Equipment intended to assist you in the game, there are various types such as flashlights, tennis, cycling and oxygen mask."
                        }
                    },
					{
                        keywords = {'pokemon abilities', 'pokemon ability'},
                        parameters = {
                            text = "The abilities are designed to help you on your journey. Abilities that do not require premium account are: Ride, Dig, Transform, Cut, Rock Smash, Flash, Find and Headbutting. Those that require premium account are: Teleport, Surf, Dive, Fly and Levitate."
                        }
                    },
					{
                        keywords = {'surf'},
                        parameters = {
                            text = "Requires Premium Account. Used for swimming. Go near the water release the Pokemon with the ability and 'order' over the border. To return to the land use 'order' over the border."
                        }
                    },
					{
                        keywords = {'dive'},
                        parameters = {
                            text = "Requires Premium Account. Used to dive in the sea there are some areas that serve swirls to go to a new area of water Pokemon. To enter you need an oxygen mask, which can be purchased at an NPC in Fuchsia, just equip the piece of equipment and go over swirl to return just pass upon bubbles close to where you down."
                        }
                    },
					{
                        keywords = {'ride'},
                        parameters = {
                            text = "It not requires Premium Account. Used to mount on top of the Pokemon. Release the Pokemon with the ability and 'order' upon yourself. To return to 'order' upon you again."
                        }
                    },
					{
                        keywords = {'teleport'},
                        parameters = {
                            text = "Requires Premium Account. Used to teleport to a city. To release use the Pokemon with the ability and say: /teleport and select the city you want to go."
                        }
                    },
					{
                        keywords = {'fly'},
                        parameters = {
                            text = "Requires Premium Account. Used to fly. To release use the Pokemon with the ability and 'order' upon you. To climb say /up and down to say /down. To dismount the Pokemon 'order' upon you."
                        }
                    },
					{
                        keywords = {'dig'},
                        parameters = {
                            text = "It not requires Premium Account. Used to open holes. Release the Pokemon with the ability and 'order' on top of a lot of small stones so you can open the hole."
                        }
                    },
					{
                        keywords = {'transform'},
                        parameters = {
                            text = "It not requires Premium Account. It is the ability to transform from Pokemon like Ditto. Release the Pokemon and 'order' in the Pokemon you want to copy. The transformation lasts 30 minutes."
                        }
                    },
					{
                        keywords = {'cut'},
                        parameters = {
                            text = "It not requires Premium Account. Used to cut grass that prevents passage. Release the Pokemon with the ability and 'order' upon a clump of bushes to cut. Note that after a while the forest grows back."
                        }
                    },
					{
                        keywords = {'rock smash'},
                        parameters = {
                            text = "It not requires Premium Account. Used to break stones that are blocking the passage. Release the Pokemon with the ability and 'order' on top of a round and smooth stone to break it. Note that after a while the stone reappears."
                        }
                    },
					{
                        keywords = {'flash'},
                        parameters = {
                            text = "It not requires Premium Account. Used to lighten the dark environment. Release the Pokemon with the ability and 'order' upon Pokemon. To cancel the effect of 'order' over the Pokemon again."
                        }
                    },
					{
                        keywords = {'find'},
                        parameters = {
                            text = "It not requires Premium Account. Used to find a player. Drop a Pokemon with the ability and say /find <username> and with that you will get a message saying the cardinal direction (north, east, south and west) where the player is. Note that this skill consumes 15 energy of Pokemon."
                        }
                    },
					{
                        keywords = {'headbutt'},
                        parameters = {
                            text = "It not requires Premium Account. Used to take down the trees wild Pokemons. Release the Pokemon with this ability, and 'order' upon a tree lighter in color and with some eyes. Depending on your skill can come many different Pokemons, after a short time the tree back to normal."
                        }
                    },
					{
                        keywords = {'mark map'},
                        parameters = {
                            text = "The map to the upper right corner can be marked using the right mouse click on it and select the one 'set mark' option so you can set a description of the desired location and also an icon, thus facilitating its location in the game."
                        }
                    },
					{
                        keywords = {'berrys', 'berry'},
                        parameters = {
                            text = "Berries are special fruits that can be grown on rented land or existing backyard gardens of some houses, you need a hoe, seeds and watering cans, which can be bought from Berries NPC of any city. The berries have special effects like HP regeneration 2000 points, 200 points regeneration of Energy, removal of burn effect, poison, sleep among others. There is an interval of 15 minutes between the use of one another and Berry."
                        }
                    },
					{
                        keywords = {'perfect pokemon'},
                        parameters = {
                            text = "The perfect Pokemon is the one that was captured in the lowest possible level found over the map."
                        }
                    },
					{
                        keywords = {'egg'},
                        parameters = {
                            text = "In daycare is possible to generate Pokemon eggs, just put two Pokemon of the same egggroup, wait 24 hours and remove the female Pokemon. Note that the type of Pokemon female egg is deciding what will be, for example, Charmander Female and Squirtle Male will generate a Charmander. Pokemon born from eggs come 1 +10, and there is a small chance of coming shinys. You can use Ditto as a wildcard, but the chance is reduced. It's not possible generate egg from quest Pokemon."
                        }
                    },
					{
                        keywords = {'pokemon market'},
                        parameters = {
                            text = {
							"It's an offline store, players can leave their Pokemons to be bought by other players.",
							"As a Pokemon be sold it is automatically transferred to the buyer's deposit and player sold will receive a letter confirming the sale. To receive money from the sale, the seller must go to the bank.",
							"To sell, say hi, sell, <Pokemon name>, price, yes.",
							"To buy, say hi, buy, <Pokemon name>, [a window appears with the offerings], <id>, yes.",
							"The shinys differ from normal, ie to buy a Shiny Arcanine should be researched by Shiny Arcanine, or saying buy, shiny, [a window appears with the offerings], <id>, yes.",
							"To see their offerings say: list, [a window appears with the offerings]."
                        }
                    }
				}
            },
			},
			{
			keywords = {'intermediate'},
                parameters = {
                    text = "Intermediate category - You can view any of these topics: 'duel against a player', 'buying a house', 'guild', 'guild house', 'tournament', 'saffari zone', 'nicknaming pokemon' and 'tms'. Say 'back' at any time to return to the previous menu."
                },
                childs = {
					{
						keywords = {'back'},
						parameters = {
							moveup = 2,
						}
					},
					{
                        keywords = {'duel against a player'},
                        parameters = {
                            text = "Click the 'duel' item and select the player to challenge. Choose the option to be used as Pokemons in the duel, then select how many players participate in the duel and then choose whether to be or not to bet."
                        }
                    },
					{
                        keywords = {'buying a house'},
                        parameters = {
                            text = "You need to be minimum level 50 and Premium Account. Make sure the house is empty by clicking both mouse buttons above the door to see the description if the description is: 'Nobody owns this house.' Means that this house has no owner. To buy it is in front of the door and enter '/house buy'. Every month you have to pay for the house, to pays just leave the money in the bank or at the Pokemon Center deposit."
                        }
                    },
					{
                        keywords = {'guild'},
                        parameters = {
                            text = "To create a guild you need at least level 50, Premium Account and have to be 15 Soul Coins. After all requirements go in the Soul Coins NPC and say hi, guild, <name>, yes. To invite someone say /invite <username>, to accept say !joinguild."
                        }
                    },
					{
                        keywords = {'guild house'},
                        parameters = {
                            text = "Only the leader of a guild can buy a Guild House. The Guild House is not a home, then the leader can have a house at the same time. The command to buy is /buy house."
                        }
                    },
					{
                        keywords = {'tournament'},
                        parameters = {
                            text = "The tournament occurs every day, to sign up talk to the NPC Joey, located in the area of trade (PvP). As a reward for winning the tournament, you win a trophy, cash (varies by category) and a special currency called Tournament Token."
                        }
                    },
					{
                        keywords = {'saffari zone', 'saffari'},
                        parameters = {
                            text = "It is a place where you can not get with Pokemon and pokeballs. There you use small stones in aggressive Pokemon, cookies in passive Pokemon, meat to distract the Pokemon and trap's. The Saffari is located in Fuchsia and cost 1000 dollars to enter. Tip: +1 potions to heal your character."
                        }
                    },
					{
                        keywords = {'nicknaming pokemon'},
                        parameters = {
                            text = "Go to the NPC that negotiate Soul Coins, put the Pokemon in the slot to release him and say hi, nick, <nickname>, yes. This option costs 1 Soul Coin."
                        }
                    },
					{
                        keywords = {'tms', 'tm', 'technical machine'},
                        parameters = {
                            text = "TMs are items that grant a new move to your Pokemon at the cost of another. There are 3 categories of TMs: Support, healing, and offensive. Pokemon can only have a TM of each category and only one healing moves. There are 3 groups of the TM beginners, intermediate and advanced levels with their need for the Pokemon learn moves: 20, 40 and 60."
                        }
                    }
				}
			},
			{
			keywords = {'advanced'},
                parameters = {
                    text = "Advanced Category - You can view any of these topics: 'mastery', 'blaze', 'avalanche', 'gaia', 'voltagic', 'hurricane', 'heremit', 'vital', 'spectrum', 'zen' and 'daycare'. Say 'back' at any time to return to the previous menu."
                },
                childs = {
					{
						keywords = {'back'},
						parameters = {
							moveup = 2,
						}
					},
					{
                        keywords = {'mastery'},
                        parameters = {
                            text = "Requires at least level 85 to join. The mastery bonus grants you 20% more attack and defense to the element of the same, being in the last rank. Besides a unique advantage for each mastery."
                        }
                    },
					{
                        keywords = {'blaze'},
                        parameters = {
                            text = "Fire: Status Burn 100% more damage."
                        }
                    },
					{
                        keywords = {'avalanche'},
                        parameters = {
                            text = "Water/Ice: Surf and Dive with extra speed; All Ice-type with chance to leave the opponent with the Freeze status."
                        }
                    },
					{
                        keywords = {'gaia'},
                        parameters = {
                            text = "Grass/Bug: All foods with higher HP and Energy regeneration."
                        }
                    },
					{
                        keywords = {'voltagic'},
                        parameters = {
                            text = "Electric/Steel: Increased regeneration of passive energy (without the use of food); Paralyse status with longer duration."
                        }
                    },
					{
                        keywords = {'hurricane'},
                        parameters = {
                            text = "Flying/Dragon: Fly with extra speed; Use of the Find skill no-cost energy; Chance of move evasion."
                        }
                    },
					{
                        keywords = {'heremit'},
                        parameters = {
                            text = "Rock/Ground: Status Low Accuracy with longer duration."
                        }
                    },
					{
                        keywords = {'vital'},
                        parameters = {
                            text = "Normal/Fight: Ride with extra speed; Moves that function as buffs with longer duration."
                        }
                    },
					{
                        keywords = {'spectrum'},
                        parameters = {
                            text = "Poison/Ghost: Poison status with 100% more damage."
                        }
                    },
					{
                        keywords = {'zen'},
                        parameters = {
                            text = "Psychic/Dark: Minor cooldown in the use of Teleport and Blink abilities."
                        }
                    },
					{
                        keywords = {'daycare'},
                        parameters = {
                            text = "It is used to give experience to your Pokémon. Requires at least level 85 and be Premium Account to use. It is located in Cerulean, north of the Pokemon Center. To put a Pokemon in the Daycare talk to the NPC Old Man for putting Pokemon male or sexless sex and the Old Lady to female or sexless Pokemon. The Daycare also serves to generate Pokemon eggs."
                        }
                    }
				}
			}
        }
    },
}