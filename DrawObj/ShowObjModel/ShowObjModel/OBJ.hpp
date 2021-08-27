//
//  OBJ.hpp
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#ifndef OBJ_hpp
#define OBJ_hpp

#include <stdio.h>
#include "Time.hpp"
#include "Mesh.hpp"
#include <OpenGL/OpenGL.h>
#include <OpenGL/gl3.h>
#include <GLKit/GLKMath.h>
#include <vector>

class ShaderProgram;
class Texture;
class OBJ
{
public:
    OBJ();
    ~OBJ();
    void Render();

private:
    ShaderProgram* program = nullptr;
    Mesh*          mesh = nullptr;
    Mesh*          planeMesh = nullptr;

    /**
     *相机位置
     */
    GLKVector3              cameraPos;
    GLKMatrix4              projViewMat;
    bool bCameraDirty;
    /**
     *是否是透视投影
     */
    bool bPerspective;
};

#endif /* OBJ_hpp */
