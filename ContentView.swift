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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToRecordTab"))) { _ in
            selectedTab = 1
        }
    }
}

// MARK: - 首页 - 饮食仪表盘
struct HomeDashboardView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @State private var animateProgress: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // 顶部问候和快速统计
                    welcomeSection
                    
                    // 主要营养仪表盘
                    mainNutritionDashboard
                    
                    // 营养详情卡片
                    nutritionDetailsGrid
                    
                    // 今日饮食记录
                    todayFoodRecords
                    
                    // 健康数据概览
                    healthDataOverview
                    
                    // OKR进度展示
                    okrProgressSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animateProgress = true
                }
                print("HomeDashboardView appeared - 滑动应该正常工作")
            }
            .navigationTitle("健康饮食")
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("你好，\(foodTracker.userProfile?.nickname ?? "用户")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("今天也要健康饮食哦 ✨")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 头像占位符
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text("👤")
                        .font(.title2)
                }
            }
            
            // 快速统计栏
            HStack(spacing: 16) {
                quickStatCard("🔥", "今日卡路里", "\(Int(foodTracker.todayCalories))", "kcal", .orange)
                quickStatCard("⚡", "完成度", "\(Int(foodTracker.calorieProgress * 100))", "%", .blue)
                quickStatCard("🎯", "目标", "\(Int(foodTracker.dailyCalorieTarget))", "kcal", .green)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func quickStatCard(_ emoji: String, _ title: String, _ value: String, _ unit: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title2)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var mainNutritionDashboard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("营养仪表盘")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("目标: \(Int(foodTracker.dailyCalorieTarget)) kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // 主要卡路里进度环
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 12)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: animateProgress ? foodTracker.calorieProgress : 0)
                    .stroke(
                        AngularGradient(
                            colors: [Color.blue, Color.purple, Color.blue],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: animateProgress)
                
                VStack(spacing: 4) {
                    Text("\(Int(foodTracker.calorieProgress * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("完成")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(foodTracker.todayCalories)) / \(Int(foodTracker.dailyCalorieTarget))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var nutritionDetailsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            nutritionCard("🥩", "蛋白质", foodTracker.todayProtein, "g", .red, 80)
            nutritionCard("🍞", "碳水化合物", foodTracker.todayCarbs, "g", .orange, 250)
            nutritionCard("🥑", "脂肪", foodTracker.todayFat, "g", .yellow, 60)
            nutritionCard("💧", "水分", 1800, "ml", .blue, 2000)
        }
    }
    
    private func nutritionCard(_ emoji: String, _ name: String, _ value: Double, _ unit: String, _ color: Color, _ target: Double) -> some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.title)
            
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("\(String(format: "%.1f", value))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // 小进度条
            ProgressView(value: value / target)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 0.8)
        }
        .frame(height: 130)
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var todayFoodRecords: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("今日饮食记录")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink(destination: FoodRecordListView()) {
                    HStack(spacing: 4) {
                        Text("查看全部")
                            .font(.caption)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            if foodTracker.todayRecords.isEmpty {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "fork.knife")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    }
                    
                    Text("今天还没有饮食记录")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("点击记录按钮开始记录吧")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(foodTracker.todayRecords.prefix(3)) { record in
                        FoodRecordRow(record: record)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.05))
                            )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var healthDataOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("健康数据")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                healthDataCard("💪", "BMI", String(format: "%.1f", foodTracker.bmi), foodTracker.bmiCategory, .purple)
                healthDataCard("⚖️", "体重", "\(String(format: "%.1f", foodTracker.currentWeight))kg", "当前", .blue)
                healthDataCard("👣", "步数", "\(foodTracker.healthData?.steps ?? 0)", "今日", .green)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func healthDataCard(_ emoji: String, _ title: String, _ value: String, _ subtitle: String, _ color: Color) -> some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.title2)
            
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
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var okrProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("OKR进度")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let okr = foodTracker.okrProgress {
                VStack(alignment: .leading, spacing: 12) {
                    Text(okr.objective)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(okr.quarter)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("整体进度 \(Int(okr.progress * 100))%")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: CGFloat(okr.progress) * 300, height: 8)
                            .animation(.easeInOut(duration: 1.0), value: animateProgress)
                    }
                    .frame(height: 8)
                    
                    VStack(spacing: 8) {
                        ForEach(okr.keyResults.prefix(2)) { keyResult in
                            HStack {
                                Text(keyResult.description)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(String(format: "%.0f", keyResult.current))/\(String(format: "%.0f", keyResult.target))\(keyResult.unit)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - 记录页面主视图
struct RecordMainView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var showingBarcodeScanner = false
    @State private var showingManualEntry = false
    @State private var showingMoodDiary = false
    @State private var showingExerciseRecord = false
    @State private var showingWeightRecord = false
    @State private var animateCards = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // 顶部欢迎区域
                    headerSection
                    
                    // 饮食记录选项
                    foodRecordOptions
                    
                    // 其他记录选项
                    otherRecordOptions
                    
                    // 快速统计
                    quickStatsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateCards = true
                }
            }
            .navigationTitle("记录")
            .background(
                LinearGradient(
                    colors: [Color.green.opacity(0.1), Color.blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
        .sheet(isPresented: $showingCamera) {
            CameraView()
                .environmentObject(foodTracker)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView()
                .environmentObject(foodTracker)
        }
        .sheet(isPresented: $showingBarcodeScanner) {
            CameraView()
                .environmentObject(foodTracker)
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualEntryView()
                .environmentObject(foodTracker)
        }
        .sheet(isPresented: $showingMoodDiary) {
            MoodDiaryView()
                .environmentObject(foodTracker)
        }
        .sheet(isPresented: $showingExerciseRecord) {
            ExerciseRecordView()
                .environmentObject(foodTracker)
        }
        .sheet(isPresented: $showingWeightRecord) {
            WeightRecordView()
                .environmentObject(foodTracker)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日记录")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("选择您要记录的内容")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text("📝")
                        .font(.title2)
                }
                .scaleEffect(animateCards ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateCards)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var foodRecordOptions: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("🍽️ 饮食记录")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("已记录 \(foodTracker.todayRecords.count) 项")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                recordOptionCard(
                    "📸", "拍照识别", "拍照自动识别食物", 
                    .blue, 0.0
                ) {
                    showingCamera = true
                }
                
                recordOptionCard(
                    "🖼️", "选择相册", "从相册选择照片识别", 
                    .green, 0.1
                ) {
                    showingImagePicker = true
                }
                
                recordOptionCard(
                    "🔍", "条形码识别", "扫描食品包装条形码", 
                    .orange, 0.2
                ) {
                    showingBarcodeScanner = true
                }
                
                recordOptionCard(
                    "✏️", "手工录入", "手动输入食物信息", 
                    .purple, 0.3
                ) {
                    showingManualEntry = true
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var otherRecordOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 其他记录")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                recordListItem("💝", "情绪日记", "记录今天的心情和感受", .pink, 0.4) {
                    showingMoodDiary = true
                }
                
                recordListItem("🏃‍♂️", "运动记录", "记录运动类型和消耗", .green, 0.5) {
                    showingExerciseRecord = true
                }
                
                recordListItem("⚖️", "体重记录", "记录体重变化", .blue, 0.6) {
                    showingWeightRecord = true
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📈 今日统计")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                quickStatCard("🍽️", "饮食", "\(foodTracker.todayRecords.count)", "次", .blue)
                quickStatCard("🏃‍♂️", "运动", "\(foodTracker.todayExercises.count)", "次", .green)
                quickStatCard("💝", "情绪", foodTracker.todayMood != nil ? "1" : "0", "次", .pink)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func recordOptionCard(_ emoji: String, _ title: String, _ description: String, _ color: Color, _ delay: Double, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 32))
                    .scaleEffect(animateCards ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: animateCards)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [color.opacity(0.5), color.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(animateCards ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: animateCards)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func recordListItem(_ emoji: String, _ title: String, _ description: String, _ color: Color, _ delay: Double, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(emoji)
                        .font(.title2)
                }
                .scaleEffect(animateCards ? 1.0 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: animateCards)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(animateCards ? 1.0 : 0.95)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: animateCards)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func quickStatCard(_ emoji: String, _ title: String, _ value: String, _ unit: String, _ color: Color) -> some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.title2)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(animateCards ? 1.0 : 0.8)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: animateCards)
    }
}

