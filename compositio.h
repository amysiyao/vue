//
//  compositio.h
//  hello
//
//  Created by 思遥 on 2018/9/7.
//  Copyright © 2018年 思遥. All rights reserved.
//

#ifndef compositio_h
#define compositio_h


#endif /* compositio_h */
#import <Foundation/Foundation.h>

@interface Tire :NSObject
@end
@implementation Tire
-(NSString *)description{
    return (@"hhhh");
}
@end
@interface Engine :NSObject
@end
@implementation Engine
-(NSString *)description{
    return (@"uuuu");
}
@end
@interface Car:NSObject
{
    Engine *engine;
    Tire *tire[4];
}

-(void) print;
@end
@implementation Car
-(id) init{
    if(self=[super init]){
        engine=[Engine new];
        tire[0]=[Tire new];
        tire[1]=[Tire new];
        tire[2]=[Tire new];
        tire[3]=[Tire new];
    }
    return (self);
}
-(void) print{
    NSLog(@"%@",engine);
    NSLog(@"%@",tire[0]);
}
@end
