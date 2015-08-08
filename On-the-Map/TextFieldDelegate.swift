//
//  TextFieldDelegate.swift
//  On-the-Map
//
//  Created by Lauren Bongartz on 8/7/15.
//  Copyright (c) 2015 Lauren Bongartz. All rights reserved.
//

import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    // Dismisses keyboard when user taps "return".
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}
