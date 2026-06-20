//
//  ContentView.swift
//  iLaugh
//
//  Created by Asad Raza on 17/10/25.
//

import SwiftUI

let today = Date()
let weekdayIndex = Calendar.current.component(.weekday, from: today)


struct ContentView: View {
    @StateObject private var daysviewmodel = DaysViewModel() // Creating an instance of DaysViewModel
    @State private var selectedDay: Day = DaysViewModel().days[0]
    @State private var newTask = ""
    @State private var textFieldFocused: Bool = false
    @State private var deleteMode = false
    
    //Function to calculate the percentage of the tasks completed, and guards against dividing by 0
    private func completionPercentage() -> Double {
        let completedTasks = selectedDay.tasks.filter { $0.isCompleted }.count
        let totalTasks = selectedDay.tasks.count
        return totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0.0
    }
    
    //Function to add a new task, guards against the user adding an empty task
    private func addTask() {
        if (newTask != "") && (newTask != " "){
            selectedDay.tasks.append(Task(name: newTask))
            newTask = ""
        }
    }
    
    //Removes a task
    private func delete(_ task: Task) {
        if let i = selectedDay.tasks.firstIndex(where: { $0.id == task.id }) {
            selectedDay.tasks.remove(at: i)
        }
    }
    var body: some View {
        ZStack{
            Color.background.ignoresSafeArea()
            ScrollView{
                VStack{
                    
                    Text("Your Weekly Planner") //The Title of the page
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .cornerRadius(10)
                    
                    Text("Today's Date: \(formattedDate())") //Getting the Formatted Date from a helper swift file
                        .font(.title2)
                        .padding()
                    
                    // Progress Circle refelecting the number of tasks completed
                    ZStack{
                        Circle() // The background circle
                            .stroke(Color.secondaryAccent.opacity(0.3), lineWidth: 20)
                            .frame(width: 100, height: 100)
                        
                        Circle() //The foreground circle showing the percentage of tasks completed
                            .trim(from: 0, to: CGFloat(completionPercentage()))
                            .stroke(Color.accent, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 100, height: 100)
                            .animation(.easeInOut(duration: 0.5), value: completionPercentage())
                    }
                    
                    Text("\(selectedDay.tasks.filter { $0.isCompleted }.count) out of \(selectedDay.tasks.count) completed")
                        .font(.headline)
                        .padding()
                    
                    Spacer(minLength: 25)
                    
                    // Small circles with initials of each Day in the week
                    
                    HStack(spacing: 12) {
                        ForEach(daysviewmodel.days) {day in
                            Circle() // Selected day's color changes on tap
                                .fill(selectedDay.id == day.id ? Color.secondaryAccent : Color.secondaryAccent.opacity(0.3))
                                .frame(width: 45, height: 45)
                                .overlay(
                                    Text(day.name.prefix(1))
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(selectedDay.id == day.id ? .textDark : .textDark.opacity(0.3))
                                    
                                )
                                .onTapGesture {
                                    selectedDay = day
                                    textFieldFocused = false
                                    deleteMode = false
                                }
                        }
                    }
                    .onAppear {
                        selectedDay = daysviewmodel.selectToday()
                    }
                    
                    // Stack of all the tasks added for that day
                    VStack {
                        Text("Tasks for \(selectedDay.name)")
                            .font(.headline)
                            .padding()
                         
                        
                        ZStack(alignment: .bottomTrailing)
                        {
                            LazyVStack (alignment: .leading, spacing: 8){
                                ForEach($selectedDay.tasks, id: \.id) {$task in
                                    HStack{
                                        Button(action: {
                                            task.isCompleted.toggle()
                                        }) {
                                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(task.isCompleted ? .black : .textDark.opacity(0.5))
                                        }
                                        Text(task.name)
                                        
                                        if (deleteMode){
                                            Button {
                                                delete(task)
                                            } label: {
                                                Image(systemName: "trash.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.system(size: 26))
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                    }
                                    .padding(10)
                                }
                                .onDelete { indexSet in
                                    // Delete task from the selected day
                                    selectedDay.tasks.remove(atOffsets: indexSet)
                                }
                                
                                // Text Field appearing to add a new task if pressed on the + button
                                
                                if (textFieldFocused) {
                                    TextField("Add new task", text: $newTask)
                                        .onSubmit {
                                            addTask()
                                        }
                                        .textInputAutocapitalization(.never)
                                        .disableAutocorrection(true)
                                        .padding()
                                        .background(Color.secondaryAccent.opacity(0.2))
                                        .cornerRadius(8)
                                        .transition(.move(edge: .bottom))
                                    
                                    Button("Add") {
                                        addTask()
                                        textFieldFocused = false
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                            .listStyle(.plain)
                        }
                        
                        HStack{
                            Button("+")
                            {
                                textFieldFocused.toggle() // TextField appearing upon pressing the + button
                            }
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(.textDark)
                            .padding()
                            .background(Color.accent)
                            .clipShape(Circle())
                            .shadow(radius: 6, y: 3)
                            
                            Button("-")
                            {
                                deleteMode.toggle()
                            }
                            .font(.system(size: 55, weight: .bold))
                            .foregroundColor(.textDark)
                            .padding()
                            .background(Color.accent)
                            .clipShape(Circle())
                            .shadow(radius: 6, y: 3)
                            
                            
                        }
                    }
                }.padding()
            }
        }
    }
}
#Preview {
    ContentView()
}
