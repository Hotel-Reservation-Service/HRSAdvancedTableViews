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

#import "HRSIndexPathMapperNode.h"


@interface HRSIndexPathMapperNode ()

@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, strong, readwrite) NSPredicate *predicate;
@property (nonatomic, weak, readwrite) id evaluationObject;

@property (nonatomic, assign, readonly, getter=isLeaf) BOOL leaf;

@end


@implementation HRSIndexPathMapperNode

- (instancetype)initWithIndex:(NSUInteger)index {
	self = [super init];
	if (self) {
		_index = index;
		_children = [NSArray array];
	}
	return self;
}

- (BOOL)isLeaf {
	return (self.children.count == 0);
}



#pragma mark - configuration

- (void)setConditionForIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth predicate:(NSPredicate *)predicate evaluationObject:(id)object {
	NSParameterAssert(predicate);
	NSParameterAssert(object);
	if (predicate == nil || object == nil) {
		return;
	}
	
	NSUInteger objectIndex = [self.children indexOfObjectPassingTest:^BOOL(HRSIndexPathMapperNode *child, NSUInteger idx, BOOL *stop) {
		return (child.index == indexes[0]);
	}];
	
	HRSIndexPathMapperNode *child;
	if (objectIndex == NSNotFound) {
		child = [[HRSIndexPathMapperNode alloc] initWithIndex:indexes[0]];
		NSArray *children = [[self.children arrayByAddingObject:child] sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES] ]];
		self.children = children;
	} else {
		child = self.children[objectIndex];
	}
	if (depth > 1) {
		[child setConditionForIndexes:&indexes[1] depth:--depth predicate:predicate evaluationObject:object];
	} else {
		child.predicate = predicate;
		child.evaluationObject = object;
	}
}

- (void)removeConditionForIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth descendant:(BOOL)descendant {
	NSUInteger objectIndex = [self.children indexOfObjectPassingTest:^BOOL(HRSIndexPathMapperNode *child, NSUInteger idx, BOOL *stop) {
		return (child.index == indexes[0]);
	}];
	
	if (objectIndex == NSNotFound) {
		return;
	}
	
	HRSIndexPathMapperNode *child = self.children[objectIndex];
	if (depth > 1) {
		[child removeConditionForIndexes:indexes depth:--depth descendant:descendant];
	} else if (descendant || child.isLeaf) {
		NSMutableArray *children = [self.children mutableCopy];
		[children removeObjectAtIndex:objectIndex];
		self.children = [NSArray arrayWithArray:children];
	} else {
		child.predicate = nil;
		child.evaluationObject = nil;
	}
}



#pragma mark - mapping

- (void)dynamicIndexesForStaticIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth {
	NSUInteger staticIndex = indexes[0];
	__block NSUInteger dynamicIndex = staticIndex;
	
	__block HRSIndexPathMapperNode *nextNode;
	
	// TODO: We could introduce a short path for NSNotFound here if we are able to find the right node in O(1).
	[self.children enumerateObjectsUsingBlock:^(HRSIndexPathMapperNode *child, NSUInteger idx, BOOL *stop) {
		if (child.index < staticIndex) {
			BOOL visible = (child.predicate ? [child.predicate evaluateWithObject:child.evaluationObject] : YES);
			if (visible == NO) {
				dynamicIndex--;
			}
		} else if (child.index == staticIndex) {
			BOOL visible = (child.predicate ? [child.predicate evaluateWithObject:child.evaluationObject] : YES);
			if (visible == NO) {
				dynamicIndex = NSNotFound;
			}
			nextNode = child;
		} else {
			*stop = YES;
		}
	}];
	
	if (dynamicIndex == NSNotFound) {
		// set all children to NSNotFound
		for (int position = 0; position < depth; position++) {
			indexes[position] = NSNotFound;
		}
		
	} else {
		indexes[0] = dynamicIndex;
		// if this node has a child with the corresponding index, there might be
		// other conditions that need to be evaluated down the road!
		if (nextNode && nextNode.isLeaf == NO && depth > 1) {
			[nextNode dynamicIndexesForStaticIndexes:&indexes[1] depth:--depth];
		}
	}
}

- (void)staticIndexesForDynamicIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth {
	NSUInteger dynamicIndex = indexes[0];
	
	__block NSUInteger staticIndex = dynamicIndex;
	__block NSUInteger childIndex = NSNotFound;
	
	[self.children enumerateObjectsUsingBlock:^(HRSIndexPathMapperNode *child, NSUInteger idx, BOOL *stop) {
		if (child.index <= staticIndex) {
			BOOL visible = (child.predicate ? [child.predicate evaluateWithObject:child.evaluationObject] : YES);
			if (visible == NO) {
				staticIndex++;
			} else if (child.index == staticIndex) {
				childIndex = idx;
			}
		} else {
			*stop = YES;
		}
	}];
	
	indexes[0] = staticIndex;
	
	if (childIndex != NSNotFound && depth > 1) {
		HRSIndexPathMapperNode *child = self.children[childIndex];
		[child staticIndexesForDynamicIndexes:&indexes[1] depth:--depth];
	}
}



#pragma mark - DEPRECATED

- (instancetype)initWithIndex:(NSUInteger)index condition:(BOOL(^)(void))condition {
	self = [super init];
	if (self) {
		_index = index;
		_children = [NSArray array];
		
		if (condition != NULL) {
			_predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
				return condition();
			}];
		}
	}
	return self;
}

- (void)setConditionForIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth condition:(BOOL(^)(void))condition {
	NSPredicate *predicate;
	if (condition == NULL) {
		predicate = [NSPredicate predicateWithValue:YES];
	} else {
		predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
			return condition();
		}];
	}
	[self setConditionForIndexes:indexes depth:depth predicate:predicate evaluationObject:self];
}

@end

