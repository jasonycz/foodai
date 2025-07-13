import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @State private var showingGoalSettings = false
    @State private var showingUserSettings = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 用户信息卡片
                    UserInfoCard()
                    
                    // 目标设置卡片
                    GoalSettingsCard()
                    
                    // 设置选项
                    SettingsSection()
                    
                    // 关于应用
                    AboutSection()
                }
                .padding()
            }
            .navigationTitle("我的")
        }
        .sheet(isPresented: $showingGoalSettings) {
            GoalSettingsView(isPresented: $showingGoalSettings)
        }
        .sheet(isPresented: $showingUserSettings) {
            UserSettingsView(isPresented: $showingUserSettings)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView(isPresented: $showingAbout)
        }
    }
}

// 用户信息卡片
struct UserInfoCard: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    private func calculateAge(from birthday: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        return ageComponents.year ?? 0
    }
    
    var bmi: Double {
        guard let profile = foodTracker.userProfile else { return 0.0 }
        let heightInMeters = profile.height / 100
        return profile.weight / (heightInMeters * heightInMeters)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5:
            return "偏瘦"
        case 18.5..<24:
            return "正常"
        case 24..<28:
            return "超重"
        default:
            return "肥胖"
        }
    }
    
    var bmiColor: Color {
        switch bmi {
        case ..<18.5:
            return .blue
        case 18.5..<24:
            return .green
        case 24..<28:
            return .orange
        default:
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // 头像和基本信息
            HStack {
                // 头像
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("用户")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(calculateAge(from: foodTracker.userProfile?.birthday ?? Date())) 岁")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(foodTracker.activeGoals.first?.type.displayName ?? "维持体重")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            
            // BMI 信息
            HStack(spacing: 20) {
                VStack {
                    Text("体重")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(foodTracker.currentWeight)) kg")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                VStack {
                    Text("身高")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(foodTracker.userProfile?.height ?? 170)) cm")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                VStack {
                    Text("BMI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", bmi))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(bmiColor)
                        Text(bmiCategory)
                            .font(.caption)
                            .foregroundColor(bmiColor)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// 目标设置卡片
struct GoalSettingsCard: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @State private var showingGoalSettings = false
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                Text("目标设置")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("编辑") {
                    showingGoalSettings = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 10) {
                GoalItem(
                    icon: "flame.fill",
                    title: "每日卡路里目标",
                    value: "\(Int(foodTracker.dailyCalorieTarget)) kcal",
                    color: .red
                )
                
                GoalItem(
                    icon: "figure.walk",
                    title: "健康目标",
                    value: foodTracker.activeGoals.first?.type.displayName ?? "维持体重",
                    color: .green
                )
                
                GoalItem(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "目标体重",
                    value: "68 kg", // 可以添加目标体重字段
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
        .sheet(isPresented: $showingGoalSettings) {
            GoalSettingsView(isPresented: $showingGoalSettings)
        }
    }
}

struct GoalItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

// 设置选项
struct SettingsSection: View {
    @State private var showingUserSettings = false
    @State private var showingDataExport = false
    @State private var showingNotifications = false
    
    var body: some View {
        VStack(spacing: 0) {
            SettingsRow(
                icon: "person.fill",
                title: "个人信息",
                action: { showingUserSettings = true }
            )
            
            Divider()
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "bell.fill",
                title: "通知设置",
                action: { showingNotifications = true }
            )
            
            Divider()
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "square.and.arrow.up.fill",
                title: "数据导出",
                action: { showingDataExport = true }
            )
            
            Divider()
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "trash.fill",
                title: "清除数据",
                color: .red,
                action: { /* 清除数据逻辑 */ }
            )
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
        .sheet(isPresented: $showingUserSettings) {
            UserSettingsView(isPresented: $showingUserSettings)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    init(icon: String, title: String, color: Color = .blue, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                    .font(.subheadline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
        }
    }
}

// 关于应用
struct AboutSection: View {
    @State private var showingAbout = false
    
    var body: some View {
        VStack(spacing: 0) {
            SettingsRow(
                icon: "info.circle.fill",
                title: "关于应用",
                action: { showingAbout = true }
            )
            
            Divider()
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "star.fill",
                title: "评价应用",
                color: .orange,
                action: { /* 打开App Store评价 */ }
            )
            
            Divider()
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "envelope.fill",
                title: "联系我们",
                action: { /* 打开邮件 */ }
            )
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
        .sheet(isPresented: $showingAbout) {
            AboutView(isPresented: $showingAbout)
        }
    }
}

// 目标设置视图
struct GoalSettingsView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @Binding var isPresented: Bool
    
    @State private var selectedGoal: GoalType
    @State private var customCalorieGoal: Double
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        // 在init中使用临时值，在onAppear中设置实际值
        self._selectedGoal = State(initialValue: .maintenance)
        self._customCalorieGoal = State(initialValue: 2000)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("健康目标") {
                    ForEach(GoalType.allCases, id: \.self) { goal in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(goal.displayName)
                                    .font(.subheadline)
                                Text(goal.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedGoal == goal {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedGoal = goal
                        }
                    }
                }
                
                Section("卡路里目标") {
                    VStack(alignment: .leading) {
                        Text("每日卡路里目标")
                        HStack {
                            Slider(value: $customCalorieGoal, in: 1200...3500, step: 50)
                            Text("\(Int(customCalorieGoal))")
                                .frame(minWidth: 60)
                        }
                        
                        Text("推荐值: \(Int(foodTracker.dailyCalorieTarget)) 卡路里")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("目标设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // 更新用户目标
                        if foodTracker.activeGoals.first != nil {
                            // 更新现有目标类型
                        }
                        foodTracker.dailyCalorieTarget = customCalorieGoal
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            selectedGoal = foodTracker.activeGoals.first?.type ?? .maintenance
            customCalorieGoal = foodTracker.dailyCalorieTarget
        }
    }
}

// 用户设置视图
struct UserSettingsView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @Binding var isPresented: Bool
    
    @State private var weight: Double
    @State private var height: Double
    @State private var age: Int
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._weight = State(initialValue: 70)
        self._height = State(initialValue: 170)
        self._age = State(initialValue: 25)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    HStack {
                        Text("体重")
                        Spacer()
                        TextField("体重", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                    }
                    
                    HStack {
                        Text("身高")
                        Spacer()
                        TextField("身高", value: $height, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("cm")
                    }
                    
                    HStack {
                        Text("年龄")
                        Spacer()
                        TextField("年龄", value: $age, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("岁")
                    }
                }
            }
            .navigationTitle("个人信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        foodTracker.currentWeight = weight
                        if var profile = foodTracker.userProfile {
                            profile.height = height
                            profile.weight = weight
                            foodTracker.userProfile = profile
                        }
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            weight = foodTracker.currentWeight
            if let profile = foodTracker.userProfile {
                height = profile.height
                let calendar = Calendar.current
                let ageComponents = calendar.dateComponents([.year], from: profile.birthday, to: Date())
                age = ageComponents.year ?? 25
            } else {
                height = 170
                age = 25
            }
        }
    }
}

// 关于应用视图
struct AboutView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // App图标和名称
                    VStack(spacing: 15) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("FoodAI")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("版本 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // 应用介绍
                    VStack(alignment: .leading, spacing: 15) {
                        Text("关于FoodAI")
                            .font(.headline)
                        
                        Text("FoodAI是一款基于人工智能的智能饮食追踪应用。只需拍照，AI就能立即识别食物并计算营养成分，让健康饮食变得简单有趣。")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("主要功能：")
                            .font(.headline)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureItem(icon: "camera.fill", text: "AI拍照识别食物")
                            FeatureItem(icon: "chart.bar.fill", text: "详细营养分析")
                            FeatureItem(icon: "target", text: "个性化目标设置")
                            FeatureItem(icon: "chart.line.uptrend.xyaxis", text: "数据统计分析")
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(FoodTracker())
} 