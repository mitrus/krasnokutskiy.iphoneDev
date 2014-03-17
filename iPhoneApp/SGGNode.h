//
//  SGGMainViewController.h
//  iPhoneApp
//
//  Created by Антон Краснокутский on 10.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface SGGNode : NSObject
@property (strong) GLKBaseEffect *effect;
@property GLKVector2 position;
@property GLKVector2 velocity;

- (id)initWithEffect:(GLKBaseEffect *)effect sideSize:(float)length andColor:(GLKVector4)color andPosition:(GLKVector2)pos;

- (void)render;

@end
