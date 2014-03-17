//
//  SGGMainViewController.h
//  iPhoneApp
//
//  Created by Антон Краснокутский on 10.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "SGGGraph.h"


@interface SGGGraphViewController : GLKViewController

@property (strong, nonatomic) IBOutlet UILabel *countOfFingers;

@property (strong, nonatomic) EAGLContext *context;
@property (strong) GLKBaseEffect *effect;
@property float rotate;
@property (strong) SGGGraph *graph;

@end
