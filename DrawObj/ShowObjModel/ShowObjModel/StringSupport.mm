//
//  StringSupport.cpp
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#include "StringSupport.hpp"
#include <fstream>
#import <Foundation/Foundation.h>

std::string FormatString(const char* format, ...)
{
    static char buffer[1024];
    va_list marker;
    va_start(marker,format);
    vsnprintf(buffer, 1024, format, marker);
    va_end(marker);
    return buffer;
}

std::string GetFilepath(const std::string& filename)
{
    NSString* fileNameObj = [[NSString alloc] initWithCString:filename.c_str() encoding:NSUTF8StringEncoding];

    NSString* body = [fileNameObj stringByDeletingPathExtension];
    NSString* ext = [fileNameObj pathExtension];

    NSString* path = [[NSBundle mainBundle] pathForResource:body ofType:ext];
    if (!path) {
        throw GameError("Cannot locate a file path: %s", filename.c_str());
    }

    return std::string([path cStringUsingEncoding:NSUTF8StringEncoding]);
}

std::string ReadTextFile(const std::string& filename)
{
    std::string filepath = GetFilepath(filename);

    std::ifstream ifs(filepath);
    if (!ifs) {
        throw GameError("Failed to open a file: %s", filepath.c_str());
    }

    ifs.seekg(0, std::ios::end);
    int length = (int)ifs.tellg();
    ifs.seekg(0, std::ios::beg);

    char *buffer = new char[length + 1];
    ifs.read(buffer, length);
    buffer[length] = '\0';
    std::string ret = buffer;
    delete[] buffer;

    return ret;
}


std::vector<std::string> Split(const std::string& str, const std::string& separator, bool ignoreEmptyString/* = false*/)
{
    std::vector<std::string> ret;

    std::string::size_type pos = 0;
    std::string::size_type length = str.length();
    if (length == 0) {
        if (!ignoreEmptyString) {
            ret.push_back("");
        }
        return ret;
    }

    while (pos < length) {
        std::string::size_type p = str.find_first_of(separator, pos);
        if (p == std::string::npos) {
            std::string::size_type len = length - pos;
            if (!ignoreEmptyString || len > 0) {
                std::string part = str.substr(pos, len);
                ret.push_back(part);
            }
            break;
        }
        std::string::size_type len = p - pos;
        if (!ignoreEmptyString || len > 0) {
            std::string part = str.substr(pos, len);
            ret.push_back(part);
        }
        pos = p + 1;
        if (pos >= length && !ignoreEmptyString) {
            ret.push_back("");
        }
    }
    return ret;
}

bool StartsWith(const std::string& str, const std::string& value, bool ignoreCase/* = true*/)
{
    auto length = value.size();
    if (str.length() < length) {
        return false;
    }

    std::string sub = str.substr(0, length);
    if (ignoreCase) {
        return (strncasecmp(sub.c_str(), value.c_str(), length) == 0);
    } else {
        return (sub == value);
    }
}

bool EndsWith(const std::string& str, const std::string& value, bool ignoreCase/* = true*/)
{
    auto length = value.size();
    if (str.length() < length) {
        return false;
    }

    std::string sub = str.substr(str.length()-length, length);
    if (ignoreCase) {
        return (strncasecmp(sub.c_str(), value.c_str(), length) == 0);
    } else {
        return (sub == value);
    }
}

std::string Trim(const std::string& str)
{
    return Trim(str, "\t\r\n ");
}

std::string Trim(const std::string& str, const std::string& trimChars)
{
    std::string::size_type left = str.find_first_not_of(trimChars);

    if (left == std::string::npos) {
        return str;
    }
    std::string::size_type right = str.find_last_not_of(trimChars);
    return str.substr(left, right - left + 1);
}
