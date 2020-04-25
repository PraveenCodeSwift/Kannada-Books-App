//
//  MenuViewController.swift
//  kannada
//
//  Created by PraveenH on 25/04/20.
//  Copyright © 2020 books. All rights reserved.
//

import UIKit

protocol MenuToDashboard {
    func tapOnIndex(index : Int)
    func tapOnValue(value : String)
    func navigateToVC(vc : UIViewController)
}


class MenuViewController: UIViewController {
    
     var delegate : MenuToDashboard?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
