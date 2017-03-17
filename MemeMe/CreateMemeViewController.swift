//
//  CreateMemeViewController.swift
//  MemeMe
//
//  Created by Omar Gonzalez on 3/13/17.
//  Copyright © 2017 Omar. All rights reserved.
//

import UIKit
import AVFoundation

class CreateMemeViewController: UIViewController, UINavigationControllerDelegate {
  

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!
  
  @IBOutlet weak var shareButton: UIBarButtonItem!
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  @IBOutlet weak var albumButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  @IBOutlet weak var croppingFrame: UIView!
  
  lazy var pan: UIPanGestureRecognizer = {
    let recognizer = UIPanGestureRecognizer(
      target: self,
      action: #selector(recognizePanGesture(sender:))
    )
    return recognizer
  }()
  
  lazy var tap: UITapGestureRecognizer = {
    let recognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(recognizeTapGesture(sender:))
    )
    return recognizer
  }()
  

  
  let defaultText = "ENTER TEXT HERE"
  
  let memeTextAttributes = [
    NSStrokeColorAttributeName : UIColor.black,
    NSForegroundColorAttributeName : UIColor.white,
    NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    NSStrokeWidthAttributeName : -3.0
    ] as [String : Any]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    
    view.backgroundColor = UIColor.gray
    
    
    shareButton.isEnabled = false
    
    if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
      
      cameraButton.isEnabled = false
    }
    
    
    topTextField.defaultTextAttributes = memeTextAttributes
    topTextField.delegate = self
    topTextField.attributedPlaceholder = NSAttributedString(string: defaultText, attributes: memeTextAttributes)
    topTextField.textAlignment = NSTextAlignment.center
    
    bottomTextField.defaultTextAttributes = memeTextAttributes
    bottomTextField.delegate = self
    bottomTextField.attributedPlaceholder = NSAttributedString(string: defaultText, attributes: memeTextAttributes)
    bottomTextField.textAlignment = NSTextAlignment.center
    
    imageView.addGestureRecognizer(pan)
    view.addGestureRecognizer(tap)
    imageView.isUserInteractionEnabled = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Subscribe to keyboard notifications
    NotificationCenter.default.addObserver(self, selector: #selector(CreateMemeViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(CreateMemeViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }


  @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
    
    switch sender {
    case albumButton:
      albumButtonAction()
      break
    case shareButton:
      shareButtonAction()
      break
    case cameraButton:
      cameraButtonAction()
      break
    default:
      cancelButtonAction()
      break
    }
    
  }
  
  func toolbarHeight() -> CGFloat {
    let toolbarHeight: CGFloat = navigationController?.toolbar?.frame.height ?? 44.0
    return toolbarHeight
  }
  
  func shareButtonAction() {
    
    
    // Generate a new memed image
    let meme = Meme(
      topText: (topTextField.text)!,
      bottomText: (bottomTextField.text)!,
      originalImage: imageView.image!,
      memedImage: generateMemedImage()
    )
    
    
    let activityView = UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil)
    
    present(activityView, animated: true, completion: nil)
  }
  
  func cancelButtonAction() {
    dismiss(animated: true, completion: nil)
  }
  
  func cameraButtonAction() {
    
    if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized {
      
      showCamera()
      
    } else {
      
      AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
        if granted == true {
          DispatchQueue.main.async(execute: { () -> Void in
            self.showCamera()
          })
        } else {
          DispatchQueue.main.async(execute: { () -> Void in
            self.configureShareEnableState(false)
          })
        }
      })
    }
  }
  
  func albumButtonAction() {
    
    let imagePicker = UIImagePickerController()
    
    imagePicker.delegate = self
    
    present(imagePicker, animated: true, completion: nil)
  }
  
  func configureHiddenPropertyToolbarsAndNavbar(_ hidden: Bool) {
    
    navigationController?.isToolbarHidden = hidden
    navigationController?.isNavigationBarHidden = hidden
  }
  
  func recognizeTapGesture(sender: UITapGestureRecognizer) {
    
    if self.imageView.image == nil {
      albumButtonAction()
    } else {
      imageView.frame = croppingFrame.frame
    }
    
  }
  

  
  func recognizePanGesture(sender: UIPanGestureRecognizer) {
    let translate = sender.translation(in: self.view)
    
    let width =  self.imageView.frame.width
    let height =  self.imageView.frame.height
    if width > height {
      sender.view!.center = CGPoint(x:sender.view!.center.x,
                                    y:sender.view!.center.y + translate.y)
    } else {
      sender.view!.center = CGPoint(x:sender.view!.center.x + translate.x,
                                    y:sender.view!.center.y)
    }
    
    sender.setTranslation(CGPoint.zero, in: self.view)
  }
  
  func configureShareEnableState(_ state: Bool) {
    
    if state {
      
      shareButton.isEnabled = true
      
    } else {
      
      shareButton.isEnabled = false
      cancelButton.isEnabled = false
      topTextField.text = defaultText
      bottomTextField.text = defaultText
      imageView.image = nil
    }
  }
  
  func showCamera() {
    
    let camera = UIImagePickerController()
    
    camera.delegate = self
    camera.allowsEditing = false
    camera.sourceType = UIImagePickerControllerSourceType.camera
    camera.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.photo
    camera.modalPresentationStyle = UIModalPresentationStyle.fullScreen
    
    present(camera, animated: true, completion: nil)
  }
  
  func generateMemedImage() -> UIImage {
    
    UIGraphicsBeginImageContext(croppingFrame.frame.size)
    view.drawHierarchy(in: croppingFrame.bounds, afterScreenUpdates: true)
    var memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    let croppingRect = croppingFrame.bounds.divided(atDistance: toolbarHeight(), from: .maxYEdge).remainder
    if let cropedImage = memedImage.cgImage?.cropping(to: croppingRect) {
      memedImage = UIImage(cgImage: cropedImage)
    }
    
    return memedImage
  }
  
  
  func keyboardWillShow(_ notification: Notification) {
    if bottomTextField.isFirstResponder {
      view.transform = view.transform.translatedBy(x: 0, y: -getKeyboardHeight(notification))
    }
  }
  
  func keyboardWillHide(_ notification: Notification) {
    if bottomTextField.isFirstResponder {
      view.transform = .identity
    }
  }
  
  func getKeyboardHeight(_ notification: Notification) -> CGFloat {
    
    guard let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
      return 230.0
    }
    
    
    return keyboardSize.cgRectValue.height - toolbarHeight()
  }
}

// MARK: UIImagePickerControllerDelegate
extension CreateMemeViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      
      imageView.contentMode = .scaleAspectFill
      imageView.image = pickedImage
      configureShareEnableState(true)
      
    } else {
      
      configureShareEnableState(false)
    }
    
    DispatchQueue.main.async { () -> Void in
      
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    
    DispatchQueue.main.async { () -> Void in
      
      self.dismiss(animated: true, completion: nil)
    }
  }
}

// MARK: UITextFieldDelegate
extension CreateMemeViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {

    
  }
}

