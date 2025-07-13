import Foundation
import Vision
import CoreML
import UIKit
import AVFoundation

class AIFoodRecognitionService: ObservableObject {
    @Published var isProcessing = false
    @Published var recognizedFoodItems: [FoodItem] = []
    @Published var error: RecognitionError?
    
    // 模拟食物数据库
    private let foodDatabase: [String: Nutrition] = [
        "apple": Nutrition(calories: 52, protein: 0.3, carbs: 14, fat: 0.2),
        "banana": Nutrition(calories: 89, protein: 1.1, carbs: 23, fat: 0.3),
        "orange": Nutrition(calories: 43, protein: 0.9, carbs: 11, fat: 0.1),
        "rice": Nutrition(calories: 130, protein: 2.7, carbs: 28, fat: 0.3),
        "chicken": Nutrition(calories: 239, protein: 27, carbs: 0, fat: 14),
        "beef": Nutrition(calories: 250, protein: 26, carbs: 0, fat: 15),
        "fish": Nutrition(calories: 206, protein: 22, carbs: 0, fat: 12),
        "egg": Nutrition(calories: 155, protein: 13, carbs: 1.1, fat: 11),
        "milk": Nutrition(calories: 42, protein: 3.4, carbs: 5, fat: 1),
        "bread": Nutrition(calories: 265, protein: 9, carbs: 49, fat: 3.2),
        "pasta": Nutrition(calories: 220, protein: 8, carbs: 44, fat: 1.1),
        "tomato": Nutrition(calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2),
        "lettuce": Nutrition(calories: 15, protein: 1.4, carbs: 2.9, fat: 0.2),
        "carrot": Nutrition(calories: 41, protein: 0.9, carbs: 10, fat: 0.2),
        "potato": Nutrition(calories: 77, protein: 2, carbs: 17, fat: 0.1),
        "cheese": Nutrition(calories: 402, protein: 25, carbs: 1.3, fat: 33),
        "yogurt": Nutrition(calories: 59, protein: 10, carbs: 3.6, fat: 0.4),
        "salmon": Nutrition(calories: 208, protein: 22, carbs: 0, fat: 12),
        "broccoli": Nutrition(calories: 34, protein: 2.8, carbs: 7, fat: 0.4),
        "spinach": Nutrition(calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4)
    ]
    
    // 食物识别
    func recognizeFood(from image: UIImage) async throws -> [FoodItem] {
        await MainActor.run {
            isProcessing = true
            error = nil
        }
        
        defer {
            Task { @MainActor in
                isProcessing = false
            }
        }
        
        // 模拟AI识别延迟
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // 模拟识别结果
        let recognizedItems = generateMockRecognition()
        
        await MainActor.run {
            recognizedFoodItems = recognizedItems
        }
        
        return recognizedItems
    }
    
    // 生成模拟识别结果
    private func generateMockRecognition() -> [FoodItem] {
        let itemCount = Int.random(in: 1...3)
        
        var results: [FoodItem] = []
        
        for _ in 0..<itemCount {
            let food = getRandomFood()
            let confidence = Double.random(in: 0.7...0.95)
            
            let foodItem = FoodItem(
                name: food.name,
                weight: Double.random(in: 50...200),
                portion: "1份",
                nutrition: food.nutrition,
                recordType: .photoRecognition,
                confidence: confidence
            )
            
            results.append(foodItem)
        }
        
        return results
    }
    
    // 获取随机食物
    private func getRandomFood() -> (name: String, nutrition: Nutrition) {
        let foods = Array(foodDatabase.keys).shuffled()
        let foodName = foods.first ?? "apple"
        let nutrition = foodDatabase[foodName] ?? Nutrition(calories: 0, protein: 0, carbs: 0, fat: 0)
        
        return (name: foodName, nutrition: nutrition)
    }
    
    // 获取食物表情符号
    private func getFoodEmoji(_ foodName: String) -> String {
        let emojiMap: [String: String] = [
            "apple": "🍎",
            "banana": "🍌",
            "orange": "🍊",
            "rice": "🍚",
            "chicken": "🍗",
            "beef": "🥩",
            "fish": "🐟",
            "egg": "🥚",
            "milk": "🥛",
            "bread": "🍞",
            "pasta": "🍝",
            "tomato": "🍅",
            "lettuce": "🥬",
            "carrot": "🥕",
            "potato": "🥔",
            "cheese": "🧀",
            "yogurt": "🥛",
            "salmon": "🐟",
            "broccoli": "🥦",
            "spinach": "🥬"
        ]
        
        return emojiMap[foodName] ?? "🍽️"
    }
    
