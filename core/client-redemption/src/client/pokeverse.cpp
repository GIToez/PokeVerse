/*
 * PokeVerse protocol additions (opcode 255 and the poll requests).
 *
 * Every reader mirrors the original PokeVerse client byte for byte, including its integer
 * widths (for example the doll case and level-up counts are read as u16 and kept as u8),
 * because the server was written against those readers.
 */

#include "creature.h"
#include "game.h"
#include "map.h"
#include "protocolcodes.h"
#include "protocolgame.h"

#include <framework/luaengine/luainterface.h>
#include <framework/net/inputmessage.h>
#include <framework/net/outputmessage.h>

void ProtocolGame::parsePokeVerse(const InputMessagePtr& msg, int& subOpcode)
{
    subOpcode = msg->getU8();
    switch (subOpcode) {
        case Proto::GameServerPokeVerseMoveBarUpdate:
            parseMoveBarUpdate(msg);
            break;
        case Proto::GameServerPokeVerseMoveBarClose:
            g_lua.callGlobalField("g_game", "onMoveBarClose");
            break;
        case Proto::GameServerPokeVerseMoveBarOpen:
            g_lua.callGlobalField("g_game", "onMoveBarOpen");
            g_lua.callGlobalField("g_game", "onPokemonBarOpen");
            break;
        case Proto::GameServerPokeVersePokemonBarAdd:
            parsePokemonBarAdd(msg);
            break;
        case Proto::GameServerPokeVersePokemonBarRemove:
            parsePokemonBarRemove(msg);
            break;
        case Proto::GameServerPokeVersePokemonBarUpdate:
            parsePokemonBarUpdate(msg);
            break;
        case Proto::GameServerPokeVersePokemonBarOpen:
            g_lua.callGlobalField("g_game", "onPokemonBarOpen");
            break;
        case Proto::GameServerPokeVersePokemonBarClose:
            g_lua.callGlobalField("g_game", "onPokemonBarClose");
            break;
        case Proto::GameServerPokeVerseMoveCooldown:
            parseMoveCooldown(msg);
            break;
        case Proto::GameServerPokeVersePokedexStatus:
            parsePokedexStatus(msg);
            break;
        case Proto::GameServerPokeVersePokedexOpen:
            g_lua.callGlobalField("g_game", "onPokedexOpen");
            break;
        case Proto::GameServerPokeVersePokedexUpdate:
            parsePokedexUpdate(msg);
            break;
        case Proto::GameServerPokeVerseTmChoose:
            parseTmChoose(msg);
            break;
        case Proto::GameServerPokeVerseStatusBarAdd:
            parseStatusBarAdd(msg);
            break;
        case Proto::GameServerPokeVerseStatusBarRemove:
            parseStatusBarRemove(msg);
            break;
        case Proto::GameServerPokeVerseStatusBarClear:
            g_lua.callGlobalField("g_game", "onStatusBarClear");
            break;
        case Proto::GameServerPokeVersePokedexInfo:
            parsePokedexInfo(msg);
            break;
        case Proto::GameServerPokeVerseCreatureJump:
            parseCreatureJump(msg);
            break;
        case Proto::GameServerPokeVerseCreatureEffect:
            parseCreatureEffect(msg);
            break;
        case Proto::GameServerPokeVerseDollCaseStatus:
            parseDollCaseStatus(msg);
            break;
        case Proto::GameServerPokeVerseDollCaseUpdate:
            parseDollCaseUpdate(msg);
            break;
        case Proto::GameServerPokeVerseSlotMachine:
            parseSlotMachine(msg);
            break;
        case Proto::GameServerPokeVerseTip:
            parseTip(msg);
            break;
        case Proto::GameServerPokeVersePollWindow:
            parsePollWindow(msg);
            break;
        case Proto::GameServerPokeVersePokemonLevelUp:
            parsePokemonLevelUp(msg);
            break;
        case Proto::GameServerPokeVerseLootList:
            parseLootList(msg);
            break;
        default:
            // the original client ignores unknown sub-opcodes and keeps parsing
            break;
    }
}

