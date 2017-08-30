#include "settings.h"

#include <string>
#include <sstream>
#include <map>
#include <cstdio>
#include <iostream>
#include <algorithm>

#define MAX_LINE_LEN 1024

using namespace vvr;

Settings::Settings(string filename)
{
    FILE *file;
    file = fopen(filename.c_str(), "r");
    if (!file) {
        std::cout << "SS Cannot open config file. Throwing exception!" << std::endl;
        throw string("Cannot open config file.");
    }

    char Line[MAX_LINE_LEN], Key[128], Val[MAX_LINE_LEN-128];
    while (fgets(Line, MAX_LINE_LEN, file)) {
        if (Line[0] == '#') continue;
        if(sscanf(Line, "%s = %s\n", Key, Val)==2){
            string key(Key);
            transform(key.begin(), key.end(), key.begin(), ::tolower);
            sMap[key] = Val;
        }
    }

    fclose(file);
}

void Settings::getKeys(vector<string> &keys) const
{
    for(map<string,string>::const_iterator it = sMap.begin(); it != sMap.end(); ++it) {
      keys.push_back(it->first);
    }
}

string Settings::getStr(const string &Key) const
{
    string key(Key);
    transform(key.begin(), key.end(), key.begin(), ::tolower);
    if (sMap.find(key) == sMap.end())
        throw string("Setting <") + key + "> not in map.";

    return sMap.at(key);
}

double Settings::getDbl(const string &key) const
{
    double dbl=0;
    std::stringstream ss(getStr(key));
    ss >> dbl;
    return dbl;
}

bool Settings::getBool(const string &key) const
{
    return getInt(key);
}

int Settings::getInt(const string &key) const
{
    return atoi(getStr(key).c_str());
}
