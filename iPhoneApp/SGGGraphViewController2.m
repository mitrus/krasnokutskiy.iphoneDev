//
//  SGGMainViewController.m
//  iPhoneApp
//
//  Created by Антон Краснокутский on 10.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import "SGGGraphViewController.m"
#import "SGGGraph.h"

@interface SGGGraphViewController () {
    int counts;
    float xTL;
    float yTL;
    float xBR;
    float yBR;
    CGPoint lastMedianInView;
    float lastDistanceInView;
    float lastKoeff;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong) GLKBaseEffect *effect;
@property float rotate;
@property (strong) SGGGraph *graph;
@property (strong, nonatomic) IBOutlet UILabel *countOfFingers;
//@property (strong, nonatomic) VKAccessToken *token;

@end

const GLKVector4 male = {0.0, 158.0/256, 232.0/256},
                female = {245/256.0, 12/256.0, 139/256.0};

@implementation SGGGraphViewController

@synthesize context = _context;
@synthesize rotate = _rotate;
@synthesize graph = _graph;
@synthesize countOfFingers = _countOfFingers;
//@synthesize token = _token;

- (float)distanceFrom:(CGPoint)a to:(CGPoint)b {
    return sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.effect = [[GLKBaseEffect alloc] init];
    
    if (!self.context) {
        NSLog(@"Error in ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    [EAGLContext setCurrentContext:self.context];

    float aspect = fabsf(self.view.bounds.size.height / self.view.bounds.size.width);
    xTL = yTL = 0;
    xBR = 320.0;
    lastDistanceInView = -1;
    yBR = aspect * 320.0;
    NSLog(@"%f width", aspect * 320);
    NSLog(@"%f width", self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(xTL, xBR, yBR, yTL, -1024, 1024);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    //MAKE GRAPH
    self.graph = [[SGGGraph alloc] initWithGlobalEffect:self.effect];
    [self.graph addNode:[[SGGNode alloc] initWithEffect:self.effect sideSize:HALF_SIDE * 2 andColor:male andPosition:GLKVector2Make(160, aspect * 160)]];
    
    for (int i = 1; i < 10; i++) {
        [self.graph addNode:[[SGGNode alloc] initWithEffect:self.effect sideSize:HALF_SIDE * 2 andColor: rand() % 2 == 0 ? female : male andPosition:GLKVector2Make((float) (rand() % 10000 - 3400) / 10.0, (float) (rand() % 10000 - 3400) / 10.0)]];
        [self.graph addEdge:0 and:i];
    }
    for (int i = 1; i < 30; i++)
        //        for (int j = 0; j < )
        [self.graph addEdge:rand() % 10 and:rand() % 10];
    
    //INIT GRAPH
    [self.graph setCurrentMousePosition:CGPointMake(-1, -1)];
    [self.graph setSelectedCell:-1];

    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.graph setStopped:false];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    
//    [self.countOfFingers setText:[NSString stringWithFormat:@"%d", [[event allTouches] count]]];
//    if ([[event allTouches] count] == 1) {
        [self.graph setCurrentMousePosition: [self transformFromViewToGl:location]];
    [self.graph setSelectedCell:[self.graph getId:[self transformFromViewToGl:location]]];
//    }
    if ([[event allTouches] count] == 1)
        lastMedianInView = location;
    [self.graph setupOffset:[self transformFromViewToGl:location]];
//    NSLog(@"Began: %f %f", location.x, location.y);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (CGPoint)transformFromViewToGl:(CGPoint)point {
    float fx = point.x / self.view.bounds.size.width,
          fy = point.y / self.view.bounds.size.height;
    return CGPointMake((xBR - xTL) * fx + xTL, (yBR - yTL) * fy + yTL);
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.graph setStopped:false];
    NSArray *allTouches = [[event allTouches] allObjects];
    if ([[event allTouches] count] == 2) {
        CGPoint pts1 = [[allTouches objectAtIndex:0] locationInView:self.view],
                pts2 = [[allTouches objectAtIndex:1] locationInView:self.view];
        if (lastDistanceInView != -1) {
            float newDistanceInView = [self distanceFrom:pts1 to:pts2];
            float coefficient = newDistanceInView / lastDistanceInView;
            
            [self.countOfFingers setText:[[NSString alloc] initWithFormat:@"%.1f %.1f", self.view.bounds.size.height, self.view.bounds.size.width]];
            
            CGPoint newMedian = CGPointMake(pts1.x / 2.0 + pts2.x / 2.0, pts1.y / 2.0 + pts2.y / 2.0);
            CGPoint mxNewMedian = [self transformFromViewToGl:newMedian],
                    mxLastMedianInView = [self transformFromViewToGl:lastMedianInView];
            CGPoint v0 = CGPointMake(mxNewMedian.x - xTL, mxNewMedian.y - yTL),
                    v1 = CGPointMake(xBR - mxNewMedian.x, yBR - mxNewMedian.y);
            
            CGPoint transformParallel = CGPointMake(mxNewMedian.x - mxLastMedianInView.x, mxNewMedian.y - mxLastMedianInView.y);
            
            v0.x /= coefficient;
            v0.y /= coefficient;
            v1.x /= coefficient;
            v1.y /= coefficient;
            
            xTL = mxNewMedian.x - v0.x;
            yTL = mxNewMedian.y - v0.y;
            xBR = mxNewMedian.x + v1.x;
            yBR = mxNewMedian.y + v1.y;
            
            xTL -= transformParallel.x;
            xBR -= transformParallel.x;
            yTL -= transformParallel.y;
            yBR -= transformParallel.y;
            
            
            GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(xTL, xBR, yBR, yTL, -1024, 1024);
            self.effect.transform.projectionMatrix = projectionMatrix;
            
            lastDistanceInView = newDistanceInView;
            lastMedianInView = newMedian;
        } else {
            lastDistanceInView = [self distanceFrom:pts1 to:pts2];
            lastMedianInView = CGPointMake(pts1.x / 2.0 + pts2.x / 2.0, pts1.y / 2.0 + pts2.y / 2.0);
            //            [self.countOfFingers setText:[[NSString alloc] initWithFormat:@"%f", 15.0]];
//            [self.countOfFingers setText:[[NSString alloc] initWithFormat:@"%.1f %.1f ", lastMedian.x, lastMedian.y]];
        }
    } else if ([[event allTouches] count] == 1){
//    [self.countOfFingers setText:[NSString stringWithFormat:@"%d", counts]];
//    [self.currentTouches unionSet:touches];
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:self.view];
        [self.graph setCurrentMousePosition: [self transformFromViewToGl:location]];
        if ([self.graph selectedCell] == -1) {
            if (lastMedianInView.x == -1) {
                lastMedianInView = [[allTouches objectAtIndex:0] locationInView:self.view];
            } else {
                CGPoint pts = [[allTouches objectAtIndex:0] locationInView:self.view];
                CGPoint mxNewMedian = [self transformFromViewToGl:pts],
                        mxLastMedianInView = [self transformFromViewToGl:lastMedianInView];
                CGPoint transformParallel = CGPointMake(mxNewMedian.x - mxLastMedianInView.x, mxNewMedian.y - mxLastMedianInView.y);
                xTL -= transformParallel.x;
                xBR -= transformParallel.x;
                yTL -= transformParallel.y;
                yBR -= transformParallel.y;
                GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(xTL, xBR, yBR, yTL, -1024, 1024);
                self.effect.transform.projectionMatrix = projectionMatrix;
                lastMedianInView = pts;
            }
        }
    }
//    [self.countOfFingers setText:[[NSString alloc] initWithFormat:@"%d", [[event allTouches] count]]];
    //    NSLog(@"Moved: %f %f", location.x, location.y);
//    [self.countOfFingers setText:[[NSString alloc] initWithFormat:@"ENDED"]];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesEnded:touches withEvent:event];
//    [self.countOfFingers setText:[[NSString alloc] initWithFormat:@"%d", [[event allTouches] count] - [touches count]]];
//    [self.countOfFingers setText:[[NSString alloc] initWithFormat:@"FUCK!"]];
    lastDistanceInView = -1;
    lastMedianInView = CGPointMake(-1, -1);
    [self.graph setCurrentMousePosition:CGPointMake(-1, -1)];
    [self.graph setSelectedCell:-1];
//    NSLog(@"Ended");

}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
//    if (![self.token.accessToken  isEqual: @"empty"]) {
//        NSLog(@"%@", self.token.accessToken);
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        [self.graph render];
//    if (![self.graph stopped]) {
        [self.graph update];
//    }
//    }
//    [self.graph update];
//    [self.graph update];
}


@end
