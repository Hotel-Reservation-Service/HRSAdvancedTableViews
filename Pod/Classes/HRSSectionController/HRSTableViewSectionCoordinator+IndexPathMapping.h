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

#import "HRSTableViewSectionCoordinator.h"

@interface HRSTableViewSectionCoordinator (IndexPathMapping)

/**
 Maps an index path from the table view space to the given controller's index
 path.
 
 @discussion A controller's section always starts with 0, no matter where it is
             displayed inside a table view. The real location in the table view
             depends from the controllers position inside the coordinator's
             `sectionControllers` array.
 
 @param tableViewIndexPath the index path returned by a table view method
 @param controller         the controller that should be used for mapping
 
 @return the index path in the space of the passed in controller
 */
- (NSIndexPath *)controllerIndexPathForTableViewIndexPath:(NSIndexPath *)tableViewIndexPath withController:(id<HRSTableViewSectionController>)controller;

/**
 Maps a section from the table view space to the given controller's section.
 
 @note When calling this with the a controller and the section it is controlling
       it will always return 0, however this is in preparation of the fact that
       one day a section controller should be able to handle more than one
       section. You can also use this method to calculate offsets between two
       different section controllers.
 
 @param tableViewSection The section you want to map in the table view's space.
 @param controller       The controller the returned section should be in
                         relation to.
 
 @return The mapped section in the space of the passed-in section controller.
 */
- (NSInteger)controllerSectionForTableViewSection:(NSInteger)tableViewSection withController:(id<HRSTableViewSectionController>)controller;

/**
 Maps an index path from the passed in controller's space to the table view.
 
 @param controllerIndexPath the index path used inside a section controller
 @param controller          the controller that the `controllerIndexPath`
                            relates to
 
 @return the index path in the space of the table view
 */
- (NSIndexPath *)tableViewIndexPathForControllerIndexPath:(NSIndexPath *)controllerIndexPath withController:(id<HRSTableViewSectionController>)controller;

/**
 Maps a section from the passed in controller's space to the table view.
 
 @param controllerSection the section used inside a section controller
 @param controller        the controller that the `controllerSection` relates to
 
 @return the section in the space of the table view
 */
- (NSInteger)tableViewSectionForControllerSection:(NSInteger)controllerSection withController:(id<HRSTableViewSectionController>)controller;

@end
