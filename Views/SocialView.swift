import SwiftUI

struct SocialView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @State private var selectedTab = 0
    @State private var showingCreatePost = false
    @State private var showingFriends = false
    @State private var refreshing = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部切换栏
            socialTopBar
            
            // 主要内容
            TabView(selection: $selectedTab) {
                // 朋友圈
                FriendsTimelineView()
                    .tag(0)
                    .environmentObject(foodTracker)
                
                // 我的动态
                MyPostsView()
                    .tag(1)
                    .environmentObject(foodTracker)
                
                // 发现
                DiscoverView()
                    .tag(2)
                    .environmentObject(foodTracker)
            }
        }
        .background(Color.clear)
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView()
                .environmentObject(foodTracker)
        }
        .sheet(isPresented: $showingFriends) {
            FriendsListView()
                .environmentObject(foodTracker)
        }
    }
    
    // MARK: - 顶部切换栏
    
    private var socialTopBar: some View {
        VStack(spacing: 0) {
            HStack {
                Text("🌟 社交")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 16) {
                    // 好友列表
                    Button(action: {
                        showingFriends = true
                    }) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    
                    // 创建动态
                    Button(action: {
                        showingCreatePost = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // 切换按钮
            HStack(spacing: 0) {
                SocialTabButton(
                    title: "朋友圈",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                SocialTabButton(
                    title: "我的动态",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
                
                SocialTabButton(
                    title: "发现",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.2))
                .background(.ultraThinMaterial)
        )
    }
}

// MARK: - 社交切换按钮

struct SocialTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - 朋友圈视图

struct FriendsTimelineView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @State private var refreshing = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // 推荐关注
                if !foodTracker.followers.isEmpty {
                    RecommendedFollowSection()
                        .environmentObject(foodTracker)
                }
                
                // 朋友圈动态
                ForEach(foodTracker.socialFeed) { post in
                    SocialPostCard(post: post, showUser: true)
                        .environmentObject(foodTracker)
                }
                
                // 空状态
                if foodTracker.socialFeed.isEmpty {
                    EmptyStateView(
                        icon: "heart.circle",
                        title: "暂无动态",
                        description: "关注好友来查看他们的饮食分享"
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .refreshable {
            await refreshFeed()
        }
        .background(Color.clear)
    }
    
    private func refreshFeed() async {
        refreshing = true
        // 模拟网络请求
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        refreshing = false
    }
}

// MARK: - 我的动态视图

struct MyPostsView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // 个人统计卡片
                PersonalStatsCard()
                    .environmentObject(foodTracker)
                
                // 我的动态
                ForEach(foodTracker.myPosts) { post in
                    SocialPostCard(post: post, showUser: false)
                        .environmentObject(foodTracker)
                }
                
                // 空状态
                if foodTracker.myPosts.isEmpty {
                    EmptyStateView(
                        icon: "camera.fill",
                        title: "还没有动态",
                        description: "分享你的饮食记录，与好友互动"
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Color.clear)
    }
}

// MARK: - 发现视图

struct DiscoverView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 搜索栏
                searchBar
                
                // 热门话题
                HotTopicsSection()
                
                // 推荐用户
                RecommendedUsersSection()
                    .environmentObject(foodTracker)
                
                // 营养知识
                NutritionTipsSection()
                
                // 健康挑战
                HealthChallengesSection()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Color.clear)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("搜索用户、话题...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - 社交帖子卡片

struct SocialPostCard: View {
    let post: Post
    let showUser: Bool
    @EnvironmentObject var foodTracker: FoodTracker
    @State private var showingComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 用户信息
            if showUser {
                userHeader
            }
            
            // 食物信息
            foodInfo
            
            // 说明文字
            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)
            }
            
            // 标签
            if !post.hashtags.isEmpty {
                hashtagsView
            }
            
            // 互动按钮
            actionButtons
            
            // 点赞和评论数
            statsRow
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .sheet(isPresented: $showingComments) {
            CommentsView(post: post)
                .environmentObject(foodTracker)
        }
    }
    
    private var userHeader: some View {
        HStack(spacing: 12) {
            // 用户头像
            if let user = foodTracker.followers.first(where: { $0.id == post.userId }) {
                Text(user.avatar)
                    .font(.system(size: 24))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.nickname)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(formatTime(post.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            // 更多操作
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    private var foodInfo: some View {
        HStack(spacing: 12) {
            // 食物图标
            Text(post.foodItem.emoji)
                .font(.system(size: 32))
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
            
            // 食物详情
            VStack(alignment: .leading, spacing: 4) {
                Text(post.foodItem.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    Text("\(Int(post.foodItem.totalNutrition.calories)) 卡路里")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    
                    Text("蛋白质 \(Int(post.foodItem.totalNutrition.protein))g")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    
                    Text("碳水 \(Int(post.foodItem.totalNutrition.carbs))g")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
                
                Text(post.foodItem.mealType.displayName)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
    
    private var hashtagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(post.hashtags, id: \.self) { hashtag in
                    Text("#\(hashtag)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 2)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 24) {
            // 点赞
            Button(action: {
                foodTracker.likePost(post)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .foregroundColor(post.isLiked ? .red : .white.opacity(0.6))
                        .font(.system(size: 18))
                    
                    Text("点赞")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: post.isLiked)
            
            // 评论
            Button(action: {
                showingComments = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "message")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 18))
                    
                    Text("评论")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // 分享
            Button(action: {}) {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 18))
                    
                    Text("分享")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
        }
    }
    
    private var statsRow: some View {
        HStack {
            if post.likesCount > 0 {
                Text("\(post.likesCount) 点赞")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            if post.commentsCount > 0 {
                Text("\(post.commentsCount) 评论")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - 个人统计卡片

struct PersonalStatsCard: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("我的数据")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("本月")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            HStack(spacing: 16) {
                StatItem(
                    title: "动态数",
                    value: "\(foodTracker.myPosts.count)",
                    color: .blue
                )
                
                StatItem(
                    title: "获赞数",
                    value: "\(foodTracker.myPosts.reduce(0) { $0 + $1.likesCount })",
                    color: .red
                )
                
                StatItem(
                    title: "连续打卡",
                    value: "\(foodTracker.streak)",
                    color: .orange
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 推荐关注区域

struct RecommendedFollowSection: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("推荐关注")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("查看全部") {
                    // 查看全部推荐
                }
                .font(.system(size: 12))
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(foodTracker.followers.prefix(5)) { user in
                        RecommendedUserCard(user: user)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct RecommendedUserCard: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 8) {
            Text(user.avatar)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
            
            VStack(spacing: 2) {
                Text(user.nickname)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("LV.\(user.level)")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Button(action: {}) {
                Text("关注")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.8))
                    )
            }
        }
        .frame(width: 80)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - 热门话题

struct HotTopicsSection: View {
    private let topics = [
        "健康饮食", "减脂餐", "增肌食谱", "营养搭配", "低卡美食"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔥 热门话题")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(topics, id: \.self) { topic in
                    HStack {
                        Text("#\(topic)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(Int.random(in: 100...999))")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}

// MARK: - 推荐用户区域

struct RecommendedUsersSection: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("👥 推荐用户")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(foodTracker.followers.prefix(3)) { user in
                    UserRecommendationRow(user: user)
                }
            }
        }
    }
}

struct UserRecommendationRow: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            Text(user.avatar)
                .font(.system(size: 20))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.nickname)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(user.bio)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("关注")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.8))
                    )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - 营养知识区域

struct NutritionTipsSection: View {
    private let tips = [
        ("🥗", "均衡饮食", "每餐包含蛋白质、碳水化合物和健康脂肪"),
        ("💧", "充足饮水", "每天至少8杯水，保持身体水分充足"),
        ("🍎", "多吃蔬果", "每天5种不同颜色的蔬菜和水果")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📚 营养知识")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(tips, id: \.1) { tip in
                    HStack(spacing: 12) {
                        Text(tip.0)
                            .font(.system(size: 20))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tip.1)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text(tip.2)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}

// MARK: - 健康挑战区域

struct HealthChallengesSection: View {
    private let challenges = [
        ("🏃‍♀️", "7天健康挑战", "连续7天记录饮食", "85%"),
        ("🥛", "每日8杯水", "保持充足水分摄入", "92%"),
        ("🍎", "彩虹饮食", "每天5种颜色蔬果", "67%")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏆 健康挑战")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(challenges, id: \.1) { challenge in
                    HStack(spacing: 12) {
                        Text(challenge.0)
                            .font(.system(size: 20))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(challenge.1)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text(challenge.2)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            
                            // 进度条
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 4)
                                        .cornerRadius(2)
                                    
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(
                                            width: geometry.size.width * (Double(challenge.3.dropLast()) ?? 0) / 100,
                                            height: 4
                                        )
                                        .cornerRadius(2)
                                }
                            }
                            .frame(height: 4)
                        }
                        
                        Spacer()
                        
                        Text(challenge.3)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}

// MARK: - 空状态视图

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.4))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 创建动态视图

struct CreatePostView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @Environment(\.dismiss) private var dismiss
    @State private var caption = ""
    @State private var selectedFoodItem: FoodItem?
    @State private var hashtags = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 选择食物
                foodSelectionSection
                
                // 输入说明
                captionSection
                
                // 添加标签
                hashtagsSection
                
                Spacer()
                
                // 发布按钮
                publishButton
            }
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.05, green: 0.1, blue: 0.15), location: 0.0),
                        .init(color: Color(red: 0.1, green: 0.15, blue: 0.25), location: 0.5),
                        .init(color: Color(red: 0.15, green: 0.2, blue: 0.3), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("分享动态")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var foodSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择食物")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(foodTracker.todayItems) { item in
                        Button(action: {
                            selectedFoodItem = item
                        }) {
                            HStack(spacing: 8) {
                                Text(item.emoji)
                                    .font(.system(size: 20))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("\(Int(item.totalNutrition.calories)) 卡")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedFoodItem?.id == item.id ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedFoodItem?.id == item.id ? Color.blue : Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
    
    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("说明文字")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            TextEditor(text: $caption)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(minHeight: 100)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
    }
    
    private var hashtagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("添加标签")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            TextField("输入标签，用空格分隔", text: $hashtags)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
    }
    
    private var publishButton: some View {
        Button(action: {
            publishPost()
        }) {
            Text("发布动态")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .disabled(selectedFoodItem == nil)
        .opacity(selectedFoodItem == nil ? 0.5 : 1.0)
    }
    
    private func publishPost() {
        guard let foodItem = selectedFoodItem else { return }
        
        let hashtagArray = hashtags.components(separatedBy: " ").filter { !$0.isEmpty }
        
        foodTracker.shareFood(foodItem, caption: caption, hashtags: hashtagArray)
        dismiss()
    }
}

// MARK: - 评论视图

struct CommentsView: View {
    let post: Post
    @EnvironmentObject var foodTracker: FoodTracker
    @Environment(\.dismiss) private var dismiss
    @State private var newComment = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 评论列表
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(foodTracker.getPostComments(post.id)) { comment in
                            CommentRow(comment: comment)
                                .environmentObject(foodTracker)
                        }
                        
                        if foodTracker.getPostComments(post.id).isEmpty {
                            Text("暂无评论")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.vertical, 40)
                        }
                    }
                    .padding(20)
                }
                
                // 输入框
                commentInputBar
            }
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.05, green: 0.1, blue: 0.15), location: 0.0),
                        .init(color: Color(red: 0.1, green: 0.15, blue: 0.25), location: 0.5),
                        .init(color: Color(red: 0.15, green: 0.2, blue: 0.3), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("评论")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var commentInputBar: some View {
        HStack(spacing: 12) {
            TextField("写评论...", text: $newComment)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                )
            
            Button(action: {
                if !newComment.isEmpty {
                    foodTracker.addComment(post, content: newComment)
                    newComment = ""
                }
            }) {
                Text("发送")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                    )
            }
            .disabled(newComment.isEmpty)
            .opacity(newComment.isEmpty ? 0.5 : 1.0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .background(.ultraThinMaterial)
        )
    }
}

