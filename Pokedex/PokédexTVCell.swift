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

        resetCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        resetCell()
    }

    func resetCell() {
        spriteImageView.image = nil
        nameLabel.text = ""
    }

    func setupWithPokémon(pokémon: Pokémon) {
        userInteractionEnabled = false

        // load in data

        // Name and ID is always givin so it is safe to load
        nameLabel.text = String(format: "#%03d - %@", arguments: [pokémon.nationalID, pokémon.name])
        tag = pokémon.nationalID
        spriteImageView.image = nil

        SwiftyPoke.getPokémon(pokémon) {
            self.pokémon = $0
            self.userInteractionEnabled = true

            self.setSprite()
        }
    }

    func setSprite() {
        // Closure blocks passed may not be called imediately and by the time it is called,
        // the cell may have already been repurposed for another pokemon, check that the
        // cell's tag is still assigned to the pokemon.

        if pokémon?.sprites.count != 0 {
            SwiftyPoke.getSprite(pokémon!.sprites[0]) {
                if self.tag == self.pokémon!.nationalID {
                    self.spriteImageView.image = UIImage(data: $0.image!)
                }
            }
        }
    }

}
