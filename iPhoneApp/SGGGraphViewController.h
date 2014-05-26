//
//  SGGMainViewController.h
//  iPhoneApp
//
//  Created by Антон Краснокутский on 10.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <VK-ios-sdk/VKSdk.h>
#import "SGGGraph.h"
#import "DLImageLoader.h"

@interface SGGGraphViewController : GLKViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *countOfFingers;
@property (strong, nonatomic) IBOutlet UITextField *personIdText;
@property (strong, nonatomic) IBOutlet UILabel *personName;
@property (strong, nonatomic) EAGLContext *context;
@property (strong) GLKBaseEffect *effect;
@property float rotate;
@property (strong) SGGGraph *graph;


@end
