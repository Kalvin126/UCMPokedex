//
//  SearchBackgroundViewController.swift
//  SwiftyPokédex
//
//  Created by Kalvin Loc on 2/14/16.
//  Copyright © 2016 redpanda. All rights reserved.
//

import SwiftyPoke
import UIKit

protocol SearchBackgroundViewDelegate : class {
    func userDidTapSpriteViewWithPokémon(pokémon: Pokémon);
}

class SearchBackgroundViewController: UIViewController {

    weak var delegate: SearchBackgroundViewDelegate?

    var pokémon: Pokémon?

    @IBOutlet weak var spriteImageView: UIImageView!
    @IBOutlet weak var pokemonLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    @IBOutlet weak var randomizeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // tap geasture on spriteView to push to pokemonDVC
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tappedSprite:"))

        // UIImageView userInteractionEnabled is false by default
        // must enabled before adding gestureRecognizer
        spriteImageView.userInteractionEnabled = true
        spriteImageView.addGestureRecognizer(tapGesture)

        // blank out content for initial load
        pokemonLabel.text = ""
    }

    private func setupPokémon() {
        // Use if let to automatically unwrap pokémon if it is not nil
        if let p = pokémon {
            if p.sprites.count != 0 {
                // Set Sprite
                SwiftyPoke.getSprite(p.sprites[0]) {
                    self.spriteImageView.image = UIImage(data: $0.image!)
                }
            }

            // Set name Label
            let idString = String(format: "#%03d - ", arguments: [p.nationalID])

            pokemonLabel.text = idString.stringByAppendingString(p.name)
        }
    }

    func randomize() {
        // Start
        activityIndicatorView.startAnimating()
        randomizeButton.enabled = false

        // Fetch random pokemon
        SwiftyPoke.getRandomPokémon {
            // $0 refers to the short hand arguments passed in a closure

            // set new pokémon
            self.pokémon = $0

            // commit new pokémon
            self.setupPokémon()

            self.activityIndicatorView.stopAnimating()
            self.randomizeButton.enabled = true
        }
    }

    func tappedSprite(recognizer: UITapGestureRecognizer) {
        if let p = pokémon {
            // let our delegate know that the user has tapped the sprite
            // and pass the current pokemon
            delegate?.userDidTapSpriteViewWithPokémon(p)
        }
    }

    // MARK: IBActions

    @IBAction func pressedRandomize(sender: UIButton) {
        randomize()
    }
}
