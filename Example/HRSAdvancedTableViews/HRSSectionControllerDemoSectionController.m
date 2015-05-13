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

#import "HRSSectionControllerDemoSectionController.h"

#import <HRSAdvancedTableViews/HRSTableViewSectionCoordinator+IndexPathMapping.h>


@implementation HRSSectionControllerDemoSectionController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (section + 1) * 10; // this should result in 10 rows in every section!
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"In"];
		cell.textLabel.text = [NSString stringWithFormat:@"(%d-%d)", (int)indexPath.section, (int)indexPath.row];
		return cell;
	} else {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Out"];
		cell.textLabel.text = [NSString stringWithFormat:@"(%d-%d) > Out of section!", (int)indexPath.section, (int)indexPath.row];
		return cell;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"%d - %d", (int)section, (int)[self.coordinator tableViewSectionForControllerSection:section withController:self]];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row % 2 == 0) {
		return [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
	} else {
		return indexPath;
	}
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did end displaying %@", indexPath);
}

@end
