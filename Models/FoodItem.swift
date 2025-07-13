import Foundation
import SwiftUI

// MARK: - 营养信息
struct Nutrition: Codable {
    let calories: Double        // 卡路里
    let protein: Double         // 蛋白质(g)
    let carbs: Double          // 碳水化合物(g)
    let fat: Double            // 脂肪(g)
    let fiber: Double          // 纤维(g)
    let sugar: Double          // 糖(g)
    let sodium: Double         // 钠(mg)
    let potassium: Double      // 钾(mg)
    let vitaminC: Double       // 维生素C(mg)
    let calcium: Double        // 钙(mg)
    let iron: Double           // 铁(mg)
    
    init(calories: Double, protein: Double, carbs: Double, fat: Double, 
         fiber: Double = 0, sugar: Double = 0, sodium: Double = 0,
         potassium: Double = 0, vitaminC: Double = 0, calcium: Double = 0, iron: Double = 0) {
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.potassium = potassium
        self.vitaminC = vitaminC
        self.calcium = calcium
        self.iron = iron
    }
}

// MARK: - 食物记录
struct FoodItem: Codable, Identifiable {
    let id: UUID
    let name: String           // 食物名称
    let emoji: String          // 食物表情符号
    let image: String?         // 食物图片
    let weight: Double         // 重量(克)
    let portion: String        // 份量描述
    let quantity: Double       // 数量
    let unit: String           // 单位
    let nutrition: Nutrition   // 营养信息
    let timestamp: Date        // 记录时间
    let recordType: FoodRecordType  // 记录方式
    let barcode: String?       // 条形码(如果是扫码录入)
    let mealType: MealType     // 餐次类型
    let imageUrl: String?      // 图片URL
    let confidence: Double     // AI识别置信度
    let tags: [String]         // 标签
    let mood: String?          // 心情备注
    
    init(name: String, emoji: String = "🍎", image: String? = nil, weight: Double, portion: String, 
         quantity: Double = 100, unit: String = "g", nutrition: Nutrition, recordType: FoodRecordType, 
         mealType: MealType = .breakfast, barcode: String? = nil, imageUrl: String? = nil, 
         confidence: Double = 1.0, tags: [String] = [], mood: String? = nil) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.image = image
        self.weight = weight
        self.portion = portion
        self.quantity = quantity
        self.unit = unit
        self.nutrition = nutrition
        self.timestamp = Date()
        self.recordType = recordType
        self.mealType = mealType
        self.barcode = barcode
        self.imageUrl = imageUrl
        self.confidence = confidence
        self.tags = tags
        self.mood = mood
    }
    
    // 计算总营养值（基于数量）
    var totalNutrition: Nutrition {
        let ratio = quantity / 100.0 // 假设nutrition是基于100g的
        return Nutrition(
            calories: nutrition.calories * ratio,
            protein: nutrition.protein * ratio,
            carbs: nutrition.carbs * ratio,
            fat: nutrition.fat * ratio,
            fiber: nutrition.fiber * ratio,
            sugar: nutrition.sugar * ratio,
            sodium: nutrition.sodium * ratio,
            potassium: nutrition.potassium * ratio,
            vitaminC: nutrition.vitaminC * ratio,
            calcium: nutrition.calcium * ratio,
            iron: nutrition.iron * ratio
        )
    }
}

// MARK: - 食物记录方式
enum FoodRecordType: String, CaseIterable, Codable {
    case photoRecognition = "photo"     // 拍照识别
    case albumSelection = "album"       // 选择相册
    case barcodeScanning = "barcode"    // 条形码识别
    case manualInput = "manual"         // 手工录入
    
    var displayName: String {
        switch self {
        case .photoRecognition: return "拍照识别"
        case .albumSelection: return "选择相册"
        case .barcodeScanning: return "条形码识别"
        case .manualInput: return "手工录入"
        }
    }
}

