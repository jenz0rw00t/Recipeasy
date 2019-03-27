//
//  Recipe.swift
//  Cookbook
//
//  Created by Jens Sellén on 2019-03-22.
//  Copyright © 2019 Jens Sellén. All rights reserved.
//

import UIKit

class Recipe: NSObject {
    
    var name:String
    var recipe:String
    var recipeImages:[UIImage]
    var timers:[Int]
    
    init(name: String, recipe:String, recipeImages:[UIImage], timers:[Int]) {
        self.name = name
        self.recipe = recipe
        self.recipeImages = recipeImages
        self.timers = timers
    }
    
    init?(dictionary:[String:String], images:[Data], timers:[Int]) {
        guard let name = dictionary["name"],
            let recipe = dictionary["recipe"]
            else { return nil }
        self.name = name
        self.recipe = recipe
        var savedImages = [UIImage]()
        for data in images {
            if let savedImage = UIImage(data: data) {
                savedImages.append(savedImage)
            }
        }
        var savedTimers = [Int]()
        for seconds in timers {
            savedTimers.append(seconds)
        }
        self.timers = savedTimers
        self.recipeImages = savedImages
    }
    
    func objectToDictionary() -> [String:String] {
        return ["name":self.name,"recipe":self.recipe]
    }
    
    func picturesToDataArray() -> [Data] {
        var dataArray = [Data]()
        for image in recipeImages {
            if let saveImage = image.pngData() {
                dataArray.append(saveImage)
            }
        }
        return dataArray
    }
    
    // TODO: Better saving for pictures

}
