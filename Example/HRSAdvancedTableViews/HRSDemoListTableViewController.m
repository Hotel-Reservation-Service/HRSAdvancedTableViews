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

#import "HRSDemoListTableViewController.h"


typedef NS_ENUM(NSUInteger, Demo) {
	DemoSectionController,
	DemoIndexPathMapping,
	
	DemoCount
};


@interface HRSDemoListTableViewController ()

@end


@implementation HRSDemoListTableViewController

+ (NSArray *)sectionNames {
	static NSArray *sectionNames;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sectionNames = @[
						 // Section Controller
						 @[
							 @"HRSSectionControllerDemoViewController",
                             @"HRSSectionControllerDynamicDemoViewController",
							 ],
						 
						 // Index Path Mapping
						 @[
							 @"HRSSimpleIndexPathMappingTableViewController",
							 @"HRSTreeIndexPathMappingTableViewController",
							 ],
						 ];
	});
	return sectionNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Demo"];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return DemoCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch ((Demo)section) {
		case DemoSectionController:
			return @"HRS Section Controller";
		case DemoIndexPathMapping:
			return @"HRS Index Path Mapping";
			
		case DemoCount:
			return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[[self class] sectionNames] objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Demo" forIndexPath:indexPath];
	
	NSString *className = [[self class] sectionNames][indexPath.section][indexPath.row];
	NSString *title = [className stringByReplacingOccurrencesOfString:@"TableViewController" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@"HRS" withString:@""];
	cell.textLabel.text = title;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *className = [[self class] sectionNames][indexPath.section][indexPath.row];
	UIViewController *controller = [NSClassFromString(className) new];
	[[self navigationController] pushViewController:controller animated:YES];
}

@end
