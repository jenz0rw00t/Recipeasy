//
//  AddRecipeViewController.swift
//  Cookbook
//
//  Created by Jens Sellén on 2019-03-20.
//  Copyright © 2019 Jens Sellén. All rights reserved.
//

import UIKit

protocol AddRecipeDelegate: AnyObject {
    func addRecipe(recipe: Recipe)
}

class AddRecipeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var recipeTextView: UITextView!
    @IBOutlet weak var addRecipeButton: UIButton!
    
    weak var addRecipeDelegate: AddRecipeDelegate?
    
    let tapRecognizer = UITapGestureRecognizer()
    var didChooseImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recipeTextView.delegate = self
        
        recipeTextView.text = "Paste in recipe here or type in manually..."
        recipeTextView.textColor = UIColor.lightGray
        
        tapRecognizer.addTarget(self, action: #selector(AddRecipeViewController.tappedImage))
        imageView.addGestureRecognizer(tapRecognizer)
        imageView.isUserInteractionEnabled = true
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Paste in recipe here or type in manually..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func tappedImage() {
        let alert = UIAlertController(title: "Choose an Image:", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Picture", style: .default, handler: { (_) in
            self.pictureFromCamera()
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
            self.pictureFromLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func pictureFromCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true)
        } else {
            Alert.showBasicOkAlert(on: self, with: "Warning!", message: "No camera was found")
        }
    }
    
    func pictureFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            imageView.image = image
            picker.dismiss(animated: true, completion: nil)
            didChooseImage = true
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addRecipeButtonPressed(_ sender: Any) {
        if !didChooseImage {
            imageView.image = UIImage(named: "image_placeholder")
        }
        guard let recipeName = recipeNameTextField.text,
        let recipe = recipeTextView.text,
        let image = imageView.image
            else {return}
        if recipeName == "" || recipe == "Paste in recipe here or type in manually..." {
            Alert.showBasicOkAlert(on: self, with: "Error", message: "The recipe was not filled in properly")
        } else {
            let newRecipe = Recipe(name: recipeName, recipe: recipe, recipeImages: [image], timers: [])
            addRecipeDelegate?.addRecipe(recipe: newRecipe)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}
