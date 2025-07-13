import Foundation
import SwiftUI
import HealthKit

class FoodTracker: ObservableObject {
    // MARK: - 饮食记录
    @Published var foodRecords: [FoodItem] = []
    @Published var todayRecords: [FoodItem] = []
    
    // MARK: - 运动记录
    @Published var exerciseRecords: [ExerciseRecord] = []
    @Published var todayExercises: [ExerciseRecord] = []
    
    // MARK: - 情绪日记
    @Published var moodDiaries: [MoodDiary] = []
    @Published var todayMood: MoodDiary?
    
    // MARK: - 体重记录
    @Published var weightRecords: [WeightRecord] = []
    @Published var currentWeight: Double = 65.0
    
    // MARK: - 用户信息
    @Published var userProfile: UserProfile?
    @Published var healthData: HealthData?
    
    // MARK: - 目标管理
    @Published var healthGoals: [HealthGoal] = []
    @Published var activeGoals: [HealthGoal] = []
    @Published var okrProgress: OKRProgress?
    
    // MARK: - 饮食计划
    @Published var dietPlans: [DietPlan] = []
    @Published var activeDietPlan: DietPlan?
    @Published var dailyCalorieTarget: Double = 2000
    
    // MARK: - 会员订阅
    @Published var subscription: Subscription?
    @Published var isVIPMember: Bool = false
    
    // MARK: - 饭搭子社交
    @Published var foodBuddies: [FoodBuddy] = []
    @Published var foodPosts: [FoodPost] = []
    @Published var myPosts: [FoodPost] = []
    @Published var followingPosts: [FoodPost] = []
    
    // MARK: - 应用状态
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - 健康数据集成
    private let healthStore = HKHealthStore()
    
    // MARK: - 数据持久化
    private let userDefaults = UserDefaults.standard
    
    init() {
        setupDefaultUser()
        loadData()
        loadTodayData()
        requestHealthPermissions()
    }
    
    // MARK: - 初始化设置
    private func setupDefaultUser() {
        if userProfile == nil {
            userProfile = UserProfile(
                nickname: "健康达人",
                gender: .female,
                birthday: Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date(),
                height: 165,
                weight: 55
            )
        }
        
        if healthData == nil {
            healthData = HealthData(
                weight: userProfile?.weight ?? 55,
                height: userProfile?.height ?? 165,
                steps: 0
            )
        }
        
        setupDefaultGoals()
        setupDefaultData()
    }
    
    private func setupDefaultGoals() {
        if healthGoals.isEmpty {
            healthGoals = [
                HealthGoal(type: .weightLoss, targetValue: 50, currentValue: 55, unit: "kg"),
                HealthGoal(type: .fitness, targetValue: 10000, currentValue: 0, unit: "步"),
                HealthGoal(type: .fatLoss, targetValue: 20, currentValue: 25, unit: "%")
            ]
            activeGoals = healthGoals.filter { $0.isActive }
        }
        
        if okrProgress == nil {
            let keyResults = [
                KeyResult(description: "每日步数达标", target: 10000, current: 0, unit: "步"),
                KeyResult(description: "体重减少", target: 5, current: 0, unit: "kg"),
                KeyResult(description: "饮食记录坚持", target: 30, current: 0, unit: "天")
            ]
            okrProgress = OKRProgress(objective: "健康生活方式养成", keyResults: keyResults, quarter: "2024 Q1")
        }
    }
    