// MARK: - 运动记录
struct ExerciseRecord: Codable, Identifiable {
    let id: UUID
    let name: String           // 运动名称
    let type: ExerciseType     // 运动类型
    let duration: TimeInterval // 运动时长(秒)
    let caloriesBurned: Double // 消耗卡路里
    let timestamp: Date        // 记录时间
    let notes: String?         // 备注
    
    init(name: String, type: ExerciseType, duration: TimeInterval, caloriesBurned: Double, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.timestamp = Date()
        self.notes = notes
    }
}

// MARK: - 运动类型
enum ExerciseType: String, CaseIterable, Codable {
    case cardio = "cardio"           // 有氧运动
    case strength = "strength"       // 力量训练
    case flexibility = "flexibility" // 柔韧性训练
    case sports = "sports"          // 运动项目
    case daily = "daily"            // 日常活动
    
    var displayName: String {
        switch self {
        case .cardio: return "有氧运动"
        case .strength: return "力量训练"
        case .flexibility: return "柔韧性训练"
        case .sports: return "运动项目"
        case .daily: return "日常活动"
        }
    }
}

// MARK: - 情绪日记
struct MoodDiary: Codable, Identifiable {
    let id: UUID
    let mood: MoodType         // 心情类型
    let intensity: Int         // 强度(1-5)
    let content: String        // 日记内容
    let timestamp: Date        // 记录时间
    let triggers: [String]     // 触发因素
    
    init(mood: MoodType, intensity: Int, content: String, triggers: [String] = []) {
        self.id = UUID()
        self.mood = mood
        self.intensity = intensity
        self.content = content
        self.timestamp = Date()
        self.triggers = triggers
    }
}

// MARK: - 心情类型
enum MoodType: String, CaseIterable, Codable {
    case happy = "happy"
    case sad = "sad"
    case angry = "angry"
    case anxious = "anxious"
    case excited = "excited"
    case calm = "calm"
    case stressed = "stressed"
    
    var displayName: String {
        switch self {
        case .happy: return "开心"
        case .sad: return "难过"
        case .angry: return "愤怒"
        case .anxious: return "焦虑"
        case .excited: return "兴奋"
        case .calm: return "平静"
        case .stressed: return "压力"
        }
    }
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .angry: return "😠"
        case .anxious: return "😰"
        case .excited: return "🤩"
        case .calm: return "😌"
        case .stressed: return "😤"
        }
    }
}

// MARK: - 体重记录
struct WeightRecord: Codable, Identifiable {
    let id: UUID
    let weight: Double         // 体重(kg)
    let timestamp: Date        // 记录时间
    let notes: String?         // 备注
    
    init(weight: Double, notes: String? = nil) {
        self.id = UUID()
        self.weight = weight
        self.timestamp = Date()
        self.notes = notes
    }
}

// MARK: - 用户基本信息
struct UserProfile: Codable, Identifiable {
    let id: UUID               // 用户ID
    var avatar: String?        // 头像
    var nickname: String       // 昵称
    var gender: Gender         // 性别
    var birthday: Date         // 生日
    var height: Double         // 身高(cm)
    var weight: Double         // 体重(kg)
    var occupation: String     // 职业
    var dietaryPreferences: [String]  // 饮食偏好
    var exercisePreferences: [String] // 运动偏好
    var foodAllergies: [String]       // 食物过敏
    
    init(nickname: String, gender: Gender, birthday: Date, height: Double, weight: Double, occupation: String = "") {
        self.id = UUID()
        self.nickname = nickname
        self.gender = gender
        self.birthday = birthday
        self.height = height
        self.weight = weight
        self.occupation = occupation
        self.dietaryPreferences = []
        self.exercisePreferences = []
        self.foodAllergies = []
    }
}

// MARK: - 性别
enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .male: return "男"
        case .female: return "女"
        case .other: return "其他"
        }
    }
}

