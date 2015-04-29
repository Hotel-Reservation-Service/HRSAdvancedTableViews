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

#define HRSSectionControllerTransformer(sel, ...) [HRSTableViewSectionTransformer registerTransformer:@selector(sel) arguments:__VA_ARGS__, NSNotFound]

@class HRSTableViewSectionCoordinator;

/**
 The table view section transformer is a class that controlls the actual
 dispatching of the table view's delegate and data source methods to the
 section that is interested in the specific call.
 
 If you want to extend the table view's delegate or data source protocol, you
 can either do so in a category of this class if you want to have a general,
 app wide support, or you can create a subclass which deals with these methods.
 
 # Subclassing
 
 When creating a subclass of a `HRSTableViewSectionTransformer` you should also
 override `HRSTableViewSectionCoordinator` and return your transformer subclass
 in `+transformerClass`.
 @see `+[HRSTableViewSectionCoordinator transformerClass]`
 
 @note In the current implementation this class forwards all the delegate and
       data source methods to the section coordinator. However, this will change
       in an upcoming release and is only implemented that way for backwards
       compatibility.
 */
@interface HRSTableViewSectionTransformer : NSObject <UITableViewDelegate, UITableViewDataSource>

/**
 The coordinator that is linked with the transformer.
 */
@property (nonatomic, weak, readonly) HRSTableViewSectionCoordinator *coordinator;

/**
 Creates a new section transformer linked with the passed in coordinator.
 
 @param coordinator The coordinator to use for this transformer.
 
 @return The newly initialized transformer
 */
+ (instancetype)transformerWithSectionCoordinator:(HRSTableViewSectionCoordinator *)coordinator;

/**
 Creates a new section transformer linked with the passed in coordinator.
 
 @param coordinator The coordinator to use for this transformer.
 
 @return The newly initialized transformer
 */
- (instancetype)initWithSectionCoordinator:(HRSTableViewSectionCoordinator *)coordinator NS_DESIGNATED_INITIALIZER;

// unavailable:
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;


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
 [HRSTableViewSectionTransformer registerTransformer:@selector(tableView:willSelectRowAtIndexPath:)
 arguments:0, 2, NSNotFound];
 ````
 
 @discussion There is a macro called `HRSSectionControllerTransformer(sel, ...)`
 for easier configuration that does not need to be terminated by
 `NSNotFound` and that does not need the `@selector()` wrapper. You
 might want to use this! The above example would then look like this:
 `HRSSectionControllerTransformer(tableView:willSelectRowAtIndexPath:, 0, 2)`
 
 @note This method is only needed when subclassing `UITableView` or extending
 the table view delegate or data source protocol. All default methods are
 already hooked up in the coordinator itself!
 
 @param selector The selector of the method to transform
 @param arg      The arguments to be transformed, **followed by `NSNotFound`**
 */
+ (void)registerTransformer:(SEL)selector arguments:(NSUInteger)arg, ...;

@end