    // 获取食物营养信息
    func getFoodNutrition(for foodName: String) -> Nutrition? {
        return foodDatabase[foodName.lowercased()]
    }
    
    // 推荐食物
    func getRecommendedFoods(for goal: GoalType) -> [String] {
        switch goal {
        case .weightLoss:
            return ["apple", "lettuce", "tomato", "broccoli", "spinach"]
        case .weightGain:
            return ["banana", "rice", "chicken", "beef", "cheese"]
        case .maintenance:
            return ["fish", "egg", "milk", "yogurt", "carrot"]
        case .muscleBuild:
            return ["chicken", "beef", "salmon", "egg", "milk"]
        case .fatLoss:
            return ["apple", "lettuce", "tomato", "broccoli", "spinach"]
        case .fitness:
            return ["fish", "egg", "milk", "yogurt", "carrot"]
        }
    }
    
    // 批量识别多个食物
    func recognizeMultipleFoods(from images: [UIImage]) async throws -> [FoodItem] {
        var allItems: [FoodItem] = []
        
        for image in images {
            let items = try await recognizeFood(from: image)
            allItems.append(contentsOf: items)
        }
        
        return allItems
    }
}

enum RecognitionError: Error, LocalizedError {
    case imageProcessingFailed
    case modelLoadingFailed
    case recognitionFailed
    case noFoodDetected
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "图像处理失败"
        case .modelLoadingFailed:
            return "模型加载失败"
        case .recognitionFailed:
            return "识别失败"
        case .noFoodDetected:
            return "未检测到食物"
        }
    }
}

// 识别结果
struct RecognitionResult {
    let foodName: String
    let confidence: Double
    let boundingBox: CGRect
    let nutrition: Nutrition
}

// 扩展：相机权限检查
extension AIFoodRecognitionService {
    func checkCameraPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
}

// 扩展：图像预处理
extension AIFoodRecognitionService {
    private func preprocessImage(_ image: UIImage) -> UIImage? {
        // 调整图像大小
        let targetSize = CGSize(width: 224, height: 224)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func normalizeImage(_ image: UIImage) -> UIImage? {
        // 图像归一化处理
        // 这里可以添加更多的图像处理逻辑
        return image
    }
}

// 扩展：营养分析
extension AIFoodRecognitionService {
    func analyzeNutrition(for items: [FoodItem]) -> NutritionSummary {
        let totalCalories = items.reduce(0) { $0 + $1.totalNutrition.calories }
        let totalProtein = items.reduce(0) { $0 + $1.totalNutrition.protein }
        let totalCarbs = items.reduce(0) { $0 + $1.totalNutrition.carbs }
        let totalFat = items.reduce(0) { $0 + $1.totalNutrition.fat }
        
        return NutritionSummary(
            calories: totalCalories,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat
        )
    }
}

struct NutritionSummary {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
}

// 扩展：食物建议
extension AIFoodRecognitionService {
    func generateFoodSuggestions(based items: [FoodItem], for goal: GoalType) -> [String] {
        let currentCalories = items.reduce(0) { $0 + $1.totalNutrition.calories }
        let currentProtein = items.reduce(0) { $0 + $1.totalNutrition.protein }
        
        var suggestions: [String] = []
        
        switch goal {
        case .weightLoss:
            if currentCalories > 500 {
                suggestions.append("今日热量较高，建议选择低热量食物")
            }
            suggestions.append("推荐：蔬菜沙拉、水果")
            
        case .weightGain:
            if currentCalories < 800 {
                suggestions.append("今日热量偏低，建议增加高热量食物")
            }
            suggestions.append("推荐：坚果、牛奶、肉类")
            
        case .maintenance:
            suggestions.append("保持均衡饮食，适量摄入各类营养")
            
        case .muscleBuild:
            if currentProtein < 50 {
                suggestions.append("今日蛋白质不足，建议增加蛋白质摄入")
            }
            suggestions.append("推荐：鸡胸肉、鱼类、鸡蛋")
            
        case .fatLoss:
            suggestions.append("推荐：低脂高蛋白食物")
            
        case .fitness:
            suggestions.append("推荐：均衡营养，适量运动")
        }
        
        return suggestions
    }
} 