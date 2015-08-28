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
#import <OCMock/OCMock.h>

#import <HRSAdvancedTableViews/HRSSectionController.h>
#import <HRSAdvancedTableViews/HRSTableViewSectionCoordinator+IndexPathMapping.h>


@interface HRSTableViewSectionCoordinatorTests : XCTestCase

@property (nonatomic, strong, readwrite) HRSTableViewSectionCoordinator *sut;

@end


@implementation HRSTableViewSectionCoordinatorTests

- (void)setUp {
    [super setUp];
	
	self.sut = [HRSTableViewSectionCoordinator new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSectionControllerNextResponderIsTableView {
	UITableView *tableView = [UITableView new];
	[self.sut setTableView:tableView];
	
	expect([self.sut nextResponder]).to.beIdenticalTo(tableView);
}

- (void)testSetSectionControllerCallsSetSectionControllerAnimated {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	
	id sutMock = OCMPartialMock(self.sut);
	[[sutMock expect] setSectionController:sectionController animated:NO];
	
	[sutMock setSectionController:sectionController];
	
	[sutMock verify];
	[sutMock stopMocking];
}

- (void)testSetSectionControllerAnimatedModifiesIvar {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	
	[self.sut setSectionController:sectionController animated:NO];
	
	expect(self.sut.sectionController).to.equal(sectionController);
}

- (void)testSetSectionControllerAnimatedHasCopyBehavior {
	NSMutableArray *sectionController = [@[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ] mutableCopy];
	
	[self.sut setSectionController:sectionController animated:NO];
	
	expect(self.sut.sectionController).to.equal(sectionController);
	expect(self.sut.sectionController).toNot.beIdenticalTo(sectionController);
}

- (void)testSetSectionControllerSetsUpBackReference {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	
	[self.sut setSectionController:sectionController animated:NO];
	
	for (HRSTableViewSectionController *controller in sectionController) {
		expect(controller.coordinator).to.beIdenticalTo(self.sut);
	}
}

- (void)testSetSectionControllerRemovesOldBackReference {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	
	[self.sut setSectionController:sectionController animated:NO];
	
	[self.sut setSectionController:nil animated:NO];
	
	for (HRSTableViewSectionController *controller in sectionController) {
		expect(controller.coordinator).to.beNil();
	}
}

- (void)testSetSameSectionControllerTwiceTriggersException {
	HRSTableViewSectionController *sectionController = [HRSTableViewSectionController new];
	NSArray *sectionControllers = @[ sectionController, sectionController ];
	
	XCTAssertThrows([self.sut setSectionController:sectionControllers animated:NO], @"Using the same section controller twice should trigger an exception.");
}

- (void)testTableViewForSectionControllerToNotReturnRealTableView {
	UITableView *tableView = [UITableView new];
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	[self.sut setSectionController:sectionController animated:NO];
	
	[self.sut setTableView:tableView];
	
	UITableView *sectionTableView = [self.sut tableViewForSectionController:[sectionController firstObject]];
	
	expect(sectionTableView).toNot.beIdenticalTo(tableView);
	expect(sectionTableView).toNot.beNil();
}

- (void)testControllerIndexPathForTableViewIndexInControllerRange {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	[self.sut setSectionController:sectionController animated:NO];
	
	NSIndexPath *tableIndexPath = [NSIndexPath indexPathForRow:5 inSection:1];
	NSIndexPath *controllerIndexPath = [self.sut controllerIndexPathForTableViewIndexPath:tableIndexPath withController:[sectionController lastObject]];
	
	expect(controllerIndexPath).toNot.beNil();
	expect(controllerIndexPath.row).to.equal(tableIndexPath.row);
	expect(controllerIndexPath.section).to.equal(0);
}

- (void)testControllerIndexPathForTableViewIndexOutOfControllerRange {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	[self.sut setSectionController:sectionController animated:NO];
	
	NSIndexPath *tableIndexPath = [NSIndexPath indexPathForRow:5 inSection:1];
	NSIndexPath *controllerIndexPath = [self.sut controllerIndexPathForTableViewIndexPath:tableIndexPath withController:[sectionController lastObject]];
	
	expect(controllerIndexPath).toNot.beNil();
	expect(controllerIndexPath.row).to.equal(tableIndexPath.row);
	expect(controllerIndexPath.section).to.equal(-1);
}

- (void)testTableViewIndexPathForControllerIndexInControllerRange {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	[self.sut setSectionController:sectionController animated:NO];
	
	NSIndexPath *controllerIndexPath = [NSIndexPath indexPathForRow:5 inSection:0];
	NSIndexPath *tableIndexPath = [self.sut tableViewIndexPathForControllerIndexPath:controllerIndexPath withController:[sectionController lastObject]];
	
	expect(tableIndexPath).toNot.beNil();
	expect(tableIndexPath.row).to.equal(tableIndexPath.row);
	expect(tableIndexPath.section).to.equal(1);
}

- (void)testTableViewIndexPathForControllerIndexOutOfControllerRange {
	NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
	[self.sut setSectionController:sectionController animated:NO];
	
	NSIndexPath *controllerIndexPath = [NSIndexPath indexPathForRow:5 inSection:-1];
	NSIndexPath *tableIndexPath = [self.sut tableViewIndexPathForControllerIndexPath:controllerIndexPath withController:[sectionController lastObject]];
	
	expect(tableIndexPath).toNot.beNil();
	expect(tableIndexPath.row).to.equal(tableIndexPath.row);
	expect(tableIndexPath.section).to.equal(1);
}

/**
 This was a bug that occured, when a section controller that already was
 attached to the coordinator was set a second time inside `setSectionController:`
 or `setSectionController:animated:`. In this case, the section controller that
 has been attached before, didn't had a coordinator attached to it afterwards.
 */
- (void)testSectionControllerHasCoordinatorAfterResetIt {
	NSArray *sectionController = @[ [HRSTableViewSectionController new] ];
	
	[self.sut setSectionController:sectionController];
	
	expect([sectionController.firstObject coordinator]).to.equal(self.sut);
	
	[self.sut setSectionController:sectionController];
	
	expect([sectionController.firstObject coordinator]).to.equal(self.sut);
}

- (void)testSectionCoordinatorForwardsTraitCollections {
    NSArray *sectionController = @[ [HRSTableViewSectionController new], [HRSTableViewSectionController new], [HRSTableViewSectionController new] ];
    [self.sut setSectionController:sectionController animated:NO];
    
    UITraitCollection *traitCollection = [UITraitCollection traitCollectionWithUserInterfaceIdiom:UIUserInterfaceIdiomPad];
    [self.sut updateTraitCollection:traitCollection];
    
    for (HRSTableViewSectionController *controller in self.sut.sectionController) {
        expect(controller.traitCollection).to.equal(traitCollection);
    }
}

- (void)testSectionCoordinatorUpdateTraitCollectionCallsTraitCollectionDidChange {
    UITraitCollection *traitCollection = [UITraitCollection traitCollectionWithUserInterfaceIdiom:UIUserInterfaceIdiomPad];
    
    id mockedSut = OCMPartialMock(self.sut);
    [[mockedSut expect] traitCollectionDidChange:OCMOCK_ANY];
    
    [mockedSut updateTraitCollection:traitCollection];
    
    [mockedSut verify];
    [mockedSut stopMocking];
}

@end
