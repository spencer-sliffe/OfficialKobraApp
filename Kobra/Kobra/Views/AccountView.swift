//
// AccountView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//
import SwiftUI
import Firebase

struct AccountView: View {
    @StateObject var viewModel = AccountViewModel()
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var homePageViewModel: HomePageViewModel
    @State var isLoggedOut = false
    @State private var isShowingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showingActionSheet = false
    @State private var isEditingBio = false
    @State private var bioInput: String = ""
    @State var showFollowerView = false
    @State var showFollowingView = false
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .accentColor(.white)
            } else if let account = viewModel.account {
                let displayName = account.username
                HStack {
                    HStack{
                        ZStack {
                            if let profilePicture = account.profilePicture {
                                AsyncImage(url: profilePicture) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.gray)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.gray)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            }
                            Button(action: {
                                showingActionSheet = true
                            }) {
                                Image(systemName: "ellipsis")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            .offset(x: 30, y: 30)
                            .actionSheet(isPresented: $showingActionSheet) {
                                ActionSheet(title: Text("Profile Picture Options"), buttons: [
                                    .default(Text("Upload a new picture")) {
                                        isShowingImagePicker = true
                                    },
                                    .destructive(Text("Delete current picture")) {
                                        viewModel.deleteProfilePicture()
                                    },
                                    .cancel()
                                ])
                            }
                            .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
                                ImagePicker(image: $inputImage)
                            }
                        }
                    }
                    .padding(.trailing, 10)
                    .padding(.leading, 10)
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .center, spacing: 0) {
                            Text(displayName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .padding(.leading, -18)
                            // Bio
                            if isEditingBio {
                                CustomTextField(text: $bioInput, placeholder: "Bio", characterLimit: 125)
                                    .padding(2)
                                HStack {
                                    Button(action: {
                                        isEditingBio = false
                                        viewModel.updateBio(bio: bioInput)
                                    }) {
                                        Text("Save")
                                    }
                                    Button(action: {
                                        isEditingBio = false
                                        viewModel.deleteBio()
                                    }) {
                                        Text("Delete")
                                    }
                                }
                            } else {
                                HStack{
                                    if let bio = account.bio {
                                        Text(bio)
                                            .font(bio.count > 63 ? .callout : .subheadline) // Change the font size as needed
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)

                                    }
                                    Button(action: {
                                        isEditingBio = true
                                        bioInput = account.bio ?? ""
                                    }) {
                                        Image(systemName: "pencil.circle") // You can change "pencil.circle" to any image name you prefer.
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.trailing, 12)
                            }
                            HStack {
                                Button(action: {
                                    showFollowerView = true
                                }) {
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
                                    .padding(.trailing, 30)
                                }
                                .sheet(isPresented: $showFollowerView) {
                                    FollowerView(viewModel: AccountProfileViewModel(accountId: viewModel.accountId))
                                        .environmentObject(homePageViewModel)
                                        .environmentObject(settingsViewModel)
                                }
                                
                                Button(action: {
                                    showFollowingView = true
                                }) {
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
                                }
                                .sheet(isPresented: $showFollowingView) {
                                    FollowingView(viewModel: AccountProfileViewModel(accountId: viewModel.accountId))
                                        .environmentObject(homePageViewModel)
                                        .environmentObject(settingsViewModel)
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.top, 4)
                            .padding(.leading, -33)
                        }
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
                        AccountPostRow(post: post)
                            .background(Color.clear)
                            .environmentObject(kobraViewModel)
                            .environmentObject(homePageViewModel)
                            .environmentObject(settingsViewModel)
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