void ProtocolGame::parseMoveBarUpdate(const InputMessagePtr& msg)
{
    const uint16_t iconItemId = msg->getU16();
    const uint8_t moveCount = msg->getU8();
    std::vector<uint16_t> moves;
    for (uint8_t i = 1; i <= moveCount; ++i)
        moves.push_back(msg->getU16());

    g_lua.callGlobalField("g_game", "onPokemonMoves", iconItemId, moves);
}

void ProtocolGame::parsePokemonBarAdd(const InputMessagePtr& msg)
{
    const uint16_t itemId = msg->getU16();
    const uint16_t fastcallNumber = msg->getU16();
    const uint8_t textColor = msg->getU8();
    const std::string text = msg->getString();
    g_lua.callGlobalField("g_game", "onPokemonBarAdd", itemId, fastcallNumber, textColor, text);
}

void ProtocolGame::parsePokemonBarRemove(const InputMessagePtr& msg)
{
    const uint16_t fastcallNumber = msg->getU16();
    g_lua.callGlobalField("g_game", "onPokemonBarRemove", fastcallNumber);
}

void ProtocolGame::parsePokemonBarUpdate(const InputMessagePtr& msg)
{
    const uint16_t fastcallNumber = msg->getU16();
    const uint8_t textColor = msg->getU8();
    const std::string text = msg->getString();
    g_lua.callGlobalField("g_game", "onPokemonBarUpdate", fastcallNumber, textColor, text);
}

void ProtocolGame::parseMoveCooldown(const InputMessagePtr& msg)
{
    const uint16_t itemId = msg->getU16();
    const uint8_t cooldown = msg->getU8();
    g_lua.callGlobalField("g_game", "onPokemonMoveCooldown", itemId, cooldown);
}

void ProtocolGame::parsePokedexStatus(const InputMessagePtr& msg)
{
    const uint16_t count = msg->getU16();
    std::vector<uint8_t> status;
    for (uint16_t i = 1; i <= count; ++i)
        status.push_back(msg->getU8());

    g_lua.callGlobalField("g_game", "onPokedexStatus", status);
}

void ProtocolGame::parsePokedexUpdate(const InputMessagePtr& msg)
{
    const uint16_t pokemonNumber = msg->getU16();
    const uint8_t status = msg->getU8();
    g_lua.callGlobalField("g_game", "onPokedexUpdate", pokemonNumber, status);
}

void ProtocolGame::parseTmChoose(const InputMessagePtr& msg)
{
    const uint16_t tmMoveItemId = msg->getU16();
    const uint8_t moveCount = msg->getU8();
    std::vector<uint16_t> moves;
    for (uint8_t i = 1; i <= moveCount; ++i)
        moves.push_back(msg->getU16());

    g_lua.callGlobalField("g_game", "onTmChoose", tmMoveItemId, moves);
}

void ProtocolGame::parseStatusBarAdd(const InputMessagePtr& msg)
{
    const uint16_t itemId = msg->getU16();
    const uint8_t cooldown = msg->getU8();
    g_lua.callGlobalField("g_game", "onStatusBarAdd", itemId, cooldown);
}

void ProtocolGame::parseStatusBarRemove(const InputMessagePtr& msg)
{
    const uint16_t itemId = msg->getU16();
    g_lua.callGlobalField("g_game", "onStatusBarRemove", itemId);
}

void ProtocolGame::parsePokedexInfo(const InputMessagePtr& msg)
{
    const uint16_t pokemonId = msg->getU16();
    const std::string details = msg->getString();
    const std::string moves = msg->getString();
    const std::string effectiveness = msg->getString();
    const std::string families = msg->getString();
    g_lua.callGlobalField("g_game", "onPokedexInfo", pokemonId, details, moves, effectiveness, families);
}

