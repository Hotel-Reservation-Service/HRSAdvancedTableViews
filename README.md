# HRSAdvancedTableViews

[![CI Status](http://img.shields.io/travis/Hotel-Reservation-Service/HRSAdvancedTableViews.svg?style=flat-square)](https://travis-ci.org/Hotel-Reservation-Service/HRSAdvancedTableViews)

[![License](https://img.shields.io/cocoapods/l/HRSAdvancedTableViews.svg?style=flat-square)](http://cocoadocs.org/docsets/HRSAdvancedTableViews)
[![Platform](https://img.shields.io/cocoapods/p/HRSAdvancedTableViews.svg?style=flat-square)](http://cocoadocs.org/docsets/HRSAdvancedTableViews)

[![Version](https://img.shields.io/cocoapods/v/HRSAdvancedTableViews.svg?style=flat-square)](http://cocoadocs.org/docsets/HRSAdvancedTableViews)
[![Release](http://img.shields.io/github/release/Hotel-Reservation-Service/HRSAdvancedTableViews.svg?style=flat-square)](https://github.com/Hotel-Reservation-Service/HRSAdvancedTableViews/releases)
[![Issues](http://img.shields.io/github/issues/Hotel-Reservation-Service/HRSAdvancedTableViews.svg?style=flat-square)](https://github.com/Hotel-Reservation-Service/HRSAdvancedTableViews/issues)

The Advanced Table Views library is a set of modules that make handling table views more convenient. The different modules are split into cocoapods subspecs so that you can only include the modules you are interested in. Some of the modules (like `HRSIndexPathMapping`) have advantages that might also be useful for other tasks than just table views, however they are mainly designed for the work with table views.


## Modules

Below you see a short overview about the various modules in this project. For a more detailed info about each of the modules, please refer to the wiki page on GitHub.

### HRSSectionController
The section controller module deals with the problem of overloaded table view controllers. It separates the data model of a table view by its sections. Each section has its own controller that is responsible for providing the table view with the information it needs by implementing the necessary methods from `UITableViewDelegate` and `UITableViewDataSource`.

### HRSIndexPathMapping
The index path mapping module is used for mapping index paths of every kind through a visibility / active state. This is mostly used to map index paths in the `UITableView` or `UICollectionView` context but can be used by every other logic that deals with index paths and needs to map between two sets of index paths based on various conditions.

In practice, this is used to collapse or hide a couple of rows or sections inside a table view based on your current model data.


## Requirements

## Installation

`HRSAdvancedTableViews` is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile if you want to install all of the modules:

    pod "HRSAdvancedTableViews"

If you only want to install a specific module, use one of the following lines:

    pod "HRSAdvancedTableViews/HRSSectionController"
    pod "HRSAdvancedTableViews/HRSIndexPathMapping"


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The example project gives you a list of available samples, grouped by the different modules in the project.


## License

HRSAdvancedTableViews is available under the Apache License, Version 2.0 license. See the LICENSE file for more info.
