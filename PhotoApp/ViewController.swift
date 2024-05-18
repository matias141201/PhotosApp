//
//  ViewController.swift
//  PhotoApp
//
//  Created by Matias Rodriguez on 05/05/2024.
//

import CropViewController
import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate, UIDocumentInteractionControllerDelegate {
    
    var croppedImages: [UIImage] = []
    var documentInteractionController: UIDocumentInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button.setTitle("Select a photo", for: .normal)
        button.setTitleColor(UIColor { traitCollection in
                   return traitCollection.userInterfaceStyle == .dark ? .white : .black
               }, for: .normal)
        view.addSubview(button)
        button.center = view.center
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        displayCroppedImages()
        
    }
    
    
    @objc func didTapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true)
        
        showCrop(image: image)
    }
    
    func showCrop(image: UIImage) {
        let vc = CropViewController(croppingStyle: .default, image: image)
        vc.aspectRatioPreset = .presetSquare
        vc.aspectRatioLockEnabled = false
        vc.showCancelConfirmationDialog = true
        vc.toolbarPosition = .bottom
        vc.doneButtonTitle = "Done"
        vc.cancelButtonTitle = "Back"
        vc.cancelButtonColor = .systemRed
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        
        saveImageToPhotoLibrary(image: image)
        
        croppedImages.append(image)
        
        displayCroppedImages()
    }
    
    func saveImageToPhotoLibrary(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully.")
        }
    }
    
    func displayCroppedImages() {
        view.subviews.filter { $0 is UIImageView }.forEach { $0.removeFromSuperview() }
        
        let imageSize = CGSize(width: 100, height: 100)
        let margin: CGFloat = 20
        let startX = margin
        var currentX = startX
        let startY = view.bounds.height - imageSize.height - margin
        
        for (index, image) in croppedImages.enumerated() {
            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: currentX, y: startY), size: imageSize))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = image
            imageView.layer.cornerRadius = 8
            imageView.isUserInteractionEnabled = true
            imageView.tag = index
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage(_:)))
            imageView.addGestureRecognizer(tapGesture)
            view.addSubview(imageView)
            
            currentX += imageSize.width + margin
        }
    }
    
    @objc func didTapImage(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        let selectedImage = croppedImages[imageView.tag]
        
        openImageInGallery(image: selectedImage)
    }
    
    func openImageInGallery(image: UIImage) {
        if let imageData = image.pngData() {
            let tempDirectory = FileManager.default.temporaryDirectory
            let imageURL = tempDirectory.appendingPathComponent("tempImage.png")
            
            do {
                try imageData.write(to: imageURL)
                documentInteractionController = UIDocumentInteractionController(url: imageURL)
                documentInteractionController?.uti = "public.png"
                documentInteractionController?.delegate = self
                documentInteractionController?.presentPreview(animated: true)
            } catch {
                let alert = UIAlertController(title: "Error", message: "Unable to open image in gallery.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
