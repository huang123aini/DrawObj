//
//  ObjGLView.m
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#import "ObjGLView.h"
#include "OBJ.hpp"
#include "Time.hpp"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>

static ObjGLView* instance = nil;

@implementation ObjGLView {
    NSOpenGLContext* glContext;
    CVDisplayLinkRef displayLink;
    bool hasDisplayLinkStopped;
    OBJ* obj;
    NSWindow            *window;
    NSSize              size;
    NSRect              viewportRect;
}

+ (ObjGLView *)sharedInstance
{
    return instance;
}

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink,
                                    const CVTimeStamp* now,
                                    const CVTimeStamp* outputTime,
                                    CVOptionFlags flagsIn,
                                    CVOptionFlags* flagsOut,
                                    void* displayLinkContext)
{
    @autoreleasepool {
        ObjGLView* glView = (__bridge ObjGLView*)displayLinkContext;
        [glView render];
        return kCVReturnSuccess;
    }
}

- (instancetype)initWithFrame:(NSRect)frame
{
    /**
     *初始化OpenGL attribs
     */
    NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFAAllowOfflineRenderers,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize, 32,
        NSOpenGLPFADepthSize, 32,
        NSOpenGLPFAMultisample,
        NSOpenGLPFASampleBuffers, 1,
        NSOpenGLPFASamples, 4,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        0
    };
    NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    
    self = [super initWithFrame:frame pixelFormat:pixelFormat];
    if (self)
    {
        instance = self;
        [self setWantsBestResolutionOpenGLSurface:YES];
    }
    return self;
}

- (void)prepareOpenGL
{
    [super prepareOpenGL];

    /**
     *获取GL版本和shader版本
     */
    const GLubyte *glVersion = glGetString(GL_VERSION);
    const GLubyte *glslVersion = glGetString(GL_SHADING_LANGUAGE_VERSION);
    printf("OpenGL Version: %s\n", glVersion);
    printf("GLSL Version: %s\n", glslVersion);

    /**
     *获取最大支持纹理单元数和纹理大小
     */
    GLint maxTextureUnits, maxTextureSize;
    glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &maxTextureUnits);
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
    printf("Max Texture Units: %d\n", maxTextureUnits);
    printf("Max Texture Size (width/height): %d\n", maxTextureSize);

    /**
     *获取最大顶点数和索引数
     */
    GLint maxIndexListVertices, maxIndexListCount;
    glGetIntegerv(GL_MAX_ELEMENTS_VERTICES, &maxIndexListVertices);
    glGetIntegerv(GL_MAX_ELEMENTS_INDICES, &maxIndexListCount);
    printf("Max IndexList Vertices: %d\n", maxIndexListVertices);
    printf("Max IndexList Count: %d\n", maxIndexListCount);

    window = self.window;
    size = self.bounds.size;
    [window makeFirstResponder:self];

    Time::Start();
    
    glContext = [self openGLContext];

    obj = new OBJ();

    [glContext flushBuffer];

    CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    CVDisplayLinkSetOutputCallback(displayLink, &DisplayLinkCallback, (__bridge void*)(self));
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
    CVDisplayLinkStart(displayLink);
}

- (void)stopDisplayLink
{
    CVDisplayLinkStop(displayLink);
    CVDisplayLinkRelease(displayLink);
}

- (void)resetViewportSize
{
    NSSize frameSize = [self frame].size;
    frameSize = [self convertSizeToBacking:frameSize];
    const float kBaseAspect = 4.0f / 3.0f;
    if (frameSize.width / frameSize.height > kBaseAspect) {
        int width = int(frameSize.height * kBaseAspect);
        viewportRect.origin.x = (frameSize.width - width) / 2;
        viewportRect.origin.y = 0;
        viewportRect.size.width = width;
        viewportRect.size.height = frameSize.height;
    } else {
        int height = int(frameSize.width / kBaseAspect);
        viewportRect.origin.x = 0;
        viewportRect.origin.y = (frameSize.height - height) / 2;
        viewportRect.size.width = frameSize.width;
        viewportRect.size.height = height;
    }
    size = self.bounds.size;
}

- (void)pauseDisplayLink
{
    CVDisplayLinkStop(displayLink);
}

- (void)restartDisplayLink
{
    CVDisplayLinkStart(displayLink);
}

- (GLKVector2)mousePosition
{
    NSPoint location = [NSEvent mouseLocation];
    NSRect rect = NSMakeRect(location.x, location.y, 0.0f, 0.0f);
    rect = [window convertRectFromScreen:rect];
    location = rect.origin;
    location.x = location.x * 2 / size.width - 1.0f;
    location.y = location.y * 2 / size.height - 1.0f;
    return GLKVector2Make(location.x, location.y);
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)render
{
    [glContext lock];
    /**
     *设置当前渲染上下文
     */
    [glContext makeCurrentContext];
    /**
     *设置视口
     */
    glViewport(viewportRect.origin.x, viewportRect.origin.y, viewportRect.size.width, viewportRect.size.height);
    obj->Render();
    /**
     *绘制结束后flush
     */
    [glContext flushBuffer];
    [glContext unlock];
    Time::Update();

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.window setTitle:[NSString stringWithFormat:@"OBJ (%.2f fps)", Time::fps]];
    }];
}
@end
