//
//  ObjGLView.h
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#import <Cocoa/Cocoa.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjGLView : NSOpenGLView

+ (ObjGLView *)sharedInstance;
- (void)stopDisplayLink;
- (void)pauseDisplayLink;
- (void)restartDisplayLink;
- (void)resetViewportSize;
- (GLKVector2)mousePosition;

@end

NS_ASSUME_NONNULL_END