    private func setupDefaultData() {
        // 添加示例饮食记录
        if foodRecords.isEmpty {
            let nutrition1 = Nutrition(calories: 250, protein: 15, carbs: 30, fat: 8, fiber: 5, potassium: 300, vitaminC: 50)
            let record1 = FoodItem(
                name: "燕麦早餐",
                weight: 100,
                portion: "1碗",
                nutrition: nutrition1,
                recordType: .manualInput
            )
            
            let nutrition2 = Nutrition(calories: 180, protein: 20, carbs: 5, fat: 8, calcium: 200)
            let record2 = FoodItem(
                name: "鸡胸肉沙拉",
                weight: 150,
                portion: "1份",
                nutrition: nutrition2,
                recordType: .photoRecognition
            )
            
            foodRecords = [record1, record2]
        }
        
        // 添加示例运动记录
        if exerciseRecords.isEmpty {
            exerciseRecords = [
                ExerciseRecord(name: "晨跑", type: .cardio, duration: 1800, caloriesBurned: 250),
                ExerciseRecord(name: "瑜伽", type: .flexibility, duration: 1200, caloriesBurned: 120)
            ]
        }
        
        // 添加示例饭搭子
        if foodBuddies.isEmpty {
            foodBuddies = [
                FoodBuddy(nickname: "健康小达人", bio: "专注健康饮食的生活达人"),
                FoodBuddy(nickname: "减脂女王", bio: "分享减脂心得和美食"),
                FoodBuddy(nickname: "营养师小李", bio: "专业营养师，分享科学饮食")
            ]
        }
    }
    
