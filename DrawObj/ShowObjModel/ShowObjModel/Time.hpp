//
//  Time.hpp
//  ShowObjModel
//
//  Created by 黄世平 on 2021/8/26.
//

#ifndef Time_hpp
#define Time_hpp

#include <stdio.h>


struct Time
{
    static unsigned frameCount;
    static float    time;
    static float    deltaTime;
    static float    fps;     

    static void Start();
    static void Update();
};


#endif /* Time_hpp */
