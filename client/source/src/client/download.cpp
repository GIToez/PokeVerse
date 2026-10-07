//#<windows.h>
#include <windows.h>
#include "download.h"
#include "game.h"
//#include "update.h"
#include <wininet.h>
#include <string>
#include <sstream>
#include <iostream>
#include <fstream>

#include <openssl/md5.h>
#include <iomanip>
#include <list>

#include <vector>
#include <conio.h>
#include <dir.h>
#include <process.h>
#include <stdio.h>


#define BUFFSIZE 16384
using namespace std;

std::map<std::string, const char *> writeFileChar;//fazendo new
std::map<std::string, unsigned long> writeFileLong;
std::list<std::string> writeFileList;
	
std::string Download::get_md5hash(const std::string& fname)
{
    char buffer[BUFFSIZE];
    unsigned char digest[MD5_DIGEST_LENGTH];

    std::stringstream ss;
    std::string md5string;

    std::ifstream ifs(fname, std::ifstream::binary);

    MD5_CTX md5Context;

    MD5_Init(&md5Context);


    while (ifs.good())
    {
        ifs.read(buffer, BUFFSIZE);
        MD5_Update(&md5Context, buffer, ifs.gcount());
    }

    ifs.close();

    int res = MD5_Final(digest, &md5Context);

    if( res == 0 ) // hash failed
      return {};   // or raise an exception

    // set up stringstream format
    ss << std::hex << std::uppercase << std::setfill('0');


    for(unsigned char uc: digest)
        ss << std::setw(2) << (int)uc;

    md5string = ss.str();

    return md5string;
}

int16_t porc = 0;
int16_t Download::getUpdateProgress()
{
    return porc;
}
void Download::setUpdateProgress(int16_t num)
{
    porc = num;
}
void Download::doUpdateProgress(int progress)
{
    porc = progress;
}
bool cancelUpdt = false;
int16_t Download::getCancelUpdaterOtc()
{
    return cancelUpdt;
}
void Download::setCancelUpdaterOtc(bool cancel)
{
    cancelUpdt = cancel;
}
int16_t proFiles = 0;
int16_t Download::getProgressFiles()
{
    return proFiles;
}
void Download::setProgressFiles(int16_t num)
{
    proFiles = num;
}
void Download::copiarArquivo( const char* de, const char* para )
{
  //criar manipulador do arquivo de entrada (leitura)
  ifstream arqEntrada( de, ios::binary);

  //Criar um manipulador para o arquivo de saída ( escrita )
  ofstream arqSaida( para, ios::binary );

  //buffer onde serão guardadas as partes dos arquivos
  const int TAMBUFFER = 1024;  //pode ser qualquer tamanho
  char buffer[ TAMBUFFER ];

  do
  {
    arqEntrada.read( buffer, TAMBUFFER );  //ler TAMBUFFER bytes do arquivo

    int c = arqEntrada.gcount();  //quantidade de bytes que foram lidos

    if( c != 0 ) arqSaida.write( buffer, c );  //Se não foi lido nenhum byte, é pq chegou ao fim do arquivo

  }while( !arqEntrada.eof() ); //Sair ao chegar o fim do arquivo

}

