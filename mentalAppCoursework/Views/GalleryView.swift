//
//  GalleryView.swift
//  mobile_implementation_coursework
//
//  Created by Влада Фурса on 30.01.25.
//

import SwiftUI

struct GalleryView: View {
    @State private var imageURLs: [URL] = []
    @State private var selectedImage: UIImage? = nil
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColour")
                    .edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack {
                        VStack {
                            Image("appLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 300, alignment: .topLeading)
                                .padding(.bottom, 40)
                            VStack {
                                ZStack {
                                    Text("Your emotion galery")
                                        .font(.system(size: 22))
                                        .foregroundColor(.textColour)
                                }.offset(y: -20)
                                ZStack {
                                    LazyVGrid(columns: [.init(.adaptive(minimum: 100, maximum: .infinity), spacing: 3)]) {
                                        ForEach(imageURLs, id: \.self) { url in
                                            if let image = UIImage(contentsOfFile: url.path) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                                    .clipped()
                                                    .aspectRatio(1, contentMode: .fit)
                                                    .onTapGesture {
                                                        selectedImage = image
                                                    }
                                            }
                                        }
                                    }
                                    .padding()
                                }
                            }
                            .offset(y: -200)
                        }
                    }
                }
                if let image = selectedImage {
                    ZStack {
                        Color.black.opacity(0.8) // Dark background
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture { selectedImage = nil } // Close on tap

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()

                        VStack {
                            HStack {
                                Spacer()
                                Button(action: { selectedImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                        .padding()
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear {
            imageURLs = FileManagementService.shared.getAllSavedImages()
        }
    }
}

#Preview {
    GalleryView()
}
