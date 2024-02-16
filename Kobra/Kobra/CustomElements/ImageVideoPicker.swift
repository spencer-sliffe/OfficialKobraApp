//
//  ImagePicker.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/6/23.
//

import Foundation
import SwiftUI
import UIKit

import SwiftUI
import UIKit

struct ImageVideoPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var image: UIImage?
    @Binding var video: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true // This allows basic editing like scaling and cropping to a square
        picker.mediaTypes = ["public.image", "public.movie"]
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImageVideoPicker

        init(_ parent: ImageVideoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.video = url
            } else if let editedImage = info[.editedImage] as? UIImage {  // Use editedImage key instead of originalImage
                parent.image = editedImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


