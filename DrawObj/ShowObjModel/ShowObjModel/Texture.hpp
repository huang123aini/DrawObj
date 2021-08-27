//
//  Texture.hpp
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#ifndef Texture_hpp
#define Texture_hpp

#include <stdio.h>

#include <OpenGL/OpenGL.h>
#include <OpenGL/gl3.h>
#include <string>

class Texture
{
public:
    //! ctor
    Texture(const std::string& filename);
    //! dtor
    ~Texture();

    void Bind();
    float GetWidth() const { return width; }
    float GetHeight() const { return height; }
private:
    GLuint nameHandle;
    float width;
    float height;
};

#endif /* Texture_hpp */
