//
//  WaterVolumeViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/11/15.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class WaterVolumeViewController: UIViewController {

    var selectedVolume = 0
    var cupBtn: UIButton!
    var volumeBtns = [VolumeBtn]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cupBtn = UIButton()
        cupBtn.setImage(UIImage(named: "emptyCup"), forState: .Normal)
        
        let blurView = UIVisualEffectView()
        blurView.frame = self.view.bounds
        
        for index in 0...3 {
            let btn = VolumeBtn(frame: CGRectMake(0, 0, 50, 50), volume: (index + 1) * 100)
            //btn.setBackgroundImage(UIImage(named: "cat"), forState: .Normal)
            btn.backgroundColor = UIColor.whiteColor()
            volumeBtns.append(btn)
            blurView.contentView.addSubview(btn)
            btn.setTitle(String(btn.volume), forState: .Normal)
            btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            btn.addTarget(self, action: "tapVolumeBtn:", forControlEvents: .TouchUpInside)
        }
        
        blurView.contentView.addSubview(self.cupBtn)
        
        self.view = blurView
        self.view.layer.cornerRadius = 8
        self.view.layer.masksToBounds = true
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let view = self.view as? UIVisualEffectView {
            let gr = UITapGestureRecognizer(target: self, action: "dismissGestureRecognizer:")
            view.contentView.addGestureRecognizer(gr)
        }
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
    
    func dismissGestureRecognizer(gesture: UITapGestureRecognizer) {
        if let presented = self.presentingViewController {
            presented.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    func tapVolumeBtn(sender: VolumeBtn) {
        if let presented = self.presentingViewController as? DrinkingViewController {
            let volume = sender.volume
            presented.dismissWaterVolumeViewController(volume)
        }
    }
}
