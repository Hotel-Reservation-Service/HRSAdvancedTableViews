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
#import "HRSTableViewSectionCoordinator+IndexPathMapping.h"
#import "HRSTableViewSectionCoordinator+TransformerSupport.h"

#import <objc/runtime.h>

#import "HRSTableViewSectionController.h"
#import "HRSTableViewSectionTransformer.h"

#import "_HRSTableViewSectionCoordinatorProxy.h"


@interface HRSTableViewSectionCoordinator ()

@property (nonatomic, weak, readwrite) UITableView *tableView;
@property (nonatomic, strong, readwrite) HRSTableViewSectionTransformer *transformer;
@property (nonatomic, strong, readwrite) NSArray *formerSectionControllerArray;
@property (nonatomic, assign, readwrite) NSUInteger removedSectionControllersCellsCount;
@property (nonatomic, assign, readwrite) NSUInteger removedSectionControllersCellsDidEndDisplayingCounter;

@end


static void *const CoordinatorTableViewLink = (void *)&CoordinatorTableViewLink;


@implementation HRSTableViewSectionCoordinator

+ (Class)transformerClass {
    return [HRSTableViewSectionTransformer class];
}

- (void)dealloc {
	// notify the section controller that the new table is now nil, in case they
	// cached it.
    for (HRSTableViewSectionController *controller in self.sectionController) {
        [controller tableViewDidChange:nil];
    }
	
	// remove association if present
	UITableView *tableView = self.tableView;
	if (tableView) {
        tableView.dataSource = nil;
        tableView.delegate = nil;
		objc_setAssociatedObject(tableView, CoordinatorTableViewLink, nil, OBJC_ASSOCIATION_ASSIGN);
	}
}



#pragma mark - responder chain

- (UIResponder *)nextResponder {
	return self.tableView;
}



#pragma mark - section controller handling

- (void)configureTransformer {
    HRSTableViewSectionTransformer *transformer = [[[self class] transformerClass] transformerWithSectionCoordinator:self];
    self.tableView.delegate = transformer;
    self.tableView.dataSource = transformer;
    self.transformer = transformer;
}

- (void)setSectionController:(NSArray *)sectionController {
	[self setSectionController:sectionController animated:NO];
}

- (void)setSectionController:(NSArray *)sectionController animated:(BOOL)animated {
	// setup local variables for operations and ensure we don't operate on or
	// store a mutable array.
    _formerSectionControllerArray = nil;
    _removedSectionControllersCellsCount = 0;
    _removedSectionControllersCellsDidEndDisplayingCounter = 0;
    
	NSArray *oldSectionController = _sectionController;
	NSArray *newSectionController = [sectionController copy];
	
	// build sets for upcoming operations
	NSSet *oldSectionControllerSet = [NSSet setWithArray:oldSectionController];
	NSSet *newSectionControllerSet = [NSSet setWithArray:newSectionController];
	
	// ensure we are not using the same section controller twice
	// we simply check if the number of unique objects (the ones in the set) are
	// the same as the number of objects in the array.
	if (newSectionController.count != newSectionControllerSet.count) {
		[NSException raise:NSInternalInconsistencyException format:@"Using the same section controller instance twice is disallowed."];
	}
	
	// build diff sets for controllers to be removed and to be added
	NSMutableSet *removeSectionControllerSet = [oldSectionControllerSet mutableCopy];
	[removeSectionControllerSet minusSet:newSectionControllerSet];
	
	NSMutableSet *addSectionControllerSet = [newSectionControllerSet mutableCopy];
	[addSectionControllerSet minusSet:oldSectionControllerSet];
	
    /**
     *  Save former section controller array
     */
    if ( removeSectionControllerSet.count > 0 ) {
        _formerSectionControllerArray = [_sectionController copy];
    }
    
	for (id<HRSTableViewSectionController> ctrl in removeSectionControllerSet) {
        
        UITableView *ctrlTableView = [self tableViewForSectionController:ctrl];
        _removedSectionControllersCellsCount += [ctrl tableView:ctrlTableView numberOfRowsInSection:0];
        
		[ctrl setCoordinator:nil];
		 // unlink the table view if we previously linked one
		if (self.tableView && [ctrl respondsToSelector:@selector(tableViewDidChange:)]) {
			[ctrl tableViewDidChange:nil];
		}
	}
	
	for (id<HRSTableViewSectionController> ctrl in addSectionControllerSet) {
		[ctrl setCoordinator:self];
		// link the table view if there is one assigned to the coordinator
		if (self.tableView && [ctrl respondsToSelector:@selector(tableViewDidChange:)]) {
			[ctrl tableViewDidChange:[self tableViewForSectionController:ctrl]];
		}
	}
	
	if (animated) {
		[self.tableView beginUpdates];
		_sectionController = newSectionController;
        [self configureTransformer];
		[self _animateFromSections:oldSectionController toSections:newSectionController];
		[self.tableView endUpdates];
	} else {
		_sectionController = newSectionController;
        [self configureTransformer];
		[self.tableView reloadData];
	}
}

