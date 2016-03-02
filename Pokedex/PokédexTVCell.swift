//
//  PokédexTVCell.swift
//  Pokedex
//
//  Created by Kalvin Loc on 2/23/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import SwiftyPoke
import UIKit

class PokédexTVCell: UITableViewCell {

    @IBOutlet weak var spriteImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    var pokémon: Pokémon?


    override func awakeFromNib() {
        super.awakeFromNib()


    }

    override func prepareForReuse() {
        super.prepareForReuse()

        spriteImageView.image = nil
        nameLabel.text = ""
    }

    func setupWithPokémon(pokémon: Pokémon) {
        self.pokémon = pokémon

        userInteractionEnabled = false

        // load in data
        nameLabel.text = String(format: "#%03d - %@", arguments: [pokémon.nationalID, pokémon.name])
        tag = pokémon.nationalID
        spriteImageView.image = nil

        // set sprite image
        // Closure blocks passed may not be called imediately and by the time it is called,
        // the cell may have already been repurposed for another pokemon, check that the
        // cell's tag is still assigned to the pokemon.
        if tag == pokémon.nationalID {
            userInteractionEnabled = true
        }

        if pokémon.sprites.count != 0 {
            SwiftyPoke.getSprite(pokémon.sprites[0]) {
                if self.tag == pokémon.nationalID {
                    self.spriteImageView.image = UIImage(data: $0.image!)
                }
            }
        }
    }


}
