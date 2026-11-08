import SwiftUI

struct SettingsView: View {
    @Environment(AppearanceSettings.self) private var settings
    @State private var showResetConfirmation = false

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section {
                HStack(spacing: 14) {
                    Image(systemName: "sunset.fill")
                        .font(.title)
                        .foregroundStyle(.orange.opacity(0.9))
                        .frame(width: 56, height: 56)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 17))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("أفق").font(AfaqFont.title3.weight(.semibold))
                        Text("مساحة هادئة ليومك").font(AfaqFont.subheadline).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 7)
            }

            Section("المظهر") {
                NavigationLink {
                    ScenePickerView()
                } label: {
                    LabeledContent("أجواء الخلفية", value: settings.mood.title)
                }
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("تعتيم الخلفية")
                        Spacer()
                        Text(settings.digits(String(Int(settings.backgroundDimming / 0.65 * 100))) + "٪")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $settings.backgroundDimming, in: 0...0.65, step: 0.01)
                        .accessibilityLabel("تعتيم الخلفية")
                }
                .padding(.vertical, 5)
            }

            Section("عرض المواقيت") {
                Picker("زجاج صفوف الصلاة", selection: $settings.prayerGlassStyle) {
                    ForEach(PrayerGlassStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                Toggle("الأرقام العربية", isOn: $settings.arabicDigits)
                Toggle("نظام 24 ساعة", isOn: $settings.use24HourClock)
                Toggle("إظهار ثواني العد التنازلي", isOn: $settings.showSeconds)
                Toggle("إظهار الشروق", isOn: $settings.showSunrise)
            }

            Section {
                LabeledContent("المرحلة الحالية", value: "الواجهة والإعدادات")
                LabeledContent("الإصدار", value: "0.1")
                NavigationLink("عن أفق") {
                    AboutView()
                }
            } header: {
                Text("عن التطبيق")
            } footer: {
                Text("المواقيت والعد التنازلي بيانات عرض ثابتة. خياراتك تُحفظ على هذا الجهاز.")
            }

            Section {
                Button("استعادة إعدادات المظهر", role: .destructive) {
                    showResetConfirmation = true
                }
            }
        }
        .navigationTitle("الإعدادات")
        .tint(.orange.opacity(0.9))
        .confirmationDialog("استعادة إعدادات المظهر؟", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("استعادة", role: .destructive) { settings.reset() }
            Button("إلغاء", role: .cancel) { }
        }
    }
}

private struct ScenePickerView: View {
    @Environment(AppearanceSettings.self) private var settings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                ZStack(alignment: .bottomTrailing) {
                    AtmosphereView()
                    VStack(alignment: .leading, spacing: 5) {
                        Text("المغرب").font(AfaqFont.title.weight(.medium))
                        Text(settings.digits("00:24:18"))
                            .font(AfaqFont.title2.monospacedDigit())
                    }
                    .foregroundStyle(.white)
                    .padding(24)
                }
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .accessibilityLabel("معاينة أجواء " + settings.mood.title)

                VStack(spacing: 8) {
                    ForEach(SceneMood.allCases) { mood in
                        Button {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                                settings.mood = mood
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: mood.symbol).frame(width: 24)
                                Text(mood.title)
                                Spacer()
                                if settings.mood == mood {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.orange)
                                }
                            }
                            .padding(17)
                            .background(.white.opacity(settings.mood == mood ? 0.11 : 0.04), in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(settings.mood == mood ? .isSelected : [])
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("أجواء الخلفية")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AboutView: View {
    var body: some View {
        Form {
            Section {
                Text("أفق").font(AfaqFont.largeTitle.weight(.medium))
                Text("واجهة عربية لمواقيت الصلاة، مستوحاة من هدوء الأفق وتغيّر الضوء.")
            }
            Section("نسخة التصميم") {
                Text("هذه النسخة لتجربة الواجهة والإعدادات. المواقيت توضيحية والعد التنازلي ثابت.")
                Text("حساب الصلاة، الموقع، الأذان، والقبلة تُضاف في مراحل لاحقة.")
            }
        }
        .navigationTitle("عن أفق")
        .navigationBarTitleDisplayMode(.inline)
    }
}
