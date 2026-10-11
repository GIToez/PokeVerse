// Header file for downloader.
#ifndef DOWNLOAD_H
#define DOWNLOAD_H

#include <string>
#include <windows.h>
#include <wininet.h>
#include <fstream>
#include <map>
#include <vector>

using namespace std;

const int MAX_ERRMSG_SIZE = 255;
const int MAX_FILENAME_SIZE = 512;
const int BUF_SIZE = 10240;          // 10 KB

// Exception class for donwload errors;
class FileWriteDown
{
    char* bufs;
 unsigned long numrcveds;
    public:

        //FileWriteDown(const char * buf, unsigned long numrcved);
        void porra(char* buf, unsigned long numrcved)
        {
            bufs = buf;
            numrcveds = numrcved;
        }

        char* getFileDown()
        {
            return bufs;
        }

        unsigned long getFileDownNum()
        {
            return numrcveds;
        }


};
class Error
{
    public:
        Error(std::string error)
        {
            message = error;
        }

    std::string message;
};

// A class for downloading files from the internet
class Download
{
     //       typedef std::map<std::string, const char *> WriteFileChar;//fazendo new
  // typedef std::map<std::string, unsigned long> WriteFileLong;

    private:
        static bool getfname(const char* url, char* fname);
        static unsigned long openfile(std::string dir, const char* url, ofstream& fout, char* fname);


    public:
        static void doUpdateProgress(int32_t progress);
        static std::string download(std::string dir, const char* url, std::string& file);
        static std::string get_md5hash(const std::string& fname);
        static int16_t getUpdateProgress();
        static void setUpdateProgress(int16_t num);
        static int16_t getProgressFiles();
        static void setProgressFiles(int16_t num);
        static void createFilesDown();
        static int16_t getCancelUpdaterOtc();
        static void setCancelUpdaterOtc(bool cancel);
        static void copiarArquivo( const char* de, const char* para );
        static bool DirectoryExists(LPCTSTR path);
        //static WriteFileChar writeFileChar;
        //static WriteFileLong writeFileLong;
};

#endif

