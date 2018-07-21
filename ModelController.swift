//
//  ModelController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/12/8.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit


class ModelController: NSObject, UIPageViewControllerDataSource {
    
    //var pageData: [String] = []
    var dataViewController: StatisticViewController!
    var secondViewController: StatisticViewController!
    var count = 0
    
    
    override init() {
        super.init()
        // Create the data model.
        //let dateFormatter = NSDateFormatter()
        //pageData = dateFormatter.monthSymbols
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.dataViewController = storyboard.instantiateViewController(withIdentifier: "StatisticViewController") as? StatisticViewController
        self.dataViewController.referenceIndex = 0
        self.secondViewController = storyboard.instantiateViewController(withIdentifier: "StatisticViewController") as? StatisticViewController
        self.secondViewController.referenceIndex = 1
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> StatisticViewController? {
        // Return the data view controller for the given index.
        //if (self.pageData.count == 0) || (index >= self.pageData.count) {
        //return nil
        //}
        
        // Create a new view controller and pass suitable data.
        if index == 0 {
            return self.dataViewController
        } else {
            return self.secondViewController
        }
    }
    
    func indexOfViewController(_ viewController: StatisticViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        //return pageData.indexOf(viewController.dataObject) ?? NSNotFound
        //return NSNotFound
        return 1
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        /*
        var index = self.indexOfViewController(viewController as! StatisticViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        if let dataViewController = self.dataViewController {
            return dataViewController
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
*/
        if let vc = viewController as? StatisticViewController {
            let index = vc.referenceIndex
            if index == 1 {
                return self.viewControllerAtIndex(0, storyboard: viewController.storyboard!)
            }
            return self.viewControllerAtIndex(1, storyboard: viewController.storyboard!)
        }
        return nil
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        /*
        var index = self.indexOfViewController(viewController as! StatisticViewController)
        if index == NSNotFound {
            return nil
        }
        
        index++
        /*if index == self.pageData.count {
        return nil
        }*/
        if let dataViewController = self.dataViewController {
            return dataViewController
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
*/
        if let vc = viewController as? StatisticViewController {
            let index = vc.referenceIndex
            if index == 1 {
                return self.viewControllerAtIndex(0, storyboard: viewController.storyboard!)
            }
            return self.viewControllerAtIndex(1, storyboard: viewController.storyboard!)
        }
        return nil
    }
    
}

