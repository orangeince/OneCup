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
        
        cupBtn.tintColor = UIColor.white
        cupBtn.backgroundColor = UIColor.white
        
        let blurView = UIVisualEffectView()
        blurView.frame = self.view.bounds
        
        for index in 0...3 {
            // 初始直径，容量越大直径越大
            var diameter = 40
            diameter += index * 6
            let btn = VolumeBtn(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter), volume: (index + 1) * 200)
            //btn.setBackgroundImage(UIImage(named: "cat"), for: .normal)
            btn.backgroundColor = UIColor.white
            volumeBtns.append(btn)
            blurView.contentView.addSubview(btn)
            btn.setTitle(String(btn.volume), for: .normal)
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.addTarget(self, action: #selector(WaterVolumeViewController.tapVolumeBtn(_:)), for: .touchUpInside)
        }
        
        blurView.contentView.addSubview(cupBtn)
        
        volumePicker.delegate = self
        volumePicker.dataSource = self
        
        submitBtn.layer.cornerRadius = 8
        submitBtn.layer.masksToBounds = true
        submitBtn.layer.borderWidth = 1.0
        submitBtn.setTitle("确定", for: UIControl.State())
        submitBtn.setTitleColor(UIColor.black, for: UIControl.State())
        submitBtn.setTitleColor(UIColor.lightGray, for: .highlighted)
        submitBtn.addTarget(self, action: #selector(WaterVolumeViewController.tapSubmitBtn(_:)), for: .touchUpInside)
        //submitBtn.setImage(UIImage(named: "cat"), forState: .Normal)
        
        
        self.view = blurView
        self.view.layer.cornerRadius = 8
        self.view.layer.masksToBounds = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let view = self.view as? UIVisualEffectView {
            let gr = UITapGestureRecognizer(target: self, action: #selector(WaterVolumeViewController.dismissGestureRecognizer(_:)))
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
    
    @objc func dismissGestureRecognizer(_ gesture: UITapGestureRecognizer) {
        if let presented = self.presentingViewController {
            presented.dismiss(animated: true, completion: nil)
        }
    }
    @objc func tapVolumeBtn(_ sender: VolumeBtn) {
        if let presented = self.presentingViewController as? DrinkingViewController {
            let volume = sender.volume
            presented.dismissWaterVolumeViewController(volume)
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 11
        } else if component == 1 {
            return 10
        }
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView()
        let size = pickerView.rowSize(forComponent: component)
        view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let label = UILabel()
        label.frame = view.bounds
        if component == 0 {
            label.text = String(row)
            label.textAlignment = .right
        } else if component == 1 {
            label.text = String(row) + "0"
            label.textAlignment = .center
        } else {
            label.text = "ml"
            label.font = UIFont.systemFont(ofSize: 8.0)
            label.textAlignment = .left
        }
        view.addSubview(label)
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 2 {
            return 12.0
        }
        return 32.0
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickedVolume = pickerView.selectedRow(inComponent: 0) * 100 + pickerView.selectedRow(inComponent: 1) * 10
        pickVolume(true)
    }
    func pickVolume(_ animate: Bool) {
        let bounds = cupBtn.bounds
        let waterRatio = CGFloat(pickedVolume) / CGFloat(maxVolume)
        let height = bounds.height * waterRatio
        if animate {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.waterView.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
            }) 
        } else {
            self.waterView.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 32.0
    }
    func initPickedVolume(_ volume: Int) {
        volumePicker.selectRow(volume / 100, inComponent: 0, animated: false)
        volumePicker.selectRow((volume % 100) / 10, inComponent: 1, animated: false)
        pickedVolume = volume
        pickVolume(true)
    }
    @objc func tapSubmitBtn(_ button: UIButton) {
        if let presented = self.presentingViewController as? DrinkingViewController {
            presented.pickedVolume = pickedVolume
            presented.dismissWaterVolumeViewController(pickedVolume)
        }
    }
}
