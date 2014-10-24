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

#import "HRSIndexPathMapper+TableView.h"

@implementation HRSIndexPathMapper (TableView)


#pragma mark - section conditions

- (void)setConditionForSection:(NSInteger)section condition:(BOOL(^)(void))condition {
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:section];
	[self setConditionForIndexPath:indexPath condition:condition];
}

- (void)setConditionForSection:(NSInteger)section predicate:(NSPredicate *)predicate evaluationObject:(id)object {
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:section];
	[self setConditionForIndexPath:indexPath predicate:predicate evaluationObject:object];
}

- (void)removeConditionForSection:(NSInteger)section includingRows:(BOOL)rows {
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:section];
	[self removeConditionForIndexPath:indexPath descendant:rows];
}



#pragma mark - row conditions

- (void)setConditionForRow:(NSInteger)row inSection:(NSInteger)section condition:(BOOL(^)(void))condition {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
	[self setConditionForIndexPath:indexPath condition:condition];
}

- (void)setConditionForRow:(NSInteger)row inSection:(NSInteger)section predicate:(NSPredicate *)predicate evaluationObject:(id)object {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
	[self setConditionForIndexPath:indexPath predicate:predicate evaluationObject:object];
}

- (void)removeConditionForRow:(NSInteger)row inSection:(NSInteger)section {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
	[self removeConditionForIndexPath:indexPath descendant:YES];
}



#pragma mark - evaluation

- (NSInteger)dynamicSectionForStaticSection:(NSInteger)section {
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:section];
	NSIndexPath *dynamicIndexPath = [self dynamicIndexPathForStaticIndexPath:indexPath];
	return [dynamicIndexPath section];
}

- (NSInteger)staticSectionForDynamicSection:(NSInteger)section {
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:section];
	NSIndexPath *staticIndexPath = [self staticIndexPathForDynamicIndexPath:indexPath];
	return [staticIndexPath section];
}

@end
