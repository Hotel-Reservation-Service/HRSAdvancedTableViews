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


@interface HRSTableViewSectionCoordinator (TransformerSupport)

/**
 Register a transformer for the table view proxy.
 
 This method used to configure the proxy that is transforming the sections and
 index pathes between a table view and its coordinator. You can register any
 method on it. Typically this can be `UITableView` methods and methods defined
 in `UITableViewDelegate` and `UITableViewDataSource`.
 
 Once a proxy should forward a method that was registered as a transforming
 method, it checks each argument in the list and transforms it.
 
 The following types can be transformed:
 - NSIndexPath
 - UITableView
 - NSUInteger
 - NSArray containing any of the above classes
 
 NSUInteger will be handled as sections. Specifying an argument that is none
 of the above will result in undefined behavior.
 
 
 # Arguments numbering
 
 Arguments numbering starts with 0, which represents the return value of a
 method. The remaining arguments are number ascending, followed by `NSNotFound`
 to terminate the list.
 
 If you want to map a method like `tableView:willSelectRowAtIndexPath:` you want
 to map the return value as well as the second argument, so you would use the
 following call:
 
 ````
 [HRSTableViewSectionCoordinator registerTransformer:@selector(tableView:willSelectRowAtIndexPath:)
                                           arguments:0, 2, NSNotFound];
 ````
 
 @note This method is only needed when subclassing `UITableView` or extending
	   the table view delegate or data source protocol. All default methods are
       already hooked up in the coordinator itself!
 
 @deprecated Please use +[HRSTableViewSectionTransformer registerTransformer:arguments:] instead.
 
 @param selector The selector of the method to transform
 @param arg      The arguments to be transformed, **followed by `NSNotFound`**
 */
+ (void)registerTransformer:(SEL)selector arguments:(NSUInteger)arg, ... DEPRECATED_ATTRIBUTE;

@end
