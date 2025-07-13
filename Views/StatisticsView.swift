import SwiftUI
import Foundation

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let dayName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
}

struct StatisticsView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "本周"
        case month = "本月"
        case year = "本年"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 时间范围选择器
                    TimeRangePicker(selectedRange: $selectedTimeRange)
                    
                    // 每日卡路里趋势图
                    CalorieChartCard()
                    
                    // 营养素分布饼图
                    NutritionPieChart()
                    
                    // 每周总结
                    WeeklySummaryCard()
                    
                    // 目标达成情况
                    GoalAchievementCard()
                }
                .padding()
            }
            .navigationTitle("数据统计")
        }
    }
}

// 时间范围选择器
struct TimeRangePicker: View {
    @Binding var selectedRange: StatisticsView.TimeRange
    
    var body: some View {
        Picker("时间范围", selection: $selectedRange) {
            ForEach(StatisticsView.TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// 卡路里趋势图卡片
struct CalorieChartCard: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    var weeklyData: [DayData] {
        foodTracker.getWeeklyData()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("每日卡路里摄入")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // 简化的图表视图（不使用Charts库）
                            CalorieBarChart(data: weeklyData, goal: foodTracker.dailyCalorieTarget)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// 简化的柱状图
struct CalorieBarChart: View {
    let data: [DayData]
    let goal: Double
    
    var maxCalories: Double {
        max(data.map { $0.calories }.max() ?? 0, goal)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { dayData in
                    let barHeight = dayData.calories / maxCalories * 120
                    let barColor = dayData.calories > goal ? Color.red : Color.green
                    let dayName = DateFormatter.dayName.string(from: dayData.date)
                    
                    VStack(spacing: 4) {
                        // 柱状图
                        Rectangle()
                            .fill(barColor)
                            .frame(width: 30, height: CGFloat(barHeight))
                            .cornerRadius(4)
                        
                        // 日期标签
                        Text(dayName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // 目标线说明
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 20, height: 2)
                Text("目标: \(Int(goal)) 卡路里")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
    }
}

// 营养素分布饼图
struct NutritionPieChart: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    var totalCalories: Double {
        foodTracker.todayCalories
    }
    
    var proteinPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (foodTracker.todayProtein * 4) / totalCalories
    }
    
    var carbsPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (foodTracker.todayCarbs * 4) / totalCalories
    }
    
    var fatPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (foodTracker.todayFat * 9) / totalCalories
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.purple)
                Text("今日营养素分布")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            if totalCalories > 0 {
                HStack(spacing: 30) {
                    // 简化的饼图
                    SimplePieChart(
                        proteinPercentage: proteinPercentage,
                        carbsPercentage: carbsPercentage,
                        fatPercentage: fatPercentage
                    )
                    
                    // 图例
                    VStack(alignment: .leading, spacing: 8) {
                        PieChartLegend(color: .blue, title: "蛋白质", percentage: proteinPercentage * 100)
                        PieChartLegend(color: .orange, title: "碳水化合物", percentage: carbsPercentage * 100)
                        PieChartLegend(color: .yellow, title: "脂肪", percentage: fatPercentage * 100)
                    }
                }
            } else {
                Text("暂无数据")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct SimplePieChart: View {
    let proteinPercentage: Double
    let carbsPercentage: Double
    let fatPercentage: Double
    
    var body: some View {
        ZStack {
            // 蛋白质
            Circle()
                .trim(from: 0, to: CGFloat(proteinPercentage))
                .stroke(Color.blue, lineWidth: 20)
                .rotationEffect(.degrees(-90))
            
            // 碳水化合物
            Circle()
                .trim(from: CGFloat(proteinPercentage), to: CGFloat(proteinPercentage + carbsPercentage))
                .stroke(Color.orange, lineWidth: 20)
                .rotationEffect(.degrees(-90))
            
            // 脂肪
            Circle()
                .trim(from: CGFloat(proteinPercentage + carbsPercentage), to: CGFloat(proteinPercentage + carbsPercentage + fatPercentage))
                .stroke(Color.yellow, lineWidth: 20)
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 100, height: 100)
    }
}

struct PieChartLegend: View {
    let color: Color
    let title: String
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.caption)
            
            Spacer()
            
            Text("\(Int(percentage))%")
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// 每周总结卡片
struct WeeklySummaryCard: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    var averageCalories: Double {
        let weekData = foodTracker.getWeeklyData()
        let totalCalories = weekData.reduce(0) { $0 + $1.calories }
        return totalCalories / Double(weekData.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.green)
                Text("本周总结")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                SummaryItem(
                    title: "平均卡路里",
                    value: "\(Int(averageCalories))",
                    unit: "kcal/天",
                    color: .blue
                )
                
                SummaryItem(
                    title: "记录天数",
                    value: "\(foodTracker.getWeeklyData().filter { $0.calories > 0 }.count)",
                    unit: "天",
                    color: .green
                )
                
                SummaryItem(
                    title: "总蛋白质",
                    value: "\(Int(foodTracker.getWeeklyData().reduce(0) { $0 + $1.protein }))",
                    unit: "g",
                    color: .purple
                )
                
                SummaryItem(
                    title: "达标天数",
                    value: "\(foodTracker.getWeeklyData().filter { abs($0.calories - foodTracker.dailyCalorieTarget) <= 200 }.count)",
                    unit: "天",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct SummaryItem: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// 目标达成情况卡片
struct GoalAchievementCard: View {
    @EnvironmentObject var foodTracker: FoodTracker
    
    var achievementRate: Double {
        let weekData = foodTracker.getWeeklyData()
        let achievedDays = weekData.filter { abs($0.calories - foodTracker.dailyCalorieTarget) <= 200 }.count
        return Double(achievedDays) / Double(weekData.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.red)
                Text("目标达成情况")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("本周达成率")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(Int(achievementRate * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                // 进度条
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: geometry.size.width * CGFloat(achievementRate), height: 8)
                            .cornerRadius(4)
                            .animation(.easeInOut, value: achievementRate)
                    }
                }
                .frame(height: 8)
                
                Text(achievementMotivation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    private var achievementMotivation: String {
        switch achievementRate {
        case 0.8...1.0:
            return "太棒了！坚持得很好，继续保持！💪"
        case 0.6..<0.8:
            return "做得不错，再加把劲就能达到更好的效果！🔥"
        case 0.4..<0.6:
            return "有进步空间，试着更规律地记录饮食吧！📈"
        default:
            return "别灰心，每天进步一点点就是成功！🌟"
        }
    }
}

#Preview {
    StatisticsView()
        .environmentObject(FoodTracker())
} 