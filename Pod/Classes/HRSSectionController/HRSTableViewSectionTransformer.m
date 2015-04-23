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

#import "HRSTableViewSectionTransformer.h"

#import <objc/runtime.h>
#import "_HRSTableViewSectionCoordinatorProxy.h"

#import "HRSTableViewSectionCoordinator.h"
#import "HRSTableViewSectionController.h"


@implementation HRSTableViewSectionTransformer

+ (void)load {
    // register default transformers
    
    // UITableView
    HRSSectionControllerTransformer(numberOfRowsInSection:, 1);
    HRSSectionControllerTransformer(rectForSection:, 1);
    HRSSectionControllerTransformer(rectForHeaderInSection:, 1);
    HRSSectionControllerTransformer(rectForFooterInSection:, 1);
    HRSSectionControllerTransformer(rectForRowAtIndexPath:, 1);
    HRSSectionControllerTransformer(indexPathForRowAtPoint:, 0);
    HRSSectionControllerTransformer(indexPathForCell:, 0);
    HRSSectionControllerTransformer(indexPathsForRowsInRect:, 0);
    HRSSectionControllerTransformer(cellForRowAtIndexPath:, 1);
    HRSSectionControllerTransformer(indexPathsForVisibleRows, 0);
    HRSSectionControllerTransformer(headerViewForSection:, 1);
    HRSSectionControllerTransformer(footerViewForSection:, 1);
    HRSSectionControllerTransformer(scrollToRowAtIndexPath:atScrollPosition:animated:, 1);
    HRSSectionControllerTransformer(insertSections:withRowAnimation:, 1);
    HRSSectionControllerTransformer(deleteSections:withRowAnimation:, 1);
    HRSSectionControllerTransformer(reloadSections:withRowAnimation:, 1);
    HRSSectionControllerTransformer(moveSection:toSection:, 1, 2);
    HRSSectionControllerTransformer(insertRowsAtIndexPaths:withRowAnimation:, 1);
    HRSSectionControllerTransformer(deleteRowsAtIndexPaths:withRowAnimation:, 1);
    HRSSectionControllerTransformer(reloadRowsAtIndexPaths:withRowAnimation:, 1);
    HRSSectionControllerTransformer(moveRowAtIndexPath:toIndexPath:, 1, 2);
    HRSSectionControllerTransformer(indexPathForSelectedRow, 0);
    HRSSectionControllerTransformer(indexPathsForSelectedRows, 0);
    HRSSectionControllerTransformer(selectRowAtIndexPath:animated:scrollPosition:, 1);
    HRSSectionControllerTransformer(deselectRowAtIndexPath:animated:, 1);
    HRSSectionControllerTransformer(dequeueReusableCellWithIdentifier:forIndexPath:, 2);
    
    // DataSource
    HRSSectionControllerTransformer(tableView:numberOfRowsInSection:, 1, 2);
    HRSSectionControllerTransformer(tableView:cellForRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(numberOfSectionsInTableView:, 1);
    HRSSectionControllerTransformer(tableView:titleForHeaderInSection:, 1, 2);
    HRSSectionControllerTransformer(tableView:titleForFooterInSection:, 1, 2);
    HRSSectionControllerTransformer(tableView:canEditRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:canMoveRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:commitEditingStyle:forRowAtIndexPath:, 1, 3);
    HRSSectionControllerTransformer(tableView:moveRowAtIndexPath:toIndexPath:, 1, 2, 3);
    
    // Delegate
    HRSSectionControllerTransformer(tableView:willDisplayCell:forRowAtIndexPath:, 1, 3);
    HRSSectionControllerTransformer(tableView:willDisplayHeaderView:forSection:, 1, 3);
    HRSSectionControllerTransformer(tableView:willDisplayFooterView:forSection:, 1, 3);
    HRSSectionControllerTransformer(tableView:didEndDisplayingCell:forRowAtIndexPath:, 1, 3);
    HRSSectionControllerTransformer(tableView:didEndDisplayingHeaderView:forSection:, 1, 3);
    HRSSectionControllerTransformer(tableView:didEndDisplayingFooterView:forSection:, 1, 3);
    HRSSectionControllerTransformer(tableView:heightForRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:heightForHeaderInSection:, 1, 2);
    HRSSectionControllerTransformer(tableView:heightForFooterInSection:, 1, 2);
    HRSSectionControllerTransformer(tableView:estimatedHeightForRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:estimatedHeightForHeaderInSection:, 1, 2);
    HRSSectionControllerTransformer(tableView:estimatedHeightForFooterInSection:, 1, 2);
    HRSSectionControllerTransformer(tableView:viewForHeaderInSection:, 1, 2);
    HRSSectionControllerTransformer(tableView:viewForFooterInSection:, 1, 2);
    HRSSectionControllerTransformer(tableView:accessoryTypeForRowWithIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:accessoryButtonTappedForRowWithIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:shouldHighlightRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:didHighlightRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:didUnhighlightRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:willSelectRowAtIndexPath:, 0, 1, 2);
    HRSSectionControllerTransformer(tableView:willDeselectRowAtIndexPath:, 0, 1, 2);
    HRSSectionControllerTransformer(tableView:didSelectRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:didDeselectRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:editingStyleForRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:editActionsForRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:shouldIndentWhileEditingRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:willBeginEditingRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:didEndEditingRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:, 0, 1, 2, 3);
    HRSSectionControllerTransformer(tableView:indentationLevelForRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:shouldShowMenuForRowAtIndexPath:, 1, 2);
    HRSSectionControllerTransformer(tableView:canPerformAction:forRowAtIndexPath:withSender:, 1, 3);
    HRSSectionControllerTransformer(tableView:performAction:forRowAtIndexPath:withSender:, 1, 3);
}

+ (void)registerTransformer:(SEL)selector arguments:(NSUInteger)arg, ... {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    va_list args;
    va_start(args, arg);
    for (NSUInteger index = arg; index != NSNotFound; index = va_arg(args, NSUInteger)) {
        [indexSet addIndex:index];
    }
    va_end(args);
    [_HRSTableViewSectionCoordinatorProxy registerSelector:selector arguments:indexSet];
}



#pragma mark - object initialization

+ (instancetype)transformerWithSectionCoordinator:(HRSTableViewSectionCoordinator *)coordinator {
    return [[self alloc] initWithSectionCoordinator:coordinator];
}

- (instancetype)init {
    return [self initWithSectionCoordinator:nil];
}

- (instancetype)initWithSectionCoordinator:(HRSTableViewSectionCoordinator *)coordinator {
    if (coordinator == nil) {
        [NSException raise:NSInvalidArgumentException format:@"coordinator can not be nil."];
    }
    
    self = [super init];
    if (self) {
        _coordinator = coordinator;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL responds = [super respondsToSelector:aSelector];
    if (responds == NO) {
        responds = [self.coordinator respondsToSelector:aSelector];
    }
    return responds;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if (sig == nil) {
        sig = [self.coordinator methodSignatureForSelector:aSelector];
    }
    return sig;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    id target = [super forwardingTargetForSelector:aSelector];
    if (target == nil) {
        target = self.coordinator;
    }
    return target;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:self.coordinator];
}

@end