void Download::createFilesDown()
{
    for(std::list<std::string>::iterator mit = writeFileList.begin(); mit != writeFileList.end(); ++mit)
    {
        std::string od = *mit + "file";
        std::string op = *mit;
        const char* de = od.c_str();
        const char* para = op.c_str();
        remove(para);
        copiarArquivo(de, para);
        remove(de);
    }
    writeFileList.clear();
}
std::string Download::download(std::string dir, const char* url, std::string& file)
{
    ofstream fout;                          // output stream
    unsigned char buf[BUF_SIZE];            // input buffer
    unsigned long numrcved;                 // number of bytes read
    unsigned long filelen;                  // length of the file on disk
    HINTERNET hIurl = NULL, hInet = NULL;   // internet handles
    unsigned long contentlen;               // length of content
    unsigned long len;                      // length of contentlen
    unsigned long total = 0;                // running total of bytes received
    char header[80];                        // holds Range header
    int m_percent;
    std::string dirFile = dir + "file";

    if(getCancelUpdaterOtc())
    {

        setCancelUpdaterOtc(false);
        setProgressFiles(0);
        setUpdateProgress(0);
        doUpdateProgress(0);
        porc = 0;//vk
        g_game.hashsUpdateClear();
        writeFileList.clear();
        return "parou";
    }

    char fname[MAX_FILENAME_SIZE];
    if(!getfname(url, fname))
        throw Error("File name error");

    remove(dirFile.c_str());
    writeFileList.push_back(dir.c_str());
    try
    {
        /*
        Open the file spcified by url.
        The open stream will be returned in fout. If reload is true, then any
        preexisting file will be truncated.
        */

        filelen = openfile(dirFile, url, fout, fname);

        // See if internet connection is available
        if(InternetAttemptConnect(0) != ERROR_SUCCESS)
            throw Error("Can not connect.");

        // Open internet connection
        hInet = InternetOpen("downloader", INTERNET_OPEN_TYPE_DIRECT, NULL, NULL, 0);
        if(hInet == NULL)
            throw Error("Can not open connection.");

        // Open the URL and request range
        //hIurl = InternetOpenUrl(hInet, url, header, -1, INTERNET_FLAG_NO_CACHE_WRITE, 0);
        hIurl = InternetOpenUrl(hInet, url, header, strlen(header), INTERNET_FLAG_NO_CACHE_WRITE, 0);
        if(hIurl == NULL)
            throw Error("Can not open url.");

        // Get content length
        len = sizeof contentlen;
        if(!HttpQueryInfo(hIurl, HTTP_QUERY_CONTENT_LENGTH | HTTP_QUERY_FLAG_NUMBER, &contentlen, &len, NULL))
            throw Error("File or content length not found.");

        // If existing file (if any) is not complete, then finish downloading
        if(filelen != contentlen && contentlen)
        {
            do
            {
                // parar
                if(getCancelUpdaterOtc())
                {
                    fout.close();
                    InternetCloseHandle(hIurl);
                    InternetCloseHandle(hInet);
                    setCancelUpdaterOtc(false);
                    setProgressFiles(0);
                    setUpdateProgress(0);
                    doUpdateProgress(0);
                    porc = 0;//vk
                    g_game.hashsUpdateClear();
                    writeFileList.clear();
                    return "parou";
                 }
                // Read a buffer of info
                if(!InternetReadFile(hIurl, &buf, BUF_SIZE, &numrcved))
                    throw Error("Error occurred during download.");

                // Write buffer to disk

                fout.write((const char *)buf, numrcved);


                if(!fout.good())
                    throw Error("Error while writing file.");

                // update running total
                total += numrcved;

                // Call update function, if specified
                if(numrcved > 0)
                {
                    int percent = (int) ((double) (total + filelen) / (contentlen + filelen) * 100);
                    if(percent != m_percent)
                    {
                        m_percent = percent;
                        doUpdateProgress(m_percent);
                        porc = m_percent;//vk
                    }
                }
            } while (numrcved > 0);
        }
    }
    catch (Error)
    {
        fout.close();
        InternetCloseHandle(hIurl);
        InternetCloseHandle(hInet);

        // rethrow the exception for use by the caller
        throw;
    }

    fout.close();
    InternetCloseHandle(hIurl);
    InternetCloseHandle(hInet);

    setProgressFiles(getProgressFiles()+1);
    std::stringstream ss;
    ss << fname;
    ss >> file;
    return ss.str();
}

// Extract the filename from the URL.
// Return false if the filename cannot be found
bool Download::getfname(const char* url, char* fname)
{
    // Find last slash /
    char *p = strrchr(url, '/');

    // Copy filename afther the last slash
    if(p && (strlen(p) < MAX_FILENAME_SIZE))
    {
        p++;
        strcpy(fname, p);
        return true;
    }

    return false;
}

/*
Open the output file, initialize the output stream, and return the file's
length.
*/



bool Download::DirectoryExists(LPCTSTR path)
{
  DWORD dwAttrib = GetFileAttributes(path);

  return (dwAttrib != INVALID_FILE_ATTRIBUTES &&
         (dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
}


unsigned long Download::openfile(std::string dir, const char *url, ofstream &fout, char* fname)
{
    std::vector<std::string> strVec = stdext::split(dir, "/");
    std::string directori;
    for(std::vector<std::string>::iterator vStr = strVec.begin(); vStr != strVec.end()-1; ++vStr)
    {
        directori += *vStr;
        mkdir(directori.c_str());
        directori += "/";
    }


    fout.open(dir.c_str(), ios::binary | ios::out | ios::app | ios::ate);

    if(!fout)
        throw Error("Can't open output file" + dir);

    // get current file length
    return fout.tellp();
}

