import SwiftUI

struct TodayView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @State private var selectedDate = Date()
    @State private var showingAddFood = false
    @State private var showingFoodDetail = false
    @State private var selectedFoodItem: FoodItem?
    
    // 日历数据
    private let calendar = Calendar.current
    private var weekDays: [(String, Int, Date, Bool, Bool)] {
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) ?? today
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            let dayNumber = calendar.component(.day, from: date)
            let isToday = calendar.isDate(date, inSameDayAs: today)
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            return (dayName, dayNumber, date, isToday, isSelected)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 顶部标题
                headerSection
                
                // 日历导航
                calendarSection
                
                // 今日营养概览
                nutritionOverviewCard
                
                // 餐食时间线
                mealsTimelineSection
                
                // 营养分析
                nutritionAnalysisSection
                
                // 建议与提醒
                suggestionsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Color.clear)
        .sheet(isPresented: $showingAddFood) {
            AddFoodView()
                .environmentObject(foodTracker)
        }
        .sheet(isPresented: $showingFoodDetail) {
            if let item = selectedFoodItem {
                FoodDetailView(foodItem: item)
                    .environmentObject(foodTracker)
            }
        }
    }
    
    // MARK: - 头部区域
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("今日记录")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text(formatDate(selectedDate))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: {
                showingAddFood = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                    
                    Text("添加")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
        }
    }
    
    // MARK: - 日历区域
    
    private var calendarSection: some View {
        VStack(spacing: 16) {
            // 月份年份
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // 日期选择器
            HStack(spacing: 12) {
                ForEach(weekDays, id: \.2) { day in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedDate = day.2
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(day.0)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("\(day.1)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(day.4 ? .white : .white.opacity(0.8))
                        }
                        .frame(width: 40, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(day.4 ? Color.white.opacity(0.2) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(day.3 ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        )
                    }
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
    
    // MARK: - 营养概览卡片
    
    private var nutritionOverviewCard: some View {
        VStack(spacing: 16) {
            nutritionOverviewHeader
            calorieProgressCircle
            
            // 三大营养素
            HStack(spacing: 20) {
                MacroNutrientCard(
                    title: "蛋白质",
                    value: Int(selectedDateProtein),
                    unit: "g",
                    color: .blue,
                    icon: "🥩"
                )
                
                MacroNutrientCard(
                    title: "碳水",
                    value: Int(selectedDateCarbs),
                    unit: "g",
                    color: .green,
                    icon: "🌾"
                )
                
                MacroNutrientCard(
                    title: "脂肪",
                    value: Int(selectedDateFat),
                    unit: "g",
                    color: .yellow,
                    icon: "🥑"
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
    
    // MARK: - 营养概览子组件
    
    private var nutritionOverviewHeader: some View {
        HStack {
            Text("营养概览")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("目标: \(Int(foodTracker.dailyCalorieTarget)) 卡")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var calorieProgressCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 8)
                .frame(width: 120, height: 120)
            
            calorieProgressRing
            
            calorieProgressText
        }
    }
    
    private var calorieProgressRing: some View {
        Circle()
            .trim(from: 0, to: CGFloat(min(calorieProgress, 1.0)))
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.red]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 8, lineCap: .round)
            )
            .frame(width: 120, height: 120)
            .rotationEffect(.degrees(-90))
    }
    
    private var calorieProgressText: some View {
        VStack(spacing: 4) {
            Text("\(Int(selectedDateCalories))")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("卡路里")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            let remainingCalories = Int(max(0, foodTracker.dailyCalorieTarget - selectedDateCalories))
            Text("剩余 \(remainingCalories)")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    // MARK: - 餐食时间线
    
    private var mealsTimelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("餐食时间线")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    MealTimelineCard(
                        mealType: mealType,
                        foods: selectedDateItems.filter { $0.mealType == mealType },
                        onFoodTap: { food in
                            selectedFoodItem = food
                            showingFoodDetail = true
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - 营养分析
    
    private var nutritionAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("营养分析")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                NutritionAnalysisRow(
                    title: "热量分布",
                    value: "\(Int(selectedDateCalories)) / \(Int(foodTracker.dailyCalorieTarget))",
                    progress: calorieProgress,
                    color: .orange
                )
                
                NutritionAnalysisRow(
                    title: "蛋白质",
                    value: "\(Int(selectedDateProtein))g",
                    progress: min(selectedDateProtein / 150, 1.0),
                    color: .blue
                )
                
                NutritionAnalysisRow(
                    title: "碳水化合物",
                    value: "\(Int(selectedDateCarbs))g",
                    progress: min(selectedDateCarbs / 250, 1.0),
                    color: .green
                )
                
                NutritionAnalysisRow(
                    title: "脂肪",
                    value: "\(Int(selectedDateFat))g",
                    progress: min(selectedDateFat / 80, 1.0),
                    color: .yellow
                )
            }
        }
    }
    
    // MARK: - 建议与提醒
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💡 智能建议")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(getSuggestions(), id: \.0) { suggestion in
                    SuggestionCard(
                        icon: suggestion.0,
                        title: suggestion.1,
                        description: suggestion.2,
                        color: suggestion.3
                    )
                }
            }
        }
    }
    
    // MARK: - 计算属性
    
    private var selectedDateItems: [FoodItem] {
        foodTracker.getDateData(selectedDate)
    }
    
    private var selectedDateCalories: Double {
        foodTracker.getDateCalories(selectedDate)
    }
    
    private var selectedDateProtein: Double {
        foodTracker.getDateProtein(selectedDate)
    }
    
    private var selectedDateCarbs: Double {
        foodTracker.getDateCarbs(selectedDate)
    }
    
    private var selectedDateFat: Double {
        foodTracker.getDateFat(selectedDate)
    }
    
    private var calorieProgress: Double {
                    min(selectedDateCalories / foodTracker.dailyCalorieTarget, 1.0)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedDate)
    }
    
    // MARK: - 辅助方法
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func getSuggestions() -> [(String, String, String, Color)] {
        var suggestions: [(String, String, String, Color)] = []
        
        if selectedDateCalories < foodTracker.dailyCalorieTarget * 0.8 {
            suggestions.append((
                "⚡",
                "热量不足",
                "今日热量摄入偏低，建议增加营养丰富的食物",
                .orange
            ))
        }
        
        if selectedDateProtein < 100 {
            suggestions.append((
                "🥩",
                "蛋白质补充",
                "蛋白质摄入不足，建议增加瘦肉、鱼类或豆制品",
                .blue
            ))
        }
        
        if selectedDateItems.isEmpty {
            suggestions.append((
                "📝",
                "开始记录",
                "今天还没有饮食记录，点击添加按钮开始记录",
                .green
            ))
        }
        
        if calendar.isDateInToday(selectedDate) && selectedDateItems.count >= 3 {
            suggestions.append((
                "🎉",
                "记录完整",
                "今天的饮食记录很完整，继续保持!",
                .purple
            ))
        }
        
        return suggestions
    }
}

