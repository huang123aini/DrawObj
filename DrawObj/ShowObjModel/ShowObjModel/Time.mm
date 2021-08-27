//
//  Time.cpp
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#include "Time.hpp"

#import <Foundation/Foundation.h>

static NSTimeInterval   startTime;
static NSTimeInterval   oldTime;
static NSTimeInterval   oldFPSTime;

unsigned Time::frameCount   = 0;
float Time::time            = 0.0f;
float Time::deltaTime       = 0.0f;
float Time::fps             = 0.0f;

void Time::Start()
{
    startTime = [NSDate timeIntervalSinceReferenceDate];
    oldTime = startTime;
    oldFPSTime = 0.0f;
}

void Time::Update()
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    time = now - startTime;
    deltaTime = now - oldTime;
    oldTime = now;

    frameCount++;
    if (frameCount % 60 == 0)
    {
        fps = 60.0f / (time - oldFPSTime);
        oldFPSTime = time;
    }
}
