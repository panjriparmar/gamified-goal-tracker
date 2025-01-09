//
//  ContentView.swift
//  Gamified Goal Tracker
//
//  Created by Panjri on 2025-01-05.
//

// SwiftUI Prototype Design for Gamified Self-Help App

import SwiftUI

struct ContentView: View {
    // Tracks the user's accumulated points
    @State private var points: Int = 0
    // Holds the list of user-defined goals
    @State private var goals: [Goal] = []
    @State private var showAddGoal = false
    // Keeps track of unlocked badges
    @State private var unlockedBadges: [Badge] = []
    @State private var showBadgeUnlocked: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Character and Points Display
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .padding()
                        .scaleEffect(points > 50 ? 1.3 : 1)
                        .foregroundColor(points > 50 ? .yellow : .blue)
                        .animation(.spring(), value: points)
                    Text("Points: \(points)")
                        .font(.title)
                        .padding()
                    if points > 50 {
                        Text("Super Achiever")
                            .font(.caption)
                    } else {
                        Text("Beginner")
                            .font(.caption)
                    }
                }
                
                // Display Unlocked Badges
                if !unlockedBadges.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Unlocked Badges")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(unlockedBadges) { badge in
                                    VStack {
                                        Image(systemName: badge.imageName)
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .padding()
                                        Text(badge.title)
                                            .font(.caption)
                                    }
                                    .background(Color.yellow.opacity(0.3))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // View Goals Button
                NavigationLink(destination: GoalListView(goals: $goals, points: $points, unlockedBadges: $unlockedBadges, showBadgeUnlocked: $showBadgeUnlocked, onPointsUpdated: checkForMilestones)) {
                    Text("View Goals")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
                ProgressView(value: Double(points), total: 100)
                    .progressViewStyle(LinearProgressViewStyle())
                    .animation(.easeOut(duration: 1), value: points)
            }
            .navigationTitle("Your Character")
            .toolbar {
                Button(action: {
                    showAddGoal = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .alert("Badge Unlocked!", isPresented: $showBadgeUnlocked) {
                Button("Awesome!") { }
            } message: {
                if let latestBadge = unlockedBadges.last {
                    Text("You unlocked: \(latestBadge.title)")
                }
            }
            .sheet(isPresented: $showAddGoal) {
                AddGoalView(goals: $goals)
            }
        }
    }
    
    // Function to check and unlock badges based on points milestones
    func checkForMilestones() {
        if points >= 100 && !unlockedBadges.contains(where: { $0.title == "First 100 Points" }) {
            let newBadge = Badge(title: "First 100 Points", description: "You've earned 100 points!", imageName: "star.fill")
            unlockedBadges.append(newBadge)
            showBadgeUnlocked = true
        }
    }
}

struct GoalListView: View {
    // Binding allows `GoalListView` to modify the list of goals managed by `ContentView`
    @Binding var goals: [Goal]
    // Binding to modify the user's points in `ContentView`
    @Binding var points: Int
    // Binding to manage unlocked badges
    @Binding var unlockedBadges: [Badge]
    // Binding to control the badge unlocked alert
    @Binding var showBadgeUnlocked: Bool
    var onPointsUpdated: () -> Void
    
    var body: some View {
        List {
            ForEach(goals.indices, id: \..self) { index in
                HStack {
                    Text(goals[index].title)
                    Spacer()
                    if !goals[index].isCompleted {
                        Button("Complete") {
                            goals[index].isCompleted = true
                            points += goals[index].points
                            onPointsUpdated()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    } else {
                        Text("Completed")
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .navigationTitle("Your Goals")
    }
}

struct AddGoalView: View {
    // Binding allows `AddGoalView` to modify the list of goals in `ContentView`
    @Binding var goals: [Goal]
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var category: String = ""
    @State private var points: Int = 10
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Title", text: $title)
                    TextField("Category", text: $category)
                    Stepper("Points: \(points)", value: $points, in: 1...100)
                }
            }
            .navigationTitle("Add New Goal")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newGoal = Goal(title: title, category: category, isCompleted: false, points: points)
                        goals.append(newGoal)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Model representing a goal
struct Goal: Identifiable {
    let id = UUID()
    var title: String
    var category: String
    var isCompleted: Bool
    var points: Int
}

// Model representing a badge
struct Badge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

