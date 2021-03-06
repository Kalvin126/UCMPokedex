//
//  SearchTableViewController.swift
//  SwiftyPokédex
//
//  Created by Kalvin Loc on 2/14/16.
//  Copyright © 2016 redpanda. All rights reserved.
//

import SwiftyPoke
import UIKit

class SearchTableViewController: UITableViewController, SearchBackgroundViewDelegate {

    var filteredData: [Pokémon] = []

    var randomBackgroundVC: SearchBackgroundViewController?
    var searchController: UISearchController?

    override func viewDidLoad() {
        super.viewDidLoad()

        randomBackgroundVC = storyboard?.instantiateViewControllerWithIdentifier("randView") as? SearchBackgroundViewController
        randomBackgroundVC?.delegate = self

        searchController = {
            let controller = UISearchController(searchResultsController: nil)
            // Configure search controller
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false

            self.navigationItem.titleView = controller.searchBar

            return controller
        }()

        // Search window provides context (information on presentation)
        definesPresentationContext = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        randomBackgroundVC?.randomize()
    }

    // MARK: SearchBackgroundViewDelegate
    func userDidTapSpriteViewWithPokémon(pokémon: Pokémon) {
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("pokeDetail") as! PokémonDVC
        detailVC.pokémon = pokémon

        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: UITableViewDelegate
extension SearchTableViewController {

    // Called when ever a row is selected, as the function name entails
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let pokemonForCell = filteredData[indexPath.row]
        // initialize a detail view
        let detailVC = storyboard?.instantiateViewControllerWithIdentifier("pokeDetail") as! PokémonDVC

        SwiftyPoke.getPokémon(pokemonForCell) {
            // set the detailVC's pokemon with the selected index pokemon
            detailVC.pokémon = $0

            // finally tell the Navigation Controller to "push" the new detailVC
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: Table view data source
extension SearchTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numOfSections = 0

        if filteredData.count != 0 {
            tableView.separatorStyle    = .SingleLine
            numOfSections               = 1
            tableView.backgroundView    = nil
        }
        else {
            // There is no search data!
            // Show the random pokemon background
            tableView.backgroundView = randomBackgroundVC!.view
            tableView.separatorStyle = .None
        }
        
        return numOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pokemonCell", forIndexPath: indexPath)

        return cell
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // A cell is about to be shown on the visible screen; lets configure and load data into it
        let pokemonForCell = filteredData[indexPath.row]

        // Cell we expect should be our custom PokédexTVCell
        if let pokédexCell = cell as? PokédexTVCell {
            pokédexCell.setupWithPokémon(pokemonForCell)
        }
    }
}

// MARK: UISearchResultsUpdating
extension SearchTableViewController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredData.removeAll(keepCapacity: false)

        if let searchText = searchController.searchBar.text {
            if searchText.characters.count > 0 {
                filteredData += SwiftyPoke.findPokémonContainingString(searchText)
                filteredData += SwiftyPoke.getPokémonWithPartialTypeString(searchText)
            }
        }

        tableView.reloadData()
    }
}
