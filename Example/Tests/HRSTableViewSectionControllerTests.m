//
//  HRSTableViewSectionControllerTests.m
//  HRSAdvancedTableViews
//
//  Created by Michael Ochs on 12/05/15.
//  Copyright (c) 2015 Michael Ochs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <HRSAdvancedTableViews/HRSSectionController.h>


@interface HRSTableViewSectionControllerRemovalTest : HRSTableViewSectionController
@property (nonatomic, assign, readwrite) NSInteger didEndDisplayingCellHitCount;
@end

@implementation HRSTableViewSectionControllerRemovalTest

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.didEndDisplayingCellHitCount++;
}

- (void)resetHitCount {
    self.didEndDisplayingCellHitCount = 0;
}

@end


@interface HRSTableViewSectionControllerTests : XCTestCase

@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong, readwrite) HRSTableViewSectionCoordinator *sut;

@end


@implementation HRSTableViewSectionControllerTests

- (void)setUp {
    [super setUp];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0) style:UITableViewStylePlain];
    
    HRSTableViewSectionCoordinator *sut = [HRSTableViewSectionCoordinator new];
    [sut setTableView:tableView];
    self.sut = sut;
    
    self.tableView = tableView;
}

- (void)tearDown {
    self.tableView = nil;
    self.sut = nil;
    
    [super tearDown];
}

/**
 This tests the issue #16, which leads to a crash as the table view sends 
 didEndDisplayingCell:forRowAtIndexPath: to a section controller that is not
 in the list of section controllers anymore.
 @see https://github.com/Hotel-Reservation-Service/HRSAdvancedTableViews/issues/16
 */
- (void)testDidEndDisplayingNotCrashing {
    HRSTableViewSectionControllerRemovalTest *controllerOne = [HRSTableViewSectionControllerRemovalTest new];
    HRSTableViewSectionControllerRemovalTest *controllerTwo = [HRSTableViewSectionControllerRemovalTest new];
    self.sut.sectionController = @[ controllerOne, controllerTwo ];
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    
    self.sut.sectionController = @[ controllerOne ];
    [self.tableView reloadData];
}

- (void)testDidEndDisplayingCallingTheRightSectionController {
    HRSTableViewSectionControllerRemovalTest *controllerOne = [HRSTableViewSectionControllerRemovalTest new];
    HRSTableViewSectionControllerRemovalTest *controllerTwo = [HRSTableViewSectionControllerRemovalTest new];
    self.sut.sectionController = @[ controllerOne, controllerTwo ];
    [self.tableView layoutIfNeeded];
    
    [controllerOne resetHitCount];
    [controllerTwo resetHitCount];
    self.sut.sectionController = @[ controllerOne ];
    [self.tableView layoutIfNeeded];
    expect(controllerTwo.didEndDisplayingCellHitCount).to.beGreaterThan(0);

    self.sut.sectionController = @[ controllerOne, controllerTwo ];
    [self.tableView layoutIfNeeded];
    
    [controllerOne resetHitCount];
    [controllerTwo resetHitCount];
    self.sut.sectionController = @[ controllerTwo ];
    [self.tableView layoutIfNeeded];
    expect(controllerOne.didEndDisplayingCellHitCount).to.beGreaterThan(0);
}

@end
