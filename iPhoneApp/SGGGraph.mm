//
//  SGGGraph.m
//  iPhoneApp
//
//  Created by Антон Краснокутский on 12.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import "SGGGraph.h"

#include <vector>
#include <cmath>
#include <map>
#include <set>

const float MIN_DISTANCE = 80;
const float ELASTICITY = 0.9;
const float eps = 5;
const float FRICTION = (1 - 0.09);
const float MAX_SPEED = 8.0;
const float MIN_SPEED = 0.4;
const float theta = 0.5;
const float HALF_SIDE = 6.0;
const float GRAVITY = 1200;
const float repeatCount = 1;

struct Body {
    float x, y;
    float m;
    Body() { }
    Body(float x, float y, float m) : x(x), y(y), m(m) { }
};

struct Force {
    float vx, vy;
    Force() { }
    Force(float vx, float vy) : vx(vx), vy(vy) { }
    Force operator +(const Force &a) const {
        return Force(vx + a.vx, vy + a.vy);
    }
    
    Force operator -(const Force &a) const {
        return Force(vx - a.vx, vy - a.vy);
    }
    
    Force operator *(const float a) const {
        return Force(vx * a, vy * a);
    }
};

class Tree {
private:
    float minx, miny, maxx, maxy;
    bool isLeaf;
    Tree *next[4];
public:
    Body main;
    
    Tree(float nx, float ny, float xx, float xy) : minx(nx), miny(ny), maxx(xx), maxy(xy) {
        for (int i = 0; i < 4; i++) next[i] = 0;
        main.m = main.x = main.y = 0.0;
        isLeaf = false;

    }
    
    int getSquare(float x, float y) {
        float midx = (minx + maxx) / 2;
        float midy = (miny + maxy) / 2;
        if (x >= midx && y >= midy)
            return 0;
        if (x >= midx)
            return 1;
        if (y < midy)
            return 2;
        return 3;
    }
    
    Tree *getNewById(int idd) {
        float nminx = minx, nminy = miny, nmaxx = maxx, nmaxy = maxy;
        float midx = (minx + maxx) / 2;
        float midy = (miny + maxy) / 2;
        switch (idd) {
            case 0:
                nminx = midx;
                nminy = midy;
                break;
            case 1:
                nminx = midx;
                nmaxy = midy;
                break;
            case 2:
                nmaxx = midx;
                nmaxy = midy;
                break;
            case 3:
                nmaxx = midx;
                nminy = midy;
                break;
            default:
                break;
        }
        return new Tree(nminx, nminy, nmaxx, nmaxy);
    }
    
    void update() {
        float totalMass = 0.0;
        float xCoor = 0.0, yCoor = 0.0;
        for (int i = 0; i < 4; i++) {
            if (next[i])
                xCoor += next[i]->main.x * next[i]->main.m,
                yCoor += next[i]->main.y * next[i]->main.m,
                totalMass += next[i]->main.m;
        }
        if (totalMass != 0) {
            xCoor /= totalMass;
            yCoor /= totalMass;
        }
        main.x = xCoor;
        main.y = yCoor;
        main.m = totalMass;
    }
    
    void insert(float x, float y) {
        if (main.m == 0.0) {
            main = Body(x, y, 1);
            isLeaf = 1;
        } else {
            if (isLeaf) {
                isLeaf = false;
                int idd = getSquare(main.x, main.y);
                if (!next[idd]) next[idd] = getNewById(idd);
                next[idd]->main = main;
                next[idd]->isLeaf = true;
            }
            int idd = getSquare(x, y);
            if (next[idd] == NULL)
                next[idd] = getNewById(idd);
            next[idd]->insert(x, y);
            this->update();
        }
    }
    
