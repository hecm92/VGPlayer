//
//  VGPlayerLoadingIndicator.swift
//  VGPlayer
//
//  Created by Vein on 2017/6/5.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit

fileprivate let kRotationAnimationKey = "kRotationAnimationKey.rotation"

open class VGPlayerLoadingIndicator: UIView {
    
   fileprivate let indicatorLayer = CAShapeLayer()
    var timingFunction : CAMediaTimingFunction!
    var isAnimating = false
    var indicatorView = UIImageView()

   public override init(frame : CGRect) {
        super.init(frame : frame)
        commonInit()
    }
    
   public convenience init() {
        self.init(frame:CGRect.zero)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    override open func layoutSubviews() {
        //indicatorLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height);
        indicatorView.frame = CGRect(x: 0, y: 0, width: 120, height: 120);
        
        //updateIndicatorLayerPath()
    }
    
   internal func commonInit(){
    timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        //setupIndicatorLayer()
        setupIndicatorView()
    }
    
   internal func setupIndicatorLayer() {
        indicatorLayer.strokeColor = UIColor.white.cgColor
        indicatorLayer.fillColor = nil
        indicatorLayer.lineWidth = 2.0
        indicatorLayer.lineJoin = CAShapeLayerLineJoin.round;
        indicatorLayer.lineCap = CAShapeLayerLineCap.round;
        layer.addSublayer(indicatorLayer)
        updateIndicatorLayerPath()
    }
    
    internal func setupIndicatorView(){
        let loaderGif = UIImage.gifImageWithName("gif_alfa")
        
        indicatorView.image = loaderGif
        indicatorView.frame = CGRect(x: frame.width/2 - 60, y: frame.height/2 - 60, width: 30, height: 30)
        //                loaderImageView.bounds = CGRect(x: bounds.width/2 - 60, y: bounds.height/2 - 60, width: 120, height: 120)
        indicatorView.center = center
        addSubview(indicatorView)
        bringSubviewToFront(indicatorView)
        layer.addSublayer(indicatorView.layer)
        self.backgroundColor = .clear
    }
    
   internal func updateIndicatorLayerPath() {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = min(self.bounds.width / 2, self.bounds.height / 2) - indicatorLayer.lineWidth / 2
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = 2 * CGFloat(Double.pi)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        indicatorLayer.path = path.cgPath
        
        indicatorLayer.strokeStart = 0.1
        indicatorLayer.strokeEnd = 1.0
    }
    
    open var lineWidth: CGFloat {
        get {
            return indicatorLayer.lineWidth
        }
        set(newValue) {
            indicatorLayer.lineWidth = newValue
            updateIndicatorLayerPath()
        }
    }
    
   open var strokeColor: UIColor {
        get {
            return UIColor(cgColor: indicatorLayer.strokeColor!)
        }
        set(newValue) {
            indicatorLayer.strokeColor = newValue.cgColor
        }
    }
    
   open func startAnimating() {
        if self.isAnimating {
            return
        }
        indicatorView.isHidden = false
        /*let animation = CABasicAnimation(keyPath: "transform.rotation")
         animation.duration = 1
         animation.fromValue = 0
         animation.toValue = (2 * Double.pi)
         animation.repeatCount = Float.infinity
         animation.isRemovedOnCompletion = false
         indicatorLayer.add(animation, forKey: kRotationAnimationKey)*/
        isAnimating = true;
    }
    
   open func stopAnimating() {
        if !isAnimating {
            return
        }
    indicatorView.isHidden = true
    //indicatorLayer.removeAnimation(forKey: kRotationAnimationKey)
    isAnimating = false;
    }
    
}

import ImageIO
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}



extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL? = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
}

