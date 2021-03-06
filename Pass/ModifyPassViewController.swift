//
//  ModifyPassViewController.swift
//  Pass
//
//  Created by Jose Aguilar on 3/23/19.
//  Copyright © 2019 Jose Aguilar. All rights reserved.
//

import UIKit
import RealmSwift

class ModifyPassViewController: UITableViewController, ErrorProtocol {

    enum State {
        case new, update(PassM)

        var value: PassM? {
            switch self {
            case .new: return nil
            case .update(let pass): return pass
            }
        }
    }

    private var state: State = .new

    init(state: State) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavbar()
        setupTableViewCells()
        setupTableView()
    }

    //MARK: - Navbar

    lazy var completionButton: UIBarButtonItem = {
        var title = "Save"
        var isEnabled = false
        if state.value != nil {
            title = "Update"
            isEnabled = true
        }
        let completionButton = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(handleCompletionPress))
        completionButton.isEnabled = isEnabled
        return completionButton
    }()

    private func setupNavbar() {
        self.title = state.value != nil ? "Update Pass" : "New Pass"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.setRightBarButton(completionButton, animated: true)
    }

    @objc private func handleCompletionPress() {
        let cleanedTitle = passTitleCell.textField.cleanedString
        let cleanedCode = passCodeCell.textField.cleanedString
        let isCode39 = code39Cell.accessoryType == .checkmark ? true : false

        if let pass = state.value {
            let updatedValues: [PassM.VariableKey: Any] = [.title: cleanedTitle, .code: cleanedCode, .isCode39: isCode39]
            do {
                try pass.setValues(updatedValues)
            } catch {
                print(error)
            }
        } else {
            let newPass = PassM(title: cleanedTitle, code: cleanedCode, isCode39: isCode39)
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(newPass)
                }
            } catch {
                print(error)
            }
        }

        navigationController?.popViewController(animated: true)
    }

    //MARK: - Cells

    var passTitleCell: TextFieldCell = {
        let passTitleCell = TextFieldCell()
        passTitleCell.tintColor = UIColor(asset: .primary)
        return passTitleCell
    }()
    var passCodeCell: TextFieldCell = {
        let passCodeCell = TextFieldCell()
        passCodeCell.tintColor = UIColor(asset: .primary)
        return passCodeCell
    }()
    var code39Cell: UITableViewCell = {
        var code39Cell = UITableViewCell(style: .subtitle, reuseIdentifier: "c39Cell")
        code39Cell.textLabel?.text = "Code39"
        code39Cell.detailTextLabel?.text = "Accepts uppercase letters, numbers, Space - . $ / + %."
        code39Cell.detailTextLabel?.numberOfLines = 0
        code39Cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        code39Cell.tintColor = UIColor(asset: .primary)
        return code39Cell
    }()
    var qrCell: UITableViewCell = {
        var qrCell = UITableViewCell(style: .subtitle, reuseIdentifier: "qrCell")
        qrCell.textLabel?.text = "QR Code"
        qrCell.detailTextLabel?.text = "Accepts all characters."
        qrCell.detailTextLabel?.numberOfLines = 0
        qrCell.detailTextLabel?.lineBreakMode = .byWordWrapping
        qrCell.tintColor = UIColor(asset: .primary)
        return qrCell
    }()
    // Only shows up when updating
    var deleteCell: UITableViewCell = {
        var deleteCell = UITableViewCell(style: .subtitle, reuseIdentifier: "deleteCell")
        deleteCell.textLabel?.text = "Delete check-in tag"
        deleteCell.detailTextLabel?.text = "This action cannot be undone."
        deleteCell.detailTextLabel?.numberOfLines = 0
        deleteCell.detailTextLabel?.lineBreakMode = .byWordWrapping
        deleteCell.tintColor = UIColor(asset: .primary)
        return deleteCell
    }()

    private func setupTableViewCells() {
        passTitleCell.addTarget(target: self, action: #selector(handlePassTitleChange), forControlEvents: .editingChanged)
        passCodeCell.addTarget(target: self, action: #selector(handlePassCodeChange), forControlEvents: .editingChanged)

        if let pass = state.value {
            passTitleCell.textField.text = pass.title
            passCodeCell.textField.text = pass.code

            if pass.isCode39 {
                code39Cell.accessoryType = .checkmark
            } else {
                qrCell.accessoryType = .checkmark
            }

            if !UIImage.canGenerateCode39(fromString: pass.code) {
                toggleCode39(enabled: false)
            }
        } else {
            qrCell.accessoryType = .checkmark
        }
    }

    //MARK: - TableView

    private func setupTableView() {
        tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        tableView.backgroundColor = .white
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Pass Title"
        case 1: return "Pass Code"
        case 2: return "Pass Type"
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2: return "QR Codes are quicker and easier to read yet not widely used. Code39 is used more often."
        default: return nil
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if state.value != nil {
            return 4
        }
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 2
        case 3: return 1
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return passTitleCell
        case (1, 0): return passCodeCell
        case (2, 0): return qrCell
        case (2, 1): return code39Cell
        case (3, 0): return deleteCell
        default: return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 2: exclusivelySelect(indexPath.row)
        case 3: navigationController?.present(warningAlertController, animated: true, completion: nil)
        default: break
        }
    }

    private func exclusivelySelect(_ row: Int) {
        switch row {
        case 0:
            qrCell.accessoryType = .checkmark
            code39Cell.accessoryType = .none
        case 1:
            if code39Cell.textLabel?.textColor != .lightGray {
                qrCell.accessoryType = .none
                code39Cell.accessoryType = .checkmark
            }
        default: break
        }
    }

    //MARK: - TextField Targets

    @objc private func handlePassTitleChange(textField: UITextField) {
        toggleCompletionEnabled()
    }

    @objc private func handlePassCodeChange(textField: UITextField) {
        toggleCode39(enabled: UIImage.canGenerateCode39(fromString: textField.cleanedString))
        toggleCompletionEnabled()
    }

    //MARK: - Safety

    private func toggleCode39(enabled: Bool) {
        if code39Cell.accessoryType == .checkmark && !enabled {
            exclusivelySelect(0)
        }

        code39Cell.textLabel?.textColor = enabled ? .black : .lightGray
        code39Cell.detailTextLabel?.textColor = enabled ? .black : .lightGray
        code39Cell.selectionStyle = enabled ? .default : .none
    }

    private func toggleCompletionEnabled() {
        let cleanedTitle = passTitleCell.textField.cleanedString
        let cleanedCode = passCodeCell.textField.cleanedString

        if cleanedTitle != "" && cleanedCode != "" {
            completionButton.isEnabled = true
        } else {
            completionButton.isEnabled = false
        }
    }

    lazy var warningAlertController: UIAlertController = {
        guard let pass = state.value else { fatalError("No pass in sight.") }
        let warningAlertController = UIAlertController(title: "Are you sure you want to delete \(pass.title)?", message: "You will not be able to undo this action.", preferredStyle: .actionSheet)
        warningAlertController.view.tintColor = UIColor(asset: .primary)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            pass.deleteSelf(completion: { (completed, error) in
                if let error = error {
                    self.presentError(withTitle: "Oops", withText: "Failed to delete self.")
                }

                if completed {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        warningAlertController.addAction(deleteAction)
        warningAlertController.addAction(cancelAction)

        return warningAlertController
    }()
}
