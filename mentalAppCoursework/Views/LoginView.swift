import Firebase
import FirebaseAuth
import Foundation
import SwiftUI

struct LoginView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    var body: some View {
        NavigationStack {
            ZStack {
                Color("authBackgroundColour")
                    .edgesIgnoringSafeArea(.all)
                // show loading screen before proceeding to the next view for firebase to be able to load data
                if loginViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(3)
                        .padding()
                } else {
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
                                Text("Login").font(.title)
                                    .foregroundColor(.textColour)
                                // input fields
                                HStack {
                                    Text("email")
                                        .foregroundColor(.textColour)
                                        .font(.system(size: 22))
                                        .frame(maxWidth: 100, alignment: .leading)
                                    Spacer()

                                    TextField(
                                        "email@gmail.com",
                                        text: $loginViewModel.email
                                    )
                                    .disableAutocorrection(true)
                                    .autocapitalization(.none)
                                    .font(.system(size: 22))
                                    .underline()
                                    .frame(maxWidth: .infinity)
                                }

                                HStack {
                                    Text("password")
                                        .font(.system(size: 22))
                                        .foregroundColor(.textColour)
                                        .frame(maxWidth: 100, alignment: .leading)
                                    SecureField(
                                        "Password1@",
                                        text: $loginViewModel.password
                                    )
                                    .disableAutocorrection(true)
                                    .font(.system(size: 22))
                                    .underline()
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.bottom)

                                Button("Submit") {
                                    loginViewModel.login()
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
                            .frame(width: 340, height: 250)
                            .background(Color.white)
                            .cornerRadius(30)
                            .shadow(radius: 5)
                        }
                        .offset(y: -120)
                        // navigation
                        VStack(spacing: 20) {
                            NavigationLink(destination: RegisterView()) {
                                Text("Not registered yet?")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(.buttonColour)
                                    .cornerRadius(7)
                                    .shadow(radius: 5)
                            }

                            NavigationLink(destination: VerifyEmailView()) {
                                Text("Forgot password?")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(.buttonColour)
                                    .cornerRadius(7)
                                    .shadow(radius: 5)
                            }
                        }
                        .frame(maxWidth: 190)
                        .offset(y: -95)
                        Spacer()
                        Button(action: {
                            loginViewModel.openEmergencyCall()
                        }) {
                            Text("Emergency line")
                        }
                        .foregroundColor(.red)
                        .bold()
                        .font(.system(size: 18))
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $loginViewModel.isLoggedIn) { ContentView() }
        }
        .onAppear {
            loginViewModel.logout()
        }
        // presenting alert
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
    LoginView()
}
