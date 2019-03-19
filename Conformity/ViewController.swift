//
//  ViewController.swift
//  Conformity
//
//  Created by Sarah Mautsch on 12.02.19.
//  Copyright © 2019 Sarah Mautsch. All rights reserved.
//

import UIKit
import EstimoteProximitySDK

class ViewController: UIViewController {
    
    var layoutStack = UIStackView()
    let credentials = CloudCredentials(appID: "conformity-9j8", appToken: "df7fa858e14802c99dc72d88a5bc0bd7")
    var proximityObserver : ProximityObserver?
    var sliderArray : [SMSlider] = []
    var switchArray : [SMSwitch] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.appropriatePurple
        
        self.view.addSubview(layoutStack)
        
        layoutStack.alignment = .fill
        layoutStack.distribution = .fill
        layoutStack.spacing = 24
        layoutStack.axis = .vertical
        
        layoutStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(50)
            make.trailing.equalToSuperview().inset(50)
            make.center.equalToSuperview()
        }
        
        for _ in 0...2 {
            let slider = SMSlider()
            sliderArray.append(slider)
            slider.setPercentage(toValue: 0.5)
            layoutStack.addArrangedSubview(slider)
        }
        
        let switchStack = UIStackView()
        switchStack.axis = .horizontal
        switchStack.distribution = .equalSpacing
        
        for _ in 0...1 {
            let switchUI = SMSwitch()
            switchArray.append(switchUI)
            switchUI.setValue(toOnState: false)
            switchStack.addArrangedSubview(switchUI)
        }
        
        layoutStack.addArrangedSubview(switchStack)        
        
        let locationViewContainer = UIView()
        self.view.addSubview(locationViewContainer)
        locationViewContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(layoutStack.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        let locationView = AAView()
        locationView.cornerRadius = 10
        locationView.contentView.backgroundColor = UIColor.white
        
        locationViewContainer.addSubview(locationView)
        locationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let locationStack = UIStackView()
        locationStack.axis = .horizontal
        locationStack.spacing = 6
        
        locationView.addSubview(locationStack)
        locationStack.snp.makeConstraints { make in
            var insets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
            make.pinAllEdges(withInsets: insets, respectingSafeAreaLayoutGuidesOfView: nil)
        }
        
        let locationLabel = AALabel()
        locationLabel.text = "Home"
        locationLabel.textColor = UIColor.appropriatePurple
        locationLabel.font = UIFont.ceraFont(ofSize: 16, Weight: .medium)
        locationLabel.letterSpacing = 0.4
        locationLabel.sizeToFit()
        
        let locationIcon = UIImageView()
        locationIcon.image = UIImage(named: "location-icon")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        locationIcon.tintColor = UIColor.appropriatePurple
        locationIcon.transform = CGAffineTransform(translationX: 0, y: -1)
        locationIcon.snp.makeConstraints { make in
            make.height.equalTo(21)
            make.width.equalTo(21)
        }
        
        locationStack.addArrangedSubview(locationIcon)
        locationStack.addArrangedSubview(locationLabel)
        
        
        // Create observer instance
        self.proximityObserver = ProximityObserver(credentials: credentials, onError: { error in print("Ooops(error)")
        })
        
        // Define zones
        let mintZone = ProximityZone(tag: "mint", range: ProximityRange(desiredMeanTriggerDistance: 0.05)!)
        mintZone.onEnter = { zoneContext in
            DispatchQueue.main.async {
                print("Entered near range of tag 'mint'. Attachments payload: \(zoneContext.attachments)")
                locationLabel.text = "France"
                self.sliderArray[0].setPercentage(toValue: 1)
                self.sliderArray[1].setPercentage(toValue: 0.3)
                self.sliderArray[2].setPercentage(toValue: 0.6)
                self.switchArray[0].setValue(toOnState: false)
                self.switchArray[1].setValue(toOnState: true)
            }
        }
        mintZone.onExit = { zoneContext in
            print("Exited near range of tag 'mint'. Attachment payload: \(zoneContext.attachments)")
        }
        
        mintZone.onContextChange = { contexts in
            print("Now in range of \(contexts.count) contexts")
        }
        
        
        
        let coconutZone = ProximityZone(tag: "coconut", range: ProximityRange(desiredMeanTriggerDistance: 0.05)!)
        coconutZone.onEnter = { zoneContext in
            DispatchQueue.main.async {
                print("Entered near range of tag 'mint'. Attachments payload: \(zoneContext.attachments)")
                locationLabel.text = "Home"
                self.sliderArray[0].setPercentage(toValue: 0.15)
                self.sliderArray[1].setPercentage(toValue: 0.85)
                self.sliderArray[2].setPercentage(toValue: 0.5)
                self.switchArray[0].setValue(toOnState: true)
                self.switchArray[1].setValue(toOnState: false)
            }
            print("Entered near range of tag 'coconut'. Attachments payload: \(zoneContext.attachments)")
        }
        coconutZone.onExit = { zoneContext in
            print("Exited near range of tag 'coconut'. Attachment payload: \(zoneContext.attachments)")
        }
        
        coconutZone.onContextChange = { contexts in
            print("Now in range of \(contexts.count) contexts")
        }
        
        self.proximityObserver?.startObserving([coconutZone, mintZone])
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

class SMSwitch : UIView {
    
    var switchContainer = AAView()
    var toggle = AAView()
    
    init () {
        super.init(frame: CGRect.zero)
        
        self.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(36)
        }
        
        switchContainer.cornerRadius = Float.infinity
        self.addSubview(switchContainer)
        switchContainer.contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        switchContainer.contentView.layer.borderWidth = 3
        switchContainer.snp.makeConstraints { make in
            make.pinAllEdgesToSuperView()
        }
        
        switchContainer.addSubview(toggle)
        toggle.cornerRadius = Float.infinity
        toggle.contentView.backgroundColor = .white
        toggle.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(24)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(6)
        }
        
    }
    
    func setValue (toOnState on : Bool) {
        
        if on {
            toggle.snp.remakeConstraints { make in
                make.height.equalTo(24)
                make.width.equalTo(24)
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().inset(6)
            }
        } else {
            toggle.snp.remakeConstraints { make in
                make.height.equalTo(24)
                make.width.equalTo(24)
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().inset(6)
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            
            self.layoutIfNeeded()
            
            if on {
                self.switchContainer.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
                self.switchContainer.contentView.animateBorderColor(toColor: UIColor.white.withAlphaComponent(0), duration: 0.3)
            } else {
                self.switchContainer.contentView.backgroundColor = UIColor.white.withAlphaComponent(0)
                self.switchContainer.contentView.animateBorderColor(toColor: UIColor.white.withAlphaComponent(0.25), duration: 0.3)
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    func animateBorderColor(toColor: UIColor, duration: Double) {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = toColor.cgColor
        animation.duration = duration
        layer.add(animation, forKey: "borderColor")
        layer.borderColor = toColor.cgColor
    }
}


class SMSlider : UIView {
    
    let thumb = AAView()
    let trail = AAView()
    let track = AAView()
    
    var currentValue : Float = 0
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(track)
        track.cornerRadius = Float.infinity
        track.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        track.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(4)
            make.center.equalToSuperview()
        }
        
        self.addSubview(trail)
        trail.cornerRadius = Float.infinity
        trail.contentView.backgroundColor = UIColor.white.withAlphaComponent(1)
        
        self.addSubview(thumb)
        thumb.contentView.backgroundColor = UIColor.white
        thumb.cornerRadius = Float.infinity
        thumb.snp.makeConstraints { make in
            make.center.equalToSuperview()
            
            make.height.equalTo(36)
            make.width.equalTo(36)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        trail.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(thumb.snp.centerX)
            make.height.equalTo(4)
            make.centerY.equalToSuperview()
        }
        
        self.setPercentage(toValue: 0)
    }
    
    func setPercentage (toValue value : Float) {
        currentValue = value
        
        if currentValue == 0 {
            thumb.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.centerX.equalTo(self.snp.left)
                
                make.height.equalTo(24)
                make.width.equalTo(24)
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        } else {
            thumb.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.centerX.equalTo(self.snp.right).multipliedBy(currentValue)
                
                make.height.equalTo(24)
                make.width.equalTo(24)
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
