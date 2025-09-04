import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var lockVM: AppLockViewModel
    @EnvironmentObject private var userVM: UserProfileViewModel
    @State private var showingSetPin = false

    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                colors: [AppColors.seaMoss, AppColors.teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 24) {
                // Profile Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("NAME")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .tracking(1.2)
                    
                    VStack(spacing: 12) {
                        TextField("First name", text: Binding(
                            get: { userVM.firstName },
                            set: { userVM.firstName = $0 }
                        ))
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .padding(16)
                        .background(Color.white)
                        .foregroundColor(AppColors.ink)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppColors.ink.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // App Lock Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("APP LOCK")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .tracking(1.2)
                    
                    VStack(spacing: 0) {
                        // Biometrics Toggle
                        HStack {
                            Text("Require Face ID/Touch ID")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { lockVM.biometricsEnabled },
                                set: { lockVM.setBiometricsEnabled($0) }
                            ))
                            .toggleStyle(SwitchToggleStyle(tint: AppColors.seaMoss))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.1))
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Change Passcode Button
                        Button {
                            showingSetPin = true
                        } label: {
                            HStack {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                Text("Change App Passcode")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.1))
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Lock Now Button
                        Button {
                            lockVM.lock()
                        } label: {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                Text("Lock Now")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.1))
                        }
                    }
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                
                // Version Footer
                Text("Incubate v0.1")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
            }
            .padding(.top, 20)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSetPin) {
            SetPinView().environmentObject(lockVM)
        }
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


