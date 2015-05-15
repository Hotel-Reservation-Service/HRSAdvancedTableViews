//
//	Licensed under the Apache License, Version 2.0 (the "License");
//	you may not use this file except in compliance with the License.
//	You may obtain a copy of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
//	Unless required by applicable law or agreed to in writing, software
//	distributed under the License is distributed on an "AS IS" BASIS,
//	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	See the License for the specific language governing permissions and
//	limitations under the License.
//

#import "HRSSectionControllerDynamicDemoViewController.h"

#import <HRSAdvancedTableViews/HRSSectionController.h>
#import "HRSSectionControllerDemoSectionController.h"


@interface HRSSectionControllerDynamicDemoViewController ()

@property (nonatomic, strong, readonly) HRSTableViewSectionController *controllerOne;
@property (nonatomic, strong, readonly) HRSTableViewSectionController *controllerTwo;
@property (nonatomic, strong, readonly) HRSTableViewSectionController *controllerThree;

@property (nonatomic, weak, readonly) UISwitch *switchOne;
@property (nonatomic, weak, readonly) UISwitch *switchTwo;
@property (nonatomic, weak, readonly) UISwitch *switchThree;

@property (nonatomic, strong, readonly) HRSTableViewSectionCoordinator *coordinator;

@end


@implementation HRSSectionControllerDynamicDemoViewController

- (instancetype)init {
	self = [super init];
	if (self) {
		self.title = @"Section Controller";
		
        HRSTableViewSectionController *controllerOne = [HRSSectionControllerDemoSectionController new];
        _controllerOne = controllerOne;
        
        HRSTableViewSectionController *controllerTwo = [HRSSectionControllerDemoSectionController new];
        _controllerTwo = controllerTwo;
        
        HRSTableViewSectionController *controllerThree = [HRSSectionControllerDemoSectionController new];
        _controllerThree = controllerThree;
        
		HRSTableViewSectionCoordinator *coordinator = [HRSTableViewSectionCoordinator new];
        [coordinator setSectionController:@[ controllerOne, controllerTwo, controllerThree ]];
		_coordinator = coordinator;
        
        UISwitch *switchOne = [UISwitch new];
        switchOne.on = YES;
        [switchOne addTarget:self action:@selector(visibilityStateChanged:) forControlEvents:UIControlEventValueChanged];
        _switchOne = switchOne;
        
        UISwitch *switchTwo = [UISwitch new];
        switchTwo.on = YES;
        [switchTwo addTarget:self action:@selector(visibilityStateChanged:) forControlEvents:UIControlEventValueChanged];
        _switchTwo = switchTwo;
        
        UISwitch *switchThree = [UISwitch new];
        switchThree.on = YES;
        [switchThree addTarget:self action:@selector(visibilityStateChanged:) forControlEvents:UIControlEventValueChanged];
        _switchThree = switchThree;
        
        self.navigationItem.rightBarButtonItems = @[
                                                    [[UIBarButtonItem alloc] initWithCustomView:switchOne],
                                                    [[UIBarButtonItem alloc] initWithCustomView:switchTwo],
                                                    [[UIBarButtonItem alloc] initWithCustomView:switchThree]
                                                    ];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.coordinator setTableView:[self tableView]];
}

- (IBAction)visibilityStateChanged:(id)sender {
    NSMutableArray *controller = [NSMutableArray new];
    if (self.switchOne.isOn) {
        [controller addObject:self.controllerOne];
    }
    if (self.switchTwo.isOn) {
        [controller addObject:self.controllerTwo];
    }
    if (self.switchThree.isOn) {
        [controller addObject:self.controllerThree];
    }
    [self.coordinator setSectionController:controller animated:YES];
}

@end
