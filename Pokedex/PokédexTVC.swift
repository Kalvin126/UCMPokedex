//
//  PokédexTVC.swift
//  SwiftyPoké
//
//  Created by Kalvin Loc on 12/18/15.
//  Copyright © 2015 redpanda. All rights reserved.
//

import SwiftyPoke
import UIKit

class PokédexTVC: UITableViewController {

    var pokémon = [Pokémon]()

    var previewDTC: PokémonDVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        // 3D Touch register
        if traitCollection.forceTouchCapability == .Available {
            registerForPreviewingWithDelegate(self, sourceView: view)
        }

        // Init Pokedex
        SwiftyPoke.fillNationalPokédex {
            // $0 refers to the short hand arguments passed in a closure
            if $0 {
                // Success, we can fetch pokedex now
                self.pokémon = SwiftyPoke.getPokédex()

                self.tableView.reloadData()
            } else {
                print("Error: Could not fillNationalPokédex")
            }
        }
    }

    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pokemonDetail" {
            let pokeDVC = segue.destinationViewController as! PokémonDVC

            // the row # corresponds to the index of pokémon array
            pokeDVC.pokémon = pokémon[tableView.indexPathForSelectedRow!.row]
        }
    }
}

// MARK: UITableViewDataSource
extension PokédexTVC {

    /* TableViews load contents by:
    
    - tableView.reloadData() called
    - numberSectionsInTableView
    - numberOfRowsInSection for each section
    - cellForRowAtIndexPath for the amount of cells in a section
    
    - willDisplayCell when a cell is about to come into view
      (configure cell here)
    */

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // If there are pokemon in the array, then there return 1 section, otherwise 0
        return (pokémon.count > 0 ? 1 : 0)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // We only ever expect one section who will have the same amount
        // of rows as there are elements in pokémon array
        return pokémon.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pokemonCell", forIndexPath: indexPath)
        // Return a cell to display
        // Reuse cells are great as memory usage is lowered by reusing off 
        // screen cells for on screen cells

        return cell
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // A cell is about to be shown on the visible screen; lets configure and load data into it
        let pokemonForCell = pokémon[indexPath.row]

        // Cell we expect should be our custom PokédexTVCell
        if let pokédexCell = cell as? PokédexTVCell {
            SwiftyPoke.getPokémon(pokemonForCell) {
                self.pokémon[indexPath.row] = $0
                pokédexCell.setupWithPokémon($0)
            }
        }
    }
}

// 3D Touch (Peek / Pop)
// MARK: UIViewControllerPreviewingDelegate
extension PokédexTVC : UIViewControllerPreviewingDelegate {
    // Peek
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRowAtPoint(location) {
            previewDTC = storyboard?.instantiateViewControllerWithIdentifier("pokeDetail") as? PokémonDVC
            previewDTC?.pokémon = pokémon[indexPath.row]

            previewingContext.sourceRect = tableView.rectForRowAtIndexPath(indexPath)

            return previewDTC
        }

        return nil
    }

    // Pop
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)

        previewDTC = nil
    }

}