//
//  OBJ.cpp
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#include "OBJ.hpp"
#include "Shader.hpp"
#include "StringSupport.hpp"
#include <fstream>
#include <cmath>

OBJ::OBJ()
{
    /**
     *开启深度测试
     */
    glEnable(GL_DEPTH_TEST);
    program = new ShaderProgram("objShader.vsh", "objShader.fsh");

    mesh = new Mesh("bunny.obj");
    planeMesh = new Mesh("plane.obj");

    cameraPos = GLKVector3Make(0.0f, 0.0f, 5.0f);
    bCameraDirty = true;
    bPerspective = true;

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

OBJ::~OBJ()
{
    delete program;
    delete planeMesh;
    delete mesh;
}

void OBJ::Render()
{
    cameraPos.x = -cosf(Time::time * 0.6f) * 5.0f;
    cameraPos.z = sinf(Time::time * 0.6f) * 5.0f;
    bCameraDirty = true;
    /**
     * use program
     */
    program->Use();

    GLKVector3 cameraTarget = GLKVector3Make(0.0f, 0.0f, 0.0f);
    if (bCameraDirty)
    {
        GLKMatrix4 viewMat = GLKMatrix4MakeLookAt(cameraPos.x, cameraPos.y, cameraPos.z,
                                              cameraTarget.x, cameraTarget.y, cameraTarget.z,
                                              0.0f, 1.0f, 0.0f);

        GLKMatrix4 projMat = bPerspective
            ? GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f), 640.f / 480.f, 0.00001f, 50.f)
            : GLKMatrix4MakeOrtho(-8.f, 8.f, -6.f, 6.f, 0.0001f, 50.f);
        projViewMat = GLKMatrix4Multiply(projMat, viewMat);

        bCameraDirty = false;
    }
    GLKVector3 eyeDir = GLKVector3Subtract(cameraTarget, cameraPos);
    eyeDir = GLKVector3Normalize(eyeDir);
    program->SetUniform("eye_dir", eyeDir);

    /**
     *每一帧清理背景色and颜色缓冲区和深度缓冲区
     */
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    {
        /**
         *点光源1
         */
        GLKVector3 lightPos = GLKVector3Make(-1.f, 4.f, 2.0f);
        GLKVector3 spotDir = GLKVector3Make(0.27f, -1.0f, -0.6f);
        program->SetUniform("lights[0].light_pos", lightPos);
        program->SetUniform("lights[0].light_attenuation", 0.01f);
        program->SetUniform("lights[0].spot_dir", spotDir);
        program->SetUniform("lights[0].spot_phi", GLKMathDegreesToRadians(45.f));
        program->SetUniform("lights[0].spot_theta", GLKMathDegreesToRadians(30.f));
        program->SetUniform("lights[0].spot_falloff", 1.f);

        program->SetUniform("lights[0].diffuse_color", GLKVector4Make(0.9f, 0.1f, 0.1f, 1.0f));
        program->SetUniform("lights[0].ambient_color", GLKVector4Make(0.3f, 0.0f, 0.0f, 1.0f));
        program->SetUniform("lights[0].specular_color", GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f));
        program->SetUniform("lights[0].specular_shininess", 50.0f);
    }

    {
        /**
         *点光源2
         */
        GLKVector3 lightPos = GLKVector3Make(-3.f, 4.f, -1.0f);
        GLKVector3 spotDir = GLKVector3Make(0.8f, -1.f, 0.3f);
        program->SetUniform("lights[1].light_pos", lightPos);
        program->SetUniform("lights[1].light_attenuation", 0.01f);
        program->SetUniform("lights[1].spot_dir", spotDir);
        program->SetUniform("lights[1].spot_phi", GLKMathDegreesToRadians(45.f));
        program->SetUniform("lights[1].spot_theta", GLKMathDegreesToRadians(30.f));
        program->SetUniform("lights[1].spot_falloff", 1.f);

        program->SetUniform("lights[1].diffuse_color", GLKVector4Make(0.1f, 0.9f, 0.1f, 1.0f));
        program->SetUniform("lights[1].ambient_color", GLKVector4Make(0.0f, 0.1f, 0.0f, 1.0f));
        program->SetUniform("lights[1].specular_color", GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f));
        program->SetUniform("lights[1].specular_shininess", 50.0f);
    }

    {
        /**
         *点光源3
         */
        GLKVector3 lightPos = GLKVector3Make(3.f, 4.f, 2.0f);
        GLKVector3 spotDir = GLKVector3Make(-0.8f, -1.f, -0.6f);
        program->SetUniform("lights[2].light_pos", lightPos);
        program->SetUniform("lights[2].light_attenuation", 0.01f);
        program->SetUniform("lights[2].spot_dir", spotDir);
        program->SetUniform("lights[2].spot_phi", GLKMathDegreesToRadians(45.f));
        program->SetUniform("lights[2].spot_theta", GLKMathDegreesToRadians(30.f));
        program->SetUniform("lights[2].spot_falloff", 1.f);

        program->SetUniform("lights[2].diffuse_color", GLKVector4Make(0.1f, 0.1f, 0.9f, 1.0f));
        program->SetUniform("lights[2].ambient_color", GLKVector4Make(0.0f, 0.0f, 0.1f, 1.0f));
        program->SetUniform("lights[2].specular_color", GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f));
        program->SetUniform("lights[2].specular_shininess", 50.0f);
    }

    GLKMatrix4 modelMat = GLKMatrix4Identity;
    modelMat = GLKMatrix4Translate(modelMat, 0.0f, -2.0f, 0.0f);
    modelMat = GLKMatrix4Scale(modelMat, 20.0f, 20.0f, 20.0f);
    program->SetUniform("model_mat", modelMat);
    GLKMatrix4 pvmMat = GLKMatrix4Multiply(projViewMat, modelMat);
    program->SetUniform("pvm_mat", pvmMat);

    program->SetUniform("emissive_color", GLKVector4Make(0.f, 0.f, 0.4f, 0.f));
    mesh->Draw();

    program->SetUniform("emissive_color", GLKVector4Make(0.f, 0.f, 0.0f, 0.f));
    planeMesh->Draw();
}
