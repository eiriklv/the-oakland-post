//
//  FavoritesViewController.swift
//  The Oakland Post
//
//  Created by Andrew Clissold on 9/1/14.
//  Copyright (c) 2014 Andrew Clissold. All rights reserved.
//

class FavoritesViewController: UITableViewController, StarButtonDelegate {

    var cellNib: UINib!

    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .Bordered, target: self, action: "logOut")
        cellNib = UINib(nibName: "PostCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: cellID)
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

    func didSelectStarButton(starButton: UIButton, withItem item: MWFeedItem, atIndexPath indexPath: NSIndexPath) {
        starButton.selected = !starButton.selected
        if starButton.selected {
            // Send the new favorite to Parse.
            let object = PFObject(item: item)
            object.saveEventually()
            starredPosts.append(object)
        } else {
            deleteStarredPostWithIdentifier(item.identifier)
            homeViewController.reloadData()
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return starredPosts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as PostCell
        let object = starredPosts[indexPath.row] as PFObject
        let item = MWFeedItem(object: object)

        cell.delegate = self
        cell.indexPath = indexPath
        cell.item = item
        cell.starButton.selected = true

        return cell

    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let usernameLabel = UILabel()
        usernameLabel.text = PFUser.currentUser().username
        usernameLabel.textAlignment = .Center
        usernameLabel.textColor = oaklandPostBlue
        usernameLabel.font = UIFont(name: boldSansSerifName, size: 34)
        usernameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        usernameLabel.sizeToFit()

        let view = UITableViewHeaderFooterView()
        view.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.contentView.addSubview(usernameLabel)

        view.contentView.addConstraints([
            NSLayoutConstraint(
                item: usernameLabel,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: view.contentView,
                attribute: .CenterX,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: usernameLabel,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: view.contentView,
                attribute: .CenterY,
                multiplier: 1,
                constant: 0)])

        return view
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }

}