- (void)_animateFromSections:(NSArray *)oldSections toSections:(NSArray *)newSections {
	NSMutableIndexSet *insertIndex = [NSMutableIndexSet indexSet];
	NSMutableIndexSet *deleteIndex = [NSMutableIndexSet indexSet];
	
	NSInteger offset = 0;
	
	if (oldSections.count == 0) {
		[insertIndex addIndexesInRange:NSMakeRange(0, newSections.count)];
	}
	
	// iterate over old array
	for (NSUInteger oldIdx = 0; oldIdx < oldSections.count; oldIdx++) {
		id oldObj = oldSections[oldIdx];
		BOOL match = NO;
		
		// iterate over new array and compare with old array
		for (NSUInteger newIdx = oldIdx + offset; newIdx < newSections.count; newIdx++) {
			id newObj = newSections[newIdx];
			
			if (oldObj == newObj) { // objects are the same!
				// define the range that was in new array but not in old array
				NSRange insertRange = NSMakeRange(oldIdx + offset, newIdx - (oldIdx + offset));
				if (insertRange.length > 0) {
					// if length was > 0, there are new insertions!
					offset += insertRange.length; // shift the offset to make sure the next iteration starts with the new obj at the current position!
					[insertIndex addIndexesInRange:insertRange];
				}
				// if we had a match, stop here!
				match = YES;
				break;
			}
		}
		
		if (match == NO) {
			// if there was no match, the old object is not in the array anymore!
			// => delete it
			[deleteIndex addIndex:oldIdx];
			offset--; // shift the offset to ignore the deleted object index in the new array
		}
		
		if (oldIdx == oldSections.count - 1) {
			// last item! Add remaining new items if present!
			NSUInteger newStart = oldIdx + offset + 1;
			NSRange remainingNewRange = NSMakeRange(newStart, newSections.count - newStart);
			if (remainingNewRange.length > 0) {
				[insertIndex addIndexesInRange:remainingNewRange];
			}
		}
	}
	
	[self.tableView insertSections:insertIndex withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.tableView deleteSections:deleteIndex withRowAnimation:UITableViewRowAnimationAutomatic];
}



#pragma mark - proxying

- (UITableView *)tableViewForSectionController:(id<HRSTableViewSectionController>)controller {
	_HRSTableViewSectionCoordinatorProxy *proxy = [_HRSTableViewSectionCoordinatorProxy proxyWithController:controller tableView:self.tableView];
	return (UITableView *)proxy;
}

- (id<HRSTableViewSectionController>)sectionControllerForTableSection:(NSInteger)section {
	id<HRSTableViewSectionController> controller = [self _sectionControllerForTableSection:section];
	_HRSTableViewSectionCoordinatorProxy *proxy = [_HRSTableViewSectionCoordinatorProxy reverseProxyWithController:controller tableView:self.tableView];
	return (id<HRSTableViewSectionController>)proxy;
}

// FIXME: The performance of this method should be improved as much as possible! - We could probably check all supported protocol methods when the sectionController array is re-set!
// FIXME: There needs to be a way to add protocols for mapping to this method!
- (BOOL)respondsToSelector:(SEL)aSelector {
	if (aSelector == @selector(numberOfSectionsInTableView:)) {
		return YES;
	}
	
	if ([super respondsToSelector:aSelector] == NO) {
		return NO;
	}
	
	// check if the selector belongs to the table view delegate or data source protocol
	struct objc_method_description hasScrollViewMethod = protocol_getMethodDescription(@protocol(UIScrollViewDelegate), aSelector, NO, YES);
	struct objc_method_description hasDelegateMethod = protocol_getMethodDescription(@protocol(UITableViewDelegate), aSelector, NO, YES);
	struct objc_method_description hasDataSourceMethod = protocol_getMethodDescription(@protocol(UITableViewDataSource), aSelector, NO, YES);
	
	if (hasScrollViewMethod.name || hasScrollViewMethod.types || hasDelegateMethod.name || hasDelegateMethod.types || hasDataSourceMethod.name || hasDataSourceMethod.types) {
		// if so, only respond to selectors that are implemented in at least one of the section controllers!
		for (id<HRSTableViewSectionController> controller in self.sectionController) {
			if ([controller respondsToSelector:aSelector]) {
				return YES;
			}
		}
		return NO;
	}
	
	return YES;
}



