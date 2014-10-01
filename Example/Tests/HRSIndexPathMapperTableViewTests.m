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

#import <HRSAdvancedTableViews/HRSIndexPathMapping.h>


@interface HRSIndexPathMapperTableViewTests : XCTestCase

@property (nonatomic, strong, readwrite) HRSIndexPathMapper *sut;

@end


@implementation HRSIndexPathMapperTableViewTests

- (void)setUp {
	[super setUp];
	
	self.sut = [HRSIndexPathMapper new];
}

- (void)tearDown {
	self.sut = nil;
	
	[super tearDown];
}



#pragma mark - table view tests

- (void)testHideCompleteSectionWithRowCheck {
	[self.sut setConditionForSection:1 condition:^BOOL{
		return NO;
	}];
	
	NSIndexPath *untouched = [NSIndexPath indexPathForRow:0 inSection:0];
	NSIndexPath *untouchedMapped = [self.sut dynamicIndexPathForStaticIndexPath:untouched];
	expect(untouchedMapped).to.equal(untouched);
	
	NSIndexPath *notFound = [NSIndexPath indexPathForRow:0 inSection:1];
	NSIndexPath *notFoundMapped = [self.sut dynamicIndexPathForStaticIndexPath:notFound];
	expect(notFoundMapped.section).to.equal(NSNotFound);
	
	NSIndexPath *moved = [NSIndexPath indexPathForRow:5 inSection:2];
	NSIndexPath *movedMapped = [self.sut dynamicIndexPathForStaticIndexPath:moved];
	expect(movedMapped.section).to.equal(1);
}

- (void)testHideCompleteSectionWithSectionCheck {
	[self.sut setConditionForSection:1 condition:^BOOL{
		return NO;
	}];
	
	NSUInteger untouchedMapped = [self.sut dynamicSectionForStaticSection:0];
	expect(untouchedMapped).to.equal(0);
	
	NSUInteger notFoundMapped = [self.sut dynamicSectionForStaticSection:1];
	expect(notFoundMapped).to.equal(NSNotFound);
	
	NSUInteger movedMapped = [self.sut dynamicSectionForStaticSection:2];
	expect(movedMapped).to.equal(1);
}

- (void)testHideSingleRowAndCheckSection {
	[self.sut setConditionForRow:3 inSection:1 condition:^BOOL{
		return NO;
	}];
	
	NSIndexPath *untouched = [NSIndexPath indexPathForRow:0 inSection:0];
	NSIndexPath *untouchedMapped = [self.sut dynamicIndexPathForStaticIndexPath:untouched];
	expect(untouchedMapped).to.equal(untouched);
	
	NSIndexPath *notFound = [NSIndexPath indexPathForRow:0 inSection:1];
	NSIndexPath *notFoundMapped = [self.sut dynamicIndexPathForStaticIndexPath:notFound];
	expect(notFoundMapped.section).to.equal(1);
	expect(notFoundMapped.row).to.equal(0);
	
	NSIndexPath *moved = [NSIndexPath indexPathForRow:5 inSection:2];
	NSIndexPath *movedMapped = [self.sut dynamicIndexPathForStaticIndexPath:moved];
	expect(movedMapped.section).to.equal(2);
	expect(movedMapped.row).to.equal(5);
}

- (void)testHideSingleRowAndCheckRow {
	[self.sut setConditionForRow:3 inSection:1 condition:^BOOL{
		return NO;
	}];
	
	NSIndexPath *untouched = [NSIndexPath indexPathForRow:2 inSection:1];
	NSIndexPath *untouchedMapped = [self.sut dynamicIndexPathForStaticIndexPath:untouched];
	expect(untouchedMapped).to.equal(untouched);
	
	NSIndexPath *notFound = [NSIndexPath indexPathForRow:3 inSection:1];
	NSIndexPath *notFoundMapped = [self.sut dynamicIndexPathForStaticIndexPath:notFound];
	expect(notFoundMapped.section).to.equal(1);
	expect(notFoundMapped.row).to.equal(NSNotFound);
	
	NSIndexPath *moved = [NSIndexPath indexPathForRow:5 inSection:1];
	NSIndexPath *movedMapped = [self.sut dynamicIndexPathForStaticIndexPath:moved];
	expect(movedMapped.section).to.equal(1);
	expect(movedMapped.row).to.equal(4);
}

@end
