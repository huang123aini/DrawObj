//
//  Mesh.cpp
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#include "Mesh.hpp"
#include "StringSupport.hpp"
#include <vector>
#include <ModelIO/ModelIO.h>

namespace
{
    struct VertexData
    {
        GLKVector3 pos;
        GLKVector3 normal;
        GLKVector4 color;
    };

    static int MDLMesh_CountVertexBuffers(MDLMesh* mesh)
    {
        NSArray<id<MDLMeshBuffer>> *buffers = mesh.vertexBuffers;
        int ret = 0;
        for (id<MDLMeshBuffer> buffer in buffers) {
            if ([buffer isKindOfClass:[NSNull class]]) {
                break;
            }
            ret++;
        }
        return ret;
    }
}

Mesh::Mesh(const std::string& filename, const GLKVector4& color, float smoothingLevel)
{
    assert(smoothingLevel >= 0.0f && smoothingLevel <= 1.0f);
    
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);
    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    
    NSString *theFilename = [NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
    NSURL *theURL = [[NSBundle mainBundle] URLForResource:[theFilename stringByDeletingPathExtension]
                                            withExtension:theFilename.pathExtension];
    if (!theURL) {
        throw GameError("Cannot locate a mesh file with name: %s", filename.c_str());
    }
    MDLAsset *asset = [[MDLAsset alloc] initWithURL:theURL];
    NSArray *assets = [asset childObjectsOfClass:[MDLMesh class]];
    if (assets.count > 0) {
        MDLMesh *mesh = assets[0];
        if (MDLMesh_CountVertexBuffers(mesh) == 1) {
            [mesh addNormalsWithAttributeNamed:MDLVertexAttributeNormal
                               creaseThreshold:(1.0f - smoothingLevel)];
        }
        std::vector<VertexData> vertices;
        MDLVertexAttributeData *attrPos = [mesh vertexAttributeDataForAttributeNamed:MDLVertexAttributePosition];
        MDLVertexAttributeData *attrNormal = [mesh vertexAttributeDataForAttributeNamed:MDLVertexAttributeNormal];
        float *p0 = (float *)attrPos.dataStart;
        float *p1 = (float *)attrNormal.dataStart;
        for (NSUInteger i = 0; i < mesh.vertexCount; i++) {
            VertexData v;
            v.pos.x = *(p0);
            v.pos.y = *(p0 + 1);
            v.pos.z = *(p0 + 2);
            v.normal.x = *(p1);
            v.normal.y = *(p1 + 1);
            v.normal.z = *(p1 + 2);
            v.color = color;
            vertices.push_back(v);
            p0 += attrPos.stride / sizeof(float);
            p1 += attrNormal.stride / sizeof(float);
        }
        for (MDLSubmesh *submesh in mesh.submeshes) {
            if (submesh.geometryType != MDLGeometryTypeTriangles) {
                throw GameError("Mesh data should be composed of triangles");
            }
            id<MDLMeshBuffer> indexBuffer = submesh.indexBuffer;
            GLsizeiptr indexDataSize;
            if (submesh.indexType == MDLIndexBitDepthUInt8) {
                indexType = GL_UNSIGNED_BYTE;
                indexCount = (GLsizei)indexBuffer.length;
                indexDataSize = sizeof(GLubyte);
            } else if (submesh.indexType == MDLIndexBitDepthUInt16) {
                indexType = GL_UNSIGNED_SHORT;
                indexCount = (GLsizei)(indexBuffer.length / 2);
                indexDataSize = sizeof(GLushort);
            } else if (submesh.indexType == MDLIndexBitDepthUInt32) {
                indexType = GL_UNSIGNED_INT;
                indexCount = (GLsizei)(indexBuffer.length / 4);
                indexDataSize = sizeof(GLuint);
            } else {
                throw GameError("Mesh data type is invalid");
            }
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexDataSize * indexCount, indexBuffer.map.bytes, GL_STATIC_DRAW);
        }
        glBufferData(GL_ARRAY_BUFFER, sizeof(VertexData) * vertices.size(), &vertices[0], GL_STATIC_DRAW);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData), &((VertexData *)0)->pos);
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData), &((VertexData *)0)->normal);
        glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, sizeof(VertexData), &((VertexData *)0)->color);
    } else {
        throw GameError("Failed to make an asset from a mesh file: %s", filename.c_str());
    }
}

Mesh::~Mesh()
{
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glDeleteBuffers(1, &ibo);
    glDeleteVertexArrays(1, &vao);
    glDeleteBuffers(1, &vbo);
}

void Mesh::Draw() const
{
    /**
     *绑定VAO
     */
    glBindVertexArray(vao);
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);
    
    glDrawElements(GL_TRIANGLES, indexCount, indexType, (void *)0);
}
