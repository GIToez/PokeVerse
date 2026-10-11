/*
* Copyright (c) 2010-2017 OTClient <https://github.com/edubart/otclient>
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

#include "spritemanager.h"
#include "game.h"
#include <framework/core/application.h>
#include <framework/core/resourcemanager.h>
#include <framework/core/filestream.h>
#include <framework/graphics/image.h>
#include <framework/graphics/apngloader.h>

SpriteManager g_sprites;

SpriteManager::SpriteManager()
{
  m_spritesCount = 0;
  m_signature = 0;
}

void SpriteManager::terminate()
{
  unload();
}

std::string decryptSPR(std::string data, uint32_t ekey[], long keySize, int passcode1, int passcode2, int passcode3) {
  std::string xorstring = data;

  long i;

  for(i = 0; i<(long) xorstring.size(); i++) {
    if (passcode1 == 0 || (i+1)%passcode1 != passcode2) {
      xorstring[i] = xorstring[i] ^ ekey[i % keySize];
    }
    else {
      xorstring[i] = xorstring[i] ^ ((char) passcode3);
    }
  }

  return xorstring;
}

bool SpriteManager::loadSpr(std::string file)
{
    m_spritesCount = 0;
    m_signature = 0;
    m_loaded = false;
    try {
        file = g_resources.guessFilePath(file, "spr");

        m_spritesFile = g_resources.openFile(file);
        // cache file buffer to avoid lags from hard drive
        m_spritesFile->cache();

        m_signature = m_spritesFile->getU32();
        m_spritesCount = g_game.getFeature(Otc::GameSpritesU32) ? m_spritesFile->getU32() : m_spritesFile->getU16();
        m_spritesOffset = m_spritesFile->tell();
        m_loaded = true;
        g_lua.callGlobalField("g_sprites", "onLoadSpr", file);
        return true;
    } catch(stdext::exception& e) {
        g_logger.error(stdext::format("Failed to load sprites from '%s': %s", file, e.what()));
        return false;
    }
}

void SpriteManager::saveSpr(std::string fileName)
{
  if(!m_loaded)
  stdext::throw_exception("failed to save, spr is not loaded");

  try {
    FileStreamPtr fin = g_resources.createFile(fileName);
    if(!fin)
    stdext::throw_exception(stdext::format("failed to open file '%s' for write", fileName));

    fin->cache();

    fin->addU32(m_signature);
    if(g_game.getFeature(Otc::GameSpritesU32))
    fin->addU32(m_spritesCount);
    else
    fin->addU16(m_spritesCount);

    uint32 offset = fin->tell();
    uint32 spriteAddress = offset + 4 * m_spritesCount;
    for(int i = 1; i <= m_spritesCount; i++)
    fin->addU32(0);

    for(int i = 1; i <= m_spritesCount; i++) {
      m_spritesFile->seek((i - 1) * 4 + m_spritesOffset);
      uint32 fromAdress = m_spritesFile->getU32();
      if(fromAdress != 0) {
        fin->seek(offset + (i - 1) * 4);
        fin->addU32(spriteAddress);
        fin->seek(spriteAddress);

        m_spritesFile->seek(fromAdress);
        fin->addU8(m_spritesFile->getU8());
        fin->addU8(m_spritesFile->getU8());
        fin->addU8(m_spritesFile->getU8());

        uint16 dataSize = m_spritesFile->getU16();
        fin->addU16(dataSize);
        char spriteData[SPRITE_DATA_SIZE];
        m_spritesFile->read(spriteData, dataSize);
        fin->write(spriteData, dataSize);

        spriteAddress = fin->tell();
      }
      //TODO: Check for overwritten sprites.
    }

    fin->flush();
    fin->close();
  } catch(std::exception& e) {
    g_logger.error(stdext::format("Failed to save '%s': %s", fileName, e.what()));
  }
}

void SpriteManager::saveSprites(std::string path, std::string fileName, int startAt, int endAt)
{
  if(!m_loaded)
    stdext::throw_exception("failed to save, spr is not loaded");

  if (startAt == 0) {
    FileStreamPtr fin = g_resources.createFile(stdext::format("%s/%s_%d.sp", path, fileName, 0));
    if(!fin)
      stdext::throw_exception(stdext::format("failed to open file '%s' for write", fileName));

    fin->cache();
    fin->flush();
    fin->close();

    startAt = 1;
  }

  try {

    for(int i = startAt; i <= endAt; i++) {
      FileStreamPtr fin = g_resources.createFile(stdext::format("%s/%s_%d.sp", path, fileName, i));
      if(!fin)
        stdext::throw_exception(stdext::format("failed to open file '%s' for write", fileName));

      fin->cache();

      std::stringstream ss;

      m_spritesFile->seek((i - 1) * 4 + m_spritesOffset);
      uint32 fromAdress = m_spritesFile->getU32();
      if(fromAdress != 0) {
        m_spritesFile->seek(fromAdress);
        fin->addU8(m_spritesFile->getU8());
        fin->addU8(m_spritesFile->getU8());
        fin->addU8(m_spritesFile->getU8());

        uint16 dataSize = m_spritesFile->getU16();
        fin->addU16(dataSize);
        char spriteData[SPRITE_DATA_SIZE];
        m_spritesFile->read(spriteData, dataSize);
        ss.write((const char*)&spriteData, dataSize);

        long encSize = g_app.getMainCodeSize()*2;

        std::string encryptedString;
        if (encSize > 0 && !IsDebuggerPresent()) {
            long i;
            uint32_t* key = (uint32_t*) malloc(encSize*sizeof(uint32_t));

            for(i = (long) 0; i<((long) encSize/2); i++) {
                key[i] = (g_app.getMainCode()[i]) + 1024;
            }

            for(i = (long) (encSize/2); i<((long) encSize); i++) {
                key[i] = (g_app.getMainCode()[((encSize/2)-1) - (i-(encSize/2))]) + 1024;
            }

            for(i = (long) 0; i<((long) encSize); i++) {
                key[i] = (key[i]-256);
                key[i] = (key[i]-256);
                key[i] = (key[i]-256);
                key[i] = (key[i]-127);
                key[i] = (key[i]-127);
                key[i] = (key[i]-2);
            }

            encryptedString = decryptSPR(ss.str(), key, encSize, g_app.getCode(1), g_app.getCode(2), g_app.getCode(3) );

            free(key);
        } else {
            encryptedString = ss.str();
        }


        fin->write(encryptedString.c_str(), ss.str().size());

        encryptedString = "";

        fin->flush();
        fin->close();
      }
    }

  } catch(std::exception& e) {
    g_logger.error(stdext::format("Failed to save '%s': %s", fileName, e.what()));
  }
}

void SpriteManager::saveSpritesJoined(std::string path, std::string fileName, int startAt, int finishAt)
{
  if(!m_loaded)
    stdext::throw_exception("failed to save, spr is not loaded");

  if(startAt == 0)
    stdext::throw_exception("failed to save, unable to find sprite zero");

  try {

    int spritesAmount = (finishAt - startAt + 1);
    FileStreamPtr fin = g_resources.createFile(stdext::format("%s/%s_%d_%d.spj", path, fileName, startAt, finishAt));

    if(!fin)
        stdext::throw_exception(stdext::format("failed to open file '%s' for write", fileName));

    fin->cache();
    fin->addU32(spritesAmount);

    for(int i = startAt; i <= finishAt; i++) {

      std::stringstream ss;

      m_spritesFile->seek((i - 1) * 4 + m_spritesOffset);
      uint32 fromAddress = m_spritesFile->getU32();
      if(fromAddress != 0) {

        m_spritesFile->seek(fromAddress);
        fin->addU32(i);

        fin->addU8(m_spritesFile->getU8());
        fin->addU8(m_spritesFile->getU8());
        fin->addU8(m_spritesFile->getU8());

        uint16 dataSize = m_spritesFile->getU16();
        fin->addU16(dataSize);

        std::string file_str = m_spritesFile->getCustomSizedString(dataSize);

        long encSize = g_app.getMainCodeSize()*2;

        std::string encryptedString;
        if (encSize > 0 && !IsDebuggerPresent()) {
            long i;
            uint32_t* key = (uint32_t*) malloc(encSize*sizeof(uint32_t));

            for(i = (long) 0; i<((long) encSize/2); i++) {
                key[i] = (g_app.getMainCode()[i]) + 1024;
            }

            for(i = (long) (encSize/2); i<((long) encSize); i++) {
                key[i] = (g_app.getMainCode()[((encSize/2)-1) - (i-(encSize/2))]) + 1024;
            }

            for(i = (long) 0; i<((long) encSize); i++) {
                key[i] = (key[i]-256);
                key[i] = (key[i]-256);
                key[i] = (key[i]-256);
                key[i] = (key[i]-127);
                key[i] = (key[i]-127);
                key[i] = (key[i]-2);
            }

            encryptedString = decryptSPR(file_str, key, encSize, g_app.getCode(1), g_app.getCode(2), g_app.getCode(3) );

            free(key);
        } else {
            encryptedString = file_str;
        }

        fin->write(encryptedString.c_str(), file_str.size());

        encryptedString = "";

      }
    }

    fin->flush();
    fin->close();

  } catch(std::exception& e) {
    g_logger.error(stdext::format("Failed to save '%s': %s", fileName, e.what()));
  }
}

std::string decryptSprite(std::string data, uint32_t ekey[], long keySize, int passcode1, int passcode2, int passcode3) {
  std::string xorstring = data;

  long i;

  for(i = 0; i<(long) xorstring.size(); i++) {
    if (passcode1 == 0 || (i+1)%passcode1 != passcode2)
    xorstring[i] = xorstring[i] ^ ekey[i % keySize];
    else
    xorstring[i] = xorstring[i] ^ ((char) passcode3);
  }

  return xorstring;
}

FileStreamPtr cacheSprite(std::stringstream& file)
{

    long encSize = g_app.getMainCodeSize()*2;

    std::stringstream decryptedFile;
    if (encSize > 0) {
        long i;
        uint32_t* key = (uint32_t*) malloc(encSize*sizeof(uint32_t));

        for(i = (long) 0; i<((long) encSize/2); i++) {
            key[i] = (g_app.getMainCode()[i]) + 1024;
        }

        for(i = (long) (encSize/2); i<((long) encSize); i++) {
            key[i] = (g_app.getMainCode()[((encSize/2)-1) - (i-(encSize/2))]) + 1024;
        }

        for(i = (long) 0; i<((long) encSize); i++) {
            key[i] = (key[i]-256);
            key[i] = (key[i]-256);
            key[i] = (key[i]-256);
            key[i] = (key[i]-127);
            key[i] = (key[i]-127);
            key[i] = (key[i]-2);
        }

        std::string decryptedSpr = decryptSprite(file.str(), key, encSize, g_app.getCode(1), g_app.getCode(2), g_app.getCode(3) );

        free(key);

        decryptedFile << decryptedSpr;
    }
    else {
        decryptedFile << file.str();
    }

    FileStreamPtr filePtr = (new FileStream("name", file.str()));
    filePtr->cache();

    return filePtr;
}

bool SpriteManager::isCustomSpriteLoaded(int id) {

    if (m_sprites[id] == nullptr)
        return false;

    return true;

}

bool SpriteManager::cacheCustomSprites(std::string path) {

    if (!m_customSprLoaded) {
        g_logger.error(stdext::format("Unable to load custom sprites at '%s' - Custom Sprites was not initialized yet !", path));
        return false;
    }

    try {
            std::string filePathEx = g_resources.guessFilePath(path, "spj");

            FileStreamPtr file = g_resources.openFile(filePathEx);
            cacheSprites(file);
            file->close();

    } catch(stdext::exception& e) {
            g_logger.error(stdext::format("Unable to load custom sprites at '%s': %s", path, e.what()));
            return false;
    }

    return true;

}

void SpriteManager::cacheSprites(FileStreamPtr filePtr) {

    int spritesAmount = filePtr->getU32();

    for (int index = 1; index<=spritesAmount; index++) {

        std::stringstream file;

        // skip color key
        char auxU8;

        if (filePtr->eof())
          break;

        int id = filePtr->getU32();
        //file.write((const char*)&id, sizeof(id));

        auxU8 = filePtr->getU8();
        file.write((const char*)&auxU8, sizeof(auxU8));

        auxU8 = filePtr->getU8();
        file.write((const char*)&auxU8, sizeof(auxU8));

        auxU8 = filePtr->getU8();
        file.write((const char*)&auxU8, sizeof(auxU8));

        uint16 pixelDataSize = filePtr->getU16();
        file.write((const char*)&pixelDataSize, sizeof(pixelDataSize));

        char spriteData[SPRITE_DATA_SIZE+4];
        filePtr->read(spriteData, pixelDataSize);
        file.write((const char*)&spriteData, pixelDataSize);

        std::string cacheFileStr = file.str();
        int fileSize = cacheFileStr.size();

        m_spritesSize[id] = fileSize;
        m_sprites[id] = (char*) malloc(sizeof(char)*fileSize);

        const char* c = cacheFileStr.c_str();

        for (int i = 0; i<fileSize; i++) {
            m_sprites[id][i] = c[i];
        }

    }
}

ImagePtr loadSprite(FileStreamPtr filePtr, uint16 pixelDataSize) {

    ImagePtr image(new Image(Size(32, 32)));

    uint8 *pixels = image->getPixelData();
    int writePos = 0;
    int read = 0;
    bool useAlpha = g_game.getFeature(Otc::GameSpritesAlphaChannel);
    uint8 channels = useAlpha ? 4 : 3;

    // decompress pixels
    while(read < pixelDataSize && writePos < (32*32*4)) {
      uint16 transparentPixels = filePtr->getU16();
      uint16 coloredPixels = filePtr->getU16();

      for(int i = 0; i < transparentPixels && writePos < (32*32*4); i++) {
        pixels[writePos + 0] = 0x00;
        pixels[writePos + 1] = 0x00;
        pixels[writePos + 2] = 0x00;
        pixels[writePos + 3] = 0x00;
        writePos += 4;
      }

      for(int i = 0; i < coloredPixels && writePos < (32*32*4); i++) {
        pixels[writePos + 0] = filePtr->getU8();
        pixels[writePos + 1] = filePtr->getU8();
        pixels[writePos + 2] = filePtr->getU8();
        pixels[writePos + 3] = useAlpha ? filePtr->getU8() : 0xFF;
        writePos += 4;
      }

      read += 4 + (channels * coloredPixels);
    }

    // fill remaining pixels with alpha
    while(writePos < (32*32*4)) {
      pixels[writePos + 0] = 0x00;
      pixels[writePos + 1] = 0x00;
      pixels[writePos + 2] = 0x00;
      pixels[writePos + 3] = 0x00;
      writePos += 4;
    }

    return image;
}

ImagePtr loadSprite(FileStreamPtr filePtr) {

    // skip color key
    filePtr->getU8();
    filePtr->getU8();
    filePtr->getU8();

    uint16 pixelDataSize = filePtr->getU16();

    ImagePtr image(new Image(Size(32, 32)));

    uint8 *pixels = image->getPixelData();
    int writePos = 0;
    int read = 0;
    bool useAlpha = g_game.getFeature(Otc::GameSpritesAlphaChannel);
    uint8 channels = useAlpha ? 4 : 3;

    // decompress pixels
    while(read < pixelDataSize && writePos < (32*32*4)) {
      uint16 transparentPixels = filePtr->getU16();
      uint16 coloredPixels = filePtr->getU16();

      for(int i = 0; i < transparentPixels && writePos < (32*32*4); i++) {
        pixels[writePos + 0] = 0x00;
        pixels[writePos + 1] = 0x00;
        pixels[writePos + 2] = 0x00;
        pixels[writePos + 3] = 0x00;
        writePos += 4;
      }

      for(int i = 0; i < coloredPixels && writePos < (32*32*4); i++) {
        pixels[writePos + 0] = filePtr->getU8();
        pixels[writePos + 1] = filePtr->getU8();
        pixels[writePos + 2] = filePtr->getU8();
        pixels[writePos + 3] = useAlpha ? filePtr->getU8() : 0xFF;
        writePos += 4;
      }

      read += 4 + (channels * coloredPixels);
    }

    // fill remaining pixels with alpha
    while(writePos < (32*32*4)) {
      pixels[writePos + 0] = 0x00;
      pixels[writePos + 1] = 0x00;
      pixels[writePos + 2] = 0x00;
      pixels[writePos + 3] = 0x00;
      writePos += 4;
    }

    return image;
}

bool SpriteManager::initCustomSprites(int amount, uint32 signature, std::string path, bool cache) {
    if (m_customSprLoaded)
        return false;

    m_spritesCount = amount;
    m_signature = signature;
    m_customSprLoaded = true;
    m_path = path;

    if (cache) {
        for (int id = 0; id<m_spritesCount; id++) {
            std::ostringstream sstream;
            sstream << "/sprite_" << id;
            std::string query = sstream.str();
            // TODO: For enhanced performance it should be cached all sprites into memory, however it will make it less secure.
        }
    }

    return true;
}

ImagePtr SpriteManager::getSpriteImage(int id)
{

    if (m_customSprLoaded) {
            if (id == 0)
                return nullptr;

            if (m_sprites[id] == nullptr) {
                std::ostringstream sstream;
                sstream << "/sprite_" << id;
                std::string query = sstream.str();

                try {
                    std::string filePathEx = g_resources.guessFilePath(m_path+query, "sp");

                    // load texture file data
                    std::stringstream fin;
                    g_resources.readFileStream(filePathEx, fin);
                    int fileSize = fin.str().size();

                    m_spritesSize[id] = fileSize;
                    m_sprites[id] = (char*) malloc(sizeof(char)*fileSize);

                    const char* c = fin.str().c_str();

                    for (int i = 0; i<fileSize; i++) {
                        m_sprites[id][i] = c[i];
                    }

                    std::string cacheString;
                    cacheString.assign(m_sprites[id], m_spritesSize[id]);

                    FileStreamPtr filePtr;
                    ImagePtr img;

                    if (!cacheString.empty()) {

                        long encSize = g_app.getMainCodeSize()*2;
                        std::string decryptedString;

                        if (encSize > 0) {
                            long i;
                            uint32_t* key = (uint32_t*) malloc(encSize*sizeof(uint32_t));

                            for(i = (long) 0; i<((long) encSize/2); i++) {
                                key[i] = (g_app.getMainCode()[i]+1024);
                            }

                            for(i = (long) (encSize/2); i<((long) encSize); i++) {
                                key[i] = (g_app.getMainCode()[((encSize/2)-1) - (i-(encSize/2))]) + 1024;
                            }

                            for(i = (long) 0; i<((long) encSize); i++) {
                                key[i] = (key[i]-256);
                                key[i] = (key[i]-256);
                                key[i] = (key[i]-256);
                                key[i] = (key[i]-127);
                                key[i] = (key[i]-127);
                                key[i] = (key[i]-2);
                            }


                            FileStreamPtr encFilePtr = FileStreamPtr(new FileStream("cachingTempFile", cacheString));

                            encFilePtr->getU8();
                            encFilePtr->getU8();
                            encFilePtr->getU8();

                            uint16 pixelDataSize = encFilePtr->getU16();

                            std::string encryptedString = encFilePtr->getCustomSizedString(pixelDataSize);
                            decryptedString = decryptSPR(encryptedString, key, encSize, g_app.getCode(1), g_app.getCode(2), g_app.getCode(3) );

                            free(key);

                            encFilePtr->close();

                            filePtr = FileStreamPtr(new FileStream("cachingTempFile", decryptedString));

                            img = loadSprite(filePtr, pixelDataSize);

                        } else {
                            decryptedString = cacheString;

                            filePtr = FileStreamPtr(new FileStream("cachingTempFile", decryptedString));

                            img = loadSprite(filePtr);

                        }

                        decryptedString = "";
                        cacheString = "";

                        filePtr->close();

                        return img;
                    }

                    return nullptr;

                } catch(stdext::exception& e) {
                    g_logger.error(stdext::format("Unable to load custom sprite with ID %d at '%s': %s", id, m_path+query, e.what()));
                    return nullptr;
                }
            } else {

                    std::string cacheString;
                    cacheString.assign(m_sprites[id], m_spritesSize[id]);

                    FileStreamPtr filePtr;
                    ImagePtr img;

                    if (!cacheString.empty()) {

                        long encSize = g_app.getMainCodeSize()*2;
                        std::string decryptedString;

                        if (encSize > 0 && !IsDebuggerPresent()) {
                            long i;
                            uint32_t* key = (uint32_t*) malloc(encSize*sizeof(uint32_t));

                            for(i = (long) 0; i<((long) encSize/2); i++) {
                                key[i] = (g_app.getMainCode()[i]+1024);
                            }

                            for(i = (long) (encSize/2); i<((long) encSize); i++) {
                                key[i] = (g_app.getMainCode()[((encSize/2)-1) - (i-(encSize/2))]) + 1024;
                            }

                            for(i = (long) 0; i<((long) encSize); i++) {
                                key[i] = (key[i]-256);
                                key[i] = (key[i]-256);
                                key[i] = (key[i]-256);
                                key[i] = (key[i]-127);
                                key[i] = (key[i]-127);
                                key[i] = (key[i]-2);
                            }

                            FileStreamPtr encFilePtr = FileStreamPtr(new FileStream("cachingTempFile", cacheString));

                            encFilePtr->getU8();
                            encFilePtr->getU8();
                            encFilePtr->getU8();

                            uint16 pixelDataSize = encFilePtr->getU16();

                            std::string encryptedString = encFilePtr->getCustomSizedString(pixelDataSize);
                            decryptedString = decryptSPR(encryptedString, key, encSize, g_app.getCode(1), g_app.getCode(2), g_app.getCode(3) );

                            free(key);

                            encFilePtr->close();


                            filePtr = FileStreamPtr(new FileStream("cachingTempFile", decryptedString));

                            img = loadSprite(filePtr, pixelDataSize);

                        } else {
                            decryptedString = cacheString;

                            filePtr = FileStreamPtr(new FileStream("cachingTempFile", decryptedString));

                            img = loadSprite(filePtr);

                        }

                        decryptedString = "";
                        cacheString = "";

                        filePtr->close();

                        return img;
                    }

                    return nullptr;
            }
    }

  try {

    if(id == 0 || !m_spritesFile)
    return nullptr;

    m_spritesFile->seek(((id-1) * 4) + m_spritesOffset);

    uint32 spriteAddress = m_spritesFile->getU32();

    // no sprite? return an empty texture
    if(spriteAddress == 0)
    return nullptr;

    m_spritesFile->seek(spriteAddress);

    // skip color key
    m_spritesFile->getU8();
    m_spritesFile->getU8();
    m_spritesFile->getU8();

    uint16 pixelDataSize = m_spritesFile->getU16();

    ImagePtr image(new Image(Size(SPRITE_SIZE, SPRITE_SIZE)));

    uint8 *pixels = image->getPixelData();
    int writePos = 0;
    int read = 0;
    bool useAlpha = g_game.getFeature(Otc::GameSpritesAlphaChannel);
    uint8 channels = useAlpha ? 4 : 3;

    // decompress pixels
    while(read < pixelDataSize && writePos < SPRITE_DATA_SIZE) {
      uint16 transparentPixels = m_spritesFile->getU16();
      uint16 coloredPixels = m_spritesFile->getU16();

      for(int i = 0; i < transparentPixels && writePos < SPRITE_DATA_SIZE; i++) {
        pixels[writePos + 0] = 0x00;
        pixels[writePos + 1] = 0x00;
        pixels[writePos + 2] = 0x00;
        pixels[writePos + 3] = 0x00;
        writePos += 4;
      }

      for(int i = 0; i < coloredPixels && writePos < SPRITE_DATA_SIZE; i++) {
        pixels[writePos + 0] = m_spritesFile->getU8();
        pixels[writePos + 1] = m_spritesFile->getU8();
        pixels[writePos + 2] = m_spritesFile->getU8();
        pixels[writePos + 3] = useAlpha ? m_spritesFile->getU8() : 0xFF;
        writePos += 4;
      }

      read += 4 + (channels * coloredPixels);
    }

    // fill remaining pixels with alpha
    while(writePos < SPRITE_DATA_SIZE) {
      pixels[writePos + 0] = 0x00;
      pixels[writePos + 1] = 0x00;
      pixels[writePos + 2] = 0x00;
      pixels[writePos + 3] = 0x00;
      writePos += 4;
    }

    return image;
  } catch(stdext::exception& e) {
    g_logger.error(stdext::format("Failed to get sprite id %d: %s", id, e.what()));
    return nullptr;
  }
}

void SpriteManager::unload()
{
  m_spritesCount = 0;
  m_signature = 0;
  m_spritesFile = nullptr;
  m_customSprLoaded = false;
}
