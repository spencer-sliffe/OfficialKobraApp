# Kobra

- The iOS application counterpart of https://kobracoding.com
        -  https://kobracoding.com is currently down to be recoded in React
- Currently being developed by the Creator of KobraCoding / https://kobracoding.com
- Created with:
        - Swift
        - FireBase

# Final Goal

- A mobile application that shares data with "kobracoding.com"
- Kobra Account Database Transaction capablity on website and app
- Universal feed for Marketplace Posts, News Posts, Help Posts, Advertisement Posts, Bug Posts
- Kobra Account Management
- Monthly Subscriptions
- Allow Kobra users to connect and communicate through private chat
- Allow Kobra users to connect and communicate through Global chat
- Expand marketplace and allow users to sell hardware and software/solutions to eachother (similar to facebook marketplace but focused)
- Forums of communities surrounding the topics: Computers, Software, Coding, Music, American Sports, Video Games, World News, etc...

# Current Navigation
MainAppView (View)
└─ HomePageView (View)
    └─ body (some View)
       └─ NavigationView (StackNavigationViewStyle)
          └─ ZStack
             └─ TabView (PageTabViewStyle)
                ├─ SettingsView (Tab)
                ├─ AccountView (Tab)
                |    ├─ AccountPostRow (Feed Elements)
                |    |    └─ AccountProfileView (SubView)  
                |    |        ├─ AccountProfilePostRow (Feed Elements)
                |    |        ├─ FollowerView (SubView)  *See Below for FollowerView Nav/View info*
                |    |        └─ FollowingView (SubView) *See Below for FollowerView Nav/View info*
                |    ├─ FollowerView (SubView)
                |    |    └─ FollowCell (List Element)  
                |    |        └─ AccountProfileView (SubView)  
                |    |            ├─ AccountProfilePostRow (Feed Elements)
                |    |            |    └─ AccountProfileView (SubView)  *Preceding AccountProfileView has Nav/View info*
                |    |            ├─ FollowerView (SubView)  *See Preceding FollowerView for Nav/View info*
                |    |            ├─ FollowingView (SubView) *See Below FollowingView for Nav/View info*
                |    ├─ FollowingView (SubView)    
                |    |    └─ FollowCell (List Element)  
                |    |        └─ AccountProfileView (SubView)  
                |    |            ├─ AccountProfilePostRow (Feed Elements)
                |    |            |    └─ AccountProfileView (SubView)  *Preceding AccountProfileView has Nav/View info*
                |    |            ├─ FollowerView (SubView)  *See Preceding FollowerView for Nav/View info*
                |    |            └─ FollowingView (SubView) *See Preceding FollowingView for Nav/View info*
                |    └─ ChangeBioView (SubView)    
                ├─ DiscoverView (Tab)         
                |    ├─ DiscoverPostRow (SubView)     
                |    |    └─ AccountProfileView (SubView)  
                |    |        ├─ FollowerView (SubView)  
                |    |        └─ FollowingView (SubView) 
                |    └─ AccountCell (Searched List Element)  
                |        └─ AccountProfileView (SubView)  
                |            ├─ FollowerView (SubView)  
                |            └─ FollowingView (SubView) 
                ├─ KobraView (Tab)         
                |    ├─ Recent Feed (SubTab)      |\
                |    ├─ Advertisement Feed (SubTab) | \
                |    ├─ Help Feed (SubTab)         |  ├─ CommentView (SubView)        
                |    ├─ News Feed (SubTab)         |  ├─ PostRow (Feed Elements)
                |    ├─ Bug Feed (SubTab)          |  /       └─ AccountProfileView (SubView)
                |    ├─ Market Feed (SubTab)       | /        ├─ AccountProfilePostRow (Feed Elements)
                |    ├─ Meme Feed (SubTab)         |/         ├─ FollowerView (SubView)  
                |    └─ CreatePostView (SubView)            └─ FollowingView (SubView) 
<<<<<<< Updated upstream
                ├─ InboxView (Tab)                        └─ *See AccountVIew for Follower/FollowingView Nav/View*
=======
                ├─ InboxView (Tab)                        └─ *See AccountView for Follower/FollowingView Nav/View*
>>>>>>> Stashed changes
                |    ├─ ChatView (SubView)
                |    |    ├─ ParticipantView (SubView)
                |    |    └─ AccountProfileView (SubView)  
                |    |        ├─ FollowerView (SubView)  *See AccountView for FollowerView for Nav/View info*
                |    |        └─ FollowingView (SubView) *See AccountView for FollowingView for Nav/View info*
                |    └─AddChatView (SubView)
                └─  FoodView (Tab)
                    ├─ FoodRow (Feed Element)
                    └─ CreateFoodView (SubView)
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes

# Account

- Creation (Complete)
- Sign in (Complete)
- Log out (Complete)
- Delete (To be Implemented)
- Create Bio (Complete)
- Edit Bio (Complete)
- Follow Users (Complete)
- Unfollow Users (Complete)
- View Followers (Complete)
- View Following (Complete)
- Profile Picture (Complete)
- View/Delete Posts (Complete)

# Create Post

- Memes (Complete)
- News (Complete)
- Advertisements (Complete)
- Bugs (Complete)
- Help (Complete)
- Market (Needs Functionality)
- Personal (Needs Implementation)
- Takes (Needs Implementation)
- Replace Category with HashTags (Needs to be Completed)
        
# Post Interaction

- Liking (Complete)
- Disliking (Complete)
- Commenting (Fix Username Bug)
- View Image (Complete)
- View Account (Complete)
- Share Post via Chat (Needs Implementation)
- Delete Post (Complete)
- View External Link (Needs Implementation)
        
# Post Feed (KobraView)

- Memes (Complete)
- News (Complete)
- Advertisements (Complete)
- Bugs (Complete)
- Help (Complete)
- Market (Needs Functionality)
- Personal (Needs Implementation)
- Takes (Needs Implementation) 
- Hot Feed (Needs Implementation)
- Following (Needs Implementation)
        
# Notifications

- New Follower (Complete)
- New Like on Post (Complete)
- New Dislike on Post (Complete)
- New Comment on Post (Fix Username Bug)
- Notification to Phones Lock Screen (Needs Implementation)
    
# Chat System 

- Add Chat
- Send Messages
- Send Posts
- Send Images
- Send Videos
- Delete Chats
- Delete Messages

# Food

- Post Recipes
- Like Recipe
- Dislike Recipe

# Update Coming Soon

- View Account Details (Complete)
- Edit Account (Complete)
- Make Posts With Account (Complete)
- View Subscription Status (Complete)
- Purchase Subscription (Needs System)
- Upgrade Subscription (Needs System)
- Cancel Subscription
- Chat System (Underway)

# Language

- Swift

# IDE

- Xcode
- TextMate

# Package Subscriptions
- Premium: $4.99
- Gold: $499.99
- Platinum: $799.99
- Diamond: $1249.99
