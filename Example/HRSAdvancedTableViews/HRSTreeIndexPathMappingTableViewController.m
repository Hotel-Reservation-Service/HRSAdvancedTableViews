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

#import "HRSTreeIndexPathMappingTableViewController.h"

#import <HRSAdvancedTableViews/HRSIndexPathMapping.h>


@interface HRSTreeIndexPathMappingTableViewController ()

@property (nonatomic, strong, readwrite) NSArray *tree;
@property (nonatomic, strong, readwrite) HRSIndexPathMapper *mapper;
@property (nonatomic, strong, readwrite) NSIndexPath *baseIndexPath;

@end


@implementation HRSTreeIndexPathMappingTableViewController

- (instancetype)initWithURL:(NSURL *)url mapper:(HRSIndexPathMapper *)mapper indexPath:(NSIndexPath *)indexPath {
	self = [self initWithStyle:UITableViewStyleGrouped];
	if (self) {
		NSArray *tree = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];
		_tree = tree;
		_mapper = mapper;
		_baseIndexPath = indexPath;
	}
	return self;
}

- (instancetype)init {
	self = [self initWithStyle:UITableViewStyleGrouped];
	if (self) {
		NSURL* appURL = [[[[NSBundle mainBundle] executableURL] URLByDeletingLastPathComponent] URLByDeletingLastPathComponent];
		NSArray *tree = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:appURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];
		_tree = tree;
		
		_mapper = [HRSIndexPathMapper new];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Demo"];
}



#pragma mark - Table view data source

- (NSIndexPath *)dataIndexPathForRow:(NSUInteger)row {
	NSIndexPath *newIndexPath;
	if (self.baseIndexPath) {
		newIndexPath = [[self.mapper dynamicIndexPathForStaticIndexPath:self.baseIndexPath] indexPathByAddingIndex:row];
	} else {
		newIndexPath = [NSIndexPath indexPathWithIndex:row];
	}
	return [self.mapper staticIndexPathForDynamicIndexPath:newIndexPath];
}

- (NSURL *)urlForRow:(NSUInteger)row {
	NSIndexPath *dataIndexPath = [self dataIndexPathForRow:row];
	
	NSURL* url = self.tree[[dataIndexPath indexAtPosition:dataIndexPath.length-1]];
	return url;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"In this example you can 'delete' files by swipe-to-delete. These files are then marked in an index path mapper as invisible. They are not actually deleted.\n\nIf you swipe on a folder, you can also restore every deleted file and folder inside this folder recursively.\n\nThis example demonstrates how index path mapping can be used to navigate through a complex data structure.";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSIndexPath *countIndexPath = (self.baseIndexPath ? [self.baseIndexPath indexPathByAddingIndex:self.tree.count] : [NSIndexPath indexPathWithIndex:self.tree.count]);
    return [[self.mapper dynamicIndexPathForStaticIndexPath:countIndexPath] indexAtPosition:self.baseIndexPath.length];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Demo" forIndexPath:indexPath];
	
	NSURL* url = [self urlForRow:indexPath.row];
	BOOL isDirectory = NO;
	[[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&isDirectory];
	
	cell.textLabel.text = [url lastPathComponent];
	cell.accessoryType = (isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
	
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSURL* url = [self urlForRow:indexPath.row];
	BOOL isDirectory = NO;
	[[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&isDirectory];
	
	return (isDirectory ? indexPath : nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSURL* url = [self urlForRow:indexPath.row];
	HRSTreeIndexPathMappingTableViewController *viewController = [[[self class] alloc] initWithURL:url mapper:self.mapper indexPath:[self dataIndexPathForRow:indexPath.row]];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSURL* url = [self urlForRow:indexPath.row];
	BOOL isDirectory = NO;
	[[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&isDirectory];
	
	NSMutableArray *actions = [NSMutableArray array];
	
	if (self.baseIndexPath) {
		UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
			NSIndexPath *dataIndexPath = [self dataIndexPathForRow:indexPath.row];
			[[self mapper] setConditionForIndexPath:dataIndexPath condition:^BOOL{
				return NO;
			}];
			[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
		}];
		[actions addObject:delete];
	}
	
	if (isDirectory) {
		UITableViewRowAction *restore = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Restore" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
			NSIndexPath *dataIndexPath = [self dataIndexPathForRow:indexPath.row];
			[[self mapper] removeConditionForIndexPath:dataIndexPath descendant:YES];
			[self.tableView setEditing:NO animated:YES];
		}];
		[actions addObject:restore];
	}
	
	return actions;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	// this is needed for the edit actions delegate to be called.
}

@end
