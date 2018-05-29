//
//  MemeMeViewController.swift
//  Image Picker Experiment
//
//  Created by Gerry Morales Meza on 5/23/18.
//  Copyright © 2018 Gerry Morales Meza. All rights reserved.
//

import UIKit

class MemeMeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBottom: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    let textFieldDelegate = TextFieldDelegate()
    
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3.5]
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if(textFieldBottom.isEditing) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextField(textfield: textFieldTop)
        setTextField(textfield: textFieldBottom)
        shareButton.isEnabled = false
        
    }
    
    func setTextField(textfield: UITextField) {
        textfield.textAlignment = .center
        textfield.defaultTextAttributes = memeTextAttributes
        textfield.delegate = textFieldDelegate
        textfield.isEnabled = false
    }

    
    @IBAction func pickImage(_ sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        if(sender.tag == 1) {
            pickerController.sourceType = .photoLibrary
        } else {
            pickerController.sourceType = .camera
        }
        
        present(pickerController, animated: true, completion: nil)
    }
    

    
    func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicker.image = image
            imagePicker.contentMode = .scaleAspectFit
            textFieldTop.text = "TOP"
            textFieldBottom.text = "BOTTOM"
            textFieldTop.isEnabled = true
            textFieldBottom.isEnabled = true
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    

    
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isToolbarHidden = true
        shareButton.isEnabled = false
        toolBar.isHidden = true
        shareButton.backgroundColor = UIColor.clear
        
        
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = false
        shareButton.isEnabled = true
        toolBar.isHidden = false
        shareButton.backgroundColor = UIColor.white
        return memedImage
    }
    
    func save(memedImage: UIImage) {
        // Create the meme
        let meme = Meme(topText: textFieldTop.text!, bottomText: textFieldBottom.text!, originalImage: imagePicker.image!, memedImage: memedImage)
       
    }
    
    
    @IBAction func share(_ sender: Any) {
        let meme = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if (completed) {
                self.save(memedImage: meme)
            }
            
        }
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
}

