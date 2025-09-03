import SwiftUI

struct LockView: View {
    @EnvironmentObject private var lockVM: AppLockViewModel
    @State private var pin: String = ""
    @State private var showingSetPin = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.seaMoss)

            Text("Welcome to Incubate")
                .font(.title)
                .foregroundColor(AppColors.ink)

            if lockVM.isLockedOut {
                Text("Try again in \(lockVM.lockoutRemainingSeconds)s")
                    .foregroundColor(.red)
            }

            SecureField("Enter PIN", text: $pin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
                .font(.title3)
                .padding(14)
                .background(AppColors.beige)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 24)

            HStack(spacing: 16) {
                Button(action: attemptUnlock) {
                    Label("Unlock", systemImage: "faceid")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(FilledPillButtonStyle())
                .accessibilityLabel("Attempt biometric unlock")

                Button(action: verifyPin) {
                    Label("Use PIN", systemImage: "number.circle")
                }
                .buttonStyle(OutlinePillButtonStyle())
                .accessibilityLabel("Verify PIN")
            }

            if !lockVM.pinSet {
                Button("Set PIN") { showingSetPin = true }
                    .buttonStyle(OutlinePillButtonStyle())
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
            ZStack {
                AppColors.backgroundGradient
                Color.white.opacity(0.9)
            }.ignoresSafeArea()
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
            VStack(spacing: 16) {
                SecureField("New PIN (4-6 digits)", text: $newPin)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .padding(14)
                    .background(AppColors.beige)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 24)

                Button("Save PIN") {
                    guard (4...6).contains(newPin.count) else { return }
                    lockVM.setPIN(newPin)
                    dismiss()
                }
                .buttonStyle(FilledPillButtonStyle())
                .padding(.top, 8)
            }
            .navigationTitle("Change Passcode")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct LockView_Previews: PreviewProvider {
    static var previews: some View {
        LockView()
            .environmentObject(AppLockViewModel())
    }
}


