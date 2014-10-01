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

#import "HRSSimpleIndexPathMappingTableViewController.h"

#import <HRSAdvancedTableViews/HRSIndexPathMapping.h>


typedef NS_ENUM(NSUInteger, Section) {
	SectionOne,
	SectionTwo,
	SectionThree,
	
	SectionCount
};


@interface HRSSimpleIndexPathMappingTableViewController ()

@property (nonatomic, strong, readwrite) NSMutableIndexSet *visibleSections;

@property (nonatomic, weak, readwrite) UISwitch *sectionOneToggle;
@property (nonatomic, weak, readwrite) UISwitch *sectionTwoToggle;
@property (nonatomic, weak, readwrite) UISwitch *sectionThreeToggle;

@property (nonatomic, strong, readwrite) HRSIndexPathMapper *mapper;

@end


@implementation HRSSimpleIndexPathMappingTableViewController

- (instancetype)init {
	self = [super init];
	if (self) {
		__weak typeof(self) weakSelf = self;
		HRSIndexPathMapper *mapper = [HRSIndexPathMapper new];
		[mapper setConditionForSection:SectionOne condition:^BOOL{
			typeof(self) self = weakSelf;
			return [self.visibleSections containsIndex:SectionOne];
		}];
		[mapper setConditionForSection:SectionTwo condition:^BOOL{
			typeof(self) self = weakSelf;
			return [self.visibleSections containsIndex:SectionTwo];
		}];
		[mapper setConditionForSection:SectionThree condition:^BOOL{
			typeof(self) self = weakSelf;
			return [self.visibleSections containsIndex:SectionThree];
		}];
		_mapper = mapper;
		
		_visibleSections = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, SectionCount)];
		
		UISwitch *switchOne = [UISwitch new];
		switchOne.on = [self.visibleSections containsIndex:SectionOne];
		[switchOne addTarget:self action:@selector(updateSectionOne:) forControlEvents:UIControlEventValueChanged];
		self.sectionOneToggle = switchOne;
		
		UISwitch *switchTwo = [UISwitch new];
		switchTwo.on = [self.visibleSections containsIndex:SectionTwo];
		[switchTwo addTarget:self action:@selector(updateSectionTwo:) forControlEvents:UIControlEventValueChanged];
		self.sectionTwoToggle = switchTwo;
		
		UISwitch *switchThree = [UISwitch new];
		switchThree.on = [self.visibleSections containsIndex:SectionThree];
		[switchThree addTarget:self action:@selector(updateSectionThree:) forControlEvents:UIControlEventValueChanged];
		self.sectionThreeToggle = switchThree;
		
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
    
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Demo"];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self mapper] dynamicSectionForStaticSection:SectionCount];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	Section staticSection = [[self mapper] staticSectionForDynamicSection:section];
	switch (staticSection) {
		case SectionOne:
			return @"Section One";
			break;
		case SectionTwo:
			return @"Section Two";
			break;
		case SectionThree:
			return @"Section Three";
			break;
			
		case SectionCount:
			return nil;
			break;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Demo" forIndexPath:indexPath];
    
	NSIndexPath *staticIndexPath = [[self mapper] staticIndexPathForDynamicIndexPath:indexPath];
	
	cell.textLabel.text = [NSString stringWithFormat:@"section %d, row %d", (int)staticIndexPath.section, (int)staticIndexPath.row];
    
    return cell;
}



#pragma mark - section animation

- (void)toggleSection:(NSUInteger)section {
	BOOL becomeVisible = ([self.visibleSections containsIndex:section] == NO);
	if (becomeVisible) {
		[self.visibleSections addIndex:section];
		NSUInteger dynamicSection = [[self mapper] dynamicSectionForStaticSection:section];
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:dynamicSection];
		[self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
	} else {
		NSUInteger dynamicSection = [[self mapper] dynamicSectionForStaticSection:section];
		[self.visibleSections removeIndex:section];
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:dynamicSection];
		[self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (IBAction)updateSectionOne:(id)sender {
	[self toggleSection:SectionOne];
}

- (IBAction)updateSectionTwo:(id)sender {
	[self toggleSection:SectionTwo];
}

- (IBAction)updateSectionThree:(id)sender {
	[self toggleSection:SectionThree];
}

@end
