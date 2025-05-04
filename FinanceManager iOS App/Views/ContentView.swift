import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // Dashboard
                NavigationView {
                    DashboardView()
                }
                .tag(0)
                .tabItem {
                    EmptyView()
                }
                
                // Personal Finance
                NavigationView {
                    PersonalAccountDashboardView()
                }
                .tag(1)
                .tabItem {
                    EmptyView()
                }
                
                // Clients
                NavigationView {
                    ClientsView()
                }
                .tag(2)
                .tabItem {
                    EmptyView()
                }
                
                // Employee
                NavigationView {
                    EmployeeDetailView()
                }
                .tag(3)
                .tabItem {
                    EmptyView()
                }
                
                // Expenses
                NavigationView {
                    ExpenseManagementView()
                }
                .tag(4)
                .tabItem {
                    EmptyView()
                }
                
                // Settings
                NavigationView {
                    SettingsView()
                }
                .tag(5)
                .tabItem {
                    EmptyView()
                }
            }
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                CustomTabBarButton(
                    imageName: "chart.bar.xaxis",
                    title: "Dashboard",
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                CustomTabBarButton(
                    imageName: "person.text.rectangle.fill",
                    title: "Personal",
                    isSelected: selectedTab == 1
                ) {
                    selectedTab = 1
                }
                
                CustomTabBarButton(
                    imageName: "person.3",
                    title: "Clients",
                    isSelected: selectedTab == 2
                ) {
                    selectedTab = 2
                }
                
                CustomTabBarButton(
                    imageName: "person.badge.clock",
                    title: "Employee",
                    isSelected: selectedTab == 3
                ) {
                    selectedTab = 3
                }
                
                CustomTabBarButton(
                    imageName: "banknote",
                    title: "Expenses",
                    isSelected: selectedTab == 4
                ) {
                    selectedTab = 4
                }
                
                CustomTabBarButton(
                    imageName: "gearshape",
                    title: "Settings",
                    isSelected: selectedTab == 5
                ) {
                    selectedTab = 5
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -2)
            )
            .padding(.horizontal)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct CustomTabBarButton: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: imageName)
                    .font(.system(size: isSelected ? 22 : 18))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(title)
                    .font(.system(size: 10))
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataManager())
    }
} 