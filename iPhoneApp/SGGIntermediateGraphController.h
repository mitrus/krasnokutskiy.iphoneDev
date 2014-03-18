//
//  SGGIntermediateGraphController.h
//  iPhoneApp
//
//  Created by Антон Краснокутский on 17.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGGGraph.h"

@interface SGGIntermediateGraphController : NSObject 

@property (weak, nonatomic) SGGGraph *graph;

- (void)clearGraph;
- (void)addNode:(int)identificator andSex:(BOOL)isMale;
- (void)addEdge:(int)id1 and:(int)id2;

@end
