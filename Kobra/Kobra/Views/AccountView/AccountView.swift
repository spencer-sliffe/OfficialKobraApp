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
    @State private var bioInput: String = ""
    @State private var showFollowerView = false
    @State private var showFollowingView = false
    @State private var showChangeBioView = false // New state
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
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
            .sheet(isPresented: $showChangeBioView, onDismiss: {
                // Perform any necessary actions when ChangeBioView is dismissed
                viewModel.fetchAccount() // Example: Refresh account data
            }) {
                ChangeBioView(bioInput: $bioInput, showChangeBioView: $showChangeBioView)
                    .environmentObject(viewModel)
                    .environmentObject(settingsViewModel)
                    .onTapGesture {
                        hideKeyboard()
                    }
            }
        }
    }
    
    private func accountDetailsView(account: Account, geometry: GeometryProxy) -> some View {
        HStack(alignment: .top) {
            profilePictureSection(account: account)
            // Remove any explicit padding here if it's causing the shift
            
            VStack(alignment: .center, spacing: 4) {
                displayNameSection(displayName: account.username)
                    .padding(.leading, -15)
                bioSection(account: account)
                followerFollowingSection(account: account)
                    .padding(.leading, -15)
            }
            // Ensure the padding is not causing the shift to the right
        }
        // Adjust this padding or remove it to fix alignment issues
        .frame(height: geometry.size.height * 0.14) // 20% of the screen height for account details
    }
    
    private func postsListView(geometry: GeometryProxy) -> some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.userPosts.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })) { post in
                    AccountPostRow(post: post, currentUserId: kobraViewModel.accountId)
                        .background(Color.clear)
                        .environmentObject(viewModel)
                }
            }
        }
        .refreshable {
            viewModel.fetchAccount()
        }
        .frame(width: geometry.size.width)                  // 75% of the screen height for posts
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
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .lineLimit(1)
            .truncationMode(.tail)
    }
    
    @ViewBuilder
    private func bioSection(account: Account) -> some View {
        HStack{
            if let bio = account.bio {
                Text(bio)
                    .font(bio.count < 40 ? .body : .caption) // Apply different font sizes based on the bio length
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)         // Ensure the bio text uses the full width available
            }
            Button(action: {
                showChangeBioView = true // Added line to show the ChangeBioView
            }) {
                Image(systemName: "pencil.circle")      // You can change "pencil.circle" to any image name you prefer.
                    .font(.body)
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, 5)
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
