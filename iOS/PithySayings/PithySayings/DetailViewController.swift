//
//  DetailViewController.swift
//  PithySayings
//
//  Created by Arthur Nsereko Kahwa on 01/08/2018.
//  Copyright © 2018 Arthur Nsereko Kahwa. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var textView: UITextView!
    var sayingText: String!
    
    func configureView() {
        // Update the user interface for the detail item.
        
        if let category = categoryItem {
            // print("\(String(describing: category.name))")
            self.navigationItem.title = category.name
            
            // self.navigationItem.backBarButtonItem?.title = ""
            
            if let sayings = category.sayings as? Set<Saying> {
                if sayings.isEmpty {
                    sayingText = "- EMPTY -"
                }
                else {
                    let randomOffset = Int(arc4random_uniform(UInt32(sayings.count)))
                    let randomIndex = sayings.index(sayings.startIndex, offsetBy: randomOffset)
                    let randomSaying = sayings[randomIndex]
                    
                    sayingText = randomSaying.text
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        textView.text = sayingText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var categoryItem: Category? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

