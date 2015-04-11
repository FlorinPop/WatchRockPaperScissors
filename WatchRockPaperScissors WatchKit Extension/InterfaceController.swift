//
//  InterfaceController.swift
//  WatchRockPaperScissors WatchKit Extension
//
//  Created by Florin Pop on 11/04/15.
//  Copyright (c) 2015 Florin Pop. All rights reserved.
//

import WatchKit
import Foundation

enum PlayerChoice : Int {
    case Rock = 0
    case Paper = 1
    case Scissors = 2
    
    var description : String {
        switch self {
            // Use Internationalization, as appropriate.
        case .Rock: return "Rock"
        case .Paper: return "Paper"
        case .Scissors: return "Scissors"
        }
    }
}

enum PlayerLife : Int {
    case Full = 0
    case Half = 1
    case Empty = 2
}

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var heroImageView: WKInterfaceImage!
    @IBOutlet weak var heroChoiceLabel: WKInterfaceLabel!
    @IBOutlet weak var heroLifeImageView: WKInterfaceImage!
    
    @IBOutlet weak var enemyImageView: WKInterfaceImage!
    @IBOutlet weak var enemyChoiceLabel: WKInterfaceLabel!
    @IBOutlet weak var enemyLifeImageView: WKInterfaceImage!
    
    @IBOutlet weak var infoTopLabel: WKInterfaceLabel!
    @IBOutlet weak var infoBottomLabel: WKInterfaceLabel!
    @IBOutlet weak var roundLabel: WKInterfaceLabel!
    
    @IBOutlet weak var rockButton: WKInterfaceButton!
    @IBOutlet weak var paperButton: WKInterfaceButton!
    @IBOutlet weak var scissorsButton: WKInterfaceButton!
    
    var heroLife = PlayerLife.Full
    var enemyLife = PlayerLife.Full
    var round = 1
    
    //Lifecycle
    
    init(context: AnyObject?) {
        // Initialize variables here.
        super.init()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        NSLog("%@ will activate", self)
        super.willActivate()
        
        // start first image
        self.loadPlayerImageWithName("p1_walk")
        self.loadEnemyImageWithName("snailWalk")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
        
        self.stopAnimating()
    }
    
    //internal interface
    func stopAnimating() {
        self.heroImageView.stopAnimating()
        self.enemyImageView.stopAnimating()
    }
    
    func loadPlayerImageWithName(name: String) {
        
        self.animateImageView(self.heroImageView, imageName: name, spriteCount: 12, duration: 11 / 15)
    }
    
    func loadEnemyImageWithName(name: String) {
        
        self.animateImageView(self.enemyImageView, imageName: name, spriteCount: 3, duration: 1 / 2)
    }
    
    func animateImageView(imageView: WKInterfaceImage!, imageName: String, spriteCount: Int, duration: Double) {
        
        imageView.setImageNamed(imageName)
        
        //animate all the images execept the placeholder (0)
        imageView.startAnimatingWithImagesInRange(NSMakeRange(1, spriteCount - 1), duration: duration, repeatCount: 0)
    }
    
    func updateLifeImageView(imageView: WKInterfaceImage!, life: PlayerLife) {
        
        var image : String!
        switch life
        {
        case .Empty: image = "hud_heartEmpty"
        case .Half: image = "hud_heartHalf"
        default: image = "hud_heartFull"
        }
        imageView.setImageNamed(image)
    }
    
    func play(heroChoice: PlayerChoice, enemyChoice: PlayerChoice)
    {
        self.roundLabel.setText("Round \(self.round++)")
        
        self.heroChoiceLabel.setHidden(false)
        self.heroChoiceLabel.setText(heroChoice.description)
        
        self.enemyChoiceLabel.setHidden(false)
        self.enemyChoiceLabel.setText(enemyChoice.description)
        
        if (heroChoice == enemyChoice)
        {
            self.infoTopLabel.setText("Tie!")
            self.infoBottomLabel.setHidden(true)
        }
        else
        {
            self.infoTopLabel.setText("You")
            self.infoBottomLabel.setHidden(false)
            
            var heroWins = (heroChoice == PlayerChoice.Rock && (enemyChoice == PlayerChoice.Scissors)) ||
                (heroChoice == PlayerChoice.Paper && (enemyChoice == PlayerChoice.Rock)) ||
                (heroChoice == PlayerChoice.Scissors && (enemyChoice == PlayerChoice.Paper))
            
            if heroWins
            {
                self.infoBottomLabel.setText("win!")
                self.enemyLife = self.takeHit(enemyLife)
                self.updateLifeImageView(enemyLifeImageView, life: enemyLife)
            }
            else
            {
                self.infoBottomLabel.setText("loose!")
                self.heroLife = self.takeHit(heroLife)
                self.updateLifeImageView(heroLifeImageView, life: heroLife)
            }
            
            if (heroLife == PlayerLife.Empty || enemyLife == PlayerLife.Empty)
            {
                self.rockButton.setHidden(true)
                self.paperButton.setHidden(true)
                self.scissorsButton.setHidden(true)
                
                self.infoTopLabel.setText("Game")
                self.infoBottomLabel.setText("over")
            }
        }
    }
    
    func takeHit(life: PlayerLife) -> PlayerLife
    {
        if (life == PlayerLife.Full)
        {
            return PlayerLife.Half
        }
        return PlayerLife.Empty
    }
    
    func randomChoice() -> PlayerChoice
    {
        return PlayerChoice(rawValue: Int(rand() % 3))!
    }
    
    //actions
    
    @IBAction func rockButtonPressed() {
        
        let heroChoice = PlayerChoice.Rock
        self.play(heroChoice, enemyChoice: randomChoice())
    }
    
    @IBAction func paperButtonPressed() {
        
        let heroChoice = PlayerChoice.Paper
        self.play(heroChoice, enemyChoice: randomChoice())
    }
    
    @IBAction func scissorsButtonPressed() {
        
        let heroChoice = PlayerChoice.Scissors
        self.play(heroChoice, enemyChoice: randomChoice())
    }
    
    //menu
    
    @IBAction func restartMenuItemPressed() {
        
        self.heroLife = PlayerLife.Full
        self.enemyLife = PlayerLife.Full
        self.round = 1
        
        self.roundLabel.setText("Round \(self.round)")
        self.infoTopLabel.setText("Ready")
        self.infoBottomLabel.setHidden(true)
        
        self.updateLifeImageView(enemyLifeImageView, life: enemyLife)
        self.updateLifeImageView(heroLifeImageView, life: heroLife)
        
        self.heroChoiceLabel.setHidden(true)
        self.enemyChoiceLabel.setHidden(true)
        
        self.rockButton.setHidden(false)
        self.paperButton.setHidden(false)
        self.scissorsButton.setHidden(false)
    }

}
