//
//  WaterVolumeViewController.swift
//  WaterPlan
//
//  Created by 赵少龙 on 15/11/15.
//  Copyright © 2015年 OITown. All rights reserved.
//

import UIKit

class WaterVolumeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var pickedVolume = 0
    let maxVolume = 1200
    var cupBtn: OICupButton!
    var volumeBtns = [VolumeBtn]()
    
    var waterView = UIView()
    var volumePicker = UIPickerView()
    var cupBlurView = UIVisualEffectView()
    var submitBtn = UIButton()
    var imageMask = UIImageView(image: UIImage(named: "emptyCup"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cupBtn = OICupButton()
        
        cupBtn.tintColor = UIColor.whiteColor()
        cupBtn.backgroundColor = UIColor.whiteColor()
        
        let blurView = UIVisualEffectView()
        blurView.frame = self.view.bounds
        
        for index in 0...3 {
            let btn = VolumeBtn(frame: CGRectMake(0, 0, 50, 50), volume: (index + 1) * 200)
            //btn.setBackgroundImage(UIImage(named: "cat"), forState: .Normal)
            btn.backgroundColor = UIColor.whiteColor()
            volumeBtns.append(btn)
            blurView.contentView.addSubview(btn)
            btn.setTitle(String(btn.volume), forState: .Normal)
            btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            btn.addTarget(self, action: "tapVolumeBtn:", forControlEvents: .TouchUpInside)
        }
        
        blurView.contentView.addSubview(cupBtn)
        
        volumePicker.delegate = self
        volumePicker.dataSource = self
        
        submitBtn.layer.cornerRadius = 8
        submitBtn.layer.masksToBounds = true
        submitBtn.layer.borderWidth = 1.0
        submitBtn.setTitle("确定", forState: .Normal)
        submitBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        submitBtn.setTitleColor(UIColor.lightGrayColor(), forState: .Highlighted)
        submitBtn.addTarget(self, action: "tapSubmitBtn:", forControlEvents: .TouchUpInside)
        //submitBtn.setImage(UIImage(named: "cat"), forState: .Normal)
        
        
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
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 11
        } else if component == 1 {
            return 10
        }
        return 1
    }
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let view = UIView()
        let size = pickerView.rowSizeForComponent(component)
        view.frame = CGRectMake(0, 0, size.width, size.height)
        let label = UILabel()
        label.frame = view.bounds
        if component == 0 {
            label.text = String(row)
            label.textAlignment = .Right
        } else if component == 1 {
            label.text = String(row) + "0"
            label.textAlignment = .Center
        } else {
            label.text = "ml"
            label.font = UIFont.systemFontOfSize(8.0)
            label.textAlignment = .Left
        }
        view.addSubview(label)
        return view
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 2 {
            return 12.0
        }
        return 32.0
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedVolume = pickerView.selectedRowInComponent(0) * 100 + pickerView.selectedRowInComponent(1) * 10
        pickVolume(true)
    }
    func pickVolume(animate: Bool) {
        let bounds = cupBtn.bounds
        let waterRatio = CGFloat(pickedVolume) / CGFloat(maxVolume)
        let height = bounds.height * waterRatio
        if animate {
            UIView.animateWithDuration(0.6) { () -> Void in
                self.waterView.frame = CGRectMake(0, bounds.height - height, bounds.width, height)
            }
        } else {
            self.waterView.frame = CGRectMake(0, bounds.height - height, bounds.width, height)
        }
        
    }
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 32.0
    }
    func initPickedVolume(volume: Int) {
        volumePicker.selectRow(volume / 100, inComponent: 0, animated: false)
        volumePicker.selectRow((volume % 100) / 10, inComponent: 1, animated: false)
        pickedVolume = volume
        pickVolume(true)
    }
    func tapSubmitBtn(button: UIButton) {
        if let presented = self.presentingViewController as? DrinkingViewController {
            presented.pickedVolume = pickedVolume
            presented.dismissWaterVolumeViewController(pickedVolume)
        }
    }
}
