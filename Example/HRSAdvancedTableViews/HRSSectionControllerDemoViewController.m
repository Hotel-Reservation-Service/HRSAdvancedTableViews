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

#import "HRSSectionControllerDemoViewController.h"

#import <HRSAdvancedTableViews/HRSSectionController.h>
#import "HRSSectionControllerDemoSectionController.h"


@interface HRSSectionControllerDemoViewController ()

@property (nonatomic, strong, readwrite) HRSTableViewSectionCoordinator *coordinator;

@end


@implementation HRSSectionControllerDemoViewController

- (instancetype)init {
	self = [super init];
	if (self) {
		self.title = @"Section Controller";
		
		HRSTableViewSectionCoordinator *coordinator = [HRSTableViewSectionCoordinator new];
		NSMutableArray *controller = [NSMutableArray array];
		for (int i = 0; i < 5; i++) {
			[controller addObject:[HRSSectionControllerDemoSectionController new]];
		}
		[coordinator setSectionController:controller];
		_coordinator = coordinator;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.coordinator setTableView:[self tableView]];
}

@end