    void erase(float x, float y) {
        if (isLeaf) {
            main.m = 0;
            isLeaf = false;
            return;
        }
        int idd = getSquare(x, y);
        next[idd]->erase(x, y);
        this->update();
        if (this->main.m == 0)
            for (int i = 0; i < 4; i++)
                if (next[i]) {
                    delete next[i];
                    next[i] = 0;
                }
    }

    Force gravityOnBody(Body t, float coeff) {
        Force currentForce(0, 0);
        float dx = this->main.x - t.x,
            dy = this->main.y - t.y;
        float dist = sqrt(dx * dx + dy * dy);
        if (dist == 0) return Force(0, 0);
        float side = this->maxx - this->minx;
        if (side / dist < theta || this->isLeaf) {
            dx /= dist;
            dy /= dist;
            float a = coeff * t.m * this->main.m / (dist * dist);
            Force forThis(-dx * a, -dy * a);
            currentForce = currentForce + forThis;
        } else {
            for (int i = 0; i < 4; i++)
                if (this->next[i])
                    currentForce = currentForce + this->next[i]->gravityOnBody(t, coeff);
        }
        return currentForce;
    }
    /*
    Force gravityOnBody(Body t, float coeff) {
        // F = k * m1 * m2 / r ^ 2
        Force currentForce(0, 0);
        if (this->isLeaf) return Force(0, 0);
        int idd = getSquare(t.x, t.y);
        for (int i = 0; i < 4; i++) {
            if (i == idd) continue;
            if (this->next[i] == NULL) continue;
            float dx = next[i]->main.x - t.x,
            dy = next[i]->main.y - t.y;
            float len = sqrt(dx * dx + dy * dy);
            assert(len > 0);
            dx /= len;
            dy /= len;
            float a = coeff * t.m * this->next[i]->main.m / (len * len);
            Force forThis(-dx * a, -dy * a);
            currentForce = currentForce + forThis;
        }
        currentForce = currentForce + this->next[idd]->gravityOnBody(t, coeff);
        return currentForce;
    }
    */
};


const GLKVector4 edgeColor = {184/256.0, 184/256.0, 184/256.0, 1.0};

@implementation SGGGraph {
    std::vector< std::set<int> > g;
    std::vector<SGGNode *> objectList;
    int countOfEdges;
    float currentMaxSpeed;
    Tree *quadTree;
    float minDist;
    std::map<int, int> nodeById;
    std::map<int, int> idByNode;
}

@synthesize globalEffect = _globalEffect;
@synthesize currentMousePosition = _currentMousePosition;
@synthesize offset = _offset;
@synthesize selectedCell = _selectedCell;
@synthesize stopped = _stopped;
//@synthesize quadTree = _quadTree;

- (int)getNodeById:(int)_id {
    return nodeById[_id];
}

- (int)getIdByNode:(int)_node {
    return idByNode[_node];
}

- (void)clearNBI {
    nodeById.clear();
    idByNode.clear();
}

- (void)setValueToNBI:(int)first with:(int) second {
    nodeById[first] = second;
    idByNode[second] = first;
}

- (int)getBy:(int)value {
    return nodeById[value];
}

- (int)getNode:(int)value {
    return idByNode[value];
}

- (id)initWithGlobalEffect:(GLKBaseEffect *)effect {
    if ((self = [super init])) {
        self.globalEffect = effect;
        countOfEdges = 0;
        currentMaxSpeed = 5.0;
        self.stopped = false;
        quadTree = new Tree(-5000, -5000, 5000, 5000);
        minDist = 1000;
    }
    return self;
}

- (float)length:(GLKVector2) v {
    return sqrt(v.x * v.x + v.y * v.y);
}

- (void)addEdge:(int)a to:(int)b {
    if (a == b || a >= objectList.size() || b >= objectList.size()) return;
    if (g[b].find(a) == g[b].end()) {
        g[a].insert(b),
        g[b].insert(a);
        countOfEdges ++;
    }
}