#pragma mark - table view handling

- (void)setTableView:(UITableView *)tableView {
	HRSTableViewSectionCoordinator *oldCoordinator = objc_getAssociatedObject(tableView, CoordinatorTableViewLink);
	[oldCoordinator setTableView:nil];
	
	_tableView = tableView;
	
	if (tableView) {
		objc_setAssociatedObject(tableView, CoordinatorTableViewLink, self, OBJC_ASSOCIATION_ASSIGN);
		tableView.delegate = self;
		tableView.dataSource = self;
        [self configureTransformer];
	}
	
	[self _tableViewDidChange];
	
	[tableView reloadData];
}

- (id<HRSTableViewSectionController>)_sectionControllerForTableSection:(NSInteger)section {
    id<HRSTableViewSectionController> sectionController;
    if (self.formerSectionControllerArray) {
        sectionController = self.formerSectionControllerArray[section];
    } else {
        sectionController = self.sectionController[section];
    }
    return sectionController;
}

- (void)_tableViewDidChange {
	for (id<HRSTableViewSectionController> controller in self.sectionController) {
		if ([controller respondsToSelector:@selector(tableViewDidChange:)]) {
			[controller tableViewDidChange:[self tableViewForSectionController:controller]];
		}
	}
	
	[self tableViewDidChange];
}

- (void)tableViewDidChange {
	// empty, only ment for subclassing...
}



#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	NSInteger numberOfRows = [sectionController tableView:tableView numberOfRowsInSection:section];
	return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	UITableViewCell *cell = [sectionController tableView:tableView cellForRowAtIndexPath:indexPath];
	return cell;
}

// - optionals:

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSections = self.sectionController.count;
	return numberOfSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView titleForHeaderInSection:section];
	} else {
		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView titleForFooterInSection:section];
	} else {
		return nil;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView canEditRowAtIndexPath:indexPath];
	} else {
		return YES;
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView canMoveRowAtIndexPath:indexPath];
	} else {
		return [sectionController respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	id<HRSTableViewSectionController> sourceSectionController = [self sectionControllerForTableSection:sourceIndexPath.section];
	if ([sourceSectionController respondsToSelector:_cmd]) {
		[sourceSectionController tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
	}
	if (sourceIndexPath.section != destinationIndexPath.section) {
		id<HRSTableViewSectionController> destinationSectionController = [self sectionControllerForTableSection:destinationIndexPath.section];
		if ([destinationSectionController respondsToSelector:_cmd]) {
			[destinationSectionController tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
		}
	}
}



#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView willDisplayHeaderView:view forSection:section];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView willDisplayFooterView:view forSection:section];
	}
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];

	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
	}
    
    self.removedSectionControllersCellsDidEndDisplayingCounter++;
    
    /**
     *  If all cells of removed sections are removed from the table view, stop using former sections controller as callback target
     */
    if (self.removedSectionControllersCellsDidEndDisplayingCounter == self.removedSectionControllersCellsCount) {
        self.formerSectionControllerArray = nil;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView didEndDisplayingHeaderView:view forSection:section];
	}
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView didEndDisplayingFooterView:view forSection:section];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView heightForRowAtIndexPath:indexPath];
	} else {
		return tableView.rowHeight;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView heightForHeaderInSection:section];
	} else {
		return UITableViewAutomaticDimension;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView heightForFooterInSection:section];
	} else {
		return UITableViewAutomaticDimension;
	}
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
	} else {
		return [self tableView:tableView heightForRowAtIndexPath:indexPath];
	}
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView estimatedHeightForHeaderInSection:section];
	} else {
		return [self tableView:tableView heightForHeaderInSection:section];
	}
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView estimatedHeightForFooterInSection:section];
	} else {
		return [self tableView:tableView heightForFooterInSection:section];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView viewForHeaderInSection:section];
	} else {
		return nil;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView viewForFooterInSection:section];
	} else {
		return nil;
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
	} else {
		return YES;
	}
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView didHighlightRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView willSelectRowAtIndexPath:indexPath];
	} else {
		return indexPath;
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView willDeselectRowAtIndexPath:indexPath];
	} else {
		return indexPath;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView didDeselectRowAtIndexPath:indexPath];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView editingStyleForRowAtIndexPath:indexPath];
	} else {
		return UITableViewCellEditingStyleDelete;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
	} else {
		return nil;
	}
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView editActionsForRowAtIndexPath:indexPath];
	} else {
		return nil;
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
	} else {
		return YES;
	}
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView didEndEditingRowAtIndexPath:indexPath];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:sourceIndexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
	} else {
		return proposedDestinationIndexPath;
	}
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
	} else {
		return 0;
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
	} else {
		return NO;
	}
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		return [sectionController tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
	} else {
		return NO;
	}
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	id<HRSTableViewSectionController> sectionController = [self sectionControllerForTableSection:indexPath.section];
	if ([sectionController respondsToSelector:_cmd]) {
		[sectionController tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
	}
}



