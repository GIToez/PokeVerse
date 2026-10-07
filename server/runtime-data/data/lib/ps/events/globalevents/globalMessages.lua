local GLOBALMESSAGES = {
	{
		"Jamais informe os dados da sua conta em qualquer site que não seja o TODO - POKEVERSE URL REQUIRED, a equipe não da itens ou pokemons.",
		"Never let the data of your account on any site other than TODO - POKEVERSE URL REQUIRED, the staff not give any item or pokemon."
	},
	{
		"Pense duas vezes antes de usar qualquer tipo de bot ou hack no seu personagem, isto não será tolerado e seu personagem será deletado. Jogue limpo.",
		"Think twice before using any bot or hack on your character, it will not be tolerated and your character will be deleted. Play nice."
	},
	{
		"Você precisa de alguma informação sobre o jogo? Acesse agora: TODO - POKEVERSE URL REQUIRED",
		"Do you need any information about the game? Visit now: TODO - POKEVERSE URL REQUIRED"
	},
	{
		"Gostou do jogo? Então comece a divulga-lo agora mesmo! Chame seus amigos para jogar! Assim você se diverte muito mais e ajuda a manter o projeto!",
		"Did you like the game? Then start to publish it right now! Call your friends to play! So you enjoy a lot more and helps keep the project!"
	},
	{
		"Nunca coloque os dados de sua conta em qualquer site que não seja o oficial do PokeVerse (TODO - POKEVERSE URL REQUIRED)! Cuide de sua conta!",
		"Never put your account information at any site other than the official PokeVerse (TODO - POKEVERSE URL REQUIRED)! Take care of your account!"
	},
	{
		"Fique por dentro das novidades, dê sua opinião e participe do desenvolvimento do jogo! Acesse: TODO - POKEVERSE URL REQUIRED",
		"Check out the news, give your opinion and participate in the development of the game! Access: TODO - POKEVERSE URL REQUIRED"
	},
	{
		"Você quer deixar alguma mensagem, comentário ou sugestão para os desenvolvedores do PokeVerse? Acesse: TODO - POKEVERSE URL REQUIRED",
		"You want to leave a message, comment or suggestion to the PokeVerse developers? Visit now: TODO - POKEVERSE URL REQUIRED"
	},
}

local MSGTYPES = {
	MESSAGE_STATUS_WARNING, --[[Red message in game window and in the console]]
	MESSAGE_EVENT_ADVANCE, --[[White message in game window and in the console]]
	MESSAGE_INFO_DESCR --[[Green message in game window and in the console]]
}

local LAST_MESSAGE_ID = 0
local LAST_TYPE_ID = 0

function onThink()
	local msgs = GLOBALMESSAGES[LAST_MESSAGE_ID + 1]
	if (msgs) then
		LAST_MESSAGE_ID = LAST_MESSAGE_ID + 1
	else
		msgs = GLOBALMESSAGES[1]
		LAST_MESSAGE_ID = 1
	end

	local msgtype = MSGTYPES[LAST_TYPE_ID + 1]
	if (msgtype) then
		LAST_TYPE_ID = LAST_TYPE_ID + 1
	else
		msgtype = MSGTYPES[1]
		LAST_TYPE_ID = 1
	end

	for i, msg in ipairs(msgs) do
		doBroadcastMessage(msg, msgtype)
	end
	return true
end
