#Changelog

The versioning in this project is based on [Semantic Versioning](http://semver.org).

## v0.3.2
- Add a respondency check before forwarding a `- scrollViewDidScroll` call to a `HRSTableViewSectionController`. (See [\#25](https://github.com/Hotel-Reservation-Service/HRSAdvancedTableViews/pull/25))

## v0.3.1
- Introduce a new property on `HRSTableViewSectionCoordinator` to make the row animation type configurable. The section coordinator uses animations
  to add/remove sections from the table view in case `setSectionController:animated:` is called with the `animated` flag set to `YES`. The animation
  type used to be always `UITableViewRowAnimationAutomatic`; now the type can be configured. Moreover, the default behavior changes with this version
  insofar as the coordinator now uses `UITableViewRowAnimationNone` if no other type is explicitly defined.

## v0.3.0
- Introduce trait collections in `HRSTableViewSectionCoordinator` and `HRSTableViewSectionController` to be able to adapt to different size classes.
- Fix Xcode 7 GM designated initializer warnings.

## v0.2.5
- Fix an issue that resulted in a crash or miss directed method calls when resetting sections under rare circumstances (See [\#16](https://github.com/Hotel-Reservation-Service/HRSAdvancedTableViews/pull/18))

## v0.2.4
- Fix an issue that resulted in delegate methods not being called under rare circumstances. (See [\#13](https://github.com/Hotel-Reservation-Service/HRSAdvancedTableViews/issues/13) for more details)

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
