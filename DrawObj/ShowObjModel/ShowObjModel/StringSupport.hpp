//
//  StringSupport.hpp
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#ifndef StringSupport_hpp
#define StringSupport_hpp

#include <stdio.h>
#include <string>
#include <vector>
#include <stdexcept>

std::string FormatString(const char* format, ...);

std::string GetFilepath(const std::string& filename);

std::string ReadTextFile(const std::string& filename);

std::vector<std::string> Split(const std::string& str, const std::string& separator, bool ignoreEmptyString = false);

bool StartsWith(const std::string& str, const std::string& value, bool ignoreCase = true);

bool EndsWith(const std::string& str, const std::string& value, bool ignoreCase = true);

std::string Trim(const std::string& str);

std::string Trim(const std::string& str, const std::string& trimChars);

class GameError : public std::runtime_error
{
public:
    template<typename... T>
    GameError(const char *format, T... args)
    : std::runtime_error(FormatString(format, args...))
    {
    }

    GameError(const std::string& message)
    : std::runtime_error(message)
    {
    }
};


#endif /* StringSupport_hpp */
