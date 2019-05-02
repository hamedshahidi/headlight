//
//  ViewController.swift
//  Headlight
//
//  Created by Tuomas Pöyry on 16/04/2019.
//  Copyright © 2019 iSchoolMusical. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        let user = CoreDataHelper.getUserData()
        print(user?.name)
        if user != nil && user?.name.count ?? 0 > 0 {
            performSegue(withIdentifier: "frontPageSegue", sender: self)
        } else {
            performSegue(withIdentifier: "signUpSegue", sender: self)
        }
    }
}

