//
//  ViewController.swift
//  StarView
//
//  Created by Pulkit Rohilla on 24/07/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScoreViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func scoreForStarAtIndex(index: NSInteger) -> NSInteger {
        
        return index
    }
    
    func titleForStarAtIndex(index: NSInteger) -> NSString {
        
        return "Title"
    }
}

