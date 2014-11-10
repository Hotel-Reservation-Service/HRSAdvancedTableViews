Pod::Spec.new do |s|
  s.name             = "HRSAdvancedTableViews"
  s.version          = "0.2.0"
  s.summary          = "HRSAdvancedTableViews is a collection of useful table view additions, split into several subspecs."
  s.description      = <<-DESC
                       The Advanced Table Views library is a set of modules that make handling table views more convenient. The different modules are split into cocoapods subspecs so that you can only include the modules you are interested in. Some of the modules (like `HRSIndexPathMapping`) have advantages that might also be useful for other tasks than just table views, however they are mainly designed for the work with table views.


                       # HRSSectionController

                       The section controller module deals with the problem of overloaded table view controllers. It separates the data model of a table view by its sections. Each section has its own controller that is responsible for providing the table view with the information it needs by implementing the necessary methods from `UITableViewDelegate` and `UITableViewDataSource`.


                       # HRSIndexPathMapping

                       The index path mapping module is used for mapping index paths of every kind through a visibility / active state. This is mostly used to map index paths in the `UITableView` or `UICollectionView` context but can be used by every other logic that deals with index paths and needs to map between two sets of index paths based on various conditions.

                       In practice, this is used to collapse or hide a couple of rows or sections inside a table view based on your current model data.
                       DESC
  s.homepage         = "https://github.com/Hotel-Reservation-Service/HRSAdvancedTableViews"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "HRS Hotel Reservation Service, Michael Ochs" => "michael.ochs@hrs.com" }
  s.source           = { :git => "https://github.com/Hotel-Reservation-Service/HRSAdvancedTableViews.git", :tag => s.version.to_s }

  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.frameworks       = 'UIKit'

  s.subspec "HRSSectionController" do |sc|
    sc.source_files = 'Pod/Classes/HRSSectionController/**/*.{h,m}'
    sc.public_header_files = 'Pod/Classes/HRSSectionController/*.h'
  end

  s.subspec "HRSIndexPathMapping" do |sc|
    sc.source_files = 'Pod/Classes/HRSIndexPathMapping/**/*.{h,m}'
    sc.public_header_files = 'Pod/Classes/HRSIndexPathMapping/*.h'
  end

end
