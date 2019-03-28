//
//  DetailRecipeViewController.swift
//  Cookbook
//
//  Created by Jens Sellén on 2019-03-20.
//  Copyright © 2019 Jens Sellén. All rights reserved.
//

import UIKit

protocol EditRecipeDelegate: AnyObject {
    func deleteRecipeAtIndex(index: Int)
    func saveRecipeEdit()
}

class DetailRecipeViewController: UIViewController {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var recipeLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editTextView: UITextView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var selectedRecipe: Recipe!
    var selectedRecipeIndex: Int!
    
    weak var editRecipeDelegate: EditRecipeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Multiple images and also the ability to add, delete and change images
        
        editTextView.isScrollEnabled = false
        navigationItem.title = selectedRecipe.name
        recipeNameLabel.text = selectedRecipe.name
        // recipeLabel.attributedText = detectTimeInRecipe()
        recipeLabel.text = selectedRecipe.recipe
        imageView2.isHidden = true
        imageView3.isHidden = true
        
        for i in 0..<selectedRecipe.recipeImages.count {
            switch i {
            case 0:
                imageView1.image = selectedRecipe.recipeImages[0]
            case 1:
                imageView2.image = selectedRecipe.recipeImages[1]
            case 2:
                imageView3.image = selectedRecipe.recipeImages[2]
            default:
                print("No images found")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.bottomConstraint.constant = keyboardFrame.size.height + 8
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint.constant = 8
    }
    
    // MARK: - Button actions
    
    var isEditingRecipe = false
    
    @IBAction func editButtonPressed(_ sender: Any) {
        if !isEditingRecipe {
            isEditingRecipe = true
            recipeLabel.isHidden = true
            recipeNameLabel.isHidden = true
            editTextView.isHidden = false
            recipeNameTextField.isHidden = false
            editTextView.text = selectedRecipe.recipe
            recipeNameTextField.text = selectedRecipe.name
            editButton.setTitle("Save", for: .normal)
        } else {
            self.view.endEditing(true)
            isEditingRecipe = false
            selectedRecipe.recipe = editTextView.text
            selectedRecipe.name = recipeNameTextField.text!
            editTextView.isHidden = true
            recipeNameTextField.isHidden = true
            recipeLabel.isHidden = false
            recipeNameLabel.isHidden = false
            recipeLabel.text = selectedRecipe.recipe
            recipeNameLabel.text = selectedRecipe.name
            navigationItem.title = selectedRecipe.name
            editButton.setTitle("Edit", for: .normal)
            editRecipeDelegate?.saveRecipeEdit()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        editRecipeDelegate?.saveRecipeEdit()
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Do you want to delete this recipe?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .cancel, handler: { (_) in
            self.deleteRecipe()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func deleteRecipe() {
        self.editRecipeDelegate?.deleteRecipeAtIndex(index: selectedRecipeIndex)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK : - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToPopupSegue" {
            let popupVC = segue.destination as? TimerPopupViewController
            popupVC?.selectedRecipe = self.selectedRecipe
        }
    }
    
    /*  TEST CODE TO TRY AND FIND ALL NUMBERS AND MAKE THEM TAPABLE DID NOT WORK :(
    func detectTimeInRecipe() -> NSAttributedString {
        let textWithLinks = NSMutableAttributedString()
        var textComponents = selectedRecipe.recipe.components(separatedBy: " ")
        
        for i in 0..<textComponents.count {
            if textComponents[i].rangeOfCharacter(from: .decimalDigits) != nil {
                let attributes: [NSAttributedString.Key : Any] = [
                    NSAttributedString.Key.foregroundColor: UIColor.blue,
                    NSAttributedString.Key.underlineColor: UIColor.lightGray,
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                    NSAttributedString.Key.link: true
                ]
                let number = NSAttributedString(string: textComponents[i], attributes: attributes)
                textWithLinks.append(number)
                textWithLinks.append(NSAttributedString(string: " "))
            } else {
                let nonNumber = NSAttributedString(string: textComponents[i], attributes: nil)
                textWithLinks.append(nonNumber)
                textWithLinks.append(NSAttributedString(string: " "))
            }
        }
        return textWithLinks
    }
    */
 


}
