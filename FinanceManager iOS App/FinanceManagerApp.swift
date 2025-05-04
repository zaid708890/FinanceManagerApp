import SwiftUI

@main
struct FinanceManagerApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .onAppear {
                    // Load data when app starts
                    dataManager.loadCompanies()
                    dataManager.loadEmployees()
                    dataManager.loadClients()
                    dataManager.loadProjects()
                    dataManager.loadExpenses()
                    dataManager.loadPayments()
                    dataManager.loadPersonalAccount()
                }
        }
    }
} 