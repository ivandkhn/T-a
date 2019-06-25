//
//  FirstViewController.swift
//  T-a
//
//  Created by Иван Дахненко on 19/05/2019.
//  Copyright © 2019 Ivan Dakhnenko. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    var redrawTimer = Timer()
    var ticksPerSecond = 100
    
    @IBOutlet weak var drawView: DrawView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.setNeedsDisplay()
        drawView.setBounds()
        recreateTimer(withInterval: 1.0/Double(ticksPerSecond))
    }
    
    @objc func updateDrawView() {
        drawView.setNeedsDisplay()
    }
    
    func recreateTimer(withInterval interval: Double) {
        redrawTimer.invalidate()
        redrawTimer = Timer.scheduledTimer(timeInterval: interval,
                                    target: self,
                                    selector: #selector(updateDrawView),
                                    userInfo: nil,
                                    repeats: true)
    }
    
    @IBAction func slider1dragged(_ sender: UISlider) {
        ticksPerSecond = Int(sender.value)
        recreateTimer(withInterval: 1.0/Double(ticksPerSecond))
    }
    
    @IBAction func slider2dragged(_ sender: UISlider) {
        drawView.controller.changeAmount(to: Int(sender.value))
    }
    
    @IBAction func button1clicked(_ sender: UIButton) {
        updateDrawView()
    }
    
    @IBAction func button2clicked(_ sender: UIButton) {
    }
}

class DrawView: UIView {
    var controller = CircleController()
    
    func setBounds() {
        controller.bounds = bounds
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {return}
        
        for circle in controller.circlesArray {
            context.strokeEllipse(in: circle.toCGRect())
            circle.updateCoordinates()
            if circle.isCollision(withinBound: rect) {
                circle.changeDirection(
                    coordinate: circle.getCollisionCoordinate(withinBound: rect)
                )
            }
        }
    }
}

class CircleController {
    var circlesArray: [Circle]
    var bounds = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    init() {
        circlesArray = [Circle(x: 100, y: 100, r: 10, dx: 1, dy: 1)]
    }
    
    func changeAmount(to newAmount: Int) {
        let diff = newAmount - circlesArray.count
        if diff < 0 {
            for _ in 0..<abs(diff) {
                _ = circlesArray.popLast()
            }
        } else {
            for _ in 0..<diff {
                circlesArray.append(getNewCircle(withinBounds: bounds))
            }
        }
    }
    
    func getNewCircle(withinBounds rect: CGRect) -> Circle {
        return Circle(x: Int.random(min: Int(rect.minX)+10, max: Int(rect.maxX)-10),
                      y: Int.random(min: Int(rect.minY)+10, max: Int(rect.maxY)-10),
                      r: 10,
                      dx: Int(CGFloat.randomSign),
                      dy: Int(CGFloat.randomSign))
    }
    
}

class Circle {
    enum coordinates {
        case x
        case y
    }
    
    var x: Int
    var y: Int
    var r: Int
    var dx: Int
    var dy: Int
    
    func toCGRect() -> CGRect {
        return CGRect(x: x-r/2, y: y-r/2, width: r, height: r)
    }
    
    init(x: Int, y: Int, r: Int, dx: Int, dy: Int) {
        self.x = x
        self.y = y
        self.r = r
        self.dx = dx
        self.dy = dy
    }
    
    func updateCoordinates() {
        x += dx
        y += dy
    }
    
    func changeDirection(coordinate: coordinates) {
        switch coordinate {
        case .x:
            dx = -dx
        case .y:
            dy = -dy
        }
    }
    
    func isCollision(withinBound rect: CGRect) -> Bool {
        return x-r/2 < Int(rect.minX) || y-r/2 < Int(rect.minY) ||
               x+r/2 > Int(rect.maxX) || y+r/2 > Int(rect.maxY)
    }
    
    func getCollisionCoordinate(withinBound rect: CGRect) -> coordinates {
        if x-r/2 <= Int(rect.minX) || x+r/2 >= Int(rect.maxX) {
            return .x
        } else {
            return .y
        }
    }
}
