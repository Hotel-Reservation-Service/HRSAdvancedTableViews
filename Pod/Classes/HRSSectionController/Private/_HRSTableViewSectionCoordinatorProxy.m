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

#import "_HRSTableViewSectionCoordinatorProxy.h"

#import "HRSTableViewSectionController.h"
#import "HRSTableViewSectionCoordinator.h"
#import "HRSTableViewSectionCoordinator+IndexPathMapping.h"


@interface _HRSTableViewSectionCoordinatorProxy () {
	_HRSTableViewSectionCoordinatorProxy *_reverseProxy;
}

@property (nonatomic, assign, readwrite) BOOL reverseProxying;
@property (nonatomic, strong, readwrite) id<HRSTableViewSectionController> controller;
@property (nonatomic, strong, readwrite) UITableView *tableView;

@end


@implementation _HRSTableViewSectionCoordinatorProxy

static NSMutableDictionary *transformer;
+ (void)registerSelector:(SEL)selector arguments:(NSIndexSet *)indexSet {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		transformer = [NSMutableDictionary dictionary];
	});
	
	transformer[NSStringFromSelector(selector)] = [indexSet copy];
}

+ (instancetype)proxyWithController:(id<HRSTableViewSectionController>)controller tableView:(UITableView *)tableView {
	return [[self alloc] initWithController:controller tableView:tableView];
}

+ (instancetype)reverseProxyWithController:(id<HRSTableViewSectionController>)controller tableView:(UITableView *)tableView {
	_HRSTableViewSectionCoordinatorProxy *proxy = [self proxyWithController:controller tableView:tableView];
	return [proxy reverseProxy];
}

- (instancetype)reverseProxy {
	// TODO: There should be some sort of hierarchy so that calling reverseProxy twice returns the initial object!
	if (_reverseProxy == nil) {
		_HRSTableViewSectionCoordinatorProxy *copy = [[_HRSTableViewSectionCoordinatorProxy alloc] initWithController:self.controller tableView:self.tableView];
		copy.reverseProxying = !self.reverseProxying;
		_reverseProxy = copy;
	}
	return _reverseProxy;
}

- (instancetype)initWithController:(id<HRSTableViewSectionController>)controller tableView:(UITableView *)tableView {
	NSParameterAssert(controller);
	NSParameterAssert(tableView);
	if (controller == nil || tableView == nil) {
		return nil;
	}
	_controller = controller;
	_tableView = tableView;
	return self;
}

- (NSArray *)sectionControllers {
    if (_sectionControllers) {
        return _sectionControllers;
    }
    
    return self.controller.coordinator.sectionController;
}



#pragma mark - forwarding

- (BOOL)respondsToSelector:(SEL)aSelector {
	return [[self forwardingTarget] respondsToSelector:aSelector];
}

- (id)forwardingTarget {
	return (self.reverseProxying ? (id)self.controller : (id)self.tableView);
}

- (id)forwardingTargetForSelector:(SEL)selector {
	if (transformer[NSStringFromSelector(selector)] == nil) {
		return [self forwardingTarget];
	} else {
		return self;
	}
}

- (id)_mappedObject:(id)object isReturnValue:(BOOL)reverse {
	if (object == nil) {
		return nil;
	}
	
	BOOL reverseLogic = reverse ^ self.reverseProxying;
	
	if ([object isKindOfClass:[NSIndexPath class]]) {
        NSIndexPath *indexPath = object;
		NSIndexPath *mappedIndexPath;
		if (reverseLogic) {
            mappedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
			
		} else {
            NSInteger section = [self.sectionControllers indexOfObject:self.controller];
            if (section != NSNotFound) {
                mappedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:section];
            }
		}
		return mappedIndexPath;
		
	} else if ([object isKindOfClass:[NSIndexSet class]]) {
		NSMutableIndexSet *mappedSet = [NSMutableIndexSet indexSet];
		[(NSIndexSet *)object enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
			NSUInteger newSection = [self _mappedSection:idx isReturnValue:reverse];
			[mappedSet addIndex:newSection];
		}];
		return [mappedSet copy];
	
	} else if ([object isKindOfClass:[UITableView class]]) {
		if (self.tableView == object) {
			return [self reverseProxy];
		} else {
			return object;
		}
		
	} else if ([object isKindOfClass:[NSArray class]]) {
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:[object count]];
		for (id element in object) {
			[array addObject:[self _mappedObject:element isReturnValue:reverse]];
		}
		
		return [array copy];
		
	}
	
	NSAssert(0, @"Object is not of supported kind!");
	
	return nil;
}

- (NSInteger)_mappedSection:(NSInteger)section isReturnValue:(BOOL)reverse {
	BOOL reverseLogic = reverse ^ self.reverseProxying;
	
	NSInteger mappedSection = 0;
	if (reverseLogic) {
		mappedSection = [self.controller.coordinator controllerSectionForTableViewSection:section withController:self.controller];
	} else {
		mappedSection = [self.controller.coordinator tableViewSectionForControllerSection:section withController:self.controller];
	}
	return mappedSection;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
	NSString *selectorKey = NSStringFromSelector(invocation.selector);
	if (transformer[selectorKey] == nil) {
		[invocation setTarget:[self forwardingTarget]];
		[invocation invoke];
		return;
	}
	
	[invocation retainArguments];
	
	// check for mapping arguments
	NSMethodSignature *signature = [invocation methodSignature];
	NSUInteger argc = [signature numberOfArguments];
	NSIndexSet *mappingList = transformer[selectorKey];
	[mappingList enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		NSAssert(idx < argc, @"Given index out of range. This is most likely a configuration issue of the transformer!");
		if (idx >= argc) {
			return;
		}
		
		if (idx == 0) {
			// return value
			// do nothing here! We first need to invoke the method!
			
		} else {
			NSUInteger arg = idx + 1; // map to objc argument counting
			const char *argType = [signature getArgumentTypeAtIndex:arg];
			if (strcmp(argType, @encode(id)) == 0) { // indexPath
				__unsafe_unretained id parameter;
				[invocation getArgument:&parameter atIndex:arg];
				
				id mappedObject = [self _mappedObject:parameter isReturnValue:NO];
				
				[invocation setArgument:&mappedObject atIndex:arg];
				
			} else if (strcmp(argType, @encode(NSInteger)) == 0) { // section
				NSInteger section;
				[invocation getArgument:&section atIndex:arg];
				
				NSInteger mappedSection = [self _mappedSection:section isReturnValue:NO];
				[invocation setArgument:&mappedSection atIndex:arg];
			}
		}
	}];
	
	[invocation setTarget:[self forwardingTarget]];
	[invocation invoke];
	
	if ([mappingList containsIndex:0]) {
		// map return value
		// return value must be mapped in opposite direction!
		
		const char *argType = [signature methodReturnType];
		if (strcmp(argType, @encode(id)) == 0) { // indexPath
			__unsafe_unretained id parameter;
			[invocation getReturnValue:&parameter];
			
			id mappedObject = [self _mappedObject:parameter isReturnValue:YES];
			
			[invocation setReturnValue:&mappedObject];
			
		} else if (strcmp(argType, @encode(NSInteger)) == 0) { // section
			NSInteger section;
			[invocation getReturnValue:&section];
			
			NSInteger mappedSection = [self _mappedSection:section isReturnValue:YES];
			[invocation setReturnValue:&mappedSection];
		}
	}
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
	NSMethodSignature *signature = [[self forwardingTarget] methodSignatureForSelector:sel];
	return signature;
}

@end
