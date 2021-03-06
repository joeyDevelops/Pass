//
//  PassM.swift
//  Pass
//
//  Created by Jose Aguilar on 3/16/19.
//  Copyright © 2019 Jose Aguilar. All rights reserved.
//

import UIKit
import RealmSwift

class PassM: Object {
    //IMPORTANT: - Remember to update VariableKey enum
    @objc dynamic var title = ""
    @objc dynamic var code = ""
    @objc dynamic var isCode39 = false
    @objc dynamic var isOnWatch = false
    @objc dynamic var isOnWidget = false
    @objc dynamic var isOnSiri = false

    // Ignored Properties
    var image: UIImage {
        return self.isCode39 ? UIImage.code39(fromString: self.code)! : UIImage.qr(fromString: self.code)
    }
    /// Forced QR image for watch app.
    var qrImage: UIImage {
        return UIImage.qr(fromString: self.code)
    }

    convenience init(title: String, code: String, isCode39: Bool) {
        self.init()
        self.title = title
        self.code = code
        self.isCode39 = isCode39
    }
}

//MARK: - Setters
extension PassM {
    enum VariableKey: String {
        case title, code, isCode39, isOnWatch, isOnWidget, isOnSiri
    }

    func setValue(_ value: Any, forKey key: VariableKey) throws {
        do {
            let realm = try Realm()
            try realm.write {
                self.setValue(value, forKeyPath: key.rawValue)
            }
        } catch {
            throw error
        }
    }

    func setValues(_ keyedValues: [VariableKey: Any]) throws {
        do {
            let realm = try Realm()
            try realm.write {
                for each in keyedValues {
                    self.setValue(each.value, forKeyPath: each.key.rawValue)
                }
            }
        } catch {
            throw error
        }
    }

    /// Loops all passes that have this value and unsets them, then set's this value for this pass. 
    func setUniqueValue(_ value: Bool, forKey key: VariableKey) throws {
        do {
            let realm = try Realm()

            let toBeUnset = realm.objects(PassM.self).filter("\(key.rawValue) = \(value)")

            try realm.write {
                for each in toBeUnset {
                    each.setValue(!value, forKeyPath: key.rawValue)
                }

                self.setValue(value, forKeyPath: key.rawValue)
            }
        } catch {
            throw error
        }
    }
}

extension PassM {
    func deleteSelf(completion: ((Bool, Error?) -> Void)) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(self)
            }
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
}
