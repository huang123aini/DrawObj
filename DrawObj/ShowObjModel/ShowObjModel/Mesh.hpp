//
//  Mesh.hpp
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#ifndef Mesh_hpp
#define Mesh_hpp

#include <stdio.h>
#include <OpenGL/OpenGL.h>
#include <OpenGL/gl3.h>
#include <GLKit/GLKMath.h>
#include <string>

class Mesh
{
    GLuint vbo;
    GLuint vao;
    GLuint ibo;
    GLenum indexType;
    GLsizei indexCount;
    
public:
    Mesh(const std::string& filename, const GLKVector4& color = {1.0f, 1.0f, 1.0f, 1.0f}, float smoothingLevel = 1.0f);
    ~Mesh();
    
    void Draw() const;
};

#endif /* Mesh_hpp */
