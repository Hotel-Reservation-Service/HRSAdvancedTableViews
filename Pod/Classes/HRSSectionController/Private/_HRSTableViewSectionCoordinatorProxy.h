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


@interface _HRSTableViewSectionCoordinatorProxy : NSProxy

+ (void)registerSelector:(SEL)selector arguments:(NSIndexSet *)indexSet;

/**
 Creates a new proxy that mediates between the controller and the table view.
 
 @param controller the controller that should be used to map the index pathes
 
 @return a newly created instance of a table view proxy.
 */
+ (instancetype)proxyWithController:(id<HRSTableViewSectionController>)controller tableView:(UITableView *)tableView;
+ (instancetype)reverseProxyWithController:(id<HRSTableViewSectionController>)controller tableView:(UITableView *)tableView;

- (instancetype)reverseProxy;

@end
