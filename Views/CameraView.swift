import SwiftUI
import AVFoundation
import UIKit

struct CameraView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @StateObject private var camera = CameraManager()
    @State private var showingImagePicker = false
    @State private var showingFoodDetail = false
    @State private var capturedImage: UIImage?
    @State private var recognizedFood: FoodItem?
    @State private var isAnalyzing = false
    @State private var showingCamera = false
    @State private var selectedDate = Date()
    
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
            ZStack {
            // 背景色
            Color(.systemGray6)
                    .ignoresSafeArea()
                
            if showingCamera {
                // 相机界面
                cameraInterface
            } else {
                // 主页界面
                VStack(spacing: 0) {
                    // 主内容
                    ScrollView {
                        VStack(spacing: 20) {
                            // 顶部标题区域
                            topHeaderSection
                            
                            // 日历导航
                            calendarNavigationSection
                            
                            // 主要卡路里卡片
                            mainCaloriesCard
                            
                            // 营养素卡片
                            nutritionCardsSection
                            
                            // 最近上传区域
                            recentlyUploadedSection
                            
                            Spacer(minLength: 100) // 为底部导航栏留空间
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                    
                    // 底部导航栏
                    bottomNavigationBar
                                }
                            }
            
            if showingCamera {
                // 相机界面已在上面定义
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $capturedImage, isPresented: $showingImagePicker)
        }
        .sheet(isPresented: $showingFoodDetail) {
            if let food = recognizedFood {
                FoodDetailView(foodItem: food)
            }
        }
        .onChange(of: capturedImage) { image in
            if let image = image {
                analyzeFood(from: image)
            }
        }
        .onAppear {
            camera.requestPermission()
        }
    }
    
    // MARK: - 界面组件
    
    private var topHeaderSection: some View {
        HStack {
            // Cal AI Logo
            HStack(spacing: 8) {
                Text("🍎")
                    .font(.title2)
                Text("Cal AI")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            // Streak counter
            HStack(spacing: 6) {
                Text("🔥")
                    .font(.title3)
                Text("0")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(20)
        }
        .padding(.top, 8)
    }
    
    private var calendarNavigationSection: some View {
        VStack(spacing: 16) {
            // 月份和年份显示
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 8)
            
            // 日历导航条
            HStack(spacing: 0) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedDate = day.2
                        }
                    }) {
                        VStack(spacing: 4) {
                            // 星期缩写
                            Text(day.0.uppercased())
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            // 日期数字
                            Text("\(day.1)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(day.4 ? .white : (day.3 ? .primary : .secondary))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if day.4 {
                                    // 选中状态：实心圆圈
                                    Circle()
                                        .fill(Color.black)
                                        .scaleEffect(1.2)
                                } else if day.3 {
                                    // 今天状态：空心圆圈
                                    Circle()
                                        .stroke(Color.primary, lineWidth: 1.5)
                                        .scaleEffect(1.2)
                                } else {
                                    // 普通状态：透明
                                    Circle()
                                        .fill(Color.clear)
                                        .scaleEffect(1.2)
                                }
                            }
                        )
                        .scaleEffect(day.4 ? 1.1 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    // 月份年份字符串
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedDate)
    }
    
    // MARK: - 选择日期的计算属性
    
    // 选择日期的食物项目
    private var selectedDayItems: [FoodItem] {
        let selectedDay = calendar.startOfDay(for: selectedDate)
        return foodTracker.foodRecords.filter { item in
            calendar.isDate(item.timestamp, inSameDayAs: selectedDay)
        }
    }
    
    // 选择日期的卡路里
    private var selectedDayCalories: Double {
        selectedDayItems.reduce(0) { $0 + $1.nutrition.calories }
    }
    
    // 选择日期的剩余卡路里
    private var selectedDayRemainingCalories: Double {
        max(foodTracker.dailyCalorieTarget - selectedDayCalories, 0)
    }
    
    // 选择日期的蛋白质
    private var selectedDayProtein: Double {
        selectedDayItems.reduce(0) { $0 + $1.nutrition.protein }
    }
    
    // 选择日期的碳水化合物
    private var selectedDayCarbs: Double {
        selectedDayItems.reduce(0) { $0 + $1.nutrition.carbs }
    }
    
    // 选择日期的脂肪
    private var selectedDayFat: Double {
        selectedDayItems.reduce(0) { $0 + $1.nutrition.fat }
    }
    
    private var mainCaloriesCard: some View {
        HStack {
            // 左侧卡路里信息
            VStack(alignment: .leading, spacing: 8) {
                Text("\(Int(selectedDayRemainingCalories))")
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                
                Text("Calories left")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 右侧圆形进度图
            ZStack {
                // 背景圆圈
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                // 进度圆圈
                Circle()
                    .trim(from: 0, to: min(selectedDayCalories / foodTracker.dailyCalorieTarget, 1.0))
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: selectedDayCalories)
                
                // 中间的火焰图标
                Text("🔥")
                    .font(.title2)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    private var nutritionCardsSection: some View {
        HStack(spacing: 12) {
            // 蛋白质卡片
            NutrientCard(
                amount: Int(max(120 - selectedDayProtein, 0)),
                unit: "g",
                name: "Protein left",
                icon: "🥩",
                color: .red,
                progress: selectedDayProtein / 120
            )
            
            // 碳水化合物卡片
            NutrientCard(
                amount: Int(max(250 - selectedDayCarbs, 0)),
                unit: "g", 
                name: "Carbs left",
                icon: "🌾",
                color: .orange,
                progress: selectedDayCarbs / 250
            )
            
            // 脂肪卡片
            NutrientCard(
                amount: Int(max(65 - selectedDayFat, 0)),
                unit: "g",
                name: "Fat left", 
                icon: "🫒",
                color: .blue,
                progress: selectedDayFat / 65
            )
        }
    }
    
    private var recentlyUploadedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recently uploaded")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !selectedDayItems.isEmpty {
                    Text(selectedDateString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if selectedDayItems.isEmpty {
                // 空状态
                VStack(spacing: 12) {
                    // 占位图片
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 40)
                    
                    Text(isSelectedDateToday ? "Tap + to add your first meal of the day" : "No meals recorded for this date")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.white)
                .cornerRadius(16)
            } else {
                // 显示选择日期的食物记录
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(selectedDayItems.prefix(4)) { item in
                        SelectedDateFoodCard(foodItem: item)
                    }
                }
                
                if selectedDayItems.count > 4 {
                    Button(action: {
                        // 查看更多功能
                    }) {
                        HStack {
                            Text("查看更多 (\(selectedDayItems.count - 4) 项)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    // 判断选择的日期是否是今天
    private var isSelectedDateToday: Bool {
        calendar.isDate(selectedDate, inSameDayAs: Date())
    }
    
    // 选择日期的字符串格式
    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedDate)
    }
    
    private var bottomNavigationBar: some View {
        HStack {
            // Home按钮
            VStack(spacing: 4) {
                Image(systemName: "house.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
                Text("Home")
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Progress按钮
            VStack(spacing: 4) {
                Image(systemName: "chart.bar")
                    .font(.title3)
                    .foregroundColor(.secondary)
                Text("Progress")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Settings按钮
            VStack(spacing: 4) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundColor(.secondary)
                Text("Settings")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 添加按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingCamera = true
                }
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.black)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 34) // 适配Home indicator
        .background(Color.white)
    }
    
    // MARK: - 相机界面
    private var cameraInterface: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // 相机预览
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            VStack {
                // 顶部控制栏
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingCamera = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("拍摄食物")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        camera.toggleFlash()
                    }) {
                        Image(systemName: camera.isFlashOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.title2)
                            .foregroundColor(camera.isFlashOn ? .yellow : .white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // AI识别提示
                if isAnalyzing {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text("AI正在识别食物...")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Text("请保持图像稳定")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.subheadline)
                    }
                    .padding(20)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // 底部控制按钮
                HStack(spacing: 40) {
                    // 相册按钮
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "photo.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    
                    // 拍照按钮
                    Button(action: takePhoto) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 6)
                                .frame(width: 100, height: 100)
                            
                            if isAnalyzing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            }
                        }
                    }
                    .disabled(isAnalyzing)
                    .scaleEffect(isAnalyzing ? 0.9 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isAnalyzing)
                    
                    // 切换相机按钮
                    Button(action: {
                        camera.switchCamera()
                    }) {
                        Image(systemName: "camera.rotate.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    // MARK: - 方法
    
    private func takePhoto() {
        camera.capturePhoto { image in
            if let image = image {
                self.capturedImage = image
                analyzeFood(from: image)
            }
        }
    }
    
    private func analyzeFood(from image: UIImage) {
        isAnalyzing = true
        
        // 模拟AI分析延迟
        Task {
            do {
                let aiService = AIFoodRecognitionService()
                let foodItems = try await aiService.recognizeFood(from: image)
                
                await MainActor.run {
                    isAnalyzing = false
                    if let firstFood = foodItems.first {
                        recognizedFood = firstFood
                        showingFoodDetail = true
                        // 分析完成后回到主页
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingCamera = false
                        }
                    } else {
                        print("未识别到食物")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingCamera = false
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    print("识别失败: \(error.localizedDescription)")
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingCamera = false
                    }
                }
            }
        }
    }
}

// MARK: - 支持视图组件

struct SelectedDateFoodCard: View {
    let foodItem: FoodItem
    
    var body: some View {
        HStack(spacing: 8) {
            // 食物emoji或图标
            Text(foodEmoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(foodItem.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("\(Int(foodItem.nutrition.calories))卡")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text(timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: foodItem.timestamp)
    }
    
    private var foodEmoji: String {
        let name = foodItem.name.lowercased()
        
        // 根据食物名称返回对应emoji
        if name.contains("苹果") { return "🍎" }
        else if name.contains("香蕉") { return "🍌" }
        else if name.contains("橙") || name.contains("橘") { return "🍊" }
        else if name.contains("草莓") { return "🍓" }
        else if name.contains("葡萄") { return "🍇" }
        else if name.contains("牛奶") || name.contains("奶") { return "🥛" }
        else if name.contains("米饭") || name.contains("大米") { return "🍚" }
        else if name.contains("面条") || name.contains("意面") { return "🍝" }
        else if name.contains("面包") { return "🍞" }
        else if name.contains("鸡蛋") || name.contains("蛋") { return "🥚" }
        else if name.contains("鸡肉") || name.contains("鸡") { return "🍗" }
        else if name.contains("牛肉") { return "🥩" }
        else if name.contains("鱼") || name.contains("三文鱼") { return "🐟" }
        else if name.contains("虾") { return "🦐" }
        else if name.contains("沙拉") { return "🥗" }
        else if name.contains("胡萝卜") { return "🥕" }
        else if name.contains("西兰花") { return "🥦" }
        else if name.contains("土豆") { return "🥔" }
        else if name.contains("番茄") || name.contains("西红柿") { return "🍅" }
        else if name.contains("汉堡") { return "🍔" }
        else if name.contains("披萨") { return "🍕" }
        else if name.contains("寿司") { return "🍣" }
        else if name.contains("咖啡") { return "☕" }
        else if name.contains("茶") { return "🍵" }
        else if name.contains("果汁") { return "🧃" }
        else if name.contains("蛋糕") { return "🍰" }
        else if name.contains("饼干") { return "🍪" }
        else if name.contains("巧克力") { return "🍫" }
        else { return "🍽️" }
    }
}

struct NutrientCard: View {
    let amount: Int
    let unit: String
    let name: String
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // 数量
            Text("\(amount)\(unit)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // 名称
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // 圆形进度指示器
            ZStack {
                // 背景圆圈
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                // 进度圆圈
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: progress)
                
                // 中间图标
                Text(icon)
                    .font(.title3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
    }
}

// 相机预览
struct CameraPreview: UIViewRepresentable {
    let camera: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

#Preview {
    CameraView()
        .environmentObject(FoodTracker())
} 