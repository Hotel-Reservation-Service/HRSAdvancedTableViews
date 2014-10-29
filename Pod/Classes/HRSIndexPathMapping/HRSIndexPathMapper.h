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
 HRSIndexPathMapper is responsible for mapping a various number of index pathes
 from a static list to a dynamic list, based on a condition.
 
 The idea behind this mapping is, that you have to lists of index pathes. One
 that never changes. This is a static list e.g. of all possible values. For
 example this could be represented by an enum of all possible sections or rows.
 The second list is a dynamic list that only contains a subset of the full list.
 This could be a list of visible sections or rows. This mapper maps these to
 lists based on a number of conditions you can specify.
 
 The most common usage of this class is to show or hide various sections or rows
 in a `UITableView` based on a number of conditions. However this is not the
 only use case. The `HRSIndexPathMapper` is written to be usefull with any index
 path depth by evaluating the conditions recursively.
 
 You can add a condition to any depth of an index path. E.g. you could add a
 condition to index path '1' and another condition to index path '1-4'.
 
 Evaluation takes place in a tree structure. In the above example, e.g. when
 mapping index path '2-5', the condition for index path '1' would be evaluated
 to map the first index of the path '2-5', however the condition for index path
 '1-4' would not be evaluated as this is a more detailed condition that is only
 relevant for the second index of an index path that has index 1 as its first
 index path.
 
 It is not necessary to have a condition for every index path. Again, in the
 above example, there is no condition for index path '0'. This is interpreted as
 index path '0' being always activated or visible, which results in index path
 '0' never participating in the mapping.
 
 @note The manager does not check if and when a condition changes. Triggering
       events that result in reevaluating the index pathes is up to you. This
       means that e.g. in the context of a table view, you are responsible for
       calling `insertSections:withRowAnimation:` and
       `deleteSections:withRowAnimation:` at the right time!
 */
@interface HRSIndexPathMapper : NSObject

/**
 Sets a block condition for a given index path while overwriting possible
 previous conditions.
 
 You specify the index path as generic as possible. For example if your data
 structure has index pathes '0-0', '0-1', '1-0', '1-1', '1-2' and you want to hide
 all the index pathes whoes first index is 1, it is enough to have a condition
 set for index path '1'. If this condition would return NO, this would result in
 the following list: '0-0', '0-1'.
 
 @param indexPath The index path the condition belongs to.
 @param condition A block that evaluates the condition for this index path.
                  The block should return YES if the index path is active or NO
                  if it should be skipped.
 */
- (void)setConditionForIndexPath:(NSIndexPath *)indexPath condition:(BOOL(^)(void))condition;

/**
 Sets a predicate condition for a given index path while overwriting possible
 previous conditions.
 
 You specify the index path as generic as possible. For example if your data
 structure has index pathes '0-0', '0-1', '1-0', '1-1', '1-2' and you want to hide
 all the index pathes whoes first index is 1, it is enough to have a condition
 set for index path '1'. If this condition would return NO, this would result in
 the following list: '0-0', '0-1'.
 
 The predicate is evaluated on a specific object that is the root of the key
 path evaluation. You can pass in any object that responds to the key path / key
 paths you specified in your predicate.
 
 @note If the predicate is nil, this method behaves as
       `removeConditionForIndexPath:descendant:` with the descendant parameter
       set to `NO`.
 
 @note If you specify a predicate, you need to specify an evaluation object as
	   well. If you do not do this, this is considered an API misuse and the
       behavior is undefined.
 
 @see -[NSPredicate evaluateWithObject:]
 
 @param indexPath The index path the condition belongs to.
 @param predicate The predicate that describes the condition.
 @param object    The object the predicate should be evaluated on.
 */
- (void)setConditionForIndexPath:(NSIndexPath *)indexPath predicate:(NSPredicate *)predicate evaluationObject:(id)object;

/**
 Remove a condition for a given index path.
 
 This makes the given index path fall back in to the default YES behaviour.
 
 If you want to remove all conditions that match a certain index path, it is
 okay to only specify the most generic index path and pass YES for the
 descendant parameter. E.g. if you have conditions set for the index pathes
 '0-0', '0-3', '1-2', '1-5', '1-6' and you call remove with index path '1' and
 `descendant` set to YES, the remaining conditions are '0-0', '0-3'.
 
 @param indexPath  the index path whoes condition should be removed
 @param descendant If this is set to YES, all descendant index path conditions
                   are removed, too.
 */
- (void)removeConditionForIndexPath:(NSIndexPath *)indexPath descendant:(BOOL)descendant;

/**
 Return the dynamically, mapped index path for a certain static index path by
 taking all conditions into account that are relevant for the index path in
 question.
 
 @param indexPath The static index path that is not altered by the conditions.
 
 @return The dynamic index path, altered by the result of evaluating the
		 conditions. If an index in the resulting index path is currently not
         activated, `NSNotFound` is returned for it and all of its descendants.
 */
- (NSIndexPath *)dynamicIndexPathForStaticIndexPath:(NSIndexPath *)indexPath;

/**
 Reverses the dynamic mapping by calculating the static index path from a
 dynamic index path based on the evaluation of the conditions.
 
 @param indexPath An index path, defined in the space of dynamic index pathes.
 
 @return The static index path that stays constant regardless of the outcome of
         evaluating the conditions.
 */
- (NSIndexPath *)staticIndexPathForDynamicIndexPath:(NSIndexPath *)indexPath;

@end
