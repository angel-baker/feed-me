//
//  AllRecipeHTMLParser.swift
//  FeedMe
//
//  Created by Jordan Brown on 9/5/15.
//  Copyright (c) 2015 woosufjordaline. All rights reserved.
//

import UIKit

class AllRecipeHTMLParser: NSObject,  RecipeHTMLParser{
    
    required init(page: String) {
    
    }
    
    func parse() -> Recipe {
        return Recipe()
    }

}
