//
//  Texture.cpp
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#include "Texture.hpp"
#include "StringSupport.hpp"
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

static NSURL *FindImageFile(const std::string& filename)
{
    NSString *filenameStr = [NSString stringWithCString:filename.c_str() encoding:NSUTF8StringEncoding];
    NSString *basename = [filenameStr stringByDeletingPathExtension];
    NSString *ext = [filenameStr pathExtension];
    return [[NSBundle mainBundle] URLForResource:basename withExtension:ext];
}


Texture::Texture(const std::string& filename)
{
    NSURL *fileURL = FindImageFile(filename);
    if (!fileURL) {
        throw GameError("Texture::Texture() Cannot find a texture file: \"%s\"", filename.c_str());
    }

    NSDictionary *option = @{ GLKTextureLoaderApplyPremultiplication: @NO,
        GLKTextureLoaderOriginBottomLeft: @YES };
    NSError *error = nil;
    GLKTextureInfo *texInfo = [GLKTextureLoader textureWithContentsOfURL:fileURL                                                                  options:option                                                                    error:&error];
    if (!texInfo) {
        throw GameError("Texture::Texture() Failed to load a texture: \"%s\"", filename.c_str());
    }

    nameHandle = texInfo.name;
    width = texInfo.width;
    height = texInfo.height;
}

Texture::~Texture()
{
    glDeleteTextures(1, &nameHandle);
}

void Texture::Bind()
{
    glBindTexture(GL_TEXTURE_2D, nameHandle);
}
