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

@protocol HRSTableViewSectionController;


/**
 A table view section coordinator proxy is responsible for mapping values
 between a section controller and the corresponding table view based on the
 mapping information from the controller's section coordinator.
 
 A proxy has a defined direction. It either maps from a table view to a section
 controller or in the other direction, but not both. You can easily create a
 reverse proxy by calling `reverseProxy`.
 
 Mapping is done based on the parameter and the data type this parameter has.
 When mapping index paths, integers (sections) or index sets they are mapped
 based on the information of the section controller's coordinator. When mapping
 data types like a table view, they are mapped by creating a proxy for the
 parameter that has the reverse order than the current proxy.
 
 A proxy automatically has a reverse behaviour when mapping a return value. E.g.
 when you are mapping the table view delegate method
 `tableView:willSelectRowAtIndexPath:` you need a proxy that maps from the table
 view to the section controller. This means the first and second argument are
 mapped to the section controller's space. When you then return an index path
 inside this method, the return value is automatically mapped back to the table
 view from the section controller.
 */
@interface _HRSTableViewSectionCoordinatorProxy : NSProxy

/**
 This is the list of all section controllers that are currently displayed in the
 table view.
 
 The proxy uses this information to calculate the mapping of index pathes and
 sections. The section controller associated to the proxy must be one element
 of this array; otherwise, setting this array will raise an exception.
 
 @note if you do not set this value, the proxy tries to determine the list of
       available section controllers itself. This might not always be correct.
       (see issue #16)
 */
@property (nonatomic, strong, readwrite) NSArray *sectionControllers;

/**
 Register a new selector that participates in object mapping.
 
 The newly registered selector will immediately be taken into account by all
 existing and new proxies.
 
 You pass in an index set with the information about which parameters should be
 mapped. Index path mapping starts with 0 as the selector and continues with 1
 for the first argument. Please refer to
 `+[HRSTableViewSectionCoordinator registerTransformer:arguments:]` for more
 information about how mapping is configured.
 
 @see +[HRSTableViewSectionCoordinator registerTransformer:arguments:]
 
 @param selector The selector you want to register.
 @param indexSet The index set with the mapping information.
 */
+ (void)registerSelector:(SEL)selector arguments:(NSIndexSet *)indexSet;

/**
 Creates a new proxy that mediates between the controller and the table view.
 
 @param controller the controller that should be used to map the index paths
 @param tableView  the table view that should be used to map the index paths
 
 @return a newly created instance of a table view proxy.
 */
+ (instancetype)proxyWithController:(id<HRSTableViewSectionController>)controller tableView:(UITableView *)tableView;

/**
 Creates a new proxy that mediates between the table view and the controller.
 
 @note This is the reverse mapping of the method `proxyWithController:tableView:`.
 
 @param controller the controller that should be used to map the index paths
 @param tableView  the table view that should be used to map the index paths
 
 @return a newly created instance of a section controller proxy.
 */
+ (instancetype)reverseProxyWithController:(id<HRSTableViewSectionController>)controller tableView:(UITableView *)tableView;

/**
 Returns the reverse proxy of the current one.
 
 This method always reverses the proxy behaviour. This means that you will get
 the original behaviour when you call this method on a reversed proxy. It simply
 toggles between the two directions.
 
 @note currently this method creates a new instance of the proxy. Do not count
	   on this behaviour as this is subject to change due to optimisations!
 
 @return a proxy that has the reverse mapping direction than the receiver.
 */
- (instancetype)reverseProxy;

@end
