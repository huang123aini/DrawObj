//
//  AppDelegate.m
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#import "AppDelegate.h"
#import "ObjGLView.h"
@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender {
    [[ObjGLView sharedInstance] stopDisplayLink];
    return NSTerminateNow;
}



@end