struct CommentRow: View {
    let comment: Comment
    @EnvironmentObject var foodTracker: FoodTracker
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 用户头像
            if let user = foodTracker.followers.first(where: { $0.id == comment.userId }) {
                Text(user.avatar)
                    .font(.system(size: 16))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.nickname)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(comment.content)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        Text(formatTime(comment.timestamp))
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                        
                        if comment.likesCount > 0 {
                            Text("\(comment.likesCount) 点赞")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - 好友列表视图

struct FriendsListView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 切换栏
                HStack(spacing: 0) {
                    Button(action: { selectedTab = 0 }) {
                        Text("关注")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Rectangle()
                                    .fill(selectedTab == 0 ? Color.blue.opacity(0.3) : Color.clear)
                            )
                    }
                    
                    Button(action: { selectedTab = 1 }) {
                        Text("粉丝")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Rectangle()
                                    .fill(selectedTab == 1 ? Color.blue.opacity(0.3) : Color.clear)
                            )
                    }
                }
                .background(Color.white.opacity(0.1))
                
                // 列表内容
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(selectedTab == 0 ? foodTracker.following : foodTracker.followers) { user in
                            FriendRow(user: user)
                        }
                    }
                    .padding(20)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.05, green: 0.1, blue: 0.15), location: 0.0),
                        .init(color: Color(red: 0.1, green: 0.15, blue: 0.25), location: 0.5),
                        .init(color: Color(red: 0.15, green: 0.2, blue: 0.3), location: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("好友")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct FriendRow: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            Text(user.avatar)
                .font(.system(size: 20))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.nickname)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text("LV.\(user.level) • \(user.followersCount) 粉丝")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {}) {
                Text(user.isFollowing ? "已关注" : "关注")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(user.isFollowing ? Color.white.opacity(0.2) : Color.blue.opacity(0.8))
                    )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    SocialView()
        .environmentObject(FoodTracker())
} 