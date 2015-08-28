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


@class HRSTableViewSectionCoordinator;


/**
 A section controller is reponsible for a single section inside a `UITableView`.
 It manages the rows that should be displayed inside of its section.
 
 The section index of a section controller always starts with 0. The controller
 should not worry about mapping its section to the correct table view index path.
 This is done entirely by the section coordinator. A section controller should
 treat its table view as if it is the only section that is visible in the table
 view.
 
 If a section controller has to communicate with the table view on its own, it
 can ask its coordinator for `tableViewForSectionController:` to get a table
 view container it can deal with. The controller should make no attempts to get
 a hand on the underlying table view.
 
 @see -[HRSTableViewSectionCoordinator tableViewForSectionController:]
 */
@protocol HRSTableViewSectionController <NSObject, UITableViewDelegate, UITableViewDataSource>

/**
 The coordinator responsible for the section controller.
 
 @note This property is automatically set by the coordinator and should never be
       changed!
 */
@property (nonatomic, weak, readwrite) HRSTableViewSectionCoordinator *coordinator;


@optional
/**
 Called after the coordinator was assigned a new table view.
 
 The default implementation does nothing. This method is ment for subclassing
 purpose.
 
 @discussion Typically you will configure the table view here to be ready to use.
 
 @param tableView The table view that is now assigned to the section coordinator
                  and its controllers.
 */
- (void)tableViewDidChange:(UITableView *)tableView;

@end


/**
 This is a base implementation of the `HRSTableViewSectionController` protocol
 for easier implementation of subclasses. It also inherits from `UIResponder`
 to enable a section controller to participate in the responder chain. This
 enables a section controller to e.g. make use of the `HRSCustomErrorHandling`
 project.
 
 Its next responder is the section coordinator.
 */
@interface HRSTableViewSectionController : UIResponder <HRSTableViewSectionController, UITraitEnvironment>

/**
 Called after the coordinator was assigned a new table view.
 
 The default implementation populates the `tableView` property of the controller.
 
 @note make sure to call super when subclassing to not break this behaviour!
 
 @param tableView The table view that is now assigned to the section coordinator
                  and its controllers.
 */
- (void)tableViewDidChange:(UITableView *)tableView NS_REQUIRES_SUPER;

/**
 The table view that this section controller is responsible for.
 
 This property will return `nil` until `tableViewDidChange:` was called.
 */
@property (nonatomic, strong, readonly) UITableView *tableView;

/**
 The section header title of the controlled section.
 
 This title will automatically be set as the table view section's header title.
 
 @note You must not override the table view data source's
       `tableView:titleForHeaderInSection:` for this to work.
 */
@property (nonatomic, strong, readwrite) NSString *sectionHeaderTitle;

/**
 The section footer title of the controlled section.
 
 This title will automatically be set as the table view section's footer title.
 
 @note You must not override the table view data source's
       `tableView:titleForFooterInSection:` for this to work.
 */
@property (nonatomic, strong, readwrite) NSString *sectionFooterTitle;

@end
