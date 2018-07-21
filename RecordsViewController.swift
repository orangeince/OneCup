//
//  RecordsViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/12/8.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class RecordsViewController: UIViewController, UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController?
    var _modelController: ModelController? = nil
    var modelController: ModelController {
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.cornerRadius = 8.0
        self.view.layer.masksToBounds = true
        // Do any additional setup after loading the view.
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self
        let startViewController: StatisticViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        self.pageViewController!.dataSource = self.modelController
        
        self.addChild(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        let pageViewRect = self.view.bounds
        
        self.pageViewController!.view.frame = pageViewRect.insetBy(dx: 0, dy: 30.0).offsetBy(dx: 0.0, dy: 30.0)
        //self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMove(toParent: self)
        
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
