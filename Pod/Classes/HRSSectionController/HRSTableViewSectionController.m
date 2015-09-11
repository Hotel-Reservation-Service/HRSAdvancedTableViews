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

#import "HRSTableViewSectionController.h"

#import "HRSTableViewSectionCoordinator.h"


@interface HRSTableViewSectionController ()

@property (nonatomic, strong, readwrite) UITableView *tableView;

@property (nonatomic, strong, readwrite) UITraitCollection *lastTraitCollection;

@end


@implementation HRSTableViewSectionController

@synthesize coordinator = _coordinator;

- (UIResponder *)nextResponder {
	return self.coordinator;
}

- (void)tableViewDidChange:(UITableView *)tableView {
	self.tableView = tableView;
}



#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.sectionHeaderTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return self.sectionFooterTitle;
}



#pragma mark - table view delegate



#pragma mark - UITraitEnvironment

- (void)_updateTraitCollectionIfNecessary {
    UITraitCollection *traitCollection = self.traitCollection;
    UITraitCollection *lastTraitCollection = self.lastTraitCollection;
    if (lastTraitCollection != traitCollection && [traitCollection isEqual:lastTraitCollection] == NO) {
        [self traitCollectionDidChange:lastTraitCollection];
        self.lastTraitCollection = traitCollection;
    }
}

- (UITraitCollection *)traitCollection {
    UITraitCollection *parentTraitCollection = [self.coordinator traitCollection];
    return parentTraitCollection;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    // empty - used for subclassing
}

@end
