import SwiftUI

struct ClientDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    var clientIndex: Int
    
    @State private var activeTab: Int = 0
    @State private var showingAddProjectSheet = false
    @State private var showingAddContactSheet = false
    @State private var showingAddPaymentSheet = false
    @State private var selectedProjectIndex: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Client Info Card
                ClientInfoCard(client: dataManager.filteredClients[clientIndex])
                
                // Tab Selection
                CustomSegmentedControl(
                    selection: $activeTab,
                    options: ["Projects", "Contacts", "Finances"]
                )
                .padding(.horizontal)
                
                // Content based on selected tab
                VStack {
                    switch activeTab {
                    case 0:
                        projectsSection
                    case 1:
                        contactsSection
                    case 2:
                        financesSection
                    default:
                        EmptyView()
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(dataManager.filteredClients[clientIndex].name)
        .navigationBarItems(trailing: EditButton())
        .sheet(isPresented: $showingAddProjectSheet) {
            AddProjectView(clientIndex: clientIndex)
        }
        .sheet(isPresented: $showingAddContactSheet) {
            AddContactPersonView(clientIndex: clientIndex)
        }
        .sheet(isPresented: $showingAddPaymentSheet) {
            if selectedProjectIndex < dataManager.filteredClients[clientIndex].projects.count {
                AddPaymentView(
                    clientIndex: clientIndex,
                    projectIndex: selectedProjectIndex
                )
            }
        }
    }
    
    // Projects tab content
    private var projectsSection: some View {
        VStack(spacing: 16) {
            // Header with add button
            HStack {
                Text("Client Projects")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showingAddProjectSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            
            if dataManager.filteredClients[clientIndex].projects.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    title: "No Projects",
                    message: "Add your first project for this client."
                )
            } else {
                ForEach(dataManager.filteredClients[clientIndex].projects.indices, id: \.self) { projectIndex in
                    ProjectCard(
                        project: dataManager.filteredClients[clientIndex].projects[projectIndex],
                        onAddPayment: {
                            selectedProjectIndex = projectIndex
                            showingAddPaymentSheet = true
                        }
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // Contacts tab content
    private var contactsSection: some View {
        VStack(spacing: 16) {
            // Header with add button
            HStack {
                Text("Contact Persons")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showingAddContactSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            
            if dataManager.filteredClients[clientIndex].contactPersons.isEmpty {
                EmptyStateView(
                    icon: "person",
                    title: "No Contacts",
                    message: "Add contact information for this client."
                )
            } else {
                ForEach(dataManager.filteredClients[clientIndex].contactPersons) { contact in
                    ContactCard(contact: contact)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    // Finances tab content
    private var financesSection: some View {
        VStack(spacing: 16) {
            // Financial summary card
            FinancialSummaryCard(client: dataManager.filteredClients[clientIndex])
                .padding(.horizontal)
            
            // Payment history
            VStack(alignment: .leading, spacing: 12) {
                Text("Payment History")
                    .font(.headline)
                    .padding(.horizontal)
                
                let allPayments = getAllPayments()
                if allPayments.isEmpty {
                    EmptyStateView(
                        icon: "dollarsign.circle",
                        title: "No Payments",
                        message: "Record payments made by this client."
                    )
                } else {
                    ForEach(allPayments) { payment in
                        PaymentHistoryRow(payment: payment)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // Helper to get all payments across projects
    private func getAllPayments() -> [PaymentWithProject] {
        var allPayments: [PaymentWithProject] = []
        let client = dataManager.filteredClients[clientIndex]
        
        for (index, project) in client.projects.enumerated() {
            for payment in project.payments {
                allPayments.append(
                    PaymentWithProject(
                        payment: payment,
                        projectName: project.name,
                        projectIndex: index
                    )
                )
            }
        }
        
        return allPayments.sorted(by: { $0.payment.date > $1.payment.date })
    }
}

// Client Info Card
struct ClientInfoCard: View {
    let client: Client
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with logo
            HStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(client.name.prefix(1).uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading) {
                    Text(client.name)
                        .font(.headline)
                    Text(client.company)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Contact info
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Label(client.email, systemImage: "envelope")
                        .font(.subheadline)
                    
                    Label(client.phone, systemImage: "phone")
                        .font(.subheadline)
                }
                
                Spacer()
                
                Button(action: {
                    if let url = URL(string: "tel:\(client.phone.replacingOccurrences(of: " ", with: ""))") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                }
                
                Button(action: {
                    if let url = URL(string: "mailto:\(client.email)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                }
            }
            
            if let address = client.companyAddress.formattedAddress, !address.isEmpty {
                Divider()
                
                Label {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

// Project Card
struct ProjectCard: View {
    let project: Project
    let onAddPayment: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                    
                    Text(project.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                StatusBadge(status: project.status)
            }
            
            Divider()
            
            // Project details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Contract Amount:")
                        .font(.subheadline)
                    Spacer()
                    Text(Formatters.formatCurrency(project.contractAmount))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Paid Amount:")
                        .font(.subheadline)
                    Spacer()
                    Text(Formatters.formatCurrency(project.totalPaid))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Remaining:")
                        .font(.subheadline)
                    Spacer()
                    Text(Formatters.formatCurrency(project.remaining))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(project.remaining > 0 ? .red : .primary)
                }
                
                // Timeline
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Started:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(Formatters.formatDate(project.startDate))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    if let endDate = project.endDate {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Ends:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(Formatters.formatDate(endDate))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            
            Divider()
            
            // Actions
            HStack {
                NavigationLink(destination: ProjectDetailView(project: project)) {
                    Text("Details")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Button(action: onAddPayment) {
                    Label("Record Payment", systemImage: "plus")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// Contact Card
struct ContactCard: View {
    let contact: ContactPerson
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.headline)
                    
                    Text(contact.position)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    if let url = URL(string: "tel:\(contact.phone.replacingOccurrences(of: " ", with: ""))") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    if !contact.email.isEmpty {
                        Label {
                            Text(contact.email)
                                .font(.subheadline)
                        } icon: {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Label {
                        Text(contact.phone)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "phone")
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// Financial Summary Card
struct FinancialSummaryCard: View {
    let client: Client
    
    var totalContractValue: Double {
        client.projects.reduce(0) { $0 + $1.contractAmount }
    }
    
    var totalPaid: Double {
        client.projects.reduce(0) { $0 + $1.totalPaid }
    }
    
    var totalOutstanding: Double {
        totalContractValue - totalPaid
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Financial Summary")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .top, spacing: 16) {
                FinancialSummaryItem(
                    title: "Total Value",
                    value: Formatters.formatCurrency(totalContractValue),
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )
                
                FinancialSummaryItem(
                    title: "Paid",
                    value: Formatters.formatCurrency(totalPaid),
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                FinancialSummaryItem(
                    title: "Outstanding",
                    value: Formatters.formatCurrency(totalOutstanding),
                    icon: "exclamationmark.circle.fill",
                    color: .red
                )
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                Text("Payment Progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 10)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .green],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: totalContractValue > 0 ? CGFloat(totalPaid / totalContractValue) * geometry.size.width : 0, height: 10)
                    }
                }
                .frame(height: 10)
                
                HStack {
                    Text("\(Int(totalContractValue > 0 ? (totalPaid / totalContractValue) * 100 : 0))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(Formatters.formatCurrency(totalPaid) + " / " + Formatters.formatCurrency(totalContractValue))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// Financial Summary Item
struct FinancialSummaryItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Payment History Row
struct PaymentHistoryRow: View {
    let payment: PaymentWithProject
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(payment.projectName) - \(payment.payment.paymentType.rawValue)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(Formatters.formatDate(payment.payment.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(Formatters.formatCurrency(payment.payment.amount))
                .font(.headline)
                .foregroundColor(.green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// Payment record with project info
struct PaymentWithProject: Identifiable {
    var id: UUID { payment.id }
    let payment: ProjectPayment
    let projectName: String
    let projectIndex: Int
}

// Status Badge
struct StatusBadge: View {
    let status: ProjectStatus
    
    var statusColor: Color {
        switch status {
        case .active:
            return .green
        case .completed:
            return .blue
        case .onHold:
            return .orange
        case .cancelled:
            return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.15))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
}

// Custom Segmented Control
struct CustomSegmentedControl: View {
    @Binding var selection: Int
    let options: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring()) {
                        selection = index
                    }
                }) {
                    Text(options[index])
                        .fontWeight(selection == index ? .semibold : .regular)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(selection == index ? .white : .primary)
                        .background(selection == index ? Color.blue : Color.clear)
                }
            }
        }
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

// Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.7))
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ClientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClientDetailView(clientIndex: 0)
                .environmentObject(DataManager())
        }
    }
} 