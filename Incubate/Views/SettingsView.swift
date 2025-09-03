import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var lockVM: AppLockViewModel
    @EnvironmentObject private var userVM: UserProfileViewModel
    @State private var showingSetPin = false

    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                TextField("First name", text: Binding(
                    get: { userVM.firstName },
                    set: { userVM.firstName = $0 }
                ))
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
            }

            Section(header: Text("App Lock")) {
                Toggle("Require Face ID/Touch ID", isOn: Binding(
                    get: { lockVM.biometricsEnabled },
                    set: { lockVM.setBiometricsEnabled($0) }
                ))

                Button {
                    showingSetPin = true
                } label: {
                    Label("Change App Passcode", systemImage: "gearshape")
                }

                Button(role: .destructive) {
                    lockVM.lock()
                } label: {
                    Label("Lock Now", systemImage: "lock.fill")
                }
            }

            Section(footer: Text("Incubate v0.1")) {
                EmptyView()
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingSetPin) {
            NavigationStack { SetPinView().environmentObject(lockVM) }
        }
        .background(
            ZStack {
                AppColors.backgroundGradient
                Color.white.opacity(0.9)
            }.ignoresSafeArea()
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(AppLockViewModel())
                .environmentObject(UserProfileViewModel())
        }
    }
}


