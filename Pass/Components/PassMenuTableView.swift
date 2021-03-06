//
//  PassMenuTableView.swift
//  Pass
//
//  Created by Jose Aguilar on 4/20/19.
//  Copyright © 2019 Jose Aguilar. All rights reserved.
//

import UIKit
import RealmSwift

protocol PassMenuDelegate: class {
    func passMenu(didSelectAt indexPath: IndexPath)
}

class PassMenuTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    weak var passMenuDelegate: PassMenuDelegate?

    let pass: PassM
    init(pass: PassM) {
        self.pass = pass
        super.init(frame: .zero, style: .plain)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.backgroundColor = .white
        self.bounces = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.dataSource = self
        self.delegate = self
    }

    //MARK: - Cells

    let chevronImageView: UIImageView = {
        let chevronImageView = UIImageView(image: UIImage(asset: .chevronRight))
        chevronImageView.tintColor = UIColor.lightGray
        return chevronImageView
    }()
    lazy var menuCell: UITableViewCell = {
        let menuCell = UITableViewCell()
        menuCell.textLabel?.text = "Extensions"
        menuCell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        menuCell.preservesSuperviewLayoutMargins = false
        menuCell.separatorInset = .zero
        menuCell.layoutMargins = .zero
        menuCell.tintColor = UIColor(asset: .primary)
        menuCell.accessoryView = chevronImageView
        return menuCell
    }()
    lazy var addToWatchCell: UITableViewCell = {
        let addToWatchCell = UITableViewCell(style: .subtitle, reuseIdentifier: "atawc")
        addToWatchCell.textLabel?.text = "Set Watch"
        addToWatchCell.detailTextLabel?.text = "Your pass will be readily available on the watch app. Must have an Apple Watch."
        addToWatchCell.detailTextLabel?.numberOfLines = 0
        addToWatchCell.detailTextLabel?.lineBreakMode = .byWordWrapping
        addToWatchCell.tintColor = UIColor(asset: .primary)
        if pass.isOnWatch {
            addToWatchCell.accessoryType = .checkmark
        }
        return addToWatchCell
    }()
    lazy var addToWidgetCell: UITableViewCell = {
        let addToWidgetCell = UITableViewCell(style: .subtitle, reuseIdentifier: "atwc")
        addToWidgetCell.textLabel?.text = "Set Widget"
        addToWidgetCell.detailTextLabel?.text = "Your pass will be readily available in the lockscreen widget."
        addToWidgetCell.detailTextLabel?.numberOfLines = 0
        addToWidgetCell.detailTextLabel?.lineBreakMode = .byWordWrapping
        addToWidgetCell.tintColor = UIColor(asset: .primary)
        if pass.isOnWidget {
            addToWidgetCell.accessoryType = .checkmark
        }
        return addToWidgetCell
    }()
    lazy var chirpCell: UITableViewCell = {
        let chirpCell = UITableViewCell(style: .subtitle, reuseIdentifier: "cc")
        chirpCell.textLabel?.text = "Play Chirp"
        chirpCell.detailTextLabel?.text = "Chirp is like an audio QR code. Your pass data is sent via sound."
        chirpCell.detailTextLabel?.numberOfLines = 0
        chirpCell.detailTextLabel?.lineBreakMode = .byWordWrapping
        chirpCell.tintColor = UIColor(asset: .primary)
        return chirpCell
    }()

    //MARK: - TableView

    var isCollapsed = true

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isCollapsed ? 1 : 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return menuCell
        case 1: return addToWatchCell
        case 2: return addToWidgetCell
        case 3: return chirpCell
        default: return UITableViewCell() // Not worth crashing over.
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            isCollapsed = !isCollapsed
            toggleChevron(); toggleRows()
            return
        case 1:
            addToWatchCell.accessoryType = .checkmark
        case 2:
            addToWidgetCell.accessoryType = .checkmark
        default:
            break
        }
        passMenuDelegate?.passMenu(didSelectAt: indexPath)
    }

    private func toggleChevron() {
        if !isCollapsed {
            UIView.animate(withDuration: 0.25) {
                self.chevronImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.chevronImageView.transform = CGAffineTransform.identity
            }
        }
    }

    var collapsibleIndexPaths = [IndexPath(row: 1, section: 0),
                                      IndexPath(row: 2, section: 0),
                                      IndexPath(row: 3, section: 0)]

    private func toggleRows() {
        self.beginUpdates()
        if isCollapsed {
            self.deleteRows(at: collapsibleIndexPaths, with: .automatic)
        } else {
            self.insertRows(at: collapsibleIndexPaths, with: .automatic)
        }
        self.endUpdates()
    }
}
