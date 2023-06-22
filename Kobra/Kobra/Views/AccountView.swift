//
// AccountView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//
import SwiftUI
import Firebase

struct AccountView: View {
    @ObservedObject var viewModel = AccountViewModel()
    @EnvironmentObject var kobraViewModel: KobraViewModel
    @State var isLoggedOut = false
    @State private var isShowingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let account = viewModel.account {
                let displayName = account.username.uppercased()
                
                HStack {
                    // Profile picture
                    ZStack {
                        if let profilePicture = account.profilePicture {
                            AsyncImage(url: profilePicture) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.gray)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 20)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .padding(.leading, 20)
                        }
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            Image(systemName: "plus")
                                .resizable() // add this to allow changing the size
                                .frame(width: 20, height: 20) // change width and height to adjust size
                                .foregroundColor(.blue) // change color here
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .offset(x: 40, y: 40)
                        .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
                            ImagePicker(image: $inputImage)
                        }
                    }
                    // Account name, subscription, and following information
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) { // Adjusted spacing from 10 to 5
                            Text(displayName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                        
                        HStack {
                            VStack {
                                Text("\(account.followers.count)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                Text("Followers")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.trailing)
                            
                            VStack {
                                Text("\(account.following.count)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                Text("Following")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.trailing)
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 2)
                
                .foregroundColor(.white)
            } else {
                Text("Failed to fetch account data")
                    .foregroundColor(.white)
            }
            Spacer()
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.userPosts.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })) { post in
                        PostRow(post: post)
                            .background(Color.clear)
                            .environmentObject(kobraViewModel)
                    }
                }
            }
            .background(Color.clear)
        }
        .background(Color.clear)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        viewModel.updateProfilePicture(image: inputImage)
    }
}



