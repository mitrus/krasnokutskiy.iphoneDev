//
//  SGGMainViewController.m
//  iPhoneApp
//
//  Created by Антон Краснокутский on 10.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import "SGGGraphViewController.h"

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



//@property (strong, nonatomic) VKAccessToken *token;

@end

const GLKVector4 male = {0.0, 158.0/256, 232.0/256},
female = {245/256.0, 12/256.0, 139/256.0};

@implementation SGGGraphViewController

@synthesize context = _context;
@synthesize rotate = _rotate;
@synthesize graph = _graph;
@synthesize countOfFingers = _countOfFingers;
@synthesize personIdText = _personIdText;
@synthesize personName = _personName;

//@synthesize token = _token;

- (float)distanceFrom:(CGPoint)a to:(CGPoint)b {
    return sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.effect = [[GLKBaseEffect alloc] init];
    self.personIdText.delegate = self;
    
    if (!self.context) {
        NSLog(@"Error in ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    [EAGLContext setCurrentContext:self.context];
    
    float aspect = fabsf(self.view.bounds.size.height / self.view.bounds.size.width);
    xTL = -500;
    xBR = 500;
    yTL = -500 * aspect;
    yBR = 500 * aspect;
    lastDistanceInView = -1;

    NSLog(@"%f width", aspect * 320);
    NSLog(@"%f width", self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(xTL, xBR, yBR, yTL, -1024, 1024);
    self.effect.transform.projectionMatrix = projectionMatrix;
    self.graph = [[SGGGraph alloc] initWithGlobalEffect:self.effect];
    
    //MAKE GRAPH
    /*
    
    [self.graph addNode:[[SGGNode alloc] initWithEffect:self.effect sideSize:6.0 * 2 andColor:male andPosition:GLKVector2Make(160, aspect * 160)]];
    
    for (int i = 1; i < 10; i++) {
        [self.graph addNode:[[SGGNode alloc] initWithEffect:self.effect sideSize:6.0 * 2 andColor: rand() % 2 == 0 ? female : male andPosition:GLKVector2Make((float) (rand() % 10000 - 3400) / 10.0, (float) (rand() % 10000 - 3400) / 10.0)]];
        [self.graph addEdge:0 to:i];
    }
    for (int i = 1; i < 30; i++)
        [self.graph addEdge:rand() % 10 to:rand() % 10];
    */
    //INIT GRAPH
    [self.graph setCurrentMousePosition:CGPointMake(-1, -1)];
    [self.graph setSelectedCell:-1];
    

    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
/*    VKRequest * audioReq = [VKRequest requestWithMethod:@"friends.getMutual" andParameters:@{@"target_uid" : @"16780990"} andHttpMethod:@"POST"];
    [audioReq executeWithResultBlock:^(VKResponse * response) {
        self.countOfFingers.text = [[NSString alloc] initWithFormat:@"%lu", [(NSArray *)response.json count]];
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            self.countOfFingers.text = @"VK error: %@";
        }
    }];
    */
    [self.graph setStopped:false];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    //    [self.countOfFingers setText:[NSString stringWithFormat:@"%d", [[event allTouches] count]]];
    //    if ([[event allTouches] count] == 1) {
    [self.graph setCurrentMousePosition: [self transformFromViewToGl:location]];
    [self.graph setSelectedCell:[self.graph getId:[self transformFromViewToGl:location]]];
    
    
    if ([self.graph selectedCell] != -1) {
        NSString *url_Img_FULL;

        int personId = [self.graph selectedCell];
        int lol = [self.graph getNode:personId];
//        VKRequest *getMutual = [VKRequest requestWithMethod:@"friends.getMutual" andParameters:@{@"target_uid" : [[[answerFriends valueForKey:@"items"]     objectAtIndex:index1] valueForKey:@"id"] } andHttpMethod:@"GET"];
//        [self.graph ]
        VKRequest *selectedUserInfo = [VKRequest requestWithMethod:@"users.get" andParameters:@{@"user_ids" : [NSNumber numberWithInt:lol], @"fields" : @"photo_50"} andHttpMethod:@"GET"];
        [selectedUserInfo executeWithResultBlock:^(VKResponse *response) {
            NSDictionary *info = response.json;
            NSLog(@"%@", info);
            NSArray *urlArray = [info valueForKey:@"photo_50"];
            NSArray *firstNameArray = [info valueForKey:@"first_name"];
            NSArray *secondNameArray = [info valueForKey:@"last_name"];
            NSString *url = [urlArray objectAtIndex:0];
            NSString *firstName = [firstNameArray objectAtIndex:0];
            NSString *secondName = [secondNameArray objectAtIndex:0];
//            [self.personName setFont:[UIFont fontWithName:@"OpenSans-Light" size:14.f]];
            self.personName.text = [secondName stringByAppendingString:[@" " stringByAppendingString:firstName]];
//            _personIdText.text = url;
//            [self.personIdText setText:url];
         //   UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
//            NSString *lol = [url substringFromIndex:8];
//            url = [@"http://" stringByAppendingString:[url substringFromIndex:8]];
//            if ([url hasPrefix:@"https://"]) {
            
//            }
//            NSURL * imageURL = [NSURL URLWithString:url];
//            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            __block UIImage * img;
            DLImageLoader *loader = [[DLImageLoader alloc] init];
            [loader loadImageFromUrl:url completed:^(NSError *error, UIImage *imageTmp) {
                img = imageTmp;
                UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
                imageView.layer.cornerRadius = img.size.width / 2;
                imageView.layer.masksToBounds = YES;
                [imageView.layer setPosition:CGPointMake(6 + img.size.width / 2, self.view.window.bounds.size.height - img.size.height / 2 - 6)];
                [self.view addSubview: imageView];
            }];
            
            NSLog(@"LOL");
        } errorBlock:^(NSError *error) {
            NSLog(@"DSDS");
        }];
        
    }
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
            
//            [self.countOfFingers setText:[[NSString alloc] initWithFormat:@"%.1f %.1f", self.view.bounds.size.height, self.view.bounds.size.width]];
            
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
    for (int i = 0; i < 1; i++)
        [self.graph update];
//    [self.graph update];
//    [self.graph update];
    //    }
    //    }
    //    [self.graph update];
    //    [self.graph update];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"OK!:)");
    [self textFieldShouldReturn:textField];
}

#pragma mark - Graph Builder By Id

- (void)buildGraphById:(int)_id { /*
    VKRequest *userId = [VKRequest requestWithMethod:@"users.get" andParameters:@{@"user_ids" : [NSNumber numberWithInteger:[self.personIdText.text integerValue]], @"fields" : @"photo_50"} andHttpMethod:@"GET"];
    userId.attempts = 0;
    [userId executeWithResultBlock:^(VKResponse * response) {
        self.countOfFingers.text = @"Everything is OK!";
        NSDictionary *answer = response.json;
        NSNumber *selfId = [[answer valueForKey:@"id"] objectAtIndex:0];
        //        NSNumber *selfId = @141429766;
        [self.graphController addNode:[selfId intValue] andSex:YES];
        
        VKRequest *getAllFriends = [[VKApi friends] get:@{VK_API_FIELDS : @"sex"}];
        [getAllFriends executeWithResultBlock:^(VKResponse * responseFriends) {
            NSDictionary *answerFriends = responseFriends.json;
            NSArray *list = [answerFriends valueForKey:@"items"];
            for (int i = 0; i < [list count]; i++) {
                NSDictionary *currentPerson = [list objectAtIndex:i];
                int sex = [[currentPerson valueForKey:@"sex"] intValue];
                int personId = [[currentPerson valueForKey:@"id"] intValue];
                [self.graphController addNode:personId andSex:sex == 2];
                [self.graphController addEdge:[selfId intValue] and:personId];
                //                [self.graphController add]
            }
            NSMutableArray *requests = [[NSMutableArray alloc] init];
            for (int i = 0 ; i < [list count]; i++) {
                //                [NSThread sleepForTimeInterval:0.3];
                //                VKRequest *getMutual = [[VK]]
                ^(int index1) {
                    VKRequest *getMutual = [VKRequest requestWithMethod:@"friends.getMutual" andParameters:@{@"target_uid" : [[[answerFriends valueForKey:@"items"]     objectAtIndex:index1] valueForKey:@"id"] } andHttpMethod:@"GET"];
                    getMutual.completeBlock = ^(VKResponse * responseMutual) {
                        NSArray *mutual = responseMutual.json;
                        for (int j = 0; j < [mutual count]; j++) {
                            [self.graphController addEdge:[[[[answerFriends valueForKey:@"items"] objectAtIndex:index1] valueForKey:@"id"] intValue] and:[[mutual objectAtIndex:j] intValue]];
                        }
                    };
                    getMutual.errorBlock = ^(NSError * error) {
                        if (error.code != VK_API_ERROR) {
                            [error.vkError.request repeat];
                        }
                        else {
                            NSLog(@"VK error: %@", error);
                        }
                    };
                    
                    [requests addObject:getMutual];
                }(i);
                
            }*/
            /*if ([requests count] > 0)
             [[requests objectAtIndex:0] executeWithResultBlock:[[requests objectAtIndex:0] completeBlock] errorBlock:[[requests objectAtIndex:0] errorBlock]];
             for (int i = 1; i < [requests count]; i++)
             [[requests objectAtIndex:i] executeAfter:[requests objectAtIndex:i-1] withResultBlock:[[requests objectAtIndex:i] completeBlock] errorBlock:[[requests objectAtIndex:i] errorBlock]];*/
            //            for (int i = 0; i < 1000; i++)
            //                [[requests objectAtIndex:rand() % [requests count]] repeat];
            //            [requets ex
    /*
            reqs = requests;
            [NSTimer scheduledTimerWithTimeInterval:0.4
                                             target:self
                                           selector:@selector(proceedRequest:)
                                           userInfo:nil
                                            repeats:YES];
            
        } errorBlock:^(NSError * error) {
            if (error.code != VK_API_ERROR) {
                [error.vkError.request repeat];
            }
            else {
                NSLog(@"VK error: %@", error);
            }
        }];
        
    } errorBlock:^(NSError * error) {
        self.countOfFingers.text = @":((...";
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        }
        else {
            NSLog(@"VK error: %@", error);
        }
    }];
*/
}

@end
