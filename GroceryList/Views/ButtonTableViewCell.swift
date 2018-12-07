//
//  ButtonTableViewCell.swift
//  GroceryList
//
//  Created by Steve Lederer on 12/7/18.
//  Copyright © 2018 Steve Lederer. All rights reserved.
//

import UIKit

// MARK: - ButtonTableViewCellDelegate
protocol ButtonTableViewCellDelegate: class {
    func buttonCellButtonTapped(_ cell: ButtonTableViewCell)
}

class ButtonTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var inCartButton: UIButton!
    
    weak var delegate: ButtonTableViewCellDelegate?
    
    var grocery: Grocery? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Acgtions
    @IBAction func inCartButtonTapped(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.buttonCellButtonTapped(self)
        }
    }
    
    func updateButton(_ itemInCart: Bool) {
        let completeImage = UIImage(named: "complete")?.withRenderingMode(.alwaysTemplate)
        let incompleteImage = UIImage(named: "incomplete")?.withRenderingMode(.alwaysTemplate)
        if itemInCart == true {
            inCartButton.setImage(completeImage, for: .normal)
            inCartButton.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else {
            inCartButton.setImage(incompleteImage, for: .normal)
            inCartButton.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
    }
    
    // MARK: - Setup
    func updateViews() {
        if let grocery = grocery {
            itemNameLabel.text = grocery.name
            updateButton(grocery.inCart)
        }
    }
}
