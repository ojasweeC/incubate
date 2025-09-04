import SwiftUI

struct LockView: View {
    @EnvironmentObject private var lockVM: AppLockViewModel
    @State private var pin: String = ""
    @State private var showingSetPin = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Incubate Logo Section
            VStack(spacing: 8) {
                Text("incubate")
                    .font(.system(size: 42, weight: .thin, design: .default))
                    .foregroundColor(.white)
                    .textCase(.lowercase)
                
                Text("where your thoughts become your strengths")
                    .font(.system(size: 16, weight: .light, design: .default))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.bottom, 20)

            if lockVM.isLockedOut {
                Text("Try again in \(lockVM.lockoutRemainingSeconds)s")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            SecureField("Enter PIN", text: $pin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
                .font(.title3)
                .padding(14)
                .background(Color.white)
                .foregroundColor(AppColors.ink)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 60)

            HStack(spacing: 16) {
                Button(action: attemptUnlock) {
                    Label("FaceID", systemImage: "faceid")
                        .labelStyle(.titleAndIcon)
                        .foregroundColor(AppColors.ink)
                }
                .buttonStyle(BeigePillButtonStyle())
                .accessibilityLabel("Attempt biometric unlock")

                Button(action: verifyPin) {
                    Label("Login", systemImage: "number.circle")
                        .foregroundColor(AppColors.ink)
                }
                .buttonStyle(BeigePillButtonStyle())
                .accessibilityLabel("Verify PIN")
            }

            if !lockVM.pinSet {
                Button("First time incubating?") { showingSetPin = true }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(AppColors.seaMoss)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: AppColors.subtleShadow, radius: 8, x: 0, y: 4)
            }

            Spacer()
        }
        .padding()
        .onAppear { lockVM.attemptBiometricUnlock() }
        .sheet(isPresented: $showingSetPin) {
            SetPinView()
                .environmentObject(lockVM)
        }
        .background(
            LinearGradient(
                colors: [AppColors.seaMoss, AppColors.teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    private func attemptUnlock() {
        lockVM.attemptBiometricUnlock()
    }

    private func verifyPin() {
        _ = lockVM.verifyPIN(pin)
        pin = ""
    }
}

struct SetPinView: View {
    @EnvironmentObject private var lockVM: AppLockViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newPin: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Title
                Text("Change Passcode")
                    .font(.system(size: 28, weight: .medium, design: .default))
                    .foregroundColor(AppColors.ink)
                    .padding(.bottom, 32)

                // PIN Input with box
                SecureField("New PIN (4-6 digits)", text: $newPin)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .padding(16)
                    .background(Color.white)
                    .foregroundColor(AppColors.ink)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppColors.ink.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, 40)

                Button("Secure Growth Chamber") {
                    guard (4...6).contains(newPin.count) else { return }
                    lockVM.setPIN(newPin)
                    dismiss()
                }
                .buttonStyle(BeigePillButtonStyle())
                .foregroundColor(AppColors.ink)
                .padding(.top, 16)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.ink)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct LockView_Previews: PreviewProvider {
    static var previews: some View {
        LockView()
            .environmentObject(AppLockViewModel())
    }
}


