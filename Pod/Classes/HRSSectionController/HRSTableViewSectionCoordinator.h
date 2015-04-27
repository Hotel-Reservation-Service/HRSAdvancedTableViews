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


@protocol HRSTableViewSectionController;


/**
 A section coordinator is responsible for agregating and managing the data flow
 between a section controller and the table view the coordinator is linked to.
 
 From a table view's perspective, it is the delegate and the data source the
 table view uses. Internally it maps these calls and forwards them to the
 section controller responsible for it.
 
 
 # Section Mapping
 
 Each section controller in a coordinator is responsible for a single section
 that should be treated as section 0, from the controllers point of view.
 
 The mapping is done internally by the coordinator. If the coordinator hands you
 a table view, you will never get the underlying table view instance, instead
 you get an object you can treat as a table view that only contains the section
 controller's content.
 
 If you do need to do custom mapping e.g. in a coordinator subclass, you can use
 the methods provided in HRSTableViewSectionCoordinator+IndexPathMapping but
 please note that you do not need those methods insisde a section controller!
 
 @see HRSTableViewSectionController
 
 
 # Responder chain
 
 The next responder of a section coordinator is the table view it is managing.
 However this hook should never be used to manipulate the table view directly
 and without the knowledge of the coordinator. If you try such a thing, it is
 very likely that strange things will happen!
 
 
 # Delegate and Data Source
 
 @warning The HRSTableViewSectionCoordinator can be used as the delegate and
          data source of a table view for backwards compatibility. You should
          never set the delegate and data source of a table view to be the
          section coordinator yourself. Instead use the `setTableView:` method
          to let the section coordinator handle the work. In a later release,
          the section coordinator will no longer be the delegate and data source
          of the table view itself.
 */
@interface HRSTableViewSectionCoordinator : UIResponder <UITableViewDelegate, UITableViewDataSource>

/**
 The transformer class to be used by the coordinator. This class must be of kind
 `HRSTableViewSectionTransformer`.
 
 This class is used as the actual delegate and data source of the table view
 that then internally triggers the forwarding to the section controllers.
 
 If you have create a subclass of `HRSTableViewSectionTransformer` you should
 also override this method to return this class in you custom
 `HRSTableViewSectionCoordinator`.
 
 @return A class of kind `HRSTableViewSectionTransformer`
 */
+ (Class)transformerClass;

/**
 The list of section controllers that are managed by the coordinator.
 
 The setter implementation simply calls `setSectionController:animated:` with
 this array and with the animated parameter set to NO.
 */
@property (nonatomic, copy, readwrite) NSArray /* id<HRSTableViewSectionController> */ *sectionController;

/**
 Sets the list of section controllers that are managed by the coordinator.
 
 The list contains all section controllers that are used for the table view
 associated with the coordinator.
 
 When setting this array, the link between the section controller and the
 coordinator is automatically created by calling `setCoordinator:` on every
 member of the array.
 
 @note Currently it is not supported to have the same instance of a section
 controller twice in the section controller. This will trigger an
 exception. To be able to enable this feature in the future, an NSArray
 is used.
 
 @param sectionController an array of objects that conform to the
                          HRSTableViewSectionController protocol
 @param animated          YES if the change in sections should be animated on
                          the table view or NO if a simple reload should be
                          triggered
 */
- (void)setSectionController:(NSArray /* id<HRSTableViewSectionController> */ *)sectionController animated:(BOOL)animated;

/**
 Link the coordinator to a table view.
 
 A coordinator can only be linked to a single table view instance, however you
 can switch between table views. Once you link a coordinator to a table view,
 other coordinators that are linked with the same table view are unlinked and
 the table view is reloaded.
 
 The table view is stored weak inside the coordinator to enable purging memory
 when needed without deallocating the coordinator itself. You can create a
 coordinator in you view controller's initialization methods and link it to the
 table view everytime `viewDidLoad` is called.
 
 @note This method automatically claims the dataSource and the delegate of the
       table view.
 
 @param tableView The table view that should be linked with the coordinator
 */
- (void)setTableView:(UITableView *)tableView; /* stored weak */

/**
 Called after the coordinator was assigned a new table view.
 
 The default implementation does nothing. This method is ment for subclassing
 purpose.
 */
- (void)tableViewDidChange;

/**
 Returns a table view proxy for the given section controller.
 
 This enables you to make calls to the table view with your local index paths as
 if your section controller is the only one that is interacting with the table
 view.
 
 @note Do not make decisions based on pointer equality. This is not the same
       object as the table view.
 
 @param controller the controller you want the index pathes to be mapped from.
        Usually you pass `self` here.
 
 @return a table view proxy
 */
- (UITableView *)tableViewForSectionController:(id<HRSTableViewSectionController>)controller;

/**
 Returns a section controller proxy for the given section.
 
 This enables you to make calls to the section controller with the index paths
 of the table view's space.
 
 @note Do not make decisions based on pointer equality. This is not the same
       object as the table view.
 
 @param section The table view's section you want the controller for.
 
 @return a section controller proxy
 */
- (id<HRSTableViewSectionController>)sectionControllerForTableSection:(NSInteger)section;

@end
