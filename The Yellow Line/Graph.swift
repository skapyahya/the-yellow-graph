//
//  Graph.swift
//  The Yellow Line
//
//  Created by Yahya Ayash Luqman on 29/09/16.
//  Copyright © 2016 Yaluqman. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "dd-MM-yyyy HH"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

class Graph {
    
    init(graphView: UIView, date: Date, completion: @escaping () -> Void) {
        let myView = GraphView()
        myView.setWidth(width: Double(graphView.frame.size.width))
        myView.setCompletion(completion: completion)
        myView.setDate(date: date)
        graphView.addSubview(myView)
    }
    
    class GraphView: UIView {
        
        var width: Double = 0;
        var completion: () -> Void = {() -> Void in
            return;
        };
        var date = Date();
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        func setWidth(width: Double) {
            self.width = width;
            setup();
        }
        
        func setDate(date: Date) {
            self.date = date
        }
        
        func setCompletion(completion: @escaping () -> Void) {
            self.completion = completion
        }
        
        func SET_DIVD() -> Int { return 168; }
        
        func getSetArray(width: Double) -> [Double] {
            var result = [Double]();
            let sets = width/Double(SET_DIVD());
            result.insert(sets/2, at: 0)
            result.insert(result[0] + sets, at: 1);
            for i in 2...SET_DIVD() {
                result.insert(result[i-1] + sets, at: i);
            }
            return result;
        }
        
        func getMValue(completion: @escaping (_ result: mValue) -> Void) {
            let result = mValue();
            
            let uid = FIRAuth.auth()?.currentUser?.uid
            
            let ref : FIRDatabaseReference!
            ref = FIRDatabase.database().reference()
            ref.child("mood").child(uid!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                let data = snapshot.value
                
                if let _ : NSNull = data as? NSNull {
                    completion(result)
                    return;
                }
                
                for (i,j) in (data as! NSDictionary){
                    result.addMValue(time: Int(i as! String)!, value: Int(j as! String)!)
                }
                completion(result)
            })
        }

        
        func bezierPath(width: Double, completion: @escaping (_ Bezier : UIBezierPath) -> Void) {
            let myBezier = UIBezierPath()
            let setArray = getSetArray(width: width)
            
            var ns : [Int] = [];
            var na : [Int] = [];
            
            getMValue(completion: {(mValues) in
                let ADate = NSDate(dateString: "01-09-2016 00")
                let BDate = NSDate(dateString: "08-09-2016 00")
                let weekEpoch = BDate.timeIntervalSince(ADate as Date);
                let w = weekEpoch/Double(self.SET_DIVD());
                
                if(mValues.data.count < 1) {
                    completion(myBezier);
                    return;
                }
                
                mValues.data.sort(by: {(prev, next) in
                    return prev["Time"]! < next["Time"]!
                })
                
                for i in mValues.data {
                    // try to break datetime to slots
                    let n = Double(i["Time"]!) - (self.date.timeIntervalSince1970);
                    let a = Double(i["Value"]!)
                    
                    if n < 0 {
                        continue
                    }
                    
                    let nn = Int(n/w)
                    ns.append(nn)
                    
                    na.append(Int(a))
                }
                
                if(!setArray.indices.contains(ns[0])) {
                    completion(myBezier)
                    return;
                }
                
                myBezier.move(to: CGPoint(x: Int(setArray[ns[0]]), y: (10 - na[0]) * 10))
                myBezier.addArc(withCenter: CGPoint(x: Int(setArray[ns[0]]), y: (10 - na[0]) * 10), radius: 2.0, startAngle: 0.0, endAngle: 360.0, clockwise: true)
                myBezier.move(to: CGPoint(x: Int(setArray[ns[0]]), y: (10 - na[0]) * 10))
                
                var yCoord = 0;
                var k = 1;
                
                for i in 0...168 {
                    for j in ns {
                        if(ns[0] == j) {
                            continue
                        }
                        if(j == i) {
                            
                            let xCoord = Int(Double(setArray[i]));
                            yCoord = (10 - na[k]) * 10;
                            k += 1;
                            myBezier.addLine(to: CGPoint(x: xCoord, y: yCoord))
                            myBezier.addArc(withCenter: CGPoint(x: xCoord, y: yCoord), radius: 3.0, startAngle: 0.0, endAngle: 360.0, clockwise: true)
                            myBezier.move(to:CGPoint(x: xCoord, y: yCoord))
                        }
                    }
                    
                }
                UIColor.yellow.set()
                myBezier.stroke()
                completion(myBezier);
                return;
                
            });
            
        }
        
        func setup() {
            
            // Create a CAShapeLayer
            let shapeLayer = CAShapeLayer()
            
            // The Bezier path that we made needs to be converted to
            // a CGPath before it can be used on a layer.
            
            // add the new layer to our custom view
            self.layer.addSublayer(shapeLayer)
            
            createBezierPath(completion: {(Bezier) in
                
                shapeLayer.path = Bezier.cgPath
                
                // apply other properties related to the path
                shapeLayer.strokeColor = UIColor(netHex: 0xFBC02D).cgColor
                shapeLayer.fillColor = UIColor(netHex: 0xEEEEEE).cgColor
                shapeLayer.lineWidth = 3.0
                shapeLayer.position = CGPoint(x: 0, y: 10)
                self.completion()
                
            })
            
        }
        
        func createBezierPath(completion : @escaping (_ Bezier : UIBezierPath) -> Void) {
            
            // see previous code for creating the Bezier path
            bezierPath(width: self.width, completion: {(Bezier) in
                completion(Bezier)
            })
        }
    }

    class mValue {
        var data : [[String : Int]] = [];
        
        func addMValue (time: Int, value: Int) {
            var mv = [String : Int]();
            mv["Time"] = time;
            mv["Value"] = value;
            data.append(mv);
        }
        
        func count() -> Int {
            return self.data.count;
        }
    }
    
}
