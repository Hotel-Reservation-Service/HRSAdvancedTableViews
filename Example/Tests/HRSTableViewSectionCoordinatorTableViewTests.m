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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <HRSAdvancedTableViews/HRSSectionController.h>
#import <HRSAdvancedTableViews/HRSTableViewSectionCoordinator+IndexPathMapping.h>


@interface HRSTableViewSectionCoordinator (Tests)

- (UITableView *)tableView;
- (id<HRSTableViewSectionController>)_sectionControllerForTableSection:(NSInteger)section beforeTransition:(BOOL)beforeTransition;

@end


@interface HRSTableViewSectionCoordinatorTableViewTests : XCTestCase

@property (nonatomic, strong, readwrite) HRSTableViewSectionCoordinator *sut;

@end


@implementation HRSTableViewSectionCoordinatorTableViewTests

- (void)setUp {
	[super setUp];
	
	self.sut = [HRSTableViewSectionCoordinator new];
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

- (void)testSetTableViewRemovesOldLinksToCoordinator {
	UITableView *tableView = [UITableView new];
	HRSTableViewSectionCoordinator *oldCoordinator = [HRSTableViewSectionCoordinator new];
	[oldCoordinator setTableView:tableView];
	
	[self.sut setTableView:tableView];
	
	expect([oldCoordinator tableView]).to.beNil();
}

- (void)testNumberOfSectionsMatchesNumberOfController {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	[self.sut setSectionController:sectionController animated:NO];
	
	UITableView *tableView = [UITableView new];
	[self.sut setTableView:tableView];
	
	expect([self.sut numberOfSectionsInTableView:tableView]).to.equal(2);
}

- (void)testCoordinatorDoesForwardToCorrectSectionController {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	[self.sut setSectionController:sectionController animated:NO];
	
	NSIndexPath *tableViewIndexPath = [NSIndexPath indexPathForRow:4 inSection:1];
	id<HRSTableViewSectionController> controller = [self.sut _sectionControllerForTableSection:tableViewIndexPath.section beforeTransition:NO];
	expect(controller).to.beIdenticalTo([sectionController lastObject]);
}

- (void)testCoordinatorDoesForwardToCorrectTableViewIndexPath {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	[self.sut setSectionController:sectionController animated:NO];
	
	UITableView *tableView = [UITableView new];
	
	NSIndexPath *expectedIndexPath = [NSIndexPath indexPathForRow:3 inSection:1];
	id tableViewMock = OCMPartialMock(tableView);
	[[tableViewMock expect] cellForRowAtIndexPath:expectedIndexPath];
	
	[self.sut setTableView:tableViewMock];
	
	UITableView *tableViewProxy = [self.sut tableViewForSectionController:[sectionController lastObject]];
	[tableViewProxy cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

// TODO: Add testing for return value mapping
// TODO: Add reverse testing (delegate & data source)

- (void)testCoordinatorDoesForwardToCorrectTableViewSection {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	[self.sut setSectionController:sectionController animated:NO];
	
	UITableView *tableView = [UITableView new];
	
	NSInteger expectedSection = 1;
	id tableViewMock = OCMPartialMock(tableView);
	[[tableViewMock expect] numberOfRowsInSection:expectedSection];
	
	[self.sut setTableView:tableViewMock];
	
	UITableView *tableViewProxy = [self.sut tableViewForSectionController:[sectionController lastObject]];
	[tableViewProxy numberOfRowsInSection:0];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

- (void)testSetTableViewTriggersReloadData {
	UITableView *tableView = [UITableView new];
	id tableViewMock = OCMPartialMock(tableView);
	[[tableViewMock expect] reloadData];
	
	[self.sut setTableView:tableViewMock];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

- (void)testSetSectionControllerWithoutAnimationTriggersReloadData {
	UITableView *tableView = [UITableView new];
	id tableViewMock = OCMPartialMock(tableView);
	
	[self.sut setTableView:tableViewMock];
	
	[[tableViewMock expect] reloadData];
	
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	[self.sut setSectionController:sectionController animated:NO];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

- (void)testSetSectionControllerWithAnimationDoesNotTriggerReloadData {
	UITableView *tableView = [UITableView new];
	id tableViewMock = OCMPartialMock(tableView);
	
	[self.sut setTableView:tableViewMock];
	
	[[tableViewMock reject] reloadData];
	
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	[self.sut setSectionController:sectionController animated:YES];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}



#pragma mark - controller animations

- (NSArray *)sectionControllerPool:(NSUInteger)count {
	NSMutableArray *array = [NSMutableArray array];
	for (NSUInteger idx = 0; idx < count; idx++) {
		[array addObject:[HRSTableViewSectionController new]];
	}
	return [array copy];
}

- (void)testSimpleInsertAnimation {
	NSArray *pool = [self sectionControllerPool:6];
	
	UITableView *tableView = [UITableView new];
	id tableViewMock = OCMPartialMock(tableView);
	self.sut.tableView = tableViewMock;
	
	NSArray *oldController = [pool subarrayWithRange:NSMakeRange(0, 5)];
	[self.sut setSectionController:oldController];
	
	NSArray *newController = pool;
	
	[[[tableViewMock expect] andForwardToRealObject] insertSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self.sut setSectionController:newController animated:YES];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

- (void)testSimpleRemoveAnimation {
	NSArray *pool = [self sectionControllerPool:6];
	
	UITableView *tableView = [UITableView new];
	id tableViewMock = OCMPartialMock(tableView);
	self.sut.tableView = tableViewMock;
	
	NSArray *oldController = pool;
	[self.sut setSectionController:oldController];
	
	NSArray *newController = [pool subarrayWithRange:NSMakeRange(0, 5)];
	
	[[[tableViewMock expect] andForwardToRealObject] deleteSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self.sut setSectionController:newController animated:YES];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

- (void)testInsertRemoveAnimation {
	NSArray *pool = [self sectionControllerPool:6];
	
	UITableView *tableView = [UITableView new];
	id tableViewMock = OCMPartialMock(tableView);
	self.sut.tableView = tableViewMock;
	
	NSArray *oldController = @[ pool[0], pool[1], pool[2], pool[3] ];
	[self.sut setSectionController:oldController];
	
	NSArray *newController = @[ pool[0], pool[4], pool[5], pool[2], pool[3] ];
	
	[[[tableViewMock expect] andForwardToRealObject] deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
	[[[tableViewMock expect] andForwardToRealObject] insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self.sut setSectionController:newController animated:YES];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

- (void)testCompleteReplacement {
	UITableView *tableView = [UITableView new];
	id tableViewMock = OCMPartialMock(tableView);
	self.sut.tableView = tableView;
	
	NSArray *oldController = [self sectionControllerPool:5];
	[self.sut setSectionController:oldController];
	
	NSArray *newController = [self sectionControllerPool:3];
	
	[[[tableViewMock expect] andForwardToRealObject] deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldController.count)] withRowAnimation:UITableViewRowAnimationAutomatic];
	[[[tableViewMock expect] andForwardToRealObject] insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newController.count)] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self.sut setSectionController:newController animated:YES];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

- (void)testInsertAtStartAnimation {
	NSArray *pool = [self sectionControllerPool:5];
	
	UITableView *tableView = [UITableView new];
	id tableViewMock = OCMPartialMock(tableView);
	self.sut.tableView = tableViewMock;
	
	NSArray *oldController = @[ pool[0], pool[1], pool[2], pool[3] ];
	[self.sut setSectionController:oldController];
	
	NSArray *newController = @[ pool[4], pool[0], pool[1], pool[2], pool[3] ];
	
	[[[tableViewMock expect] andForwardToRealObject] insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self.sut setSectionController:newController animated:YES];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

- (void)testInsertAtEndAnimation {
	NSArray *pool = [self sectionControllerPool:5];
	
	UITableView *tableView = [UITableView new];
	id tableViewMock = OCMPartialMock(tableView);
	self.sut.tableView = tableViewMock;
	
	NSArray *oldController = @[ pool[0], pool[1], pool[2], pool[3] ];
	[self.sut setSectionController:oldController];
	
	NSArray *newController = @[ pool[0], pool[1], pool[2], pool[3], pool[4] ];
	
	[[[tableViewMock expect] andForwardToRealObject] insertSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self.sut setSectionController:newController animated:YES];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

- (void)testDeleteAtStartAnimation {
	NSArray *pool = [self sectionControllerPool:5];
	
	UITableView *tableView = [UITableView new];
	id tableViewMock = OCMPartialMock(tableView);
	self.sut.tableView = tableViewMock;
	
	NSArray *oldController = @[ pool[4], pool[0], pool[1], pool[2], pool[3] ];
	[self.sut setSectionController:oldController];
	
	NSArray *newController = @[ pool[0], pool[1], pool[2], pool[3] ];
	
	[[[tableViewMock expect] andForwardToRealObject] deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self.sut setSectionController:newController animated:YES];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

- (void)testDeleteAtEndAnimation {
	NSArray *pool = [self sectionControllerPool:5];
	
	UITableView *tableView = [UITableView new];
	id tableViewMock = OCMPartialMock(tableView);
	self.sut.tableView = tableViewMock;
	
	NSArray *oldController = @[ pool[0], pool[1], pool[2], pool[3], pool[4] ];
	[self.sut setSectionController:oldController];
	
	NSArray *newController = @[ pool[0], pool[1], pool[2], pool[3] ];
	
	[[[tableViewMock expect] andForwardToRealObject] deleteSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self.sut setSectionController:newController animated:YES];
	
	[tableViewMock verify];
	[tableViewMock stopMocking];
}

@end
