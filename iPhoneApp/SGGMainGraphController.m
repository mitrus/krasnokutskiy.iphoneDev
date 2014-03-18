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

@interface SGGMainGraphController () {
    NSMutableArray *reqs;
    int currentRequest;
}

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

//- (void)addAllEdgesFor

- (void)proceedRequest:(id)sender {
    if (currentRequest < [reqs count])
        [[reqs objectAtIndex:currentRequest] executeWithResultBlock:[[reqs objectAtIndex:currentRequest] completeBlock] errorBlock:[[reqs objectAtIndex:currentRequest] errorBlock]];
    currentRequest++;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentRequest = 0;
    self.graphController = [[SGGIntermediateGraphController alloc] init];
    self.graphController.graph = self.graph;
    
    //Build graph for current main user
    VKRequest *userId = [[VKApi users] get];
    userId.attempts = 0;
    [userId executeWithResultBlock:^(VKResponse * response) {
        self.countOfFingers.text = @"HMM...";
        NSDictionary *answer = response.json;
        NSNumber *selfId = [[answer valueForKey:@"id"] objectAtIndex:0];
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
            
            }
            /*if ([requests count] > 0)
                [[requests objectAtIndex:0] executeWithResultBlock:[[requests objectAtIndex:0] completeBlock] errorBlock:[[requests objectAtIndex:0] errorBlock]];
            for (int i = 1; i < [requests count]; i++)
                [[requests objectAtIndex:i] executeAfter:[requests objectAtIndex:i-1] withResultBlock:[[requests objectAtIndex:i] completeBlock] errorBlock:[[requests objectAtIndex:i] errorBlock]];*/
//            for (int i = 0; i < 1000; i++)
//                [[requests objectAtIndex:rand() % [requests count]] repeat];
//            [requets ex
            reqs = requests;
            [NSTimer scheduledTimerWithTimeInterval:0.34
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
