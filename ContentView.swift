import SwiftUI

struct ContentView: View {
    @StateObject private var foodTracker = FoodTracker()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页 - 饮食仪表盘
            HomeDashboardView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("首页")
                }
                .tag(0)
            
            // 记录 - 各种记录功能
            RecordMainView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "plus.circle.fill" : "plus.circle")
                    Text("记录")
                }
                .tag(1)
            
            // 饭搭子 - 社交功能
            FoodBuddyView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "person.2.fill" : "person.2")
                    Text("饭搭子")
                }
                .tag(2)
            
            // 我的 - 个人信息和设置
            ProfileMainView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.crop.circle.fill" : "person.crop.circle")
                    Text("我的")
                }
                .tag(3)
        }
        .environmentObject(foodTracker)
        .accentColor(.blue)
        .preferredColorScheme(.light)
    }
}

// MARK: - 首页 - 饮食仪表盘
struct HomeDashboardView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 顶部问候和快速统计
                    welcomeSection
                    
                    // 饮食仪表盘
                    nutritionDashboard
                    
                    // 今日饮食记录清单
                    todayFoodRecords
                    
                    // 健康数据概览
                    healthDataOverview
                    
                    // OKR进度展示
                    okrProgressSection
                }
                .padding()
            }
            .navigationTitle("健康饮食")
            .background(Color(.systemGray6))
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("你好，\(foodTracker.userProfile?.nickname ?? "用户")")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("今天也要健康饮食哦 ✨")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 快速统计
                VStack {
                    Text("\(Int(foodTracker.todayCalories))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("今日卡路里")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var nutritionDashboard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("营养仪表盘")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("目标: \(Int(foodTracker.dailyCalorieTarget)) kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 卡路里进度环
            HStack {
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: foodTracker.calorieProgress)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(foodTracker.calorieProgress * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text("完成")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    nutritionItem("蛋白质", value: foodTracker.todayProtein, unit: "g", color: .green)
                    nutritionItem("碳水", value: foodTracker.todayCarbs, unit: "g", color: .orange)
                    nutritionItem("脂肪", value: foodTracker.todayFat, unit: "g", color: .red)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func nutritionItem(_ name: String, value: Double, unit: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text("\(name): \(String(format: "%.1f", value))\(unit)")
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    private var todayFoodRecords: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日饮食记录")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink(destination: FoodRecordListView()) {
                    Text("查看全部")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            if foodTracker.todayRecords.isEmpty {
                VStack {
                    Image(systemName: "fork.knife.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("今天还没有饮食记录")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("点击记录按钮开始记录吧")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
            } else {
                LazyVStack {
                    ForEach(foodTracker.todayRecords.prefix(3)) { record in
                        FoodRecordRow(record: record)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var healthDataOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("健康数据")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                healthDataCard("BMI", value: String(format: "%.1f", foodTracker.bmi), subtitle: foodTracker.bmiCategory, color: .purple)
                healthDataCard("体重", value: "\(String(format: "%.1f", foodTracker.currentWeight))kg", subtitle: "当前", color: .blue)
                healthDataCard("步数", value: "\(foodTracker.healthData?.steps ?? 0)", subtitle: "今日", color: .green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func healthDataCard(_ title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var okrProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OKR进度")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let okr = foodTracker.okrProgress {
                VStack(alignment: .leading, spacing: 8) {
                    Text(okr.objective)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(okr.quarter) • 整体进度 \(Int(okr.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: okr.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    
                    ForEach(okr.keyResults.prefix(2)) { keyResult in
                        HStack {
                            Text(keyResult.description)
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("\(String(format: "%.0f", keyResult.current))/\(String(format: "%.0f", keyResult.target))\(keyResult.unit)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - 记录页面主视图
struct RecordMainView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 饮食记录选项
                    foodRecordOptions
                    
                    // 其他记录选项
                    otherRecordOptions
                }
                .padding()
            }
            .navigationTitle("记录")
            .background(Color(.systemGray6))
        }
    }
    
    private var foodRecordOptions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("饮食记录")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                recordOptionCard("拍照识别", icon: "camera.fill", description: "拍照自动识别食物", color: .blue) {
                    // 拍照识别功能
                }
                
                recordOptionCard("选择相册", icon: "photo.fill", description: "从相册选择照片识别", color: .green) {
                    // 选择相册功能
                }
                
                recordOptionCard("条形码识别", icon: "barcode.viewfinder", description: "扫描食品包装条形码", color: .orange) {
                    // 条形码识别功能
                }
                
                recordOptionCard("手工录入", icon: "square.and.pencil", description: "手动输入食物信息", color: .purple) {
                    // 手工录入功能
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var otherRecordOptions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("其他记录")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                recordListItem("情绪日记", icon: "heart.fill", color: .pink) {
                    // 情绪日记功能
                }
                
                recordListItem("运动记录", icon: "figure.run", color: .green) {
                    // 运动记录功能
                }
                
                recordListItem("体重记录", icon: "scalemass.fill", color: .blue) {
                    // 体重记录功能
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func recordOptionCard(_ title: String, icon: String, description: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func recordListItem(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 饭搭子页面
struct FoodBuddyView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // 顶部分段控制
                Picker("", selection: $selectedSegment) {
                    Text("动态").tag(0)
                    Text("列表").tag(1)
                    Text("主页").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 内容区域
                Group {
                    switch selectedSegment {
                    case 0:
                        buddyFeedView
                    case 1:
                        buddyListView
                    default:
                        buddyHomeView
                    }
                }
            }
            .navigationTitle("饭搭子")
        }
    }
    
    private var buddyFeedView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<5) { index in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading) {
                                Text("健康达人\(index + 1)")
                                    .font(.headline)
                                
                                Text("2小时前")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("关注") {
                                // 关注功能
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Text("今天的午餐很健康哦，低脂高蛋白 💪")
                            .font(.body)
                        
                        // 模拟食物图片
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .cornerRadius(8)
                        
                        HStack {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "heart")
                                    Text("点赞")
                                }
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "message")
                                    Text("评论")
                                }
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("分享")
                                }
                            }
                            
                            Spacer()
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
            }
            .padding()
        }
        .background(Color(.systemGray6))
    }
    
    private var buddyListView: some View {
        ScrollView {
            LazyVStack {
                ForEach(foodTracker.foodBuddies) { buddy in
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text(buddy.nickname)
                                .font(.headline)
                            
                            Text(buddy.bio)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(buddy.isFollowing ? "已关注" : "关注") {
                            foodTracker.followFoodBuddy(buddy)
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(buddy.isFollowing ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color(.systemGray6))
    }
    
    private var buddyHomeView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 邀请功能
                inviteSection
                
                // 抄作业功能
                copyHomeworkSection
            }
            .padding()
        }
        .background(Color(.systemGray6))
    }
    
    private var inviteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("邀请/添加饭搭子")
                .font(.headline)
                .fontWeight(.semibold)
            
            Button("邀请朋友加入") {
                // 邀请功能
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("搜索添加饭搭子") {
                // 搜索功能
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var copyHomeworkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("抄作业")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("看看优秀饭搭子的饮食搭配")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(0..<4) { index in
                    VStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 100)
                            .cornerRadius(8)
                        
                        Text("健康搭配 \(index + 1)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 1)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - 我的页面
struct ProfileMainView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 用户信息卡片
                    userInfoCard
                    
                    // 功能菜单
                    functionalMenu
                }
                .padding()
            }
            .navigationTitle("我的")
            .background(Color(.systemGray6))
        }
    }
    
    private var userInfoCard: some View {
        VStack(spacing: 16) {
            // 头像和基本信息
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text("头像")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(foodTracker.userProfile?.nickname ?? "用户昵称")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let profile = foodTracker.userProfile {
                        Text("\(profile.gender.displayName) • \(Int(profile.height))cm • \(String(format: "%.1f", profile.weight))kg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(profile.occupation.isEmpty ? "职业未设置" : profile.occupation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // 会员状态
            HStack {
                Image(systemName: foodTracker.isVIPMember ? "crown.fill" : "crown")
                    .foregroundColor(foodTracker.isVIPMember ? .yellow : .gray)
                
                Text(foodTracker.isVIPMember ? "VIP会员" : "普通用户")
                    .font(.caption)
                    .foregroundColor(foodTracker.isVIPMember ? .yellow : .secondary)
                
                Spacer()
                
                if !foodTracker.isVIPMember {
                    Button("升级VIP") {
                        // 升级VIP功能
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var functionalMenu: some View {
        VStack(spacing: 12) {
            menuGroup("目标管理", items: [
                ("目标", "target", { /* 目标设置 */ }),
                ("饮食计划", "list.bullet.clipboard", { /* 饮食计划 */ })
            ])
            
            menuGroup("会员服务", items: [
                ("会员订阅", "crown", { /* 会员订阅 */ })
            ])
            
            menuGroup("个人信息", items: [
                ("基本信息", "person.circle", { /* 基本信息 */ }),
                ("智能硬件对接", "applewatch", { /* 硬件对接 */ })
            ])
            
            menuGroup("设置", items: [
                ("个人信息收集清单", "list.bullet", { /* 信息清单 */ }),
                ("第三方信息共享清单", "square.and.arrow.up", { /* 共享清单 */ }),
                ("关于我们", "info.circle", { /* 关于我们 */ }),
                ("账号登出", "arrow.right.square", { /* 登出 */ })
            ])
        }
    }
    
    private func menuGroup(_ title: String, items: [(String, String, () -> Void)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Button(action: item.2) {
                        HStack {
                            Image(systemName: item.1)
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text(item.0)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

// MARK: - 辅助视图
struct FoodRecordRow: View {
    let record: FoodItem
    
    var body: some View {
        HStack {
            // 食物图标
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "fork.knife")
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(record.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(record.portion) • \(String(format: "%.0f", record.nutrition.calories)) kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(record.recordType.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            
            Spacer()
            
            Text(DateFormatter.timeFormatter.string(from: record.timestamp))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct FoodRecordListView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    var body: some View {
        List {
            ForEach(foodTracker.foodRecords) { record in
                FoodRecordRow(record: record)
            }
        }
        .navigationTitle("饮食记录")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    ContentView()
} 