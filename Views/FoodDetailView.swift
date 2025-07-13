import SwiftUI

struct FoodDetailView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @Environment(\.dismiss) private var dismiss
    @State private var foodItem: FoodItem
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @State private var showingAddRecordAlert = false
    
    init(foodItem: FoodItem) {
        self._foodItem = State(initialValue: foodItem)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    // 食物图片和基本信息
                    foodHeaderSection
                    
                    // 营养信息详情
                    nutritionDetailsSection
                    
                    // 餐食时间和类型
                    mealInfoSection
                    
                    // AI识别信息
                    if foodItem.confidence > 0 {
                        aiInfoSection
                    }
                    
                    // 标签
                    if !foodItem.tags.isEmpty {
                        tagsSection()
                    }
                    
                    // 心情记录
                    if let mood = foodItem.mood {
                        moodSection(mood)
                    }
                    
                    // 操作按钮
                    actionButtonsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
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
            .navigationTitle("食物详情")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingEditView) {
            EditFoodView(foodItem: $foodItem)
                .environmentObject(foodTracker)
        }
        .alert("删除食物", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                foodTracker.removeFoodItem(foodItem)
                dismiss()
            }
        } message: {
            Text("确定要删除这个食物记录吗？")
        }
        .alert("添加记录", isPresented: $showingAddRecordAlert) {
            Button("取消", role: .cancel) { }
            Button("添加") {
                addFoodRecord()
            }
        } message: {
            Text("将此食物添加到今天的饮食记录中吗？")
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheetView(foodItem: foodItem)
        }
    }
    
    // MARK: - 视图组件
    
    private var foodHeaderSection: some View {
        VStack(spacing: 16) {
            // 食物图标
            Text(foodItem.emoji)
                .font(.system(size: 80))
                .frame(width: 120, height: 120)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        )
                )
            
            // 食物名称
            Text(foodItem.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            // 基本信息
            VStack(spacing: 8) {
                Text("\(Int(foodItem.quantity)) \(foodItem.unit)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(Int(foodItem.totalNutrition.calories)) 卡路里")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var nutritionDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("营养成分")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                NutritionRow(
                    icon: "flame.fill",
                    name: "热量",
                    value: "\(Int(foodItem.totalNutrition.calories))",
                    unit: "卡路里",
                    color: .orange
                )
                
                NutritionRow(
                    icon: "drop.fill",
                    name: "蛋白质",
                    value: String(format: "%.1f", foodItem.totalNutrition.protein),
                    unit: "g",
                    color: .blue
                )
                
                NutritionRow(
                    icon: "leaf.fill",
                    name: "碳水化合物",
                    value: String(format: "%.1f", foodItem.totalNutrition.carbs),
                    unit: "g",
                    color: .green
                )
                
                NutritionRow(
                    icon: "circle.fill",
                    name: "脂肪",
                    value: String(format: "%.1f", foodItem.totalNutrition.fat),
                    unit: "g",
                    color: .yellow
                )
                
                if foodItem.totalNutrition.fiber > 0 {
                    NutritionRow(
                        icon: "tree.fill",
                        name: "纤维",
                        value: String(format: "%.1f", foodItem.totalNutrition.fiber),
                        unit: "g",
                        color: .mint
                    )
                }
                
                if foodItem.totalNutrition.sugar > 0 {
                    NutritionRow(
                        icon: "sparkles",
                        name: "糖分",
                        value: String(format: "%.1f", foodItem.totalNutrition.sugar),
                        unit: "g",
                        color: .pink
                    )
                }
                
                if foodItem.totalNutrition.sodium > 0 {
                    NutritionRow(
                        icon: "drop.circle.fill",
                        name: "钠",
                        value: String(format: "%.0f", foodItem.totalNutrition.sodium),
                        unit: "mg",
                        color: .purple
                    )
                }
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
    
    private var mealInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("餐食信息")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                InfoRow(
                    icon: foodItem.mealType.emoji,
                    title: "餐食类型",
                    value: foodItem.mealType.displayName
                )
                
                InfoRow(
                    icon: "clock.fill",
                    title: "记录时间",
                    value: formatTime(foodItem.timestamp)
                )
                
                InfoRow(
                    icon: "calendar",
                    title: "日期",
                    value: formatDate(foodItem.timestamp)
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
    
    private var aiInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI识别信息")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                InfoRow(
                    icon: "brain.head.profile",
                    title: "识别准确度",
                    value: "\(Int(foodItem.confidence * 100))%"
                )
                
                // 准确度进度条
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("识别信心")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text(getConfidenceLevel(foodItem.confidence))
                            .font(.system(size: 12))
                            .foregroundColor(getConfidenceColor(foodItem.confidence))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            getConfidenceColor(foodItem.confidence).opacity(0.6),
                                            getConfidenceColor(foodItem.confidence)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(foodItem.confidence), height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
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
    
    private func tagsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("标签")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(foodItem.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                )
                        )
                }
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
    
    private func moodSection(_ mood: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("心情记录")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            InfoRow(
                icon: "heart.fill",
                title: "当时心情",
                value: mood
            )
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
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // 添加饮食记录按钮
            Button(action: {
                showingAddRecordAlert = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("添加饮食记录")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            
            // 分享按钮
            Button(action: {
                showingShareSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("分享到社交")
                        .font(.system(size: 16, weight: .medium))
                }
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
            
            // 删除按钮
            Button(action: {
                showingDeleteAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("删除记录")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.8))
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - 辅助方法
    
    private func addFoodRecord() {
        // 创建新的食物记录，使用当前时间戳
        let newFoodItem = FoodItem(
            name: foodItem.name,
            emoji: foodItem.emoji,
            weight: foodItem.weight,
            portion: foodItem.portion,
            quantity: foodItem.quantity,
            unit: foodItem.unit,
            nutrition: foodItem.nutrition,
            recordType: .manualInput,
            mealType: getCurrentMealType(),
            imageUrl: foodItem.imageUrl,
            confidence: foodItem.confidence,
            tags: foodItem.tags,
            mood: foodItem.mood
        )
        
        // 添加到食物追踪器
        foodTracker.addFoodItem(newFoodItem)
        
        // 发送通知，切换到记录tab
        NotificationCenter.default.post(name: NSNotification.Name("SwitchToRecordTab"), object: nil)
        
        // 关闭当前视图
        dismiss()
    }
    
    private func getCurrentMealType() -> MealType {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<11:
            return .breakfast
        case 11..<14:
            return .lunch
        case 14..<17:
            return .snack
        case 17..<22:
            return .dinner
        default:
            return .snack
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func getConfidenceLevel(_ confidence: Double) -> String {
        switch confidence {
        case 0.9...1.0:
            return "非常高"
        case 0.8..<0.9:
            return "高"
        case 0.7..<0.8:
            return "中等"
        case 0.6..<0.7:
            return "较低"
        default:
            return "低"
        }
    }
    
    private func getConfidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.9...1.0:
            return .green
        case 0.8..<0.9:
            return .blue
        case 0.7..<0.8:
            return .yellow
        case 0.6..<0.7:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - 辅助视图组件

struct NutritionRow: View {
    let icon: String
    let name: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(unit)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            if icon.count == 1 {
                Text(icon)
                    .font(.system(size: 16))
                    .frame(width: 24)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 24)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - 编辑食物视图

struct EditFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var foodTracker: FoodTracker
    @Binding var foodItem: FoodItem
    
    @State private var editedName: String
    @State private var editedQuantity: String
    @State private var editedCalories: String
    @State private var editedProtein: String
    @State private var editedCarbs: String
    @State private var editedFat: String
    @State private var editedMealType: MealType
    @State private var editedTags: String
    @State private var editedMood: String
    @State private var selectedEmoji: String
    
    private let foodEmojis = ["🍎", "🍌", "🥗", "🍚", "🍞", "🥛", "🍗", "🐟", "🥑", "🥜", "🍅", "🥒", "🥕", "🍠", "🌽", "🥬", "🍄", "🫐", "🍓", "🥝"]
    
    init(foodItem: Binding<FoodItem>) {
        self._foodItem = foodItem
        self._editedName = State(initialValue: foodItem.wrappedValue.name)
        self._editedQuantity = State(initialValue: String(Int(foodItem.wrappedValue.quantity)))
        self._editedCalories = State(initialValue: String(Int(foodItem.wrappedValue.nutrition.calories)))
        self._editedProtein = State(initialValue: String(format: "%.1f", foodItem.wrappedValue.nutrition.protein))
        self._editedCarbs = State(initialValue: String(format: "%.1f", foodItem.wrappedValue.nutrition.carbs))
        self._editedFat = State(initialValue: String(format: "%.1f", foodItem.wrappedValue.nutrition.fat))
        self._editedMealType = State(initialValue: foodItem.wrappedValue.mealType)
        self._editedTags = State(initialValue: foodItem.wrappedValue.tags.joined(separator: " "))
        self._editedMood = State(initialValue: foodItem.wrappedValue.mood ?? "")
        self._selectedEmoji = State(initialValue: foodItem.wrappedValue.emoji)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 表情符号选择
                    emojiSelectionSection
                    
                    // 基本信息
                    basicInfoSection
                    
                    // 营养信息
                    nutritionSection
                    
                    // 其他信息
                    additionalInfoSection
                    
                    // 保存按钮
                    saveButton
                }
                .padding(20)
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
            .navigationTitle("编辑食物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var emojiSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择图标")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 10), spacing: 12) {
                ForEach(foodEmojis, id: \.self) { emoji in
                    Button(action: {
                        selectedEmoji = emoji
                    }) {
                        Text(emoji)
                            .font(.system(size: 24))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(selectedEmoji == emoji ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(selectedEmoji == emoji ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                            )
                    }
                }
            }
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("基本信息")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("食物名称")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    TextField("请输入食物名称", text: $editedName)
                        .textFieldStyle(EditTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("数量 (克)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    TextField("100", text: $editedQuantity)
                        .textFieldStyle(EditTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("餐食类型")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Picker("餐食类型", selection: $editedMealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
    }
    
    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("营养信息 (每100克)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("卡路里")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        TextField("0", text: $editedCalories)
                            .textFieldStyle(EditTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("蛋白质(g)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        TextField("0", text: $editedProtein)
                            .textFieldStyle(EditTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("碳水化合物(g)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        TextField("0", text: $editedCarbs)
                            .textFieldStyle(EditTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("脂肪(g)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        TextField("0", text: $editedFat)
                            .textFieldStyle(EditTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
            }
        }
    }
    
    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("其他信息")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("标签 (用空格分隔)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    TextField("健康 低脂 高蛋白", text: $editedTags)
                        .textFieldStyle(EditTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("心情记录")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    TextField("记录当时的心情", text: $editedMood)
                        .textFieldStyle(EditTextFieldStyle())
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            saveChanges()
        }) {
            Text("保存修改")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .disabled(editedName.isEmpty)
        .opacity(editedName.isEmpty ? 0.5 : 1.0)
    }
    
    private func saveChanges() {
        let updatedNutrition = Nutrition(
            calories: Double(editedCalories) ?? 0,
            protein: Double(editedProtein) ?? 0,
            carbs: Double(editedCarbs) ?? 0,
            fat: Double(editedFat) ?? 0
        )
        
        let updatedFoodItem = FoodItem(
            name: editedName,
            emoji: selectedEmoji,
            weight: foodItem.weight,
            portion: foodItem.portion,
            quantity: Double(editedQuantity) ?? 100,
            unit: foodItem.unit,
            nutrition: updatedNutrition,
            recordType: foodItem.recordType,
            mealType: editedMealType,
            imageUrl: foodItem.imageUrl,
            confidence: foodItem.confidence,
            tags: editedTags.components(separatedBy: " ").filter { !$0.isEmpty },
            mood: editedMood.isEmpty ? nil : editedMood
        )
        
        // 保持原有的ID和时间戳
        var finalFoodItem = updatedFoodItem
        finalFoodItem = FoodItem(
            name: updatedFoodItem.name,
            emoji: updatedFoodItem.emoji,
            weight: updatedFoodItem.weight,
            portion: updatedFoodItem.portion,
            quantity: updatedFoodItem.quantity,
            unit: updatedFoodItem.unit,
            nutrition: updatedFoodItem.nutrition,
            recordType: updatedFoodItem.recordType,
            mealType: updatedFoodItem.mealType,
            imageUrl: updatedFoodItem.imageUrl,
            confidence: updatedFoodItem.confidence,
            tags: updatedFoodItem.tags,
            mood: updatedFoodItem.mood
        )
        
        foodItem = finalFoodItem
        foodTracker.updateFoodItem(finalFoodItem)
        dismiss()
    }
}

// MARK: - 自定义文本输入框样式

struct EditTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

// MARK: - 分享视图

struct ShareSheetView: View {
    let foodItem: FoodItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 分享预览
                sharePreview
                
                // 分享选项
                shareOptions
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
            .navigationTitle("分享食物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var sharePreview: some View {
        VStack(spacing: 16) {
            Text("分享预览")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                HStack {
                    Text(foodItem.emoji)
                        .font(.system(size: 32))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(foodItem.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(Int(foodItem.totalNutrition.calories)) 卡路里")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                }
                
                Text("刚刚享用了美味的\(foodItem.name)，营养又健康！🍎✨")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
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
    
    private var shareOptions: some View {
        VStack(spacing: 12) {
            Text("分享到")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ShareOptionButton(
                    icon: "heart.circle.fill",
                    title: "分享到FoodAI社区",
                    subtitle: "与好友分享你的饮食记录",
                    color: .blue
                ) {
                    // 分享到社区
                    dismiss()
                }
                
                ShareOptionButton(
                    icon: "camera.fill",
                    title: "保存为图片",
                    subtitle: "生成精美的食物卡片",
                    color: .green
                ) {
                    // 保存为图片
                    dismiss()
                }
                
                ShareOptionButton(
                    icon: "square.and.arrow.up",
                    title: "分享到其他应用",
                    subtitle: "微信、微博、朋友圈等",
                    color: .purple
                ) {
                    // 系统分享
                    dismiss()
                }
            }
        }
    }
}

struct ShareOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(16)
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

#Preview {
    let sampleNutrition = Nutrition(calories: 52, protein: 0.3, carbs: 14, fat: 0.2)
    let sampleFoodItem = FoodItem(
        name: "苹果",
        weight: 150,
        portion: "1个",
        nutrition: sampleNutrition,
        recordType: .photoRecognition
    )
    
    FoodDetailView(foodItem: sampleFoodItem)
        .environmentObject(FoodTracker())
} 