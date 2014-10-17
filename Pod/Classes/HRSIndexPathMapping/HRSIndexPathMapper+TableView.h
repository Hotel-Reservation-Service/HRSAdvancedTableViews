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


/**
 The `TableView` category of the `HRSIndexPathMapper` contains a couple of
 convenience methods that can be used when dealing with table views.
 
 They are all mapping directly to one of the standard index path methods but are
 easier to use and easier to read in the context of a table view. You can use
 them side by side with the regular methods.
 
 In the context of a table view, the static space is your data source where the
 dynamic space represents the state of the table view.
 */
@interface HRSIndexPathMapper (TableView)

/**
 Sets a condition for the given section while overwriting possible previous
 conditions.
 
 This is a convenience method for working with `UITableView`s. You use this
 method when controlling a complete section. If the condition returns `NO`, the
 complete section is not visible inside the table view.
 
 This behavior is different from adding an appropriate condition to each row for
 a section, where the section is still visible but has no visible rows. In the
 first case, a possible table section header or footer title is not visible,
 whereas in the second case, the titles remain visible with no cell between them.
 
 @param section   The section you want to add a condition to.
 @param condition The condition block that should be evaluated to determine the
                  visibility status of this section.
 */
- (void)setConditionForSection:(NSInteger)section condition:(BOOL(^)(void))condition;

/**
 Removes the condition for the given section.
 
 This makes the given section fall back to the default `YES` behaviour.
 
 If you want to remove all conditions that match a certain section, including
 all of its row conditions, simply set the `rows` argument to `YES`. Please note
 that this parameter is directly passed to `descendant` parameter from
 `removeConditionForIndexPath:descendant:`; in the case you are using the table
 view methods and the regular index path methods in conjunction and have added
 a condition that is more detailed than just a section and a row, these
 conditions will be removed as well.
 
 @param section The section you want to remove the condition from.
 @param rows    If this is set to `YES`, all row conditions for this section are
                removed, too.
 */
- (void)removeConditionForSection:(NSInteger)section includingRows:(BOOL)rows;

/**
 Sets a condition for the given row in the passed-in section while overwriting
 possible previous conditions for this row.
 
 This is a convenience method for working with `UITableView`s. You use this
 method when controlling a specific row. If the condition returns `NO`, the row
 in the specified section is not visible inside the table view.
 
 @param row       The row you want to add a condition to.
 @param section   The section of the row in question.
 @param condition The condition block that should be evaluated to determine the
                  visibility status of this row.
 */
- (void)setConditionForRow:(NSInteger)row inSection:(NSInteger)section condition:(BOOL(^)(void))condition;

/**
 Removes the condition for the given row in the passed-in section.
 
 This makes the given row fall back to the default `YES` behaviour.
 
 In the case you are using the table view methods and the regular index path
 methods in conjunction and have added a condition that is more detailed than
 just a section and a row, this method also removed all descendant index pathes.
 If you do not want this behaviour, you need to use the regular index path
 method to remove the row in question and pass in `NO` as the descendant
 parameter.
 
 @param row     The row you want to remove the condition from.
 @param section The section of the row in question.
 */
- (void)removeConditionForRow:(NSInteger)row inSection:(NSInteger)section;

/**
 Return the dynamically, mapped section for a certain static section by taking
 all conditions into account that are relevant for the section in question.
 
 @param section The static section that is not altered by any condition.
 
 @return The dynamic section, altered by the result of evaluating the conditions.
         If the section is currently not activated, `NSNotFound` is returned.
 */
- (NSInteger)dynamicSectionForStaticSection:(NSInteger)section;

/**
 Reverses the dynamic mapping by calculating the static section from a dynamic
 section based on the evaluation of the conditions.
 
 @param section A section, defined in the space of the table view.
 
 @return The static section that stays constant regardless of the outcome of
         evaluating the conditions.
 */
- (NSInteger)staticSectionForDynamicSection:(NSInteger)section;

@end
