#Changelog

The versioning in this project is based on [Semantic Versioning](http://semver.org).

## v0.2.3
- Fix an issue that caused a crash when the `HRSTableViewSectionCoordinator`was dealloc'ed while the underlying table view was still scrolling.
The coordinator failed to unregister itself from the table view (delegate & data source) on `-dealloc`, causing crashes (delegate and data source are kept as `unsafe_unretained` properties by the table view / scroll view).

## v0.2.2
- Fix an issue that created a retain cycle between a `HRSTableViewSectionController` and its table view proxy resulting in the `UITableView` not being released.

## v0.2.1
- Fix an issue where passing nil as the index path to `dynamicIndexPathForStaticIndexPath:` or `staticIndexPathForDynamicIndexPath:` returned an index path instead of `nil`.
- Fix an issue where calling `setSectionController:` more than once with the same instance of a section controller resulted in the section controller's coordinator becoming `nil`.

## v0.2.0
Add `NSPredicate` support for the HRS Index Path Mapping module. You can now easily specify conditions based on `NSPredicate`.

## v0.1.1
Release 0.1.1 completes the documentation of the header files. In this version all header files are fully documented.

*This version does not change any source code.*

## v0.1.0
- Initial release including the modules:
	- HRS Section Controller
	- HRS Index Path Mapping