#pragma mark - scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[[self.sectionController firstObject] scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			return [sectionController scrollViewDidZoom:scrollView];
		}
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			return [sectionController scrollViewWillBeginDragging:scrollView];
		}
	}
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			return [sectionController scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			return [sectionController scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
		}
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			return [sectionController scrollViewWillBeginDecelerating:scrollView];
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			return [sectionController scrollViewDidEndDecelerating:scrollView];
		}
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			return [sectionController scrollViewDidEndScrollingAnimation:scrollView];
		}
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			UIView *view = [sectionController viewForZoomingInScrollView:scrollView];
			if (view) {
				return view;
			}
		}
	}
	return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			return [sectionController scrollViewWillBeginZooming:scrollView withView:view];
		}
	}
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			return [sectionController scrollViewDidEndZooming:scrollView withView:view atScale:scale];
		}
	}
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			BOOL shouldScrollToTop = [sectionController scrollViewShouldScrollToTop:scrollView];
			if (shouldScrollToTop) {
				return YES;
			}
		}
	}
	return NO;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	for (id<HRSTableViewSectionController> sectionController in self.sectionController) {
		if ([sectionController respondsToSelector:_cmd]) {
			return [sectionController scrollViewDidScrollToTop:scrollView];
		}
	}
}


@end



@implementation HRSTableViewSectionCoordinator (TransformerSupport)

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

@end



@implementation HRSTableViewSectionCoordinator (IndexPathMapping)

- (NSInteger)controllerSectionForTableViewSection:(NSInteger)tableViewSection withController:(id<HRSTableViewSectionController>)controller {
	NSInteger sectionOffset = [self.sectionController indexOfObject:controller];
	NSInteger controllerSection = tableViewSection - sectionOffset;
	return controllerSection;
}

- (NSIndexPath *)controllerIndexPathForTableViewIndexPath:(NSIndexPath *)tableViewIndexPath withController:(id<HRSTableViewSectionController>)controller {
	NSInteger section = [self controllerSectionForTableViewSection:tableViewIndexPath.section withController:controller];
	NSIndexPath *controllerIndexPath = [NSIndexPath indexPathForRow:tableViewIndexPath.row inSection:section];
	return controllerIndexPath;
}

- (NSInteger)tableViewSectionForControllerSection:(NSInteger)controllerSection withController:(id<HRSTableViewSectionController>)controller {
	NSInteger sectionOffset = [self.sectionController indexOfObject:controller];
	NSInteger tableViewSection = controllerSection + sectionOffset;
	return tableViewSection;
}

- (NSIndexPath *)tableViewIndexPathForControllerIndexPath:(NSIndexPath *)controllerIndexPath withController:(id<HRSTableViewSectionController>)controller {
	NSInteger section = [self tableViewSectionForControllerSection:controllerIndexPath.section withController:controller];
	NSIndexPath *tableViewIndexPath = [NSIndexPath indexPathForRow:controllerIndexPath.row inSection:section];
	return tableViewIndexPath;
}

@end
