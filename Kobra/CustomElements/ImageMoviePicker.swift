//
//  ImagePicker.swift
//  Kobra
//
//  Created by Spencer Sliffe on 4/6/23.
//

import Foundation
import SwiftUI
import UIKit

struct ImageMoviePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var media: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = ["public.image", "public.movie"]
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImageMoviePicker

        init(_ parent: ImageMoviePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.media = url
            } else if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 1.0) {
                let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
                do {
                    try data.write(to: tempUrl)
                    parent.media = tempUrl
                } catch {
                    print(error)
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


