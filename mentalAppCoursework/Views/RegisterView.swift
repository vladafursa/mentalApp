

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct RegisterView: View {
    @StateObject private var registerViewModel = RegisterViewModel()
    var body: some View {
        ZStack {
            Color("authBackgroundColour")
                .edgesIgnoringSafeArea(.all)
            if registerViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(3)
                    .padding()
            } else {
                VStack {
                    ZStack {
                        // title
                        Text("Mental health assistant is your tool to manage mental well-being")
                            .font(.system(size: 30))
                            .foregroundColor(.titleColour)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .offset(y: 60)
                    // logo
                    ZStack {
                        Image("appLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 300, alignment: .topLeading)
                    }
                    .offset(y: 40)
                    // frame
                    ZStack {
                        VStack(spacing: 20) {
                            Text("Register yourself").font(.title)
                                .foregroundColor(.textColour)
                            // input fields
                            HStack {
                                Text("name")
                                    .foregroundColor(.textColour)
                                    .font(.system(size: 22))
                                    .frame(maxWidth: 100, alignment: .leading)
                                Spacer()

                                TextField(
                                    "John Doe",
                                    text: $registerViewModel.username
                                )
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .font(.system(size: 22))
                                .underline()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                            }
                            HStack {
                                Text("email")
                                    .foregroundColor(.textColour)
                                    .font(.system(size: 22))
                                    .frame(maxWidth: 100, alignment: .leading)
                                Spacer()

                                TextField(
                                    "email@gmail.com",
                                    text: $registerViewModel.email
                                )
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .font(.system(size: 22))
                                .underline()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                            }
                            HStack {
                                Text("age")
                                    .font(.system(size: 22))
                                    .foregroundColor(.textColour)
                                    .frame(maxWidth: 100, alignment: .leading)

                                TextField("Type age", value: $registerViewModel.age, format: .number)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .foregroundColor(registerViewModel.age > 0 ? .black : .gray)
                            }

                            HStack {
                                Text("password")
                                    .font(.system(size: 22))
                                    .foregroundColor(.textColour)
                                    .frame(maxWidth: 100, alignment: .leading)

                                SecureField(
                                    "pasSword2#",
                                    text: $registerViewModel.password
                                )
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .font(.system(size: 22))
                                .underline()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                            }
                            HStack {
                                Text("repeat password")
                                    .font(.system(size: 22))
                                    .foregroundColor(.textColour)
                                    .frame(maxWidth: 100, alignment: .leading)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                SecureField(
                                    "pasSword2#",
                                    text: $registerViewModel.repeatedPassword
                                )
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .font(.system(size: 22))
                                .underline()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                                .fixedSize(horizontal: false, vertical: true)
                            }

                            Button("Join now!") {
                                registerViewModel.register()
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
                        .frame(width: 340, height: 430)
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(radius: 5)
                    }
                    .offset(y: -100)
                }
                .padding()
            }
        }
        // showing alerts
        .alert(isPresented: $registerViewModel.showAlert) {
            Alert(
                title: Text(registerViewModel.alertTitle ?? "Unsuccessful registration"),
                message: Text(registerViewModel.alertMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text(registerViewModel.dismissMessage ?? "Ok"))
            )
        }
    }
}

#Preview {
    RegisterView()
}
