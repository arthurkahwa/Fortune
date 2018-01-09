//
//  DetailViewController.swift
//  PithySayings
//
//  Created by Arthur Nsereko Kahwa on 01/08/2018.
//  Copyright © 2018 Arthur Nsereko Kahwa. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var sayingTextView: UITextView!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let category = categoryItem {
            if let label = detailDescriptionLabel {
                label.text = category.name
                
                let sayings = category.saying
                
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
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

