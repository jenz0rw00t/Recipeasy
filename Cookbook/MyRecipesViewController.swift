//
//  MyRecipesViewController.swift
//  Cookbook
//
//  Created by Jens Sellén on 2019-03-20.
//  Copyright © 2019 Jens Sellén. All rights reserved.
//

import UIKit

class MyRecipesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, AddRecipeDelegate, EditRecipeDelegate {
    
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    
    var recipeArray:[Recipe] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        if recipeArray.count<1 {
            loadRecipeArray()
        }
        
        let itemSize = UIScreen.main.bounds.width/3 - 15
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: itemSize, height: itemSize+30)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 5
        
        recipeCollectionView.collectionViewLayout = layout
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.recipeCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipeArray.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RecipeCell
        
        if indexPath.item<recipeArray.count {
            cell.imageView.image = recipeArray[indexPath.item].recipeImages[0]
            cell.recipeNameLabel.text = recipeArray[indexPath.item].name
        } else {
            createAddNewCell(cell: cell, indexPath: indexPath)
        }
        
        return cell
    }
    
    func createAddNewCell(cell: RecipeCell, indexPath: IndexPath) {
        cell.recipeNameLabel.text = "Add Recipe"
        cell.imageView.image = #imageLiteral(resourceName: "add_new_placeholder")
    }
    
    // MARK: - On Click
    
    var selectedRecipe:Recipe!
    var selectedRecipeIndex:Int!
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item<recipeArray.count {
            selectedRecipe = recipeArray[indexPath.item]
            selectedRecipeIndex = indexPath.item
            performSegue(withIdentifier: "collectionToDetail", sender: nil)
        } else {
            performSegue(withIdentifier: "addRecipe", sender: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "collectionToDetail" {
            let detailRecipeVC = segue.destination as! DetailRecipeViewController
            detailRecipeVC.selectedRecipe = selectedRecipe
            detailRecipeVC.selectedRecipeIndex = selectedRecipeIndex
            detailRecipeVC.editRecipeDelegate = self
        } else if segue.identifier == "addRecipe" {
            let addRecipeVC = segue.destination as! AddRecipeViewController
            addRecipeVC.addRecipeDelegate = self
        }
    }
    
    // MARK: - Delegate functions
    
    func deleteRecipeAtIndex(index: Int){
        recipeArray.remove(at: index)
        saveRecipeArray()
    }
    
    func saveRecipeEdit(){
        saveRecipeArray()
    }
    
    func addRecipe(recipe: Recipe){
        recipeArray.append(recipe)
        saveRecipeArray()
    }
    
    // MARK: - Userdefaults
    
    func saveRecipeArray(){
        let defaults = UserDefaults.standard
        var saveArray = [Dictionary<String, String>]()
        for recipe in recipeArray {
            saveArray.append(recipe.objectToDictionary())
            let imagesDataArray: [Data] = recipe.picturesToDataArray()
            defaults.set(imagesDataArray, forKey: recipe.name+"img")
            defaults.set(recipe.timers, forKey: recipe.name+"timer")
        }
        defaults.set(saveArray, forKey: "savedRecipes")
    }
    
    func loadRecipeArray(){
        let defaults = UserDefaults.standard
        guard let saveArray = defaults.array(forKey: "savedRecipes") as? [[String:String]] else { return }
        for data in saveArray {
            guard let imagesSaveData = defaults.array(forKey: data["name"]!+"img") as? [Data] else { return }
            var imageArray = [Data]()
            for imageData in imagesSaveData {
                imageArray.append(imageData)
            }
            guard let timerSaveArray = defaults.array(forKey: data["name"]!+"timer") as? [Int] else { return }
            if let recipe = Recipe.init(dictionary: data, images: imagesSaveData, timers: timerSaveArray) {
                recipeArray.append(recipe)
            }
        }
    }

}
