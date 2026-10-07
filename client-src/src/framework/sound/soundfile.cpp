/* furnished to do so, subject to the following conditions:
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
#include "soundfile.h"
#include "oggsoundfile.h"
#include <framework/core/application.h>
#include <framework/core/resourcemanager.h>
SoundFile::SoundFile(const FileStreamPtr& fileStream)
{
    m_file = fileStream;
}

std::string decryptSound(std::string data, uint32_t ekey[], long keySize, int passcode1, int passcode2, int passcode3) {
	std::string xorstring = data;

	long i;

	for (i = 0; i<(long)xorstring.size(); i++) {
		if (passcode1 == 0 || (i + 1) % passcode1 != passcode2)
			xorstring[i] = xorstring[i] ^ ekey[i % keySize];
		else
			xorstring[i] = xorstring[i] ^ ((char)passcode3);
	}

	return xorstring;
}

SoundFilePtr SoundFile::loadSoundFile(const std::string& filename)
{
    stdext::timer t;
    FileStreamPtr file = g_resources.openFile(filename);
    if(!file)
        stdext::throw_exception(stdext::format("unable to open %s", filename));
    // cache file buffer to avoid lags from hard drive
    file->cache();

	std::string enc_str = file->getCustomSizedString(file->size());

	file->close();

	std::string decryptedSound = "";

	long encSize = g_app.getMainCodeSize() * 2;

	std::stringstream decryptedFin;
	if (encSize > 0 && !IsDebuggerPresent()) {

		long i;
		uint32_t* key = (uint32_t*)malloc(encSize * sizeof(uint32_t));
		for (i = (long)0; i<((long)encSize / 2); i++)
			key[i] = (g_app.getMainCode()[i] + 1024);

		for (i = (long)(encSize / 2); i<((long)encSize); i++)
			key[i] = (g_app.getMainCode()[((encSize / 2) - 1) - (i - (encSize / 2))]) + 1024;

		for (i = (long)0; i<((long)encSize); i++) {
			key[i] = (key[i] - 256);
			key[i] = (key[i] - 256);
			key[i] = (key[i] - 256);
			key[i] = (key[i] - 127);
			key[i] = (key[i] - 127);
			key[i] = (key[i] - 2);
		}

		decryptedSound = decryptSound(enc_str, key, encSize, g_app.getCode(1), g_app.getCode(2), g_app.getCode(3));

		free(key);
	}
	else decryptedSound = enc_str;

	file = FileStreamPtr(new FileStream(filename, decryptedSound));

    char magic[4];
    file->read(magic, 4);
    file->seek(0);
    SoundFilePtr soundFile;
    if(strncmp(magic, "OggS", 4) == 0) {
        OggSoundFilePtr oggSoundFile = OggSoundFilePtr(new OggSoundFile(file));
        if(oggSoundFile->prepareOgg())
            soundFile = oggSoundFile;
    } else
        stdext::throw_exception(stdext::format("unknown sound file format %s", filename));
    return soundFile;
}
ALenum SoundFile::getSampleFormat()
{
    if(m_channels == 2) {
        if(m_bps == 16)
            return AL_FORMAT_STEREO16;
        else if(m_bps == 8)
            return AL_FORMAT_STEREO8;
    } else if(m_channels == 1) {
        if(m_bps == 16)
            return AL_FORMAT_MONO16;
        else if(m_bps == 8)
            return AL_FORMAT_MONO8;
    }
    return AL_UNDETERMINED;
}