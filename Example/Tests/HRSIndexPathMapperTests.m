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


@interface HRSIndexPathMapperTests : XCTestCase

@property (nonatomic, strong, readwrite) HRSIndexPathMapper *sut;

@end


@implementation HRSIndexPathMapperTests

- (void)setUp {
    [super setUp];
	
	self.sut = [HRSIndexPathMapper new];
}

- (void)tearDown {
	self.sut = nil;
	
    [super tearDown];
}



#pragma mark - black box tests

- (void)testMappingFromStaticToDynamicIndexPath {
	[self.sut setConditionForIndexPath:[NSIndexPath indexPathWithIndex:1] condition:^BOOL{
		return NO;
	}];
	
	NSIndexPath *untouched = [NSIndexPath indexPathWithIndex:0];
	NSIndexPath *untouchedMapped = [self.sut dynamicIndexPathForStaticIndexPath:untouched];
	expect(untouchedMapped).to.equal(untouched);
	
	NSIndexPath *notFound = [NSIndexPath indexPathWithIndex:1];
	NSIndexPath *notFoundMapped = [self.sut dynamicIndexPathForStaticIndexPath:notFound];
	expect([notFoundMapped indexAtPosition:0]).to.equal(NSNotFound);
	
	NSIndexPath *moved = [NSIndexPath indexPathWithIndex:2];
	NSIndexPath *movedMapped = [self.sut dynamicIndexPathForStaticIndexPath:moved];
	expect([movedMapped indexAtPosition:0]).to.equal(1);
}

- (void)testMappingFromDynamicToStaticIndexPath {
	[self.sut setConditionForIndexPath:[NSIndexPath indexPathWithIndex:1] condition:^BOOL{
		return NO;
	}];
	
	NSIndexPath *untouched = [NSIndexPath indexPathWithIndex:0];
	NSIndexPath *untouchedStatic = [self.sut staticIndexPathForDynamicIndexPath:untouched];
	expect(untouchedStatic).to.equal(untouched);
	
	NSIndexPath *moved = [NSIndexPath indexPathWithIndex:1];
	NSIndexPath *movedStatic = [self.sut staticIndexPathForDynamicIndexPath:moved];
	expect([movedStatic indexAtPosition:0]).to.equal(2);
}

- (void)testRemovingGenericConditionRemovesDescendants {
	NSUInteger indexes[] = { 1, 1 };
	[self.sut setConditionForIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2] condition:^BOOL{
		return NO;
	}];
	
	NSIndexPath *notFound = [NSIndexPath indexPathWithIndexes:indexes length:2];
	NSIndexPath *notFoundMapped = [self.sut dynamicIndexPathForStaticIndexPath:notFound];
	expect([notFoundMapped indexAtPosition:1]).to.equal(NSNotFound);
	
	[self.sut removeConditionForIndexPath:[NSIndexPath indexPathWithIndex:indexes[0]] descendant:NO];
	NSIndexPath *notFoundMappedAgain = [self.sut dynamicIndexPathForStaticIndexPath:notFound];
	expect([notFoundMappedAgain indexAtPosition:0]).to.equal(1);
	expect([notFoundMappedAgain indexAtPosition:1]).to.equal(NSNotFound);
	
	[self.sut removeConditionForIndexPath:[NSIndexPath indexPathWithIndex:indexes[0]] descendant:YES];
	NSIndexPath *notFoundMappedRestored = [self.sut dynamicIndexPathForStaticIndexPath:notFound];
	expect([notFoundMappedRestored indexAtPosition:0]).to.equal(1);
	expect([notFoundMappedRestored indexAtPosition:1]).to.equal(1);
}

- (void)testDynamicMatchingForDescendants {
	[self.sut setConditionForIndexPath:[NSIndexPath indexPathWithIndex:1] condition:^BOOL{
		return NO;
	}];
	
	NSUInteger indexes[] = { 1, 0 };
	
	NSIndexPath *notFound = [NSIndexPath indexPathWithIndexes:indexes length:2];
	NSIndexPath *notFoundMapped = [self.sut dynamicIndexPathForStaticIndexPath:notFound];
	expect([notFoundMapped indexAtPosition:0]).to.equal(NSNotFound);
	expect([notFoundMapped indexAtPosition:1]).to.equal(NSNotFound);
}

@end
