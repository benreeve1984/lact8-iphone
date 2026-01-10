import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultSportType") private var defaultSportType = "cycling"
    @AppStorage("preferredZoneSystem") private var preferredZoneSystem = "threeZone"
    @AppStorage("intensityUnit") private var intensityUnit = "watts"
    @AppStorage("decimalSeparator") private var decimalSeparator = "."
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = true

    @State private var showClearDataAlert = false
    @State private var showOnboarding = false

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationStack {
            Form {
                Section("Defaults") {
                    Picker("Sport Type", selection: $defaultSportType) {
                        Text("Cycling").tag("cycling")
                        Text("Running").tag("running")
                        Text("Swimming").tag("swimming")
                        Text("Other").tag("other")
                    }

                    Picker("Zone System", selection: $preferredZoneSystem) {
                        Text("3-Zone (Simple)").tag("threeZone")
                        Text("7-Zone (Touretski)").tag("touretski")
                        Text("8-Zone (Couzens)").tag("couzens")
                    }

                    Picker("Intensity Unit", selection: $intensityUnit) {
                        Text("Watts").tag("watts")
                        Text("km/h").tag("kmh")
                        Text("min/km").tag("pace")
                    }

                    Picker("Decimal Separator", selection: $decimalSeparator) {
                        Text("Period (1.5)").tag(".")
                        Text("Comma (1,5)").tag(",")
                    }
                }

                Section("Help") {
                    Button {
                        showOnboarding = true
                    } label: {
                        Label("Replay Introduction", systemImage: "play.circle")
                    }
                }

                Section("Data") {
                    Button(role: .destructive) {
                        showClearDataAlert = true
                    } label: {
                        Label("Clear All Test Data", systemImage: "trash")
                    }
                }

                Section("Acknowledgements") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("The lactate testing methodology in this app is based on what I learned from Alan Couzens via the MadCrew Forum and his excellent Substack book.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Link(destination: URL(string: "https://alancouzens.substack.com/")!) {
                            Label("Alan Couzens on Substack", systemImage: "book.fill")
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text(buildNumber)
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: "https://github.com/benreeve1984/lact8-iphone")!) {
                        Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Disclaimer")
                            .font(.headline)
                        Text("This app is for informational purposes only and does not constitute medical advice. Consult a qualified professional before making training decisions.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .alert("Clear All Data?", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all your lactate tests. This action cannot be undone.")
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(hasSeenOnboarding: .constant(true))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            showOnboarding = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    private func clearAllData() {
        let fetchRequest = TestEntity.fetchRequest()
        do {
            let tests = try viewContext.fetch(fetchRequest)
            for test in tests {
                viewContext.delete(test)
            }
            try viewContext.save()
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
}

#Preview {
    SettingsView()
}
