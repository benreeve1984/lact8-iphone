import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    private let totalPages = 4

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                WelcomePage()
                    .tag(0)

                WhatIsLactateTestingPage()
                    .tag(1)

                HowToTestPage()
                    .tag(2)

                UnderstandingResultsPage()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Bottom controls
            VStack(spacing: 16) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }

                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.secondary)
                    }

                    Spacer()

                    if currentPage < totalPages - 1 {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Get Started") {
                            hasSeenOnboarding = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Page 1: Welcome

private struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("Welcome to Lact8")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your personal lactate threshold analyzer for optimized training zones")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Lactate Tests",
                    description: "Record and analyze your step test results"
                )

                FeatureRow(
                    icon: "target",
                    title: "Find Your Thresholds",
                    description: "Automatically calculate LT1 and LT2"
                )

                FeatureRow(
                    icon: "heart.text.square",
                    title: "Personalized Zones",
                    description: "Get training zones based on YOUR physiology"
                )
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Page 2: What is Lactate Testing

private struct WhatIsLactateTestingPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Why Test Lactate?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)

                InfoCard(
                    title: "Beyond Arbitrary Percentages",
                    content: "Training zones based on percentages of max heart rate don't account for individual differences. Two athletes with the same max HR can have vastly different thresholds.",
                    icon: "percent",
                    color: .orange
                )

                InfoCard(
                    title: "Your Personal Benchmarks",
                    content: "Lactate testing identifies YOUR aerobic (LT1) and anaerobic (LT2) thresholds - the intensities where your metabolism shifts between energy systems.",
                    icon: "person.fill.checkmark",
                    color: .green
                )

                InfoCard(
                    title: "Train Smarter",
                    content: "Knowing your thresholds lets you train at precisely the right intensity - easy enough on recovery days, hard enough on threshold days.",
                    icon: "brain.head.profile",
                    color: .blue
                )

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Page 3: How to Test

private struct HowToTestPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("How to Test")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)

                Text("The Step Test Protocol")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 16) {
                    StepItem(
                        number: 1,
                        title: "Start Easy",
                        description: "Begin at a comfortable warm-up intensity"
                    )

                    StepItem(
                        number: 2,
                        title: "5-Minute Stages",
                        description: "Each step should last 5 minutes to reach steady state"
                    )

                    StepItem(
                        number: 3,
                        title: "Progressive Increase",
                        description: "Increase intensity by 20-30W (cycling) or 1 km/h (running) per step"
                    )

                    StepItem(
                        number: 4,
                        title: "Measure at End",
                        description: "Record lactate, heart rate, and intensity at the end of each step"
                    )

                    StepItem(
                        number: 5,
                        title: "Continue to Exhaustion",
                        description: "Or until lactate rises sharply (>4-6 mmol/L)"
                    )
                }

                Text("Equipment Needed")
                    .font(.headline)
                    .padding(.top)

                HStack(spacing: 16) {
                    EquipmentItem(icon: "drop.fill", name: "Lactate Meter")
                    EquipmentItem(icon: "heart.fill", name: "HR Monitor")
                    EquipmentItem(icon: "speedometer", name: "Power/Pace")
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Page 4: Understanding Results

private struct UnderstandingResultsPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Understanding Results")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)

                ThresholdExplanation(
                    title: "LT1 - Aerobic Threshold",
                    description: "The point where lactate first begins to rise above baseline. Below this, you can exercise for hours. This marks the top of your easy/recovery zone.",
                    color: .green,
                    typical: "~2.0 mmol/L"
                )

                ThresholdExplanation(
                    title: "LT2 - Anaerobic Threshold",
                    description: "The maximum sustainable intensity. Above this, lactate accumulates rapidly and fatigue sets in quickly. Often called 'threshold pace'.",
                    color: .orange,
                    typical: "~4.0 mmol/L"
                )

                // Disclaimer
                VStack(alignment: .leading, spacing: 8) {
                    Label("Important Disclaimer", systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundColor(.red)

                    Text("This app is for informational purposes only and does not constitute medical advice. Lactate testing should ideally be performed under professional supervision. Consult a qualified sports scientist or physician before making training decisions based on these results.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Helper Views

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct InfoCard: View {
    let title: String
    let content: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }

            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

private struct StepItem: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.accentColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct EquipmentItem: View {
    let icon: String
    let name: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

private struct ThresholdExplanation: View {
    let title: String
    let description: String
    let color: Color
    let typical: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                Text(title)
                    .font(.headline)
                Spacer()
                Text(typical)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
