

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct RegisterView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var age: Int = 0
    @State private var password: String = ""
    @State private var repeatedPassword: String = ""
    // @StateObject private var firestoreService = FirestoreService.shared
    // @StateObject private var authService = AuthenticationService.shared
    @StateObject private var loginViewModel = LoginViewModel()
    var body: some View {
        ZStack {
            Color("backgroundColour")
                .edgesIgnoringSafeArea(.all)
            if loginViewModel.isLoading {
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
                                    text: $username
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
                                    text: $email
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

                                TextField("Type age", value: $age, format: .number)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .foregroundColor(.gray)
                            }

                            HStack {
                                Text("password")
                                    .font(.system(size: 22))
                                    .foregroundColor(.textColour)
                                    .frame(maxWidth: 100, alignment: .leading)

                                TextField(
                                    "pasSword2#",
                                    text: $password
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
                                TextField(
                                    "pasSword2#",
                                    text: $repeatedPassword
                                )
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .font(.system(size: 22))
                                .underline()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                                .fixedSize(horizontal: false, vertical: true)
                            }

                            Button("Join now!") {}

                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .bold()
                                .padding(12)
                                .background(.buttonColour)
                                .cornerRadius(7)
                                .shadow(radius: 5)
                        }
                        .padding()
                        .frame(width: 340, height: 440)
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(radius: 5)
                    }
                    .offset(y: -80)
                }
                .padding()
            }
        }
    }
}

#Preview {
    RegisterView()
}
