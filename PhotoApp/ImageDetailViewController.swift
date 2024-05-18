//
//  ImageDetailViewController.swift
//  PhotoApp
//
//  Created by Matias Rodriguez on 18/05/2024.
//

import UIKit

class ImageDetailViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    var imageView: UIImageView!
    var image: UIImage?
    var documentInteractionController: UIDocumentInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openInGallery()
        
        
    }
    
    @objc func openInGallery() {
        guard let image = image else { return }
        
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