// MARK: - 健康目标
struct HealthGoal: Codable, Identifiable {
    let id: UUID
    let type: GoalType         // 目标类型
    let targetValue: Double    // 目标值
    let currentValue: Double   // 当前值
    let unit: String          // 单位
    let deadline: Date?       // 截止日期
    let isActive: Bool        // 是否激活
    
    init(type: GoalType, targetValue: Double, currentValue: Double = 0, unit: String, deadline: Date? = nil) {
        self.id = UUID()
        self.type = type
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.unit = unit
        self.deadline = deadline
        self.isActive = true
    }
}

// MARK: - 目标类型
enum GoalType: String, CaseIterable, Codable {
    case weightLoss = "weightLoss"       // 减重
    case weightGain = "weightGain"       // 增重
    case maintenance = "maintenance"     // 维持体重
    case muscleBuild = "muscleBuild"    // 增肌
    case fatLoss = "fatLoss"            // 减脂
    case fitness = "fitness"            // 体能提升
    
    var displayName: String {
        switch self {
        case .weightLoss: return "减重"
        case .weightGain: return "增重"
        case .maintenance: return "维持体重"
        case .muscleBuild: return "增肌"
        case .fatLoss: return "减脂"
        case .fitness: return "体能提升"
        }
    }
}

// MARK: - 饮食计划
struct DietPlan: Codable, Identifiable {
    let id: UUID
    let name: String           // 计划名称
    let description: String    // 计划描述
    let duration: Int          // 持续天数
    let dailyCalories: Double  // 每日卡路里目标
    let mealPlans: [MealPlan]  // 餐食计划
    let isActive: Bool         // 是否激活
    
    init(name: String, description: String, duration: Int, dailyCalories: Double, mealPlans: [MealPlan] = []) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.duration = duration
        self.dailyCalories = dailyCalories
        self.mealPlans = mealPlans
        self.isActive = false
    }
}

// MARK: - 餐食计划
struct MealPlan: Codable, Identifiable {
    let id: UUID
    let mealType: MealType     // 餐类型
    let foods: [String]        // 推荐食物
    let targetCalories: Double // 目标卡路里
    
    init(mealType: MealType, foods: [String], targetCalories: Double) {
        self.id = UUID()
        self.mealType = mealType
        self.foods = foods
        self.targetCalories = targetCalories
    }
}

// MARK: - 餐类型
enum MealType: String, CaseIterable, Codable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"
    
    var displayName: String {
        switch self {
        case .breakfast: return "早餐"
        case .lunch: return "午餐"
        case .dinner: return "晚餐"
        case .snack: return "零食"
        }
    }
    
    var emoji: String {
        switch self {
        case .breakfast: return "🌅"
        case .lunch: return "☀️"
        case .dinner: return "🌙"
        case .snack: return "🍿"
        }
    }
}

// MARK: - 会员订阅
struct Subscription: Codable, Identifiable {
    let id: UUID
    let type: SubscriptionType // 订阅类型
    let startDate: Date        // 开始日期
    let endDate: Date          // 结束日期
    let isActive: Bool         // 是否激活
    let price: Double          // 价格
    
    init(type: SubscriptionType, startDate: Date, price: Double) {
        self.id = UUID()
        self.type = type
        self.startDate = startDate
        self.price = price
        self.isActive = true
        
        // 计算结束日期
        let calendar = Calendar.current
        switch type {
        case .monthly:
            self.endDate = calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        case .halfYearly:
            self.endDate = calendar.date(byAdding: .month, value: 6, to: startDate) ?? startDate
        case .yearly:
            self.endDate = calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        }
    }
}

// MARK: - 订阅类型
enum SubscriptionType: String, CaseIterable, Codable {
    case monthly = "monthly"       // 月卡
    case halfYearly = "halfYearly" // 半年卡
    case yearly = "yearly"         // 年卡
    
    var displayName: String {
        switch self {
        case .monthly: return "月卡"
        case .halfYearly: return "半年卡"
        case .yearly: return "年卡"
        }
    }
    
