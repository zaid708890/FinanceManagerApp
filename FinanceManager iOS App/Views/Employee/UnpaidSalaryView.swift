import SwiftUI

struct UnpaidSalaryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingPaymentSheet = false
    @State private var selectedEmployee: Employee?
    @State private var paymentAmount = ""
    @State private var paymentDate = Date()
    @State private var paymentNotes = ""
    @State private var paymentMethod = PaymentMethod.bankTransfer
    @State private var paidFromPersonalFunds = false
    @State private var referenceNumber = ""
    @State private var showingAddPeriodSheet = false
    @State private var newPeriodDate = Date().startOfMonth
    @State private var newPeriodAmount = ""
    @State private var newPeriodNotes = ""
    
    var body: some View {
        List {
            if dataManager.filteredEmployees.isEmpty {
                Text("No employees found")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(dataManager.filteredEmployees) { employee in
                    Section(header: 
                        HStack {
                            Text(employee.name)
                            Spacer()
                            Button(action: {
                                newPeriodDate = Date().startOfMonth
                                newPeriodAmount = "\(employee.monthlySalary)"
                                newPeriodNotes = ""
                                showingAddPeriodSheet = true
                                selectedEmployee = employee
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Monthly Salary:")
                                    .font(.subheadline)
                                Spacer()
                                Text(Formatters.formatCurrency(employee.monthlySalary))
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Total Unpaid:")
                                    .font(.subheadline)
                                Spacer()
                                Text(Formatters.formatCurrency(employee.totalUnpaidSalary))
                                    .fontWeight(.bold)
                                    .foregroundColor(employee.totalUnpaidSalary > 0 ? .red : .primary)
                            }
                            
                            if employee.totalUnpaidSalary > 0 {
                                Button(action: {
                                    selectedEmployee = employee
                                    paymentAmount = "\(employee.totalUnpaidSalary)"
                                    paymentDate = Date()
                                    paymentNotes = ""
                                    paymentMethod = .bankTransfer
                                    paidFromPersonalFunds = false
                                    referenceNumber = ""
                                    showingPaymentSheet = true
                                }) {
                                    Text("Make Payment")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(8)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Display unpaid periods
                        let unpaidSalary = dataManager.getUnpaidSalaryByMonth(for: employee.id)
                        
                        if unpaidSalary.isEmpty {
                            Text("No unpaid salary periods")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(unpaidSalary, id: \.month) { period in
                                HStack {
                                    VStack(alignment: .leading) {
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "MMMM yyyy"
                                        
                                        Text(formatter.string(from: period.month))
                                            .font(.headline)
                                        
                                        Text("Unpaid Balance")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(Formatters.formatCurrency(period.amount))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            
            // Generate Periods Section
            Section {
                Button(action: {
                    dataManager.createMonthlySalaryPeriods(for: Date())
                }) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.blue)
                        Text("Create Salary Periods for Current Month")
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Unpaid Salary")
        .sheet(isPresented: $showingPaymentSheet) {
            if let employee = selectedEmployee {
                NavigationView {
                    Form {
                        Section(header: Text("Payment Details")) {
                            TextField("Amount", text: $paymentAmount)
                                .keyboardType(.decimalPad)
                            
                            DatePicker("Payment Date", selection: $paymentDate, displayedComponents: .date)
                            
                            Picker("Payment Method", selection: $paymentMethod) {
                                ForEach(PaymentMethod.allCases, id: \.self) { method in
                                    Text(method.rawValue).tag(method)
                                }
                            }
                            
                            TextField("Reference Number", text: $referenceNumber)
                            
                            TextField("Notes", text: $paymentNotes)
                        }
                        
                        Section {
                            Toggle("Paid from Personal Funds", isOn: $paidFromPersonalFunds)
                                .tint(.blue)
                        }
                        
                        Section {
                            Button(action: {
                                makePayment(for: employee)
                                showingPaymentSheet = false
                            }) {
                                Text("Submit Payment")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .disabled(paymentAmount.isEmpty)
                        }
                        .listRowInsets(EdgeInsets())
                        .padding()
                    }
                    .navigationTitle("Salary Payment")
                    .navigationBarItems(
                        trailing: Button("Cancel") {
                            showingPaymentSheet = false
                        }
                    )
                }
            }
        }
        .sheet(isPresented: $showingAddPeriodSheet) {
            if let employee = selectedEmployee {
                NavigationView {
                    Form {
                        Section(header: Text("Add Salary Period")) {
                            DatePicker("Month", selection: $newPeriodDate, displayedComponents: [.date])
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .onChange(of: newPeriodDate) { _ in
                                    // Ensure we're using the first day of the month
                                    newPeriodDate = newPeriodDate.startOfMonth
                                }
                            
                            TextField("Salary Amount", text: $newPeriodAmount)
                                .keyboardType(.decimalPad)
                            
                            TextField("Notes", text: $newPeriodNotes)
                        }
                        
                        Section {
                            Button(action: {
                                addSalaryPeriod(for: employee)
                                showingAddPeriodSheet = false
                            }) {
                                Text("Add Period")
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .disabled(newPeriodAmount.isEmpty)
                        }
                        .listRowInsets(EdgeInsets())
                        .padding()
                    }
                    .navigationTitle("Add Salary Period")
                    .navigationBarItems(
                        trailing: Button("Cancel") {
                            showingAddPeriodSheet = false
                        }
                    )
                }
            }
        }
    }
    
    private func makePayment(for employee: Employee) {
        guard let amount = Double(paymentAmount), amount > 0 else { return }
        
        dataManager.salaryPaymentWithCarryForward(
            amount: amount,
            date: paymentDate,
            employeeID: employee.id,
            paymentMethod: paymentMethod,
            processedBy: "",
            paidFromPersonalFunds: paidFromPersonalFunds,
            referenceNumber: referenceNumber.isEmpty ? nil : referenceNumber,
            notes: paymentNotes.isEmpty ? nil : paymentNotes
        )
    }
    
    private func addSalaryPeriod(for employee: Employee) {
        guard let amount = Double(newPeriodAmount), amount > 0 else { return }
        
        dataManager.addSalaryPeriod(
            for: employee.id,
            month: newPeriodDate,
            totalSalaryDue: amount,
            notes: newPeriodNotes.isEmpty ? nil : newPeriodNotes
        )
    }
}

// Date extension for startOfMonth
extension Date {
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var endOfMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return calendar.date(byAdding: components, to: self.startOfMonth) ?? self
    }
}

struct UnpaidSalaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UnpaidSalaryView()
                .environmentObject(DataManager())
        }
    }
} 