//
//  SGGGraph.h
//  iPhoneApp
//
//  Created by Антон Краснокутский on 12.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "SGGNode.h"



@interface SGGGraph : NSObject

@property (strong) GLKBaseEffect *globalEffect;
@property CGPoint currentMousePosition;
@property CGPoint offset;
@property int selectedCell;
@property bool stopped;

- (id)initWithGlobalEffect:(GLKBaseEffect *)effect;
- (void)addEdge:(int)a to:(int)b;
- (void)addNode:(SGGNode *)node;
//- (void)eraseNode:(SGGNode *)node;
- (void)render;
- (void)update;
- (int)getId:(CGPoint)point;
- (void)setupOffset:(CGPoint)point;

@end
