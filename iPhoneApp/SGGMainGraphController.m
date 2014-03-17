//
//  SGGMainGraphController.m
//  iPhoneApp
//
//  Created by Антон Краснокутский on 17.03.14.
//  Copyright (c) 2014 Антон Краснокутский. All rights reserved.
//

#import "SGGMainGraphController.h"
#import "SGGIntermediateGraphController.h"

//#include <set>
//#include <map>
//#include <vector>

@interface SGGMainGraphController ()

@property (strong, nonatomic) SGGIntermediateGraphController *graphController;

@end

@implementation SGGMainGraphController {
//    std::vector< std::set<int> > graphOfIds;
//    std::set<int> currentPeople;
//    std::map<int, int> nodeById;
}

@synthesize graphController = _graphController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.graphController = [[SGGIntermediateGraphController alloc] init];
    self.graphController.graph = self.graph;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
