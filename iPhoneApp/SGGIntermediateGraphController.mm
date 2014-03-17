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
}

@synthesize graph = _graph;

- (void)clearGraph {
    graphOfIds.clear();
    currentPeople.clear();
    nodeById.clear();
}

- (void)addNode:(int)identificator {
    if (currentPeople.find(identificator) == currentPeople.end()) {
        nodeById[identificator] = (int) currentPeople.size();
        currentPeople.insert(identificator);
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
