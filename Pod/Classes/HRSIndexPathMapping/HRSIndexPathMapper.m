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

#import "HRSIndexPathMapper.h"

#import "HRSIndexPathMapperNode.h"


@interface HRSIndexPathMapper ()

@property (nonatomic, strong, readwrite) HRSIndexPathMapperNode *root;

@end


@implementation HRSIndexPathMapper

- (instancetype)init {
	self = [super init];
	if (self) {
		_root = [[HRSIndexPathMapperNode alloc] initWithIndex:0 condition:NULL];
	}
	return self;
}



#pragma mark - configuration

- (void)setConditionForIndexPath:(NSIndexPath *)indexPath condition:(BOOL(^)(void))condition {
	NSUInteger indexes[indexPath.length];
	[indexPath getIndexes:indexes];
	
	[self.root setConditionForIndexes:indexes depth:indexPath.length condition:condition];
}

- (void)removeConditionForIndexPath:(NSIndexPath *)indexPath descendant:(BOOL)descendant {
	NSUInteger indexes[indexPath.length];
	[indexPath getIndexes:indexes];
	
	[self.root removeConditionForIndexes:indexes depth:indexPath.length descendant:descendant];
}



#pragma mark - mapping

- (NSIndexPath *)dynamicIndexPathForStaticIndexPath:(NSIndexPath *)indexPath {
	NSUInteger indexes[indexPath.length];
	[indexPath getIndexes:indexes];
	
	[self.root dynamicIndexesForStaticIndexes:indexes depth:indexPath.length];
	
	NSIndexPath *dynamicIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:indexPath.length];
	return dynamicIndexPath;
}

- (NSIndexPath *)staticIndexPathForDynamicIndexPath:(NSIndexPath *)indexPath {
	NSUInteger indexes[indexPath.length];
	[indexPath getIndexes:indexes];
	
	[self.root staticIndexesForDynamicIndexes:indexes depth:indexPath.length];
	
	NSIndexPath *staticIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:indexPath.length];
	return staticIndexPath;
}

@end