// MARK: - 手工录入视图
struct ManualEntryView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @Environment(\.dismiss) private var dismiss
    @State private var foodName = ""
    @State private var quantity = ""
    @State private var selectedUnit = "g"
    @State private var selectedMealType: MealType = .breakfast
    @State private var selectedEmoji = "🍎"
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    
    let units = ["g", "ml", "个", "份", "杯", "勺"]
    let mealTypes = MealType.allCases
    let foodEmojis = ["🍎", "🍌", "🍊", "🥕", "🍞", "🥩", "🍚", "🥛", "🍫", "🥗"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 顶部图标
                    headerSection
                    
                    // 基本信息
                    basicInfoSection
                    
                    // 营养信息
                    nutritionSection
                    
                    // 餐次选择
                    mealTypeSection
                    
                    // 提交按钮
                    submitButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .navigationTitle("手工录入")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text("✏️")
                    .font(.system(size: 32))
            }
            
            Text("手工录入食物信息")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🍽️ 基本信息")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                // 食物名称
                VStack(alignment: .leading, spacing: 8) {
                    Text("食物名称")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    TextField("请输入食物名称", text: $foodName)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // 表情符号选择
                VStack(alignment: .leading, spacing: 8) {
                    Text("选择表情")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(foodEmojis, id: \.self) { emoji in
                                Button(action: {
                                    selectedEmoji = emoji
                                }) {
                                    Text(emoji)
                                        .font(.title2)
                                        .padding(8)
                                        .background(
                                            Circle()
                                                .fill(selectedEmoji == emoji ? Color.purple.opacity(0.2) : Color.gray.opacity(0.1))
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // 数量和单位
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("数量")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        TextField("100", text: $quantity)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("单位")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Picker("单位", selection: $selectedUnit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 营养信息")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                nutritionInputField("🔥", "卡路里", "kcal", $calories)
                nutritionInputField("🥩", "蛋白质", "g", $protein)
                nutritionInputField("🍞", "碳水", "g", $carbs)
                nutritionInputField("🥑", "脂肪", "g", $fat)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func nutritionInputField(_ emoji: String, _ label: String, _ unit: String, _ binding: Binding<String>) -> some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.title2)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("0", text: binding)
                .textFieldStyle(CustomTextFieldStyle())
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var mealTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🍽️ 餐次选择")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(mealTypes, id: \.self) { mealType in
                    Button(action: {
                        selectedMealType = mealType
                    }) {
                        HStack {
                            Text(mealType.emoji)
                                .font(.title2)
                            
                            Text(mealType.displayName)
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedMealType == mealType ? Color.purple.opacity(0.2) : Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedMealType == mealType ? Color.purple.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                        )
                        .foregroundColor(selectedMealType == mealType ? .purple : .primary)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var submitButton: some View {
        Button(action: submitFood) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                
                Text("添加食物记录")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .disabled(foodName.isEmpty)
        .opacity(foodName.isEmpty ? 0.6 : 1.0)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func submitFood() {
        let nutrition = Nutrition(
            calories: Double(calories) ?? 0,
            protein: Double(protein) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0
        )
        
        let foodItem = FoodItem(
            name: foodName,
            emoji: selectedEmoji,
            weight: Double(quantity) ?? 100,
            portion: "1份",
            quantity: Double(quantity) ?? 100,
            unit: selectedUnit,
            nutrition: nutrition,
            recordType: .manualInput,
            mealType: selectedMealType
        )
        
        foodTracker.addFoodItem(foodItem)
        dismiss()
    }
}

// MARK: - 情绪日记视图占位符
struct MoodDiaryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("情绪日记")
                .font(.title)
            Text("这里将实现情绪记录功能")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("关闭") {
                dismiss()
            }
            .padding()
            .background(Color.pink)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

// MARK: - 运动记录视图占位符
struct ExerciseRecordView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("运动记录")
                .font(.title)
            Text("这里将实现运动记录功能")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("关闭") {
                dismiss()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

// MARK: - 体重记录视图占位符
struct WeightRecordView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("体重记录")
                .font(.title)
            Text("这里将实现体重记录功能")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("关闭") {
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
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

// MARK: - 图片选择器包装视图
struct ImagePickerView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var showingPicker = true
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = selectedImage {
                    VStack(spacing: 20) {
                        Text("已选择图片")
                            .font(.headline)
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                        
                        Button("确认使用") {
                            // 这里可以调用AI识别服务
                            // 暂时创建一个模拟的食物记录
                            let mockNutrition = Nutrition(calories: 150, protein: 8, carbs: 20, fat: 5)
                            let foodItem = FoodItem(
                                name: "相册选择的食物",
                                emoji: "🍎",
                                weight: 100,
                                portion: "1份",
                                nutrition: mockNutrition,
                                recordType: .albumSelection
                            )
                            foodTracker.addFoodItem(foodItem)
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    Text("选择图片...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $showingPicker) {
                ImagePicker(image: $selectedImage, isPresented: $showingPicker)
            }
            .navigationTitle("选择图片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
} 