    var duration: String {
        switch self {
        case .monthly: return "1个月"
        case .halfYearly: return "6个月"
        case .yearly: return "12个月"
        }
    }
}

// MARK: - 饭搭子相关
struct FoodBuddy: Codable, Identifiable {
    let id: UUID
    let nickname: String       // 昵称
    let avatar: String?        // 头像
    let bio: String           // 个人简介
    let followersCount: Int   // 粉丝数
    let followingCount: Int   // 关注数
    let postsCount: Int       // 动态数
    let isFollowing: Bool     // 是否已关注
    
    init(nickname: String, avatar: String? = nil, bio: String = "") {
        self.id = UUID()
        self.nickname = nickname
        self.avatar = avatar
        self.bio = bio
        self.followersCount = 0
        self.followingCount = 0
        self.postsCount = 0
        self.isFollowing = false
    }
}

// MARK: - 饭搭子动态
struct FoodPost: Codable, Identifiable {
    let id: UUID
    let authorId: UUID         // 作者ID
    let content: String        // 动态内容
    let images: [String]       // 图片
    let foodRecords: [FoodItem] // 关联的食物记录
    let timestamp: Date        // 发布时间
    let likesCount: Int        // 点赞数
    let commentsCount: Int     // 评论数
    let isLiked: Bool         // 是否已点赞
    
    init(authorId: UUID, content: String, images: [String] = [], foodRecords: [FoodItem] = []) {
        self.id = UUID()
        self.authorId = authorId
        self.content = content
        self.images = images
        self.foodRecords = foodRecords
        self.timestamp = Date()
        self.likesCount = 0
        self.commentsCount = 0
        self.isLiked = false
    }
}

// MARK: - 健康数据
struct HealthData: Codable {
    var bmi: Double {
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    let weight: Double         // 体重
    let height: Double         // 身高
    let steps: Int            // 步数(从苹果健康获取)
    let heartRate: Int?       // 心率
    let bloodPressure: String? // 血压
    let sleepHours: Double?   // 睡眠时长
    
    init(weight: Double, height: Double, steps: Int = 0) {
        self.weight = weight
        self.height = height
        self.steps = steps
        self.heartRate = nil
        self.bloodPressure = nil
        self.sleepHours = nil
    }
}

// MARK: - OKR进度
struct OKRProgress: Codable {
    let objective: String      // 目标
    let keyResults: [KeyResult] // 关键结果
    let progress: Double       // 整体进度(0-1)
    let quarter: String        // 季度
    
    init(objective: String, keyResults: [KeyResult], quarter: String) {
        self.objective = objective
        self.keyResults = keyResults
        self.quarter = quarter
        // 计算平均进度
        self.progress = keyResults.isEmpty ? 0 : keyResults.map { $0.progress }.reduce(0, +) / Double(keyResults.count)
    }
}

// MARK: - 关键结果
struct KeyResult: Codable, Identifiable {
    let id: UUID
    let description: String    // 描述
    let target: Double         // 目标值
    let current: Double        // 当前值
    let unit: String          // 单位
    let progress: Double       // 进度(0-1)
    
    init(description: String, target: Double, current: Double = 0, unit: String) {
        self.id = UUID()
        self.description = description
        self.target = target
        self.current = current
        self.unit = unit
        self.progress = target > 0 ? min(current / target, 1.0) : 0
    }
}

// MARK: - 统计数据
struct DayData: Codable, Identifiable {
    let id: UUID
    let date: Date
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let exerciseMinutes: Int
    let waterIntake: Double
    
    init(date: Date, calories: Double, protein: Double, carbs: Double, fat: Double, exerciseMinutes: Int = 0, waterIntake: Double = 0) {
        self.id = UUID()
        self.date = date
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.exerciseMinutes = exerciseMinutes
        self.waterIntake = waterIntake
    }
} 