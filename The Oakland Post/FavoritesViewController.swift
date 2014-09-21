//
//  FavoritesViewController.swift
//  The Oakland Post
//
//  Created by Andrew Clissold on 9/1/14.
//  Copyright (c) 2014 Andrew Clissold. All rights reserved.
//

class FavoritesViewController: BugFixTableViewController, StarButtonDelegate {

    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .Bordered, target: self, action: "logOut")
    }

    func logOut() {
        PFUser.logOut()
        configureLogOutButton()
        navigationController!.popViewControllerAnimated(true)
    }

    func configureLogOutButton() {
        homeViewController.navigationItem.rightBarButtonItem = homeViewController.logInBarButtonItem
        homeViewController.tableView.reloadData()
    }

    func didSelectStarButton(starButton: UIButton, forItem item: MWFeedItem) {
        starButton.selected = !starButton.selected
        if starButton.selected {
            // Send the new favorite to Parse.
            let object = PFObject(item: item)
            object.saveEventually()
            starredPosts.append(object)
        } else {
            deleteStarredPostWithIdentifier(item.identifier)
            deleteTableViewRowWithItem(item)
            homeViewController.reloadData()
        }
    }

    func deleteTableViewRowWithItem(item: MWFeedItem) {
        var indexPath: NSIndexPath!
        loop: for cell in tableView.visibleCells() {
            if let postCell = cell as? PostCell {
                if postCell.item.identifier == item.identifier {
                    indexPath = tableView.indexPathForCell(cell as UITableViewCell)!
                    break loop
                }
            }
        }

        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableView.endUpdates()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return starredPosts.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(favoritesHeaderViewID, forIndexPath: indexPath) as FavoritesHeaderView
            cell.usernameLabel.text = PFUser.currentUser().username
            return cell
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as PostCell
        let object = starredPosts[indexPath.row - 1] as PFObject
        let item = MWFeedItem(object: object)

        cell.delegate = self
        cell.item = item
        cell.starButton.selected = true

        return cell
    }

    // MARK: Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == readPostID {
            let link = (sender as PostCell).item.link
            (segue.destinationViewController as PostViewController).URL = link
        }
    }

}
