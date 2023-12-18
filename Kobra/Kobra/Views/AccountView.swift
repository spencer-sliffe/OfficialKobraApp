//
// AccountView.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/28/23.
//
import SwiftUI
import Firebase
import Combine

struct AccountView: View {
    @EnvironmentObject private var viewModel: AccountViewModel
    @EnvironmentObject private var kobraViewModel: KobraViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var homePageViewModel: HomePageViewModel
    
    @State var isLoggedOut = false
    @State private var isShowingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showingActionSheet = false
    @State private var isEditingBio = false
    @State private var bioInput: String = ""
    @State private var showFollowerView = false
    @State private var showFollowingView = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if viewModel.isLoading {
                    loadingView()
                } else if let account = viewModel.account {
                    VStack() {
                        accountDetailsView(account: account, geometry: geometry)
                        postsListView(geometry: geometry)
                    }
                } else {
                    failureView()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func accountDetailsView(account: Account, geometry: GeometryProxy) -> some View {
        HStack(alignment: .top) {
            profilePictureSection(account: account)
                // Remove any explicit padding here if it's causing the shift

            VStack(alignment: .center, spacing: 4) {
                displayNameSection(displayName: account.username)
                    .padding(.leading, -5)
                bioSection(account: account)
                followerFollowingSection(account: account)
                    .padding(.leading, -5)
            }
            // Ensure the padding is not causing the shift to the right
        }
        // Adjust this padding or remove it to fix alignment issues
        .frame(height: geometry.size.height * 0.18) // 20% of the screen height for account details
    }

    
    private func postsListView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack {
                ForEach(viewModel.userPosts.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })) { post in
                    AccountPostRow(post: post)
                        .background(Color.clear)
                        .environmentObject(viewModel)
                }
            }
        }
        .frame(width: geometry.size.width) // 75% of the screen height for posts
    }
    
    private func loadingView() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func failureView() -> some View {
        Text("Failed to fetch account data")
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func profilePictureSection(account: Account) -> some View {
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
                    .frame(width: 25, height: 25)
                    .foregroundColor(.blue)
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
    
    @ViewBuilder
    private func displayNameSection(displayName: String) -> some View {
        Text(displayName)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .lineLimit(1)
            .truncationMode(.tail)
    }
    
    @ViewBuilder
    private func bioSection(account: Account) -> some View {
        if isEditingBio {
            CustomTextField(text: $bioInput, placeholder: "Bio", characterLimit: 125)
            HStack {
                Button(action: {
                    isEditingBio = false
                    viewModel.updateBio(bio: bioInput)
                }) {
                    Text("Save")
                }
                Button(action: {
                    isEditingBio = false
                    bioInput = "" // Clear the bio input when deleting
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
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity) // Ensure the bio text uses the full width available
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
        }
    }
    
    @ViewBuilder
    private func followerFollowingSection(account: Account) -> some View {
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
            }
            .sheet(isPresented: $showFollowerView) {
                FollowerView(viewModel: AccountProfileViewModel(accountId: viewModel.accountId))
                    .environmentObject(viewModel)
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
                    .environmentObject(viewModel)
            }
            .padding(.leading, 5)
        }
        .foregroundColor(.white)
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        viewModel.updateProfilePicture(image: inputImage)
    }
}

// Define other custom views like CustomTextField, FollowerView, FollowingView, ImagePicker as needed
