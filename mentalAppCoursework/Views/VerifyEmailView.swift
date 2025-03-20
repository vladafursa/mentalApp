import SwiftUI

struct VerifyEmailView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    var body: some View {
        ZStack {
            Color("backgroundColour")
                .edgesIgnoringSafeArea(.all)
            VStack {
                // title
                Text("Your mental health assistant")
                    .font(.system(size: 30))
                    .foregroundColor(.titleColour)
                // logo
                Image("appLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 300, alignment: .topLeading)

                ZStack {
                    // frame
                    VStack(spacing: 20) {
                        Text("Verify email").font(.title)
                            .foregroundColor(.textColour)
                            .fixedSize(horizontal: false, vertical: true)
                        // input fields
                        HStack {
                            Text("email")
                                .foregroundColor(.textColour)
                                .font(.system(size: 22))
                                .frame(maxWidth: 80, alignment: .leading)
                            Spacer()

                            TextField(
                                "example@gmail.com",
                                text: $loginViewModel.email
                            )
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .font(.system(size: 22))
                            .underline()
                            .frame(maxWidth: .infinity)
                        }

                        .padding(.bottom)

                        Button("Verify") {
                            loginViewModel.forgotPassword()
                        }
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .bold()
                        .padding(12)
                        .background(.buttonColour)
                        .cornerRadius(7)
                        .shadow(radius: 5)
                    }

                    .padding()
                    .frame(width: 340, height: 220)
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(radius: 5)
                }
                .offset(y: -80)
                Spacer()
            }
            .padding()
        }
        .alert(isPresented: $loginViewModel.showAlert) {
            Alert(
                title: Text(loginViewModel.alertTitle ?? "Unsuccessful login"),
                message: Text(loginViewModel.alertMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("try again"))
            )
        }
    }
}

#Preview {
    VerifyEmailView()
}
