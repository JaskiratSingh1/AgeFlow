import SwiftUI
import WidgetKit

struct SettingsView: View {
    @Binding var isPresented: Bool
    @Binding var birthDate: Date?
    
    // Track Dark/Light Mode in UserDefaults
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Birth Date")) {
                    DatePicker("Select Birth Date",
                               selection: Binding(
                                   get: { birthDate ?? Date() },   // Use the current date as fallback
                                   set: { birthDate = $0 }         // Save the selected date
                               ),
                               in: ...Date(),                     // Allow any date up to today
                               displayedComponents: [.date]       // Show day, month, year
                    )
                    .datePickerStyle(.wheel)                      // Use the wheel style for better precision
                    .labelsHidden()                               // Hide the label for a cleaner UI
                    .padding()
                }
                
                Section(header: Text("Theme")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) { newValue, oldValue in
                            // Update the color scheme dynamically when toggled
                            print("Theme changed from \(oldValue) to \(newValue)")
                            updateColorScheme()
                        }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if let actualBirthDate = birthDate {
                            let defaults = UserDefaults(suiteName: "group.com.jaskirat.singh.ageflow.AgeFlow")
                            defaults?.set(actualBirthDate, forKey: "userBirthDate")
                        } else {
                            // If no date was set, default to the current date
                            let defaultDate = Date()
                            let defaults = UserDefaults(suiteName: "group.com.jaskirat.singh.ageflow.AgeFlow")
                            defaults?.set(defaultDate, forKey: "userBirthDate")
                            birthDate = defaultDate
                        }

                        // Reload widget
                        WidgetCenter.shared.reloadAllTimelines()
                        
                        // Dismiss the settings sheet
                        isPresented = false
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light) // Dynamically apply the theme
        }
    }
    
    /// Dynamically update the app's color scheme
    private func updateColorScheme() {
        // SwiftUI automatically updates the app's color scheme with @AppStorage.
        // This function ensures that the view is refreshed immediately.
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
}
