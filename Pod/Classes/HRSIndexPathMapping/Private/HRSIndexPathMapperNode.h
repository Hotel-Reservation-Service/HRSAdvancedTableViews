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

#import <Foundation/Foundation.h>

/**
 A `HRSIndexPathMapperNode` represents a node in a tree of index paths that
 contains a condition and/or child nodes for a specific index in that index path.
 
 If a node does not have a child, it always has a condition, otherwise it is
 automatically removed by its parent.
 
 @note A mapper node evaluates the conditions of its children, not the condition
       of itself! This approach ensures we always have a single root node for
       all conditions that are attached to a mapper that can never be deleted
       and is never be evaluated by itself.
 */
@interface HRSIndexPathMapperNode : NSObject

/**
 The index the node represents.
 
 This index does not carry any information about the hierarchical position of
 this node.
 */
@property (nonatomic, assign, readonly) NSUInteger index;

/**
 The children of the node that either contain conditions or more children.
 
 This array contains `HRSIndexPatchMapperNode` objects.
 */
@property (nonatomic, strong, readwrite) NSArray /* HRSIndexPathMapperNode */ *children;

/**
 Create a new node with the given index and a condition if there is any.
 
 @param index     The index the node represents.
 @param condition The condition that is linked to the index of this node or NULL
                  if this node only contains further children.
 
 @return An initialized node object
 */
- (instancetype)initWithIndex:(NSUInteger)index condition:(BOOL(^)(void))condition DEPRECATED_ATTRIBUTE NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithIndex:(NSUInteger)index NS_DESIGNATED_INITIALIZER;

/**
 Sets a condition for the given indexes by creating a child (if not present) for
 the next index in the index list and calling this method recursively by
 removing the first index from the indexes list and decrementing the depth by 1.
 
 If this method is called with only one index left in the list (meaning the
 depth parameter is 1), it will set the condition.
 
 @param indexes   A pointer to a list of indexes that represent the remaining
                  indexes of the index path from the receiver's node to the
                  leaf.
 @param depth     The number of indexes in the list.
 @param condition The condition that should be set to the last index in the list.
 */
- (void)setConditionForIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth condition:(BOOL(^)(void))condition DEPRECATED_ATTRIBUTE;

- (void)setConditionForIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth predicate:(NSPredicate *)predicate evaluationObject:(id)object;

/**
 Removes a condition for the given indexes by traversing through the child
 hierarchy to find the next index. After the item with the next index is found
 the method is forwarded to this item, the first index is removed from the list,
 and the `depth` parameter is decremented by 1.
 
 If this method is called with only one index left in the list (meaning the
 depth parameter is 1), it will remove the condition.
 
 If the child that is removed is a leaf or `descendant` is set to `YES`, it
 removes the complete child.
 
 @param indexes    A pointer to a list of indexes that represent the remaining
                   indexes of the index path from the receiver's node to the
                   leaf.
 @param depth      The number of indexes in the list.
 @param descendant Specifies if you want to remove all descendant child nodes
                   as well.
 */
- (void)removeConditionForIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth descendant:(BOOL)descendant;

/**
 Recursively traverses through the list of given static indexes and maps them in
 place to its coresponding dynamic index based on the condition of the receiver.
 
 The first node that evaluates its condition to `NO` sets `NSNotFound` on it and
 all of its children.
 
 @param indexes A pointer to a list of indexes that represent the remaining
                indexes of the index path from the receiver's node to the
                leaf.
 @param depth   The number of indexes in the list.
 */
- (void)dynamicIndexesForStaticIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth;

/**
 Recursively traverses through the list of given dynamic indexes and maps them
 in place to its coresponding static index based on the condition of the
 receiver.
 
 @param indexes A pointer to a list of indexes that represent the remaining
                indexes of the index path from the receiver's node to the
                leaf.
 @param depth   The number of indexes in the list.
 */
- (void)staticIndexesForDynamicIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth;

@end
