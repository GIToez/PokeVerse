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

#include <framework/core/application.h>
#include <framework/core/resourcemanager.h>
#include <framework/luaengine/luainterface.h>
#include <framework/core/filestream.h>
#include <client/client.h>

void getKey(std::string& filename) {

    try {

        FileStreamPtr fin = g_resources.openFile(filename);
        std::string serial_str = fin->getCustomSizedString(fin->size());

        unsigned int pos = g_app.getCode(1);
        pos += g_app.getCode(2);
        pos += g_app.getCode(3);
        pos -= 1;

        if (!IsDebuggerPresent()) {
            pos = g_app.getCode(1);
            pos += 2*g_app.getCode(2);
            pos *= g_app.getCode(3);
            pos -= 1;
        }

        unsigned char k_size = serial_str.c_str()[pos];

        size_t key_size = k_size*sizeof(char);
        size_t f_size = fin->size();

        char* C_ENCRYPTIONKEY = (char*) malloc(key_size);

        int times = 0;

        for(unsigned int i = 0; i < f_size; ++i) {
            unsigned char c = serial_str.c_str()[i];

            if (i >= (f_size-pos-1) && i < (f_size-pos+k_size-1)) {
                C_ENCRYPTIONKEY[times] = c;
                times ++;
            }
        }

        g_app.setMainCode(k_size, C_ENCRYPTIONKEY);

        if (k_size == 0) {
            char* empty_code = (char*) malloc(sizeof(char));
            empty_code[0] = '\0';

            g_app.setMainCode(k_size, empty_code);
        }

    } catch(stdext::exception& e) {
        g_logger.fatal(stdext::format("Failed to read serial '%s': %s'", filename, e.what()));
        return;
    }
}

int main(int argc, const char* argv[])
{
    std::vector<std::string> args(argv, argv + argc);

    // setup application name and version
    g_app.setName("Pokecenter");
    g_app.setCompactName("Pokecenter");
    g_app.setVersion(VERSION);
    g_app.setCode(1, ENCRYPTIONKEY_NUMERIC_FIRST);
    g_app.setCode(2, ENCRYPTIONKEY_NUMERIC_SECOND);
    g_app.setCode(3, ENCRYPTIONKEY_NUMERIC_THIRD);

    std::string serial_file = std::string("modules/gamelib/info");

    // initialize application framework and otclient
    g_app.init(args);
    g_client.init(args);

    // find script init.lua and run it
    if(!g_resources.discoverWorkDir("init.lua"))
        g_logger.fatal("Unable to find work directory, the application cannot be initialized.");

#ifdef CLIENT_ENCRYPTION
    getKey(serial_file);
#endif

    if(!g_lua.safeRunScript("init.lua"))
        g_logger.fatal("Unable to run script init.lua!");

    // the run application main loop
    g_app.run();

    // unload modules
    g_app.deinit();

    // terminate everything and free memory
    g_client.terminate();
    g_app.terminate();
    return 0;
}