- (void)addNode:(SGGNode *)node {
    quadTree->insert(node.position.x, node.position.y);
    objectList.push_back(node);
    g.resize(objectList.size());
}
/*
- (void)eraseNode:(SGGNode *)node {
    int index = 0;
    for (; index < (int) objectList.size(); index++)
        if (objectList[index] == node)
            break;
    if (index == objectList.size()) return;
    quadTree->erase(node.position.x, node.position.y);
    objectList.erase(objectList.begin() + index);
    countOfEdges -= g[index].size();
    for (std::set<int>::iterator it = g[index].begin(); it != g[index].end(); it++)
        g[*it].erase(g[*it].find(index));
    g[index].clear();
}
*/

- (int)getId:(CGPoint)point {
    if (point.x == -1)
        return -1;
    int n = (int) objectList.size();
    for (int i = 0; i < n; ++i) {
        if (objectList[i].position.x - 2 * HALF_SIDE <= point.x && objectList[i].position.x + 2 * HALF_SIDE >= point.x && objectList[i].position.y - 2 * HALF_SIDE <= point.y && objectList[i].position.y + 2 * HALF_SIDE >= point.y)
            return i;
    }
    return -1;
}

- (void)render {
    GLKVector4 redColor = GLKVector4Make(1.0, 0.0, 0.0, 1.0);
    GLKVector2 *vertcies = new GLKVector2[2 * countOfEdges];
    GLKVector4 *colors = new GLKVector4[2 * countOfEdges];
    int redEdges = 0;
    if (self.selectedCell != -1)
        redEdges = (int) g[self.selectedCell].size();
    int currentRedIt = 2 * countOfEdges - redEdges * 2;
    int currentIt = 0;
    for (int i = 0; i < (int) objectList.size(); i++) {
        for (std::set<int>::iterator it = g[i].begin(); it != g[i].end(); it++) {
            int to = *it;
            if (to > i) continue;
            if (to == self.selectedCell || i == self.selectedCell) {
                colors[currentRedIt] = colors[currentRedIt + 1] = redColor;
                vertcies[currentRedIt] = objectList[i].position;
                vertcies[currentRedIt + 1] = objectList[to].position;
                currentRedIt += 2;
            } else {
                vertcies[currentIt] = objectList[i].position;
                vertcies[currentIt + 1] = objectList[to].position;
                colors[currentIt] = edgeColor;
                colors[currentIt + 1] = edgeColor;
                currentIt += 2;
            }
        }
    }
    self.globalEffect.transform.modelviewMatrix = GLKMatrix4Identity;
    [self.globalEffect prepareToDraw];
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4,
                          GL_FLOAT, GL_FALSE, 0, colors);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2,
                          GL_FLOAT, GL_FALSE, 0, vertcies);
    
    glDrawArrays(GL_LINES, 0, 2 * countOfEdges);
    
    
    
    for (int i = 0; i < (int) objectList.size(); i++)
        [objectList[i] render];
    delete[] vertcies;
    delete[] colors;
}

- (void)setupOffset:(CGPoint)point {
    if (_selectedCell != -1)
        _offset.x = point.x - objectList[_selectedCell].position.x,
        _offset.y = point.y - objectList[_selectedCell].position.y;
    else
        _offset = CGPointMake(0, 0);
}
//215.66615	138.91