// MARK: - 辅助视图组件

struct MacroNutrientCard: View {
    let title: String
    let value: Int
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))
            
            Text("\(value)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(unit)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.7))
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
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
}

struct MealTimelineCard: View {
    let mealType: MealType
    let foods: [FoodItem]
    let onFoodTap: (FoodItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(mealType.emoji)
                    .font(.system(size: 20))
                
                Text(mealType.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !foods.isEmpty {
                    Text("\(Int(foods.reduce(0) { $0 + $1.totalNutrition.calories })) 卡")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            if foods.isEmpty {
                Text("暂无记录")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(foods) { food in
                        Button(action: {
                            onFoodTap(food)
                        }) {
                            FoodItemRow(food: food)
                        }
                    }
                }
            }
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

struct FoodItemRow: View {
    let food: FoodItem
    
    var body: some View {
        HStack(spacing: 12) {
            Text(food.emoji)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text("\(Int(food.totalNutrition.calories)) 卡")
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                    
                    Text("\(Int(food.quantity))\(food.unit)")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatTime(food.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
                
                if food.confidence > 0 {
                    Text("\(Int(food.confidence * 100))% 准确")
                        .font(.system(size: 9))
                        .foregroundColor(.green.opacity(0.8))
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct NutritionAnalysisRow: View {
    let title: String
    let value: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.6), color]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * min(progress, 1.0), height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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

struct SuggestionCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - 添加食物视图

struct AddFoodView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMealType: MealType = .lunch
    @State private var foodName = ""
    @State private var quantity = "100"
    @State private var calories = "0"
    @State private var protein = "0"
    @State private var carbs = "0"
    @State private var fat = "0"
    @State private var selectedEmoji = "🍎"
    
    private let foodEmojis = ["🍎", "🍌", "🥗", "🍚", "🍞", "🥛", "🍗", "🐟", "🥑", "🥜", "🍅", "🥒", "🥕", "🍠", "🌽", "🥬", "🍄", "🫐", "🍓", "🥝"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 食物图标选择
                    emojiSelectionSection
                    
                    // 基本信息
                    basicInfoSection
                    
                    // 营养信息
                    nutritionInfoSection
                    
                    // 添加按钮
                    addButton
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
            .navigationTitle("添加食物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
                // 食物名称
                VStack(alignment: .leading, spacing: 8) {
                    Text("食物名称")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    TextField("请输入食物名称", text: $foodName)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // 餐食类型
                VStack(alignment: .leading, spacing: 8) {
                    Text("餐食类型")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Picker("餐食类型", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 数量
                VStack(alignment: .leading, spacing: 8) {
                    Text("数量 (克)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    TextField("100", text: $quantity)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
        }
    }
    
    private var nutritionInfoSection: some View {
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
                        
                        TextField("0", text: $calories)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("蛋白质(g)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        TextField("0", text: $protein)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("碳水化合物(g)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        TextField("0", text: $carbs)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("脂肪(g)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        TextField("0", text: $fat)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                }
            }
        }
    }
    
    private var addButton: some View {
        Button(action: {
            addFood()
        }) {
            Text("添加食物")
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
        .disabled(foodName.isEmpty)
        .opacity(foodName.isEmpty ? 0.5 : 1.0)
    }
    
    private func addFood() {
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
            unit: "g",
            nutrition: nutrition,
            recordType: .manualInput,
            mealType: selectedMealType
        )
        
        foodTracker.addFoodItem(foodItem)
        dismiss()
    }
}

// MARK: - 自定义文本输入框样式

struct CustomTextFieldStyle: TextFieldStyle {
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

#Preview {
    TodayView()
        .environmentObject(FoodTracker())
} 