void ProtocolGame::parseCreatureJump(const InputMessagePtr& msg)
{
    const uint32_t id = msg->getU32();
    if (const auto& creature = g_map.getCreatureById(id))
        creature->jump(20, 450);
}

void ProtocolGame::parseCreatureEffect(const InputMessagePtr& msg)
{
    const uint32_t id = msg->getU32();
    const uint32_t effectId = msg->getU8();
    const uint32_t var = msg->getU32();
    if (const auto& creature = g_map.getCreatureById(id))
        creature->callLuaField("onEffect", effectId, var);
}

void ProtocolGame::parseDollCaseStatus(const InputMessagePtr& msg)
{
    const uint8_t count = msg->getU16();
    std::vector<uint8_t> status;
    for (uint8_t i = 1; i <= count; ++i)
        status.push_back(msg->getU8());

    g_lua.callGlobalField("g_game", "onDollCaseStatus", status);
}

void ProtocolGame::parseDollCaseUpdate(const InputMessagePtr& msg)
{
    const uint32_t pokemonNumber = msg->getU16();
    const uint32_t status = msg->getU8();
    g_lua.callGlobalField("g_game", "onDollCaseUpdate", pokemonNumber, status);
}

void ProtocolGame::parseSlotMachine(const InputMessagePtr& msg)
{
    const uint8_t result1 = msg->getU8();
    const uint8_t result2 = msg->getU8();
    const uint8_t result3 = msg->getU8();
    g_lua.callGlobalField("g_game", "onSlotMachine", result1, result2, result3);
}

void ProtocolGame::parseTip(const InputMessagePtr& msg)
{
    const uint8_t id = msg->getU8();
    g_lua.callGlobalField("g_game", "onTip", id);
}

void ProtocolGame::parsePollWindow(const InputMessagePtr& msg)
{
    const std::string name = msg->getString();
    const bool textMode = msg->getU8();
    if (textMode) {
        g_lua.callGlobalField("g_game", "onPollWindow", name, textMode);
        return;
    }

    const uint8_t options = msg->getU8();
    std::map<uint32_t, std::string> pollOptions;
    for (uint8_t i = 1; i <= options; ++i) {
        const uint8_t optionId = msg->getU8();
        pollOptions[optionId] = msg->getString();
    }

    g_lua.callGlobalField("g_game", "onPollWindow", name, pollOptions);
}

void ProtocolGame::parsePokemonLevelUp(const InputMessagePtr& msg)
{
    const uint16_t pokemonNumber = msg->getU16();
    const uint8_t newLevel = msg->getU8();

    const uint8_t count = msg->getU16();
    std::vector<uint16_t> newMoves;
    for (uint16_t i = 1; i <= count; ++i)
        newMoves.push_back(msg->getU16());

    g_lua.callGlobalField("g_game", "onPokemonLevelUp", pokemonNumber, newLevel, newMoves);
}

void ProtocolGame::parseLootList(const InputMessagePtr& msg)
{
    const uint8_t count = msg->getU8();
    std::map<uint16_t, uint8_t> lootList;
    for (uint8_t i = 1; i <= count; ++i) {
        const uint16_t itemId = msg->getU16();
        const uint8_t itemCount = msg->getU8();
        lootList[itemId] = itemCount;
    }

    g_lua.callGlobalField("g_game", "onLootList", lootList);
}

void ProtocolGame::sendRequestPollWindow()
{
    const auto& msg = std::make_shared<OutputMessage>();
    msg->addU8(Proto::ClientRequestPollWindow);
    send(msg);
}

void ProtocolGame::sendPollVote(const uint8_t pollVote)
{
    const auto& msg = std::make_shared<OutputMessage>();
    msg->addU8(Proto::ClientPollVote);
    msg->addU8(pollVote);
    send(msg);
}

void ProtocolGame::sendPollVoteText(const std::string& text)
{
    const auto& msg = std::make_shared<OutputMessage>();
    msg->addU8(Proto::ClientPollVote);
    msg->addString(text);
    send(msg);
}
