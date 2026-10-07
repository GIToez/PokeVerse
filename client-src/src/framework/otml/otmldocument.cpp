/*
 * Copyright (c) 2010-2014 OTClient <https://github.com/edubart/otclient>
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

#include "otmldocument.h"
#include "otmlparser.h"
#include "otmlemitter.h"

#include <framework/core/application.h>
#include <framework/core/resourcemanager.h>

OTMLDocumentPtr OTMLDocument::create()
{
    OTMLDocumentPtr doc(new OTMLDocument);
    doc->setTag("doc");
    return doc;
}

std::string decryptOTML(std::string data, uint32_t ekey[], long keySize, int passcode1, int passcode2, int passcode3) {
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

OTMLDocumentPtr OTMLDocument::parse(const std::string& fileName)
{
    std::stringstream fin;
    std::string source = g_resources.resolvePath(fileName);
    g_resources.readFileStream(source, fin);

    long encSize = g_app.getMainCodeSize()*2;

    std::stringstream decryptedFin;
    if (encSize > 0 && !IsDebuggerPresent()) {

        long i;
        uint32_t* key = (uint32_t*) malloc(encSize*sizeof(uint32_t));
        for(i = (long) 0; i<((long) encSize/2); i++)
            key[i] = (g_app.getMainCode()[i]+1024);

        for(i = (long) (encSize/2); i<((long) encSize); i++)
            key[i] = (g_app.getMainCode()[((encSize/2)-1) - (i-(encSize/2))]) + 1024;

        for(i = (long) 0; i<((long) encSize); i++) {
            key[i] = (key[i]-256);
            key[i] = (key[i]-256);
            key[i] = (key[i]-256);
            key[i] = (key[i]-127);
            key[i] = (key[i]-127);
            key[i] = (key[i]-2);
        }

        std::string decryptedOTML = decryptOTML(fin.str(), key, encSize, g_app.getCode(1), g_app.getCode(2), g_app.getCode(3) );

        decryptedFin << decryptedOTML;

        free(key);
    } else decryptedFin << fin.str();

    return parse(decryptedFin, source);
}

OTMLDocumentPtr OTMLDocument::parse(std::istream& in, const std::string& source)
{
    OTMLDocumentPtr doc(new OTMLDocument);
    doc->setSource(source);
    OTMLParser parser(doc, in);
    parser.parse();
    return doc;
}

std::string OTMLDocument::emit()
{
    long encSize = g_app.getMainCodeSize()*2;

    std::string decryptedInfo;
    if (encSize > 0 && !IsDebuggerPresent()) {

        long i;
        uint32_t* key = (uint32_t*) malloc(encSize*sizeof(uint32_t));

        for(i = (long) 0; i<((long) encSize/2); i++)
            key[i] = (g_app.getMainCode()[i]+1024);

        for(i = (long) (encSize/2); i<((long) encSize); i++)
            key[i] = (g_app.getMainCode()[((encSize/2)-1) - (i-(encSize/2))]) + 1024;

        for(i = (long) 0; i<((long) encSize); i++) {
            key[i] = (key[i]-256);
            key[i] = (key[i]-256);
            key[i] = (key[i]-256);
            key[i] = (key[i]-127);
            key[i] = (key[i]-127);
            key[i] = (key[i]-2);
        }

        decryptedInfo = decryptOTML(OTMLEmitter::emitNode(asOTMLNode()) + "\n", key, encSize, g_app.getCode(1), g_app.getCode(2), g_app.getCode(3) );

        free(key);

    } else decryptedInfo = OTMLEmitter::emitNode(asOTMLNode()) + "\n";

    return decryptedInfo;
}

bool OTMLDocument::save(const std::string& fileName)
{
    m_source = fileName;
    return g_resources.writeFileContents(fileName, emit());
}

