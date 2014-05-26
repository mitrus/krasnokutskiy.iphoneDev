//
//  SGGNode.m
//  iPhoneApp
//
//  Created by Антон Краснокутский on 12.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import "SGGNode.h"

@implementation SGGNode {
    float rotate;
    float len;
    GLKVector4 col;
}

@synthesize effect = _effect;
@synthesize position = _position;
@synthesize velocity = _velocity;

- (id)initWithEffect:(GLKBaseEffect *)effect sideSize:(float)length andColor:(GLKVector4)color andPosition:(GLKVector2)pos {
    if (self = [super init]) {
        self.position = pos;
        self.effect = effect;
        rotate = 0.0;
        len = length;
        col = color;
    }
    return self;
}

- (void)render {

    GLKVector2 vertices[] = {
        GLKVector2Make(-len/2, -len/2), // Left  bottom front
        GLKVector2Make( len/2, -len/2), // Right bottom front
        GLKVector2Make( len/2,  len/2), // Right top    front
        GLKVector2Make(-len/2,  len/2), // Left  top    front
    };
    
    GLKVector2 triangleVertices[] = {
        // Front
        vertices[0], vertices[1], vertices[2],
        vertices[2], vertices[3], vertices[0],
    };
    
    GLKVector4 colors[] = {
        col,
        col,
        col,
        col,
    };
    
    GLKVector4 colorVertices[] = {
        // Front
        colors[0], colors[1], colors[2],
        colors[2], colors[3], colors[0],
    };
    
    self.effect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(self.position.x, self.position.y, 0);
//    self.effect.transform.modelviewMatrix = GLKMatrix4MakeZRotation(rotate);
//    rotate += 0.04;
    
    [self.effect prepareToDraw];
    
    //    glEnable(GL_DEPTH_TEST);
    //    glEnable(GL_CULL_FACE);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4,
                          GL_FLOAT, GL_FALSE, 0, colorVertices);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2,
                          GL_FLOAT, GL_FALSE, 0, triangleVertices);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribColor);
}

@end
