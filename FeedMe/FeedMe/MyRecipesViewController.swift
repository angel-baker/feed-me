//
//  MyRecipesViewController.swift
//  FeedMe
//
//  Created by Caroline Hermans on 9/5/15.
//  Copyright (c) 2015 woosufjordaline. All rights reserved.
//

import UIKit

private var numberOfCards: UInt = 5
class MyRecipesViewController: UIViewController, UITextFieldDelegate {

    var foodImage : UIImage? = nil;
    var localUser : User = User();
    var recipes = [Recipe]()
    var currentRecipe = Recipe()
    
    @IBOutlet var textField : UITextField!
    @IBOutlet var recipeView : UIView!
    @IBOutlet var foodNameLabel : UILabel!
    @IBOutlet var prepTimeLabel : UILabel!
    @IBOutlet var foodButton : UIButton!
    @IBOutlet var ingredientFractionLabel : UILabel!
    @IBOutlet var friendInfoLabel : UILabel!
    @IBOutlet var likeButton : UIButton!
    @IBOutlet var dislikeButton : UIButton!
    @IBOutlet var bigBG : UIImageView!
    @IBOutlet var smallBG : UIImageView!
    
    func hideInfo() {
        self.foodNameLabel.hidden = true
        self.foodButton.hidden = true
        self.ingredientFractionLabel.hidden = true
        self.friendInfoLabel.hidden = true
        self.likeButton.hidden = true
        self.dislikeButton.hidden = true
        self.bigBG.hidden = true
        self.smallBG.hidden = true
    }
    func showInfo() {
        self.foodNameLabel.hidden = false
        self.foodButton.hidden = false
        self.ingredientFractionLabel.hidden = false
        self.friendInfoLabel.hidden = false
        self.likeButton.hidden = false
        self.dislikeButton.hidden = false
        self.bigBG.hidden = false
        self.smallBG.hidden = false
    }
    
    func populateView(recipe: Recipe?) {
        if (recipe == nil) {
            return; // show no more recipes screen
        }
        self.currentRecipe = recipe!
        foodNameLabel.text = recipe!.name
        let url = NSURL(string: recipe!.imageURLString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        self.foodButton.setImage(UIImage(data: data!), forState: .Normal)
        var totalFoods = recipe!.ingredients.count + recipe!.missingIngredients.count
        var weHave = String(recipe!.ingredients.count)
        self.ingredientFractionLabel.text = "✓ " + String(weHave) + " out of " + String(totalFoods) + " ingredients"
        var server = Server()
        var foodsFriendsHave = 0
        for missingIngredient in (recipe!.missingIngredients as [Food]){
            println(missingIngredient.name)
            if (server.whoHasIngredient(missingIngredient.name).count > 0) {
                foodsFriendsHave++
            }
        }
        self.friendInfoLabel.text = "Your friends have " + String(foodsFriendsHave) + " of " + String(recipe!.missingIngredients.count) + " missing ingredients."
    }
    
    @IBAction func clickedRecipe() {
        println("here")
        var server = Server()
        println("now her")
        var detailedRecipe = server.getDetailedRecipe(self.currentRecipe.urlString, name: self.currentRecipe.name)
        println("her??")
        let detailedRecipeVC = self.storyboard?.instantiateViewControllerWithIdentifier("RecipeDetailViewController") as! RecipeDetailViewController
        detailedRecipeVC.name = self.currentRecipe.name
        println(self.currentRecipe.name)
        detailedRecipeVC.ingredients = detailedRecipe.ingredients
        detailedRecipeVC.instructions = detailedRecipe.instructions
        let url = NSURL(string: self.currentRecipe.imageURLString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        detailedRecipeVC.picture = UIImage(data: data!)!
        self.presentViewController(detailedRecipeVC, animated: true, completion: nil)
    }
    
    @IBAction func showNextRecipe() {
        if (self.recipes.count < 1) {
            return;
        }
        var object = self.recipes[0];
        self.recipes.removeAtIndex(0)
        self.recipes.append(object)
        self.populateView(self.recipes.first)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Handle the text field’s user input through delegate callbacks.
        textField.delegate = self
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        self.view.addGestureRecognizer(tap)
        self.foodNameLabel.adjustsFontSizeToFitWidth = true
        self.hideInfo()
        self.getLocalUser()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getLocalUser() -> Void {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/", parameters:nil)
        var user = User()
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                // Process error
                println("Error: \(error)")
                
            }
            else {
                if let fbid = result["id"] as? String {
                    self.localUser.fbid = fbid
                    if let name = result["name"] as? String {
                        self.localUser.name = name
                    }
                }
                var server = Server()
                self.recipes = server.getAllRecipes(self.localUser);
                self.showInfo()
                self.populateView(self.recipes.first)
                
            }
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func addFavorite() {
        var server = Server()
        server.setFavoriteRecipe(self.localUser, recipe: self.currentRecipe)
    }
}
