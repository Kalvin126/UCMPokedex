//
//  PokémonDVC.swift
//  SwiftyPoké
//
//  Created by Kalvin Loc on 12/21/15.
//  Copyright © 2015 redpanda. All rights reserved.
//

import SwiftyPoke
import UIKit

class PokémonDVC: UITableViewController {

    var pokémon: Pokémon?

    // IBOutlets are what are visible to the interface builder
    // When a view is about to appear, These references will be loaded

    @IBOutlet weak var idBarButton: UIBarButtonItem!
    @IBOutlet weak var spriteImageView: UIImageView!

    @IBOutlet var labelCollection: [UIView]!

    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var atkLabel: UILabel!
    @IBOutlet weak var defLabel: UILabel!

    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var catchRateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!

    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!

    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var mfLabel: UILabel!

    @IBOutlet weak var descriptionCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set descriptionCollectionView's delegate as self
        // so that it askes PokémonDVC (self) what to display, etc..
        descriptionCollection.delegate = self
        descriptionCollection.dataSource = self

        if let p = pokémon {
            // Set Pokeball + Name titleLabel using NSAttributedString

            // pokeballImage
            let pokeballAttach = NSTextAttachment()
            pokeballAttach.image = UIImage(named: "pokeball_small")

            let pokeball = NSMutableAttributedString(attributedString: NSAttributedString(attachment: pokeballAttach))
            // give pokeball -5 y offset
            pokeball.addAttribute(NSBaselineOffsetAttributeName, value: NSNumber(float: -5), range: NSMakeRange(0, 1))

            // Name
            let attribName = NSMutableAttributedString(string: p.name)
            attribName.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, attribName.length))

            // Finally combine pokeball and name
            let combined = pokeball.mutableCopy() as! NSMutableAttributedString
            combined.appendAttributedString(attribName)

            // Init a UILabel and set its text as the attributed string
            let attribLabel = UILabel()
            attribLabel.attributedText = combined
            attribLabel.sizeToFit()
            navigationItem.titleView = attribLabel

            // Right bar item as label stating Pokemon's ID
            idBarButton.title = String(format: "#%03d ", arguments: [p.nationalID])
        }

        // Pokémon wiggle on tap with UITapGeastureRecognizer
        let tapRecog = UITapGestureRecognizer(target: self, action: Selector("tappedSprite:"))
        spriteImageView.addGestureRecognizer(tapRecog)

        // call helper method to setup detail
        setupDetail()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // set the length of the headerView
        let collecFrame = descriptionCollection.frame
        tableView.tableHeaderView?.frame.size.height = collecFrame.origin.y + collecFrame.size.height
        tableView.tableHeaderView = tableView.tableHeaderView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Background Grid
        let gridView = UIImageView(image: UIImage(named: "grid"))
        gridView.bounds = tableView.bounds
        gridView.contentMode = .ScaleAspectFill
        gridView.alpha = 0.5
        tableView.backgroundView = gridView

        // Label view setup
        let setupView = { (let view: UIView) -> Void in
            view.layer.borderColor = UIColor.grayColor().CGColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = 5.0

            // shadow
            view.layer.shadowOffset = CGSizeMake(2, 2)
            view.layer.shadowOpacity = 0.5
            view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: 5.0).CGPath

            view.backgroundColor = UIColor.whiteColor()
        }

        labelCollection.forEach { setupView($0) }
    }

    // MARK: Helper funcs

    func setupDetail() {
        if let p = pokémon {
            // Fill in content through IBOutlet reference

            hpLabel.text = "\(p.hp!)"
            atkLabel.text = "\(p.attack!)"
            defLabel.text = "\(p.defense!)"
            speedLabel.text = "\(p.speed!)"
            totalLabel.text = "\(p.total!)"

            catchRateLabel.text = "\(p.catchRate!)"

            expLabel.text = "\(p.exp!)"
            mfLabel.text = p.maleFemalRatio

            heightLabel.text = "\(Double(p.height!)! * 0.1) m"     // Need to convert from dm to m
            weightLabel.text = "\(Double(p.weight!)! * 0.1) kg"    // Need to convert from g to kg

            if p.sprites.count > 0 {
                SwiftyPoke.getSprite(p.sprites[0]) { (sprite) -> Void in
                    self.pokémon!.sprites[0] = sprite
                    self.spriteImageView.image = UIImage(data: sprite.image!)
                }
            }
        }
    }

    // Pokémon wiggle on tap
    func tappedSprite(recognizer: UITapGestureRecognizer) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = 0.0
        animation.fromValue = M_PI/16
        animation.duration = 0.1
        animation.repeatCount = 2.0
        animation.autoreverses = true

        spriteImageView.layer.addAnimation(animation, forKey: "shake")
    }
}