    // MARK: - 健康数据权限
    private func requestHealthPermissions() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let readTypes: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
            HKQuantityType.quantityType(forIdentifier: .height)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, error in
            if success {
                self?.fetchHealthData()
            }
        }
    }
    
    private func fetchHealthData() {
        fetchStepCount()
        fetchWeight()
    }
    
    private func fetchStepCount() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            DispatchQueue.main.async {
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                self?.healthData = HealthData(
                    weight: self?.healthData?.weight ?? 55,
                    height: self?.healthData?.height ?? 165,
                    steps: Int(steps)
                )
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchWeight() {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, _ in
            DispatchQueue.main.async {
                if let sample = samples?.first as? HKQuantitySample {
                    let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                    self?.currentWeight = weight
                    self?.healthData = HealthData(
                        weight: weight,
                        height: self?.healthData?.height ?? 165,
                        steps: self?.healthData?.steps ?? 0
                    )
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - 饮食记录管理
    func addFoodRecord(_ record: FoodItem) {
        foodRecords.insert(record, at: 0)
        updateTodayRecords()
        saveData()
    }
    
    func deleteFoodRecord(_ record: FoodItem) {
        foodRecords.removeAll { $0.id == record.id }
        updateTodayRecords()
        saveData()
    }
    
    // 别名方法，为了兼容其他文件的调用
    func addFoodItem(_ item: FoodItem) {
        addFoodRecord(item)
    }
    
    func removeFoodItem(_ item: FoodItem) {
        deleteFoodRecord(item)
    }
    
    func updateFoodItem(_ item: FoodItem) {
        if let index = foodRecords.firstIndex(where: { $0.id == item.id }) {
            foodRecords[index] = item
            updateTodayRecords()
            saveData()
        }
    }
    
    func shareFood(_ item: FoodItem, caption: String, hashtags: [String]) {
        let post = FoodPost(
            authorId: userProfile?.id ?? UUID(),
            content: "\(caption) #\(hashtags.joined(separator: " #"))",
            foodRecords: [item]
        )
        foodPosts.append(post)
        saveData()
    }
    
    func updateTodayRecords() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        todayRecords = foodRecords.filter { record in
            record.timestamp >= today && record.timestamp < tomorrow
        }
    }
    
    // MARK: - 运动记录管理
    func addExerciseRecord(_ record: ExerciseRecord) {
        exerciseRecords.insert(record, at: 0)
        updateTodayExercises()
        saveData()
    }
    
    func deleteExerciseRecord(_ record: ExerciseRecord) {
        exerciseRecords.removeAll { $0.id == record.id }
        updateTodayExercises()
        saveData()
    }
    
    func updateTodayExercises() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        todayExercises = exerciseRecords.filter { record in
            record.timestamp >= today && record.timestamp < tomorrow
        }
    }
    
    // MARK: - 情绪日记管理
    func addMoodDiary(_ diary: MoodDiary) {
        moodDiaries.insert(diary, at: 0)
        
        // 检查是否是今天的情绪记录
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        if diary.timestamp >= today && diary.timestamp < tomorrow {
            todayMood = diary
        }
        
        saveData()
    }
    
    // MARK: - 体重记录管理
    func addWeightRecord(_ record: WeightRecord) {
        weightRecords.insert(record, at: 0)
        currentWeight = record.weight
        
        // 更新健康数据
        healthData = HealthData(
            weight: record.weight,
            height: healthData?.height ?? 165,
            steps: healthData?.steps ?? 0
        )
        
        saveData()
    }
    
    // MARK: - 目标管理
    func updateGoalProgress(_ goalId: UUID, newValue: Double) {
        if let index = healthGoals.firstIndex(where: { $0.id == goalId }) {
            healthGoals[index] = HealthGoal(
                type: healthGoals[index].type,
                targetValue: healthGoals[index].targetValue,
                currentValue: newValue,
                unit: healthGoals[index].unit,
                deadline: healthGoals[index].deadline
            )
        }
        activeGoals = healthGoals.filter { $0.isActive }
        saveData()
    }
    
    // MARK: - 饮食计划管理
    func activateDietPlan(_ plan: DietPlan) {
        activeDietPlan = plan
        dailyCalorieTarget = plan.dailyCalories
        saveData()
    }
    
    // MARK: - 会员管理
    func purchaseSubscription(_ type: SubscriptionType, price: Double) {
        subscription = Subscription(type: type, startDate: Date(), price: price)
        isVIPMember = true
        saveData()
    }
    
    // MARK: - 饭搭子社交
    func followFoodBuddy(_ buddy: FoodBuddy) {
        // 更新关注状态
        if let index = foodBuddies.firstIndex(where: { $0.id == buddy.id }) {
            let updatedBuddy = FoodBuddy(nickname: buddy.nickname, avatar: buddy.avatar, bio: buddy.bio)
            foodBuddies[index] = updatedBuddy
        }
        saveData()
    }
    
    func createFoodPost(content: String, images: [String] = [], foodRecords: [FoodItem] = []) {
        guard let userId = userProfile?.id else { return }
        
        let post = FoodPost(authorId: userId, content: content, images: images, foodRecords: foodRecords)
        foodPosts.insert(post, at: 0)
        myPosts.insert(post, at: 0)
        saveData()
    }
    
    // MARK: - 数据计算
    var todayCalories: Double {
        todayRecords.reduce(0) { $0 + $1.nutrition.calories }
    }
    
    var todayProtein: Double {
        todayRecords.reduce(0) { $0 + $1.nutrition.protein }
    }
    
    var todayCarbs: Double {
        todayRecords.reduce(0) { $0 + $1.nutrition.carbs }
    }
    
    var todayFat: Double {
        todayRecords.reduce(0) { $0 + $1.nutrition.fat }
    }
    
    var calorieProgress: Double {
        dailyCalorieTarget > 0 ? min(todayCalories / dailyCalorieTarget, 1.0) : 0
    }
    
    var bmi: Double {
        guard let height = userProfile?.height, let weight = userProfile?.weight else { return 0 }
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    var bmiCategory: String {
        let bmiValue = bmi
        switch bmiValue {
        case ..<18.5: return "偏瘦"
        case 18.5..<24: return "正常"
        case 24..<28: return "超重"
        default: return "肥胖"
        }
    }
    
    // MARK: - 数据持久化
    private func saveData() {
        // 保存到UserDefaults
        if let encoded = try? JSONEncoder().encode(foodRecords) {
            userDefaults.set(encoded, forKey: "foodRecords")
        }
        
        if let encoded = try? JSONEncoder().encode(exerciseRecords) {
            userDefaults.set(encoded, forKey: "exerciseRecords")
        }
        
        if let encoded = try? JSONEncoder().encode(moodDiaries) {
            userDefaults.set(encoded, forKey: "moodDiaries")
        }
        
        if let encoded = try? JSONEncoder().encode(weightRecords) {
            userDefaults.set(encoded, forKey: "weightRecords")
        }
        
        if let profile = userProfile, let encoded = try? JSONEncoder().encode(profile) {
            userDefaults.set(encoded, forKey: "userProfile")
        }
        
        if let goals = try? JSONEncoder().encode(healthGoals) {
            userDefaults.set(goals, forKey: "healthGoals")
        }
    }
    
    private func loadData() {
        // 从UserDefaults加载数据
        if let data = userDefaults.data(forKey: "foodRecords"),
           let decoded = try? JSONDecoder().decode([FoodItem].self, from: data) {
            foodRecords = decoded
        }
        
        if let data = userDefaults.data(forKey: "exerciseRecords"),
           let decoded = try? JSONDecoder().decode([ExerciseRecord].self, from: data) {
            exerciseRecords = decoded
        }
        
        if let data = userDefaults.data(forKey: "moodDiaries"),
           let decoded = try? JSONDecoder().decode([MoodDiary].self, from: data) {
            moodDiaries = decoded
        }
        
        if let data = userDefaults.data(forKey: "weightRecords"),
           let decoded = try? JSONDecoder().decode([WeightRecord].self, from: data) {
            weightRecords = decoded
        }
        
        if let data = userDefaults.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
        
        if let data = userDefaults.data(forKey: "healthGoals"),
           let decoded = try? JSONDecoder().decode([HealthGoal].self, from: data) {
            healthGoals = decoded
        }
    }
    
    private func loadTodayData() {
        updateTodayRecords()
        updateTodayExercises()
        
        // 加载今日情绪
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        todayMood = moodDiaries.first { diary in
            diary.timestamp >= today && diary.timestamp < tomorrow
        }
    }
    
    // MARK: - 周度数据获取
    func getWeeklyData() -> [DayData] {
        var weeklyData: [DayData] = []
        let calendar = Calendar.current
        
        // 生成过去7天的数据
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            // 计算当天的食物摄入
            let dayFoodRecords = foodRecords.filter { food in
                food.timestamp >= dayStart && food.timestamp < dayEnd
            }
            
            let dayCalories = dayFoodRecords.reduce(0) { $0 + $1.nutrition.calories }
            let dayProtein = dayFoodRecords.reduce(0) { $0 + $1.nutrition.protein }
            let dayCarbs = dayFoodRecords.reduce(0) { $0 + $1.nutrition.carbs }
            let dayFat = dayFoodRecords.reduce(0) { $0 + $1.nutrition.fat }
            
            // 计算当天的运动时间
            let dayExercises = exerciseRecords.filter { exercise in
                exercise.timestamp >= dayStart && exercise.timestamp < dayEnd
            }
            let dayExerciseMinutes = dayExercises.reduce(0) { $0 + Int($1.duration / 60) }
            
            // 创建DayData对象
            let dayData = DayData(
                date: date,
                calories: dayCalories,
                protein: dayProtein,
                carbs: dayCarbs,
                fat: dayFat,
                exerciseMinutes: dayExerciseMinutes,
                waterIntake: 2000 // 默认值，可以根据需要调整
            )
            
            weeklyData.append(dayData)
        }
        
        return weeklyData.reversed() // 按时间顺序排列
    }
    
    // MARK: - 日期相关方法
    
    func getDateData(_ date: Date) -> [FoodItem] {
        let calendar = Calendar.current
        return foodRecords.filter { foodItem in
            calendar.isDate(foodItem.timestamp, inSameDayAs: date)
        }
    }
    
    func getDateCalories(_ date: Date) -> Double {
        let dateItems = getDateData(date)
        return dateItems.reduce(0.0) { $0 + $1.nutrition.calories }
    }
    
    func getDateProtein(_ date: Date) -> Double {
        let dateItems = getDateData(date)
        return dateItems.reduce(0.0) { $0 + $1.nutrition.protein }
    }
    
    func getDateCarbs(_ date: Date) -> Double {
        let dateItems = getDateData(date)
        return dateItems.reduce(0.0) { $0 + $1.nutrition.carbs }
    }
    
    func getDateFat(_ date: Date) -> Double {
        let dateItems = getDateData(date)
        return dateItems.reduce(0.0) { $0 + $1.nutrition.fat }
    }
    
    // MARK: - 食物管理方法
    
    func shareFood(_ item: FoodItem) {
        // 分享食物到社交模块
        let post = FoodPost(
            authorId: userProfile?.id ?? UUID(),
            content: "分享了一个食物记录",
            foodRecords: [item]
        )
        foodPosts.append(post)
        myPosts.append(post)
    }
} 