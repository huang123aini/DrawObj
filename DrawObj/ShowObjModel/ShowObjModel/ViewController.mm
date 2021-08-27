//
//  ViewController.m
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#import "ViewController.h"
#import "ObjGLView.h"
@implementation ViewController
{
    bool    isShiftOn;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSRect viewFrame = [self.view frame];
    ObjGLView* glView = [[ObjGLView alloc] initWithFrame:viewFrame];
    glView.translatesAutoresizingMaskIntoConstraints = YES;
    glView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.view addSubview:glView];

    isShiftOn = false;
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