// MARK: UITableViewDelegate
extension PokémonDVC {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 { // evolutions Section
            let evoForCell = pokémon!.evolutions[indexPath.row]

            // grab pokemon and push a new detailView
            SwiftyPoke.getPokémonByID(evoForCell.pokémonNationalID) {
                let newDVC = self.storyboard?.instantiateViewControllerWithIdentifier("pokeDetail") as! PokémonDVC
                newDVC.pokémon = $0

                self.navigationController?.pushViewController(newDVC, animated: true)
            }
        }
    }
}

// MARK: UITableViewDataSource
extension PokémonDVC {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3 // 3 sections - Evolutions, Abilities, Moves
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // Evolutions
            return pokémon!.evolutions.count
        case 1: // Abilities
            return pokémon!.abilities.count
        case 2: // Moves
            return pokémon!.moves.count
        default:
            // should never get here
            return 0
        }
    }

    // Set section title through titleForHeaderInSection
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Evolutions"
        case 1:
            return "Abilities"
        case 2:
            return "Moves"
        default:
            // should never get here
            return nil
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 { // evolutionCell
            return 100.0
        } else {
            return tableView.rowHeight
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellName = ""

        switch indexPath.section {
        case 0:
            cellName = "evolutionCell"
        case 1:
            cellName = "abilityCell"
        case 2:
            cellName = "moveCell"
        default:
            cellName = ""
        }

        return tableView.dequeueReusableCellWithIdentifier(cellName)!
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.reuseIdentifier == "evolutionCell" {
            let spriteView  = cell.viewWithTag(1) as! UIImageView
            let nameLabel   = cell.viewWithTag(2) as! UILabel
            let methodLabel = cell.viewWithTag(3) as! UILabel

            let evoForCell = pokémon!.evolutions[indexPath.row]

            SwiftyPoke.getPokémonByID(evoForCell.pokémonNationalID) {
                if $0.sprites.count > 0 {
                    SwiftyPoke.getSprite($0.sprites[0]) {
                        spriteView.image = UIImage(data: $0.image!)
                    }
                }
            }

            nameLabel.text = evoForCell.to

            var detailString = "By " + evoForCell.method

            if evoForCell.level != nil {
                detailString += " at LV. \(evoForCell.level!)"
            }

            methodLabel.text = detailString.stringByReplacingOccurrencesOfString("_", withString: " ")


        }else if cell.reuseIdentifier == "abilityCell" {
            let abilityForCell = pokémon!.abilities[indexPath.row]

            cell.textLabel?.text = abilityForCell.name
            cell.detailTextLabel?.text = abilityForCell.description
        }else if cell.reuseIdentifier == "moveCell" {
            SwiftyPoke.getMove((pokémon?.moves[indexPath.row])!) {
                self.pokémon?.moves[indexPath.row] = $0

                cell.textLabel?.text = $0.name
                cell.detailTextLabel?.text = $0.desc
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension PokémonDVC : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (pokémon != nil ? 1 : 0);
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (pokémon?.descriptions.count)!;
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("descriptionCell", forIndexPath: indexPath)

        let textView = cell.viewWithTag(1) as! UITextView
        let gamesLabel = cell.viewWithTag(2) as! UILabel

        textView.text = ""
        gamesLabel.text = ""

        return cell
    }
}

// MARK: UICollectionViewDelegate
extension PokémonDVC : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 2.0

        // shadow
        cell.layer.shadowOffset = CGSizeMake(2, 2)
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 2.0).CGPath
        cell.layer.masksToBounds = false

        let textView = cell.viewWithTag(1) as! UITextView
        let gamesLabel = cell.viewWithTag(2) as! UILabel
        cell.bringSubviewToFront(gamesLabel)
        gamesLabel.text = ""

        SwiftyPoke.getDescription((pokémon?.descriptions[indexPath.row])!) {
            textView.text = $0.description

            if $0.games.count != 0 {
                gamesLabel.text = $0.games[0].name
            }

            if $0.games.count > 1 {
                for _ in 1...$0.games.count-1 {
                    gamesLabel.text = gamesLabel.text! + ", " + $0.name
                }
            }
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension PokémonDVC : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let collectionViewWidth = descriptionCollection.bounds.size.width

        return CGSizeMake(collectionViewWidth - (15*2), 90)
    }
}
