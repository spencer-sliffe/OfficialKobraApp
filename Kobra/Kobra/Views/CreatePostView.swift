//
//  CreatePostView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 4/1/23.
//
import SwiftUI
import FirebaseAuth

struct CreatePostView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var kobraViewModel: KobraViewModel
    @State private var postType = "Advertisement"
    @State private var title = ""
    @State private var content = ""
    @State private var stepperPrice: Double = 0
    @State private var marketPostType = "Hardware"
    @State private var hardwareCondition = Hardware.HardwareCondition.used.rawValue
    @State private var category = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var postTypeExpanded = false
    @State private var marketPostTypeExpanded = false
    @State private var hardwareConditionExpanded = false

    var body: some View {
           NavigationView {
               ZStack {
                   LinearGradient(
                       gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.black.opacity(0.4)]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing
                   )
                   .edgesIgnoringSafeArea(.all)
                   VStack {
                       ScrollView {
                           VStack(alignment: .leading, spacing: 20) {
                               Text("Post Type")
                                   .foregroundColor(.white)
                               DropDownMenu(isExpanded: $postTypeExpanded, options: ["Advertisement", "Help", "News", "Market"], selection: $postType)
                                   .frame(maxWidth: .infinity)
                               CustomTextField(text: $title, placeholder: "Title")
                               CustomTextField(text: $content, placeholder: "Content")

                               if postType != "Market" {
                                   CustomTextField(text: $category, placeholder: "Category")
                               }
                               if postType == "Market" {
                                   marketPostContent()
                               }
                           }
                           .padding()
                       }
                       if let image = selectedImage {
                           Image(uiImage: image)
                               .resizable()
                               .scaledToFit()
                               .frame(maxWidth: 200, maxHeight: 200)
                               .shadow(radius: 10)
                       }
                       Button(action: {
                           isImagePickerPresented = true
                       }) {
                           Text("Select Image")
                               .foregroundColor(.white)
                               .padding()
                               .background(Color.black.opacity(0.6))
                               .cornerRadius(8)
                               .overlay(
                                   RoundedRectangle(cornerRadius: 8)
                                       .stroke(Color.white, lineWidth: 1)
                               )
                       }
                       .sheet(isPresented: $isImagePickerPresented, onDismiss: loadImage) {
                           ImagePicker(image: $selectedImage)
                       }
                       Spacer()
                       Button(action: {
                           // Your post creation logic here
                       }) {
                           Text("Post")
                               .foregroundColor(.white)
                               .frame(minWidth: 0, maxWidth: .infinity)
                               .padding()
                               .background(Color.black.opacity(0.6))
                               .cornerRadius(8)
                               .overlay(
                                   RoundedRectangle(cornerRadius: 8)
                                       .stroke(Color.white, lineWidth: 1)
                               )
                       }
                       .padding()
                   }
               }
               .navigationBarTitle("Create Post", displayMode: .inline)
               .navigationBarItems(trailing: Button(action: {
                   presentationMode.wrappedValue.dismiss()
               }) {
                   Text("Cancel")
                       .foregroundColor(.white)
               })
           }
       }
    
    private func loadImage() {
        isImagePickerPresented = false
    }
    
    @ViewBuilder
    private func marketPostContent() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Market Post Type")
                .foregroundColor(.white)
            DropDownMenu(isExpanded: $marketPostTypeExpanded, options: ["Hardware", "Software", "Service", "Other"], selection: $marketPostType)
                .frame(maxWidth: .infinity)
            if marketPostType == "Hardware" {
                Text("Condition")
                    .foregroundColor(.white)
                DropDownMenu(isExpanded: $hardwareConditionExpanded, options: [Hardware.HardwareCondition.new.rawValue, Hardware.HardwareCondition.used.rawValue], selection: $hardwareCondition)
                    .frame(maxWidth: .infinity)
            }
            CustomTextField(text: $category, placeholder: "Category")
            VStack(alignment: .leading) {
                Stepper(value: $stepperPrice, in: 0...Double.infinity, step: 1.0) {
                    Text("Price: $\(stepperPrice, specifier: "%.2f")")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

