//
//  ViewController.swift
//  HelloMetal
//
//  Created by Akio Takei on 2017/12/21.
//  Copyright © 2017 Akio Takei. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var combinedIv: UIImageView!
    @IBOutlet weak var imageSizeLb: UILabel!
    
    let metal = ATMetal.shared
    
    @IBAction func onVideoButtonPressed(_ sender: Any) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.delegate = self
        picker.allowsEditing = true
        picker.videoMaximumDuration = 5
        picker.videoQuality = .typeMedium
        present(picker, animated: true)
    }
    
    func combineManyFrames(_ url: URL) {
        
        self.combinedIv.image = nil
        self.imageSizeLb.text = ""
        
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            var cgImages = [CGImage]()
            for i in 0..<Int(asset.duration.seconds * 60) {
                let time = CMTimeMake(Int64(i), 60)
                guard let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) else {
                    break
                }
                cgImages.append(cgImage)
            }
            let startTime = Date()
            self.metal.combineImages(cgImages, { (combinedImage) in
                if let image = combinedImage {
                    self.combinedIv.image = image
                    let duration = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
                    self.imageSizeLb.text = "\(image.size) : \(duration)"
                }
            })
        }
    }
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType == kUTTypeMovie as String, let url = info[UIImagePickerControllerMediaURL] as? URL {
            combineManyFrames(url)
        }
        picker.dismiss(animated: true)
    }
}
