//
//  WindowController.m
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/27.
//

#import "WindowController.h"
#include "ObjGLView.h"
@interface WindowController ()

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.delegate = self;
    self.window.frameAutosaveName = @"Main Window";
    [self.window setContentSize:NSMakeSize(640, 480)];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
    if ([self.window styleMask] & NSWindowStyleMaskFullScreen)
    {
        return frameSize;
    }
    else
    {
        NSRect rect = NSMakeRect(0, 0, 640, 480);
        rect = [self.window frameRectForContentRect:rect];
        return rect.size;
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    [NSApp terminate:self];
}
- (void)windowWillEnterFullScreen:(NSNotification *)notification
{
    [[ObjGLView sharedInstance] pauseDisplayLink];
}

- (void)windowDidEnterFullScreen:(NSNotification *)notification
{
    [[ObjGLView sharedInstance] restartDisplayLink];
}

- (void)windowWillExitFullScreen:(NSNotification *)notification
{
    [[ObjGLView sharedInstance] pauseDisplayLink];
}

- (void)windowDidExitFullScreen:(NSNotification *)notification
{
    [[ObjGLView sharedInstance] restartDisplayLink];
}

- (void)windowDidResize:(NSNotification *)notification
{
    [[ObjGLView sharedInstance] resetViewportSize];
}

@end