- (void) update {
    int n = (int) objectList.size();
    std::vector<bool> p(n, false);
//    NSLog(@"%f", [self length:GLKVector2Subtract(objectList[1].position, objectList[2].position)]);
    
    for (int i = 0; i < n; i++) {
        for (std::set<int>::iterator it = g[i].begin(); it != g[i].end(); it++) {
            float a = 0;
            if (*it > i) continue;
            SGGNode *p0 = objectList[i], *p1 = objectList[*it];
            GLKVector2 vect = GLKVector2Subtract([p0 position], [p1 position]);
            GLKVector2 norm = GLKVector2Normalize(vect);
            float d = [self length:vect];
            float x = d - MIN_DISTANCE;
            if (x >= 0)
                a = ELASTICITY * (x / d);
            else
                a = ELASTICITY * (x) / d;
            //            if (a < 0) x *= 10;
            norm = GLKVector2MultiplyScalar(norm, a);
            //            a /= COUNT;
            if (*it != 0)
                p1.velocity = GLKVector2Add(p1.velocity, norm);
            if (i != 0)
                p0.velocity = GLKVector2Subtract(p0.velocity, norm);
        }
    } /*
    for (int i = 0; i < n; i++)
        for (int j = 0; j < i; j++) {
            SGGNode *p0 = objectList[i], *p1 = objectList[j];
            GLKVector2 vect = GLKVector2Subtract([p0 position], [p1 position]);
            GLKVector2 norm = GLKVector2Normalize(vect);
            float d = [self length:vect];
            float a = 0;
            a = (1000) / d / d;
            //            a /= COUNT;
            norm = GLKVector2MultiplyScalar(norm, a);
            if (i != 0)
                p0.velocity = GLKVector2Add(p0.velocity, norm);
            if (j != 0)
                p1.velocity = GLKVector2Subtract(p1.velocity, norm);

        }*/
    
    for (int i = 1; i < n; i++) {
        Body currentBody(objectList[i].position.x, objectList[i].position.y, 1.0);
        Force totalForce = quadTree->gravityOnBody(currentBody, GRAVITY);
        GLKVector2 copyForce = GLKVector2Make(totalForce.vx, totalForce.vy);
        objectList[i].velocity = GLKVector2Add(objectList[i].velocity, copyForce);
    }
    
    if (self.selectedCell != -1)
        objectList[self.selectedCell].velocity = GLKVector2Make(0, 0);
    currentMaxSpeed = 0;
    for (int i = 0; i < n; i++) {
        objectList[i].velocity = GLKVector2MultiplyScalar(objectList[i].velocity, FRICTION);
        float spd = [self length:objectList[i].velocity];
        currentMaxSpeed = (spd > currentMaxSpeed ? spd : currentMaxSpeed);
        if (spd > MAX_SPEED && !p[i])
            objectList[i].velocity = GLKVector2MultiplyScalar(objectList[i].velocity, MAX_SPEED / spd);
        //     printf("%d\n", ids[i].center.vx);
        //        if (ids[i].center.vx * ids[i].center.vx + ids[i].center.vy * ids[i].center.vy ) {
        //        if (spd > MAX_SPEED) {
        if (!p[i]) {
            quadTree->erase(objectList[i].position.x, objectList[i].position.y);
            objectList[i].position = GLKVector2Add(objectList[i].position, GLKVector2MultiplyScalar(objectList[i].velocity, 1 / repeatCount));
            quadTree->insert(objectList[i].position.x, objectList[i].position.y);
        }
        //      }
    }//215.66615	138.91
    if (self.selectedCell != -1) {
        CGFloat dc[2] = {_currentMousePosition.x - _offset.x - objectList[self.selectedCell].position.x, _currentMousePosition.y - _offset.y - objectList[self.selectedCell].position.y};
//        objectList[currentCell].position.x += 0.3 * dc[0];
//        objectList[currentCell].position.y = objectList[currentCell].position.y + 0.3 * dc[1];
        quadTree->erase(objectList[self.selectedCell].position.x, objectList[self.selectedCell].position.y);
        objectList[self.selectedCell].position = GLKVector2Add(objectList[self.selectedCell].position, GLKVector2MultiplyScalar(GLKVector2Make(dc[0], dc[1]), 0.3));
        quadTree->insert(objectList[self.selectedCell].position.x, objectList[self.selectedCell].position.y);
    }
    if (currentMaxSpeed < MIN_SPEED)
        self.stopped = true;
//    else
//        NSLog(@"%f", currentMaxSpeed);
}

@end
