//
//  SGGIntermediateGraphController.m
//  iPhoneApp
//
//  Created by Антон Краснокутский on 17.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import "SGGIntermediateGraphController.h"
#include <vector>
#include <map>
#include <set>

@implementation SGGIntermediateGraphController {
    std::vector< std::set<int> > graphOfIds;
    std::set<int> currentPeople;
    std::map<int, int> nodeById;
    bool hasSet;
}

@synthesize graph = _graph;

const GLKVector4 male = {0.0, 158.0/256, 232.0/256},
    female = {245/256.0, 12/256.0, 139/256.0};

- (void)clearGraph {
    hasSet = NO;
    graphOfIds.clear();
    currentPeople.clear();
    nodeById.clear();
}

- (void)addNode:(int)identificator andSex:(BOOL)isMale {
    if (currentPeople.find(identificator) == currentPeople.end()) {

        nodeById[identificator] = (int) currentPeople.size();
        currentPeople.insert(identificator);
        if (!hasSet) {
            [self.graph addNode:[[SGGNode alloc] initWithEffect:self.graph.globalEffect sideSize:6.0 * 2 andColor:isMale ? male : female andPosition:GLKVector2Make(0, 0)]];
            hasSet = YES;
        } else
            [self.graph addNode:[[SGGNode alloc] initWithEffect:self.graph.globalEffect sideSize:6.0 * 2 andColor:isMale ? male : female andPosition:GLKVector2Make((float) (rand() % 50000) / 200.0, (float) (rand() % 50000) / 200.0)]];
    }
}

- (void)addEdge:(int)id1 and:(int)id2 {
    if (currentPeople.find(id1) == currentPeople.end() || currentPeople.find(id2) == currentPeople.end())
        return;
    int node1 = nodeById.find(id1)->second,
        node2 = nodeById.find(id2)->second;
    [self.graph addEdge:node1 to:node2];
}


@end
