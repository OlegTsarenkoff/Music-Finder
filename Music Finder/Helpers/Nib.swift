//
//  Nib.swift
//  Music Finder
//
//  Created by Oleg Tsarenkoff on 21.07.21.
//

import UIKit

extension UIView {
    
    class func loadFